---
layout: post
title:  "Image Classification with RandomForests in R (and QGIS)"
date:   2015-11-28 11:02:52
categories: blog en
tags: R RemoteSensing landsat QGIS GIS
image: 2015-11-28-classification-r-mini.jpg
published: true
---

The goal of this post is to demonstrate the ability of R to classify multispectral imagery using [RandomForests algorithms]. RandomForests are currently one of the top performing algorithms for data classification and regression. Although their interpretability may be difficult, RandomForests are widely popular because of their ability to classify large amounts of data with high accuracy.

In the sections below I show how to import into R a Landsat image and how to extract pixel data to train and fit a RandomForests model. I also explain how to speed up image classification through parallel processing. Finally I demonstrate how to implement this R-based RandomForests algorithms for image classification in [QGIS].

<!--more-->

<img src="/images/2015-11-28-classification-r-fig-0.png" alt="" title="" style="width:750px">

<br>

### **Loading the data in R**

For the purpose of this post, I'm going to conduct a land-cover classification of a 6-band Landsat 7 image (path 7 row 57) taken in 2000 that has been processed to surface reflectance, as shown [in a previous post in my blog]. Several R packages are needed, including: [rgdal], [raster], [caret], [randomForest] and [e1071]. After installation, let's load the packages:

```
library(rgdal)
 library(raster)
 library(caret)
```
<br>

Now let's import the Landsat image into R as a `RasterBrick` object using the `brick` function from the ['raster' package]. Also let's replace the original band names (e.g., 'X485.0.Nanometers') with shorter ones ('B1' to 'B5', and 'B7'): 

```
img <- brick("C:/data/landsat/images/2000/LE70070572000076EDC00/L7007057_20000316_refl")
 names(img) <- paste0("B", c(1:5, 7))  
```
<br>

We can make a RGB visualization of the Landsat image in R using the `plotRGB` command, for example, a false color composite RGB 4:5:3 (Near infrared - Shortwave infrarred - Red). I'm using the expression `img * (img >= 0)` to convert the negative values to zero:

```
plotRGB(img * (img >= 0), r = 4, g = 5, b = 3, scale = 10000)
```

<a href="/images/2015-11-28-classification-r-fig-1.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-1.JPG" alt="" title="Plotting a Landsat scene in RStudio"></a>

I created a set of training areas in a polygon shapefile ('training_15.shp') which stores the id for each land cover type in a column in the attribute table called 'class' as shown below:

<a href="/images/2015-11-28-classification-r-fig-2.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-2.JPG" alt="" title="Training areas for classification"></a>

Let's use the `shapefile` function from the 'raster' package to import this file into R as an object of class `SpatialPolygonsDataFrame` and let's create a variable to store the name of the 'class' column:

```
trainData <- shapefile("C:/data/landsat/shps/UTM18N_32618/training_15.shp")
 responseCol <- "class"
```
<br>

### **Extracting training pixels values**

Now let's extract the pixel values in the training areas for every band in the Landsat image and store them in a data frame (called here `dfAll`) along with the corresponding land cover class id:

```
dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  if(is(trainData, "SpatialPointsDataFrame")){
    dataSet <- cbind(dataSet, class = as.numeric(rep(category, nrow(dataSet))))
    dfAll <- rbind(dfAll, dataSet[complete.cases(dataSet),])
  }
  if(is(trainData, "SpatialPolygonsDataFrame")){
    dataSet <- dataSet[!unlist(lapply(dataSet, is.null))]
    dataSet <- lapply(dataSet, function(x){cbind(x, class = as.numeric(rep(category, nrow(x))))})
    df <- do.call("rbind", dataSet)
    dfAll <- rbind(dfAll, df)
  }
}
```
<br>

The data frame resulting from working with my data has about 80K rows. It is necessary to work with a smaller dataset as it may take a long time to train and fit a RandomForests model with a dataset this size. For a start, let's subset the data generating 1000 random samples: 

```
nsamples <- 1000
 sdfAll <- dfAll[sample(1:nrow(dfAll), nsamples), ]
```
<br>

### **Model fitting and image classification**

Next we must define and fit the RandomForests model using the `train` function from the 'caret' package. First, let's specify the model as a formula with the dependent variable (i.e., the land cover types ids) encoded as factors. For this exercise I'll only use three bands as explanatory variables (Red, Near infrared and Short wave infrared bands). We then define the method as 'rf' which stands for the random forest algorithm. (Note: try `names(getModelInfo())` to see a complete list of all the classification and regression methods available in the 'caret' package). 

```
modFit_rf <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = sdfAll)
```
<br>

At this point we could simply use the `predict` command to make a raster with predictions from the fitted model object (i.e., `modFit_rf`). However, it is possible to speed up computations using the `clusterR` function from the 'raster' package which supports multi-core computing for functions such as `predict` (Note: the ['snow' package] has to be installed). We just need to add one line for creating a cluster object and another one for deleting it after the operation is finished:

```
beginCluster()
 preds_rf <- clusterR(img, raster::predict, args = list(model = modFit_rf))
 endCluster()
```
<br>

The implementation of parallel computation using my 8-core processor laptop gave an improvement of about 70% in terms of computation time (~14.2 min for unparallel processing vs. ~4.1 min for multicore procedure). You can see an screenshot of the classified image below:

<a href="/images/2015-11-28-classification-r-fig-3.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-3.JPG" alt="" title="Classified Landsat image in RStudio"></a>

Additional arguments for parameter tuning such as number of trees to grow (default to 500), minimum size of terminal nodes or maximum number of terminal nodes trees in the forest, among others, can also be modified in or added to the model. Please refer to the documentation in the 'randomForest' and 'caret' packages for more details.

The following video shows these R commands in action in RStudio:

<iframe width="750" height="422" src="https://www.youtube.com/embed/fal4Jj81uMA" frameborder="0" allowfullscreen></iframe>

<br>

### **How to perform a RandomForests classification in QGIS using R packages**

For running the QGIS version of the R script described above, you can download the script available in the following link and save it in the R Scripts folder (or copy and paste the content in the QGIS Script editor) as explained [in my previous post]:

&#42; [R Script for RandomForests classification in QGIS]

Watch the following video to see how to perform a RandomForests classification for a Landsat image in QGIS using R packages:

<iframe width="750" height="422" src="https://www.youtube.com/embed/-6Hsase6xQw" frameborder="0" allowfullscreen></iframe>

<br>

### **Additional resources**

For digging into the process of predictive models creation, I recommend you visit the ['caret' package website] which provides extensive documentation about data preprocessing, data splitting, variable importance evaluation and model fitting and tuning. Also take a look at [RStoolbox], a new R package that provides a set of tools for remote sensing processing. 

The R+QGIS approach shown in this post expands the image classification methods available in QGIS. There are other image processing techniques included in QGIS such as those found in the [Semi-Automatic Classification Plugin], the [GRASS GIS plugin] and the [Orfeo Toolbox]. I suggest you also explore these other options.

In a future post I'll write about recommended practices for accuracy assessment of classified images through the comparison of reference data versus the corresponding classification results. Stay tuned!

<br>

**You may also be interested in:**

&#42; [Integrating QGIS and R: A stratified sampling example]

&#42; [Prepare files for production of reflectance imagery in CLASlite using R]

<a id="comments"></a>

[RandomForests algorithms]:              https://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm
[in a previous post in my blog]:         /blog/en/2015/10/03/reflectance-R.html
[Prepare files for production of reflectance imagery in CLASlite using R]:         /blog/en/2015/10/03/reflectance-R.html
[rgdal]:                                 http://cran.r-project.org/package=rgdal
[raster]:                                http://cran.r-project.org/package=raster
[caret]:                                 http://cran.r-project.org/package=caret
[randomForest]:                          http://cran.r-project.org/package=randomForest
[e1071]:                                 http://cran.r-project.org/package=e1071
['snow' package]:                        http://cran.r-project.org/package=snow
['raster' package]:                      http://cran.r-project.org/package=raster
[QGIS]:                                  http://www.qgis.org/
[in my previous post]:                   /blog/en/2015/10/31/qgis-r.html
[Integrating QGIS and R: A stratified sampling example]:       /blog/en/2015/10/31/qgis-r.html 
[R Script for RandomForests classification in QGIS]:  https://gist.github.com/amsantac/5183c0c71a8dcbc27a4f
[Semi-Automatic Classification Plugin]:  http://fromgistors.blogspot.com/
[RStoolbox]:                             http://bleutner.github.io/RStoolbox/
['caret' package website]:               http://topepo.github.io/caret/index.html
[GRASS GIS plugin]:                      https://docs.qgis.org/2.8/en/docs/user_manual/grass_integration/grass_integration.html
[Orfeo Toolbox]:                         https://www.orfeo-toolbox.org/



