---
layout: post
title:  "Prepare files for production of reflectance imagery in CLASlite using R"
date:   2015-10-03 11:02:52
categories: blog en
tags: R RemoteSensing CLASlite reflectance landsat
image: 2015-10-03-reflectance-r-mini.jpg
published: true
---

A common step in land cover mapping and multitemporal analysis of land cover change based on remotely-sensed data is the conversion of the data registered in each pixel of land cover by the satellite sensor into surface reflectance values that can be used for mapping. This process is known as calibration to surface reflectance and involves radiometric calibration and atmospheric correction. 

As mentioned in [my previous post], these steps can be done using the [CLASlite software]. In this post I explain how to automate the creation of the text files required by CLASlite for image calibration through batch processing.

<!--more-->

<img src="/images/2015-10-03-reflectance-r-fig-0.jpg" alt="" title="" style="width:800px">

For the batched conversion to surface reflectance, CLASlite asks for a CSV text file containing 18 columns with the following names: "Input_FileName", "Date", "Time", "Gain_Settings", "Satellite", "Lead_File", "Therm_File", "QA_File", "Output_File", "GeoTIFF", "Proc_sys", "Reduce_masking", "no_masking", "fmask", "cldpix", "sdpix", "snpix" and "cldprob". A template file called 'step1_template.csv' can be found in the templates folder inside the CLASlite installation directory.

"Input_FileName" refers to the absolute paths of the folders containing images to be processed. "Date" and "Time" refer to the date and time of the image acquisition. "Gain_Settings" refers to low or high gain settings used for optimizing sensor sensitivity. "Therm_File" and "QA_File" refer to the absolute paths of the thermal band files and the quality image files (e.g., for Landsat 8). "Output_File" refers to the desired name for the output surface reflectance file while "Proc_sys" refers to the processing software version (e.g., LPGS or NLAPS used by [USGS]). The description of the other data columns required by CLASlite can be seen [here].

I wrote an R script called [reflectanceImgTable4csv.R] that helps to the creation of this text file by reading the required information from the metadata file of the corresponding images. Below I describe how to run this script and how to use the output text file in CLASlite for producing surface reflectance from raw imagery.


### **How to run the script**

For using the R script, it is necessary to create first a list of the folders containing the [stacked Landsat images] that will be processed. Let's assume we have a group of Landsat images for a number of years for which we have already created raw and thermal files as shown in [my previous post]:

<img src="/images/2015-10-03-reflectance-r-fig-1.png" alt="Input folder" title="Input folder" style="width:800px">

Let's use R to create the folders list:

```
setwd("C:/images/2000")   # set the working directory
 foldersList <- normalizePath(list.dirs(full.names = TRUE, recursive = FALSE))  # get absolute folder paths
```
<br>

You can found the complete code script for the `reflectanceImgTable4csv` function in [this link]. Let's source the script file:

```
source("https://raw.githubusercontent.com/amsantac/extras/gh-pages/code/reflectanceImgTable4csv.R")
```
<br>

Now we need to run the function providing the folders list as the first parameter. For this example, I am going to set the `no_masking` parameter to 1, in order to ask CLASlite to not mask clouds and cloud shadows. I will use the default values for the other parameters. As the last step in R, we have to save the output data frame as a comma separated values file. The row names must not be saved in the file and the strings must not be surrounded by double quotes:

```
outDF <- reflectanceImgTable4csv(foldersList, no_masking = 1)
 write.table(outDF, "reflectance_2000.csv", row.names = FALSE, quote = FALSE, sep = ", ")
```
<br>

### **Back to CLASlite**
Open CLASlite and click "1. Calibrate Image". Browse for and enter the Input Directory and the Output Directory, which are the same and correspond to the folder for each year, in this example. Click "Load". In the new window select the number of images to be processed (e.g., 12) and click "OK". 

<img src="/images/2015-10-03-reflectance-r-fig-2.png" alt="Calibrate image in CLASlite 1" title="Calibrate image in CLASlite 1" style="width:800px">

In the next window click "Load Table". Browse for and select the csv file generated with R, and click "Select". The parameters must be filled in in the table shown in the window:  

<img src="/images/2015-10-03-reflectance-r-fig-3.png" alt="Calibrate image in CLASlite 2" title="Calibrate image in CLASlite 2" style="width:800px">

Finally click "Run" to create the surface reflectance imagery for the provided list of images. After CLASlite processes all the files, you should see in each folder a new image with "_refl" appended to its name that corresponds to the atmospherically-corrected images: 

<img src="/images/2015-10-03-reflectance-r-fig-4.png" alt="Output folder" title="Output folder" style="width:800px">

<br>

### **What the script does**

In the next lines I'm going to provide a brief review about what the [reflectanceImgTable4csv.R script] does.

First, a data frame with the 18 columns required by CLASlite is created:

```
outDF <- data.frame(matrix(data = NA, nrow = length(foldersList), ncol = 18))
 colnames(outDF) <- c("Input_FileName", "Date", "Time", "Gain_Settings", "Satellite", "Lead_File", "Therm_File",
                              "QA_File", "Output_File", "GeoTIFF", "Proc_sys", "Reduce_masking", "no_masking", "fmask", 
                               "cldpix", "sdpix", "snpix", "cldprob")
```
<br>

Then the values for the `GeoTIFF`, `Reduce_masking`, `no_masking`, `fmask`, `cldpix`, `sdpix`, `snpix` and `cldprob` parameters are assigned, based on user input or on the default values if the user does not change them:

```
outDF[, "GeoTIFF"] <- GeoTIFF
 outDF[, 12:18] <- t(apply(outDF[, 12:18], 1, function(x){c(Reduce_masking, no_masking, fmask, cldpix, sdpix, snpix,
                                                                                           cldprob)}))
```
<br>

For each folder in the folders list, the absolute path of each raw image file is stored in the `Input_FileName` column of the data frame: 

```
rawImg1 <- grep("raw", list.files(folder, full.names = TRUE), value = TRUE)[1] 
 outDF[i, "Input_FileName"] <- gsub("/", "\\", rawImg1, fixed = TRUE)
```
<br>

The text file containing the image metadata is read to extract the image acquisition date...

```
mtlTxt <- grep("MTL.txt", list.files(folder, full.names = TRUE), value = TRUE)  
 mtl <- readLines(mtlTxt)
 date1 <- strsplit(mtl[grep("DATE_ACQUIRED", mtl)], "= ")[[1]][2]
 outDF[i, "Date"] <- format(as.Date(date1), "%d%m%Y")
```
<br>

... and the acquisition time:

```
time1 <- strsplit(mtl[grep("SCENE_CENTER_TIME", mtl)], "= ")[[1]][2]
 time2 <- paste(unlist(strsplit(time1, ":"))[1:2], collapse = "")
 outDF[i, "Time"] <- gsub("\"", "", time2)
```
<br>

Then the satellite platform is extracted from the metadata file:

```
sid1 <- strsplit(mtl[grep("SPACECRAFT_ID", mtl)], "= ")[[1]][2]
 sid2 <- gsub("\"", "", sid1)
 if(sid2 == "LANDSAT_8") Satellitei <- 0
 if(sid2 == "LANDSAT_7") Satellitei <- 1
 if(sid2 == "LANDSAT_5") Satellitei <- 2
 if(sid2 == "LANDSAT_4") Satellitei <- 3
 if(sid2 == "ALI") Satellitei <- 4
 if(sid2 == "ASTER") Satellitei <- 5
 if(sid2 == "SPOT4") Satellitei <- 6
 if(sid2 == "SPOT5") Satellitei <- 7
 outDF[i, "Satellite"] <- Satellitei
```
<br>

Next the gain settings for bands 1 through 5 and 7 for Landsat 7 images are extracted:

```
gains <- NULL
 if (Satellitei == 1){
  for (band in c(1:5, 7)){
   bandGain_1 <- strsplit(mtl[grep(paste0(" GAIN_BAND_", band), mtl)], "= ")[[1]][2]
   bandGain_2 <- gsub("\"", "", bandGain_1)
   gains <- c(gains, bandGain_2)
  }
  outDF[i, "Gain_Settings"] <- paste(gains, collapse="")
}
```    
<br>

The processing software version is read and treated as a boolean variable (i.e., 0 for LPGS, 1 for NLAPS):

```
sys1 <- strsplit(mtl[grep("PROCESSING_SOFTWARE_VERSION", mtl)], "= ")[[1]][2]
 sys2 <- strsplit(gsub("\"", "", sys1), "_")[[1]][1]
 if(sys2 == "LPGS") outDF[i, "Proc_sys"] <- 0
 if(sys2 == "NLAPS") outDF[i, "Proc_sys"] <- 1
```
<br>

Then the names of the thermal image files are read and stored in the `Therm_File` column of the data frame:

```
ThermImg1 <- grep("therm", list.files(folder, full.names = TRUE), value = TRUE)[1]
 outDF[i, "Therm_File"] <- gsub("/", "\\", ThermImg1, fixed = TRUE)
```    
<br>

For Landsat 8 imagery the absolute path of the quality image file is extracted:

```
if (Satellitei == 0){
   QAImg1 <- grep("_QA", list.files(folder, full.names = TRUE), value = TRUE)[1]
   outDF[i, "QA_File"] <- gsub("/", "\\", QAImg1, fixed = TRUE)
}
```    
<br>

Finally the names of the output files are assigned:

```
outDF[i, "Output_File"] <- sub("_therm", "_refl", outDF[i, "Therm_File"])
```    
<br>

This R script intends to help for an efficient creation of the text files required by the CLASlite software for producing surface reflectance imagery. The script has been tested for Landsat imagery on a Windows environment. If you happen to use this script, I appreciate any feedback that helps to its improvement. Hope you find it helpful! 


<br>

**You may be also interested in:**

&#42; [Using R for file stacking in CLASlite]

<a id="comments"></a>

[CLASlite software]:                http://claslite.carnegiescience.edu/
[R language]:                       http://r-project.org
[USGS]:                             http://www.usgs.gov
[here]:                             https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[this link]:                        https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[my previous post]:                 /blog/en/r/2015/09/05/stacking-R.html
[stacked Landsat images]:           /blog/en/r/2015/09/05/stacking-R.html
[Using R for file stacking in CLASlite]:                 /blog/en/r/2015/09/05/stacking-R.html
[reflectanceImgTable4csv.R]:        https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[reflectanceImgTable4csv.R script]: https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
