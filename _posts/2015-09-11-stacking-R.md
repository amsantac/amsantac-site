---
layout: post
title:  "Preparing files for CLASlite using R"
date:   2015-09-11 11:02:52
categories: blog R CLASlite stacking
---

[CLASlite] is a powerful software designed to process satellite imagery from its original (raw) format to . I will describe in this post how to use the [R language] for creating the text files required by CLASlite for stacking imagery through batch processing.

satellite imagery from its original (raw) format, through calibration, pre-processing, atmospheric correction, and cloud masking steps, Monte Carlo Spectral Mixture Analysis, and expert classification to derive high-resolution output images. Usually the first step when processing imagery that has been obtained in raw format is to stack the individual layers into a single file. CLASlite allows stacking Landsat imagery using the 'Prepare Landsat' tool that can be access from the menu Tools - Prepare Landsat in the CLASlite graphical user interface.

<img src="/images/2015-09-11-stacking-R-fig-1.png" alt="Stacking Landsat imagery in CLASlite" style="width:600px">

One the nicest features in CLASlite is the possibility of performing processing or preprocessing tasks for several files at a time through batch processing. This avoids repetitive 

The 'Prepare Landsat' tool requires the user to enter a CSV file that lists the absolute path of the folder of each Landsat image to be processed. Each folder must contain all the individual 


```
stackImgTable4csv <- function(path, years){
  oldwd <- getwd()
  foldersList <- NULL
    for (year in years){
    path_y <- paste0(path, "/", year)
    setwd(path_y)
    foldersList <- c(foldersList, paste0(path_y, "/", list.files()))
  }
  setwd(oldwd)
  foldersListDF <- data.frame("LANDSAT_Folder_Names" = foldersList)
  return(foldersListDF)
}

## set working directory: folder where the output csv files should be written
setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/CLASliteCSVs")

## parameters to run the function
path <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"
years <- 2000:2014
fname <- "stack_2000_2014.csv"

## run the function for the given years
outDF <- stackImgTable4csv(path, years)

## create the csv file
write.csv(outDF, fname, row.names = FALSE, quote = FALSE)
```
<br>

Go to the folder for the corresponding year to process (C:\amsantac\PhD\Research\dissertation\data\landsat\images).
Unzip all the zipped GZ files using "Extract Here". Delete the GZ files.
Unzip all the .tar files using: "Extract to *\". Delete the .tar files.
If needed, repeat steps 1-3 for all the required years 
Create the .csv file required by CLASlite using the stackLandsatCSV.R script for the years needed, e.g.:

source the R script

```
source("https://github.com/amsantac/cuproject/raw/gh-pages/code/stackImgTable4csv.R")
```
<br>
parameters to run the function

```
path <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"
years <- 2000:2014
output <- "stack_2000_2014.csv"

# create the csv file for the given years
stackLandsatCSV(path, years, output)
```
<br>
Open CLASlite and click "Tools" - "Prepare Landsat". Select "Batch Process" and click the "Load File" button to browse and select the output .csv file created in step 5. Finally click the "Stack" button.



Now you have a fancy web map with legend, layers controls and popups:

In the next post I will provide  

[CLASlite]:                  http://claslite.carnegiescience.edu/
[R language]:                http://r-project.org

[RStudio]:                   https://www.rstudio.com/
[RStudio IDE]:               https://www.rstudio.com/products/rstudio/ 
[leaflet]:                   https://rstudio.github.io/leaflet/
[R language]:                http://r-project.org
[rstudio_ss]:                /images/2015-08-11-leaflet-R-fig-1.png "Web map with leaflet"
[web map]:                   http://amsantac.github.io/cuproject/www/landsat_scenes.html
[OpenStreetMap (OSM)]:       http://www.openstreetmap.org/
[MapQuest Open]:             http://www.mapquest.com/
[MapBox]:                    https://www.mapbox.com/
[Bing Maps]:                 http://www.microsoft.com/maps/choose-your-bing-maps-API.aspx
[Leaflet Quick Start Guide]: http://leafletjs.com/examples/quick-start.html
[shapefile]:                 https://doc.arcgis.com/en/arcgis-online/reference/shapefiles.htm
[rgdal]:                     https://cran.r-project.org/package=rgdal
[maptools]:                  https://cran.r-project.org/package=maptools
[shapefiles]:                https://cran.r-project.org/package=shapefiles
[others]:                    http://gis.stackexchange.com/questions/118077/read-esri-shape-file-polygon-or-polyline-in-r-environment
[raster]:                    https://cran.r-project.org/package=raster
[SpatialPolygonsDataFrame]:  http://www.inside-r.org/packages/cran/sp/docs/as.data.frame.SpatialPolygonsDataFrame
[Landsat]:                   http://landsat.usgs.gov/
[WRS2 descending grid]:      http://landsat.usgs.gov/tools_wrs-2_shapefile.php
