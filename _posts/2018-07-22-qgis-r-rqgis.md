---
layout      : post
title       : "Advanced QGIS+R integration I: RQGIS"
date        : 2018-07-22 11:02:52
categories  : blog en
tags        : R GIS QGIS 
image       : 2016-12-11-skywatch-r-mini.jpg
published   : false
---

Several people have been asking me how to further integrate R with GIS software programs, mainly QGIS, especially for speeding up certain tasks that may take too long with only R code as well as for automating through R the execution of geoprocessing algorithms available in certain GIS packages. Although R has made an impressive progress in its capabilities for processing and analyzing geospatial data, there is still room for R users to benefit from integrating R to free/open source and commercial GIS software. 

Thus I have written a couple of posts where I'll introduce some of the most helpful packages recently developed for combining R and QGIS capabilities. In this post I introduce RQGIS En este post presento RQGIS, una herramienta que permite de una manera muy facil hacer uso de mas de 1000 geoalgoritmos de QGIS desde la consola de R.

Furthermore I have prepared an online course that I expect will help people to develop their skills for efficiently analyze spatial data both using the R language as well as by integrating R with free/open source and commercial GIS software. If you're interested, you'll find *the link to access this online course for free* (until December 31, 2018) below in this post, so keep reading!

<!--more-->

<a href="" class="image full"><img src="/images/2016-12-11-skywatch-r-fig-0.png" alt="Advanced QGIS+R integration - RQGIS" title=""></a>

### **RQGIS: Integrating R with QGIS**

First let's install the RQGIS package which can be done directly from CRAN:
  
```r
install.packages("RQGIS")
```
<br>

If you are using Linux then you may get an error saying that the installation of the RQGIS package failed as the v8 and udunits2 packages could not be installed. To solve it, open a terminal window and install the libv8 and libudunits2 libraries as follows:

```
$ sudo apt-get install libv8-3.14-dev
 $ sudo apt-get install libudunits2-dev
```
<br>

Once the RQGIS package is installed, load it: 
  
```r
library(RQGIS)
```
<br>

Then it is necessary to retrieve the environment settings to run QGIS from within R. On Linux simply:

```r
set_env()
```
<br>

On Windows it is better to explicitly set the root path to the QGIS installation assigning this to an object and then use this object when running any command, for instance:

```r
myenv <- set_env("C:/Program Files/QGIS 2.18")  # For QGIS standalone application
 find_algorithms("simplify", qgis_env = myenv)  # Test
 myenv2 <- set_env("C:/OSGeo4W64")                # For QGIS installed through OSGeoW 
 find_algorithms("simplify", qgis_env = myenv2)
```
<br>

For the remainder of this post I assume that the user is working under Windows OS. The `find_algorithms` command shown in the previous code chunk searches and lists all QGIS algorithms that match the keyword in their name, not only in QGIS itself but also in external applications such as SAGA, GRASS, and so on. 

For the first example I'm going to simplify the geometry of a vector layer using the `simplifygeometries` module available in QGIS. Let's call the `get_args_man` function to query which parameters are required to run it: 

```r
params <- get_args_man(alg = "qgis:simplifygeometries", qgis_env = myenv)
 params
```
<br>

`simplifygeometries` requires three parameters: *INPUT* (ie., the vector layer), *TOLERANCE* (ie., distance threshold in map units) and *OUTPUT* (ie., name of the resulting vector layer). Let's import the shapefile that we want its geometry to be simplified:
  
```r
library(raster)
 shp1 <- shapefile("data/llanos_col_v3_epsg3117.shp")
```
<br>

Now let's enter the value for each parameter:
  
```r
params$INPUT  <- shp1
 params$TOLERANCE  <- 1000
 params$OUTPUT  <- file.path(tempdir(), "simpl.shp") 
 simpl <- run_qgis(alg = "qgis:simplifygeometries", params = params, load_output = TRUE, qgis_env = myenv)
```
<br>

Let's visualize the result (zoom in and turn on/off the layers to see the difference):
  
```r
library(mapview)
 mapView(shp1) + simpl
```
<br>

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/2018-07-22-qgis-r-rqgis-simplifygeometries.html"></iframe>

<br>

Besides QGIS algorithms, it is possible to execute modules from different external applications such as SAGA GIS, as mentioned before. For instance, let's find what algorithms are available for applying a difference operation between two vector layers:

```r
find_algorithms("difference", qgis_env = myenv)
```
<br>

In this case, SAGA offers a `difference` algorithm that we could execute for this task. Using the `get_args_man` command you should find out that `saga:difference` asks for three parameters, *A*, *B* and *RESULT*:

```r
params <- get_args_man(alg = "saga:difference", qgis_env = myenv)
 params
```
<br>

Let's import two vector layers for this exercise:

```r
shpA <- shapefile("data/mpios_llanos_latlon_col_v3.shp")
 shpB <- shapefile("data/llanos_latlon_col_v3.shp")
```
<br>

Now let's enter each parameter, execute the function and plot the result:

```r
params$A  <- shpA
 params$B  <- shpB
 params$RESULT  <- file.path(tempdir(), "diff.shp")
 out <- run_qgis(alg = "saga:difference", params = params, load_output = TRUE, qgis_env = myenv)
 plot(out[1])
```

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-1.png" alt="Difference between vector layers using RQGIS" title=""></a>

**Note for GRASS users:** If results retrieved by `find_algorithms` don't show any GRASS commands, then go to the Processing menu in QGIS and click Options... - Providers - GRASS commands and mark the Activate checkbox:

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-2.PNG" alt="Activate GRASS GIS in QGIS" title=""></a>


To check GRASS activation, search algorithms that contain "contour" as keyword. You should see in the results algorithms provided by GRASS, SAGA and GDAL:

```r
find_algorithms("contour", qgis_env = myenv)
```
<br>

Let's try the `contour` function from GDAL. First let's query what parameters it requires:

```r
params <- get_args_man(alg = "gdalogr:contour", qgis_env = myenv)
 params
```
<br>

Then let's enter the input DEM raster (*INPUT_RASTER*), the contour interval (*INTERVAL*) and the name for the output contours layer (*OUTPUT_VECTOR*), and let's execute the function and plot the result:

```r
params$INPUT_RASTER  <- "data/AP_26958_FBS_F0060_RT2.dem.tif"
 params$INTERVAL  <- 500
 params$OUTPUT_VECTOR  <- file.path(tempdir(), "contours.shp")
 contours <- run_qgis(alg = "gdalogr:contour", params = params, load_output = TRUE, qgis_env = myenv)
 image(raster("data/AP_26958_FBS_F0060_RT2.dem.tif"))
 lines(as(contours, "Spatial"))
```

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-3.png" alt="Difference between vector layers using RQGIS" title=""></a>

As you can see, the RQGIS package provides an easy-to-use interface for accessing (1000+) geoprocessing modules available in QGIS and third-party providers (such as GRASS, SAGA and GDAL) from the R console. Take a look at the following video tutorial to see it in action:

<iframe width="750" height="422" src="https://www.youtube.com/embed/H_mr2JPxmiY" frameborder="0" allowfullscreen></iframe>

<br>

Don't forget to *subscribe to my YouTube channel!* In the next posts in my blog I'll cover a couple of other advanced packages that expand R spatial capabilities through further integration with QGIS-related tools, so stay tuned! The posts are already prepared and I'll be publishing them in the following weeks.

**Note:** 

If you want to develop your skills in processing and analysis geospatial data using the R language I have prepared an *online course* which will be available for free until December 31, 2018. In this course I first cover the basics of the R language and then introduce the ... (spatial data input/output, R classes and functions for spatial data, integration with GIS software, visualization, etc.) tools that will help you to efficiently xxx common GIS tasks and efficiently solve xxx problems. Here is the access for this *free online course*. Enroll now!

<br>


**You may also be interested in:**

&#42; [Image Classification with RandomForests in R (and QGIS)]

<a id="comments"></a>

[SkyWatch API]: https://github.com/skywatchspaceapps/api
[SkyWatch]: http://www.skywatch.co/
[SkyWatchr]: https://cran.r-project.org/package=SkyWatchr
[CRAN]: https://cran.r-project.org/package=SkyWatchr
[package repository on GitHub]: https://github.com/amsantac/SkyWatchr
[package repository]: https://github.com/amsantac/SkyWatchr
[package documentation]: https://github.com/amsantac/SkyWatchr
[request an API key]: http://www.skywatch.co/request-access
[here]: https://amsantac.github.io/SkyWatchr/examples/html_output_example.html
[Image Classification with RandomForests in R (and QGIS)]: /blog/en/2015/11/28/classification-r.html
[available datasets]: http://www.skywatch.co/datasets-index
[install the development version 0.5-1 from GitHub]: https://github.com/amsantac/SkyWatchr 
