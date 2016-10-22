---
layout      : post
title       : "Why it is important to work with a balanced classification dataset"
date        : 2016-09-20 11:02:52
categories  : blog en
tags        : R DataScience RemoteSensing landsat 
image       : 2016-09-20-balanced-image-classification-r-mini.jpg
published   : true
---

When conducting a supervised classification with machine learning algorithms such as RandomForests, one recommended practice is to work with a balanced classification dataset. However, this recommendation is sometimes overlooked due to unawareness of its relevance or lack of knowledge about how to deal with it. 

The purpose of this post is, first, to examine some of the consequences of working with an imbalanced dataset, using an image classification example, and second, to test and suggest some techniques to solve this problem.

<!--more-->

<a href="" class="image full"><img src="/images/2016-09-20-balanced-image-classification-r-fig-0.png" alt="Balanced image classification with R" title=""></a>

### **What is imbalanced data**

Imbalanced data refers to a situation where the number of observations is not the same for all the classes in a classification dataset. In some fields, imbalanced data problems are quite common.  Think of fraud detection or rare disease diagnosing, for instance, where the majority of the cases will be in the "Not-Fraud" or "Not-Disease" class and a very small minority will be in the "Fraud" or "Disease" class, respectively. In remote sensing, binary classification of urban and non-urban areas, or detection of small burned patches in an agricultural landscape, represent examples of imbalanced two-class classification problems. Class-imbalanced issues can also happen in multi-class classifications as well. 

Machine learning classifiers such as Random Forests fail to cope with imbalanced training datasets as they are sensitive to the proportions of the different classes. As a consequence, these algorithms tend to favor the class with the largest proportion of observations (known as majority class), which may lead to misleading accuracies. This may be particularly problematic when we are interested in the correct classification of a "rare" class (also known as minority class) but we find high accuracies which are actually the product of the correct classification of the majority class (ie, are the reflection of the underlying class distribution). 

Given that these algorithms aim to minimize the overall error rate, instead of paying special attention to the minority class, they may fail to make an accurate prediction for this class if they don't get the necessary amount of information about it. Thus it is highly recommended to perform an analysis of the sensitivity of the classifier to the training sample distribution. Below I show a basic analysis using remote sensing data.

### **A practical remote sensing example**

I'll use the usual packages to handle spatial data and the [caret package] for classification and accuracy assessment. An specific seed is also set for results replicability:


```r
library(rgdal)
 library(raster)
 library(caret)
 set.seed(123)
```
<br>

For this example I'll be using a Landsat 7 ETM+ image, path 7 row 57, taken on 2000-03-16, processed to surface reflectance with the LEDAPS algorithm and downloaded from the [USGS EarthExplorer]. I've unzipped the downloaded file and extracted the surface reflectance bands to a folder called 'data'. For the training data I'm using a polygons shapefile that you can [download from this link]:


```r
img <- brick(stack(as.list(list.files("data/", "sr_band", full.names = TRUE))))
 names(img) <- c(paste0("B", 1:5, coll = ""), "B7") 
```


```r
 trainData <- shapefile("data/training_15.shp")
 responseCol <- "class"
```
<br>

Next I extract the training data from the image bands using a code snippet I described in [a previous post]:


```r
dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){                          
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  dataSet <- sapply(dataSet, function(x){cbind(x, class = rep(category, nrow(x)))})
  df <- do.call("rbind", dataSet)
  dfAll <- rbind(dfAll, df)  
}
```


```r
dim(dfAll)
```

```
[1] 80943     7
```
<br>

The `dfAll` data.frame contains the values for each of six Landsat surface reflectance bands plus the class attribute. We can create a training/test partition with 70% of data going to training:


```r
inBuild <- createDataPartition(y = dfAll$class, p = 0.7, list = FALSE)
 training <- dfAll[inBuild,]
 testing <- dfAll[-inBuild,]
```


```r
table(training$class)
```

```

    1     2     3     5     6     7 
 4753 21626 14866  8093  3535  3789 
```

```r
table(testing$class)
```

```

   1    2    3    5    6    7 
2068 9236 6371 3468 1508 1630 
```
<br>

For training the model I'll be using only 2400 observations which are randomly sample from the `dfAll` data.frame. In this data subset (object `training_ub`), the number of observations in the majority class (class 2) is about six times that of the minority classes (classes 6 and 7). Although it is not excessively imbalanced, this subset will serve as example for the purpose of this exercise: 


```r
training_ub <- training[sample(1:nrow(training), 2400), ]
 table(training_ub$class)
```

```

  1   2   3   5   6   7 
211 904 608 357 149 171 
```
<br>

Let's train a RandomForest (RF) model applying the `train` function from the caret package which calculates and retrieves the training error rate:
 

```r
mod1_ub <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_ub)
```

```
note: only 2 unique complexity parameters in default grid. Truncating the grid to 2 .
```

```r
mod1_ub$results[, 1:2]
```

```
  mtry  Accuracy
1    2 0.9787367
2    3 0.9758969
```
<br>

We see that the overall accuracy using the imbalanced dataset was 0.9787. Let's create a balanced dataset and train a RF model so we can compare the accuracies between the two types of datasets.

### **How to deal with an imbalanced dataset**

There are several sampling methods that have been designed for dealing with imbalanced datasets, which could be grouped into four categories: undersampling, oversampling, synthetic data generation and cost sensitive learning. All these methods modify the class proportion and the size of the original dataset. 

The undersampling methods delete instances from the majority class in order to even-up the classes. We'll try this approach for the exercise in this post. The function below, which follows this undersampling rule, requires as arguments a data.frame (`x`), a string with the column name that identifies the classes (`classCol`), and the desired integer number of observations for each class (`nsamples_class`):


```r
undersample_ds <- function(x, classCol, nsamples_class){
  for (i in 1:length(unique(x[, classCol]))){
    class.i <- unique(x[, classCol])[i]
    if((sum(x[, classCol] == class.i) - nsamples_class) != 0){
      x <- x[-sample(which(x[, classCol] == class.i), 
                     sum(x[, classCol] == class.i) - nsamples_class), ]
      }
  }
  return(x)
}
```
<br>

This function deals with multi-class datasets. If you are working specifically with binary classifications, I'd suggest you check out the [ROSE package] which provides a convenient set of functions for data balancing. Also, if you are interested in a description of the other sampling methods please [see this post].

Let's apply the `undersample_ds` function to the `training` dataset requesting a number of 400 observations for each class:


```r
(nsamples_class <- 400) 
```

```
[1] 400
```

```r
training_bc <- undersample_ds(training, "class", nsamples_class)
 table(training_bc$class)
```

```

  1   2   3   5   6   7 
400 400 400 400 400 400 
```
<br>

Now let's train the RF model and assess the resulting overall accuracy:


```r
mod1_bc <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_bc)
```

```
note: only 2 unique complexity parameters in default grid. Truncating the grid to 2 .
```

```r
mod1_bc$results[, 1:2]
```

```
  mtry  Accuracy
1    2 0.9814680
2    3 0.9775064
```
<br>

We can see that the RandomForest classifier has a slightly better performance with the balanced dataset than with the imbalanced one, even though this dataset is not excessively imbalanced as mentioned before.

When working with imbalanced data, however, using the overall accuracy as the performance metric can be misleading since minority classes hold an small effect on this measure. Therefore it is recommended for a better insight to examine more carefully the confusion matrix and to analyze other metrics more suitable for assessing model accuracy in these situations, such as [precision], [recall] or the [F-score]. You may find different names for these metrics: precision is also called positive predictive value or *user's accuracy* in remote sensing terminology; recall is also known as sensitivity, true positive rate or as *producer's accuracy* in remote sensing.

For the final part of this exercise let's better work with the testing set as it is an independent set of data (not used for training the models shown above) and let's examine the producer's accuracy (aka sensitivity in the caret package) for the model fitted with imbalanced data:


```r
pred1_ub <- predict(mod1_ub, testing)
 confusionMatrix(pred1_ub, testing$class)$overall[1]
```

```
 Accuracy 
0.9840204 
```

```r
confusionMatrix(pred1_ub, testing$class)$byClass[, 1]
```

```
 Class: 1  Class: 2  Class: 3  Class: 5  Class: 6  Class: 7 
0.9946809 0.9785621 0.9811647 0.9919262 1.0000000 0.9809816 
```
<br>

...and for the model fitted with the balanced dataset:


```r
pred1_bc <- predict(mod1_bc, testing)
 confusionMatrix(pred1_bc, testing$class)$overall[1]
```

```
 Accuracy 
0.9779251 
```

```r
confusionMatrix(pred1_bc, testing$class)$byClass[, 1]
```

```
 Class: 1  Class: 2  Class: 3  Class: 5  Class: 6  Class: 7 
0.9845261 0.9671936 0.9704913 0.9976932 1.0000000 0.9969325 
```
<br>

First we find that the overall accuracy of the *imbalanced model* was higher than that of the *balanced model* when predicting on the testing set which is explained by the uneven proportion of classes in this dataset. This result clearly shows the effect of the larger proportion of the majority class on the overall accuracy measure, as described previously. Second, we see that the producer's accuracy of class 2 was lower in the *balanced model* than in the *imbalanced model*, while the opposite was true for class 7, which shows how machine learning algorithms such as RandomForests are accuracy-driven, that is, they aim to minimize the overall error. In the balanced dataset, errors from class 7 have the same cost as those from class 2, which leads the algorithm to search for maximizing accuracy of all classes in a more balanced way.  

In this particular example the class with the smallest number of observations, class 6, is associated to water bodies and was an easy class to be predicted perfectly by the RF algorithm in both scenarios. Thus we can ignore it and consider class 7 as the minority class.

I've recorded the following video which describes the imbalanced classification topic based on this remote sensing example:

<iframe width="750" height="422" src="https://www.youtube.com/embed/RGDhMJc0sUY" frameborder="0" allowfullscreen></iframe>

<br>

Below you find the slides from the video:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/jBz1k1o2oku9BF" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/balanced-image-classification" title="Imbalanced classification problem: A remote sensing example" target="_blank">Imbalanced classification problem: A remote sensing example</a> </strong> by <strong><a href="//www.slideshare.net/amsantac" target="_blank">Ali Santacruz</a></strong> </div>

<br>

The source code for the slides is available for [download from this link] and [on GitHub]. Hope this post gives you a few things to consider regarding the relevance of data distribution in your classification datasets. Don't forget to [subscribe to my blog] for more posts on remote sensing data science!

<br>

**You may also be interested in:**

&#42; [Image Classification with RandomForests in R (and QGIS)]

&#42; [Intro to Spatial Data Science with R]

<a id="comments"></a>

[Image Classification with RandomForests in R (and QGIS)]: /blog/en/2015/11/28/classification-r.html
[USGS EarthExplorer]: http://earthexplorer.usgs.gov/
[caret package]: https://cran.r-project.org/package=caret
[ROSE package]: https://cran.r-project.org/package=ROSE
[a previous post]: /blog/en/2015/11/28/classification-r.html
[download from this link]: https://www.dropbox.com/sh/6l572eieht0rerw/AADnWuTyvneKa8D-dIPbKnJQa?dl=0
[see this post]: https://www.analyticsvidhya.com/blog/2016/03/practical-guide-deal-imbalanced-classification-problems/
[precision]: https://en.wikipedia.org/wiki/Precision_and_recall
[recall]: https://en.wikipedia.org/wiki/Precision_and_recall
[F-score]: https://en.wikipedia.org/wiki/F1_score
[on GitHub]: https://github.com/amsantac/extras/tree/master/2016-09-20-balanced-image-classification-r
[Intro to Spatial Data Science with R]: /blog/en/2016/08/07/spatial-data-science-r.html
[subscribe to my blog]: /subscribe.html
[link1]: http://statistics.berkeley.edu/sites/default/files/tech-reports/666.pdf
[link2]: http://machinelearningmastery.com/tactics-to-combat-imbalanced-classes-in-your-machine-learning-dataset/
[link3]: http://machinelearningmastery.com/classification-accuracy-is-not-enough-more-performance-measures-you-can-use/
