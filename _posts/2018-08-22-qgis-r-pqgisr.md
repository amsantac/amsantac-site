---
layout      : post
title       : "Advanced QGIS+R integration II: pqgisr"
date        : 2018-08-22 11:02:52
categories  : blog en
tags        : R GIS QGIS 
image       : 2016-12-11-skywatch-r-mini.jpg
published   : false
---

Continuing with the series of posts on how to integrate QGIS with the R language, we'll learn in this entry about `pqgisr`, an experimental R package that helps us to easily visualize and style spatial layers using a typical QGIS map canvas from an R session. I'm going to show you first how to conduct the installation of pqgisr, which is slightly different from the usual installation process for regular R packages. Then we'll see a couple of examples showing the most important functionalities of pqgisr and review its pros and cons.

Don't forget about the **free online course on Analyzing Spatial Data with the R Language** that will start quite soon! The course will start running on September 1 this year and will be available for **free only until December 31**. This course expands on the topic covered in this post and explains how to handle and process geospatial data in R. You will find the link to this free course at the bottom of this post.

Now let's begin learning about pqgisr!

<!--more-->

<a href="" class="image full"><img src="/images/2016-12-11-skywatch-r-fig-0.png" alt="Advanced QGIS+R integration - RQGIS" title=""></a>

### **pqgisr: Qgis from Python via rPython package**

`pqgisr` has some particular requirements that we must be aware of first. This package only runs on Linux (and possibly on a Mac) as it depends on the rPython package which is not available for Windows. If you are a Windows user and want to test pqgisr, I suggest you try runnning Linux using a Virtual Machine (VM). My favorite is [OSGeo-Live] which runs on Lubuntu, an Ubuntu-based distribution, and contains a preconfigured set of open source geospatial applications. 

To install and run OSGeo-Live you will need a virtualization software such as [Oracle VM VirtualBox] that is also free and open source. The [instructions to run OSGeo-Live within a VirtualBox virtual machine] are easy to follow and have always worked for me without any issues. 


**Installation of the pqgisr package**

Before installing and running pqgisr it is necessary to install in R some ancillary packages:

```r
install.packages(c("devtools", "pathological", "wkb", "base64enc"))
```
<br>

Then you need to install the rPython package:
  
```r
install.packages("rPython")
```
<br>

It is possible that an error is shown if configuration fails for the rPython package, as seen below:
  
```
** package 'rPython' successfully unpacked and MD5 sums checked
 a specific python version to use was not provided
 defaulting to the standard python in the system
 could not locate python-config
 ERROR: configuration failed for package 'rPython'
 * removing '/usr/local/lib/R/site-library/rPython'
```
<br>

In that case, open a Linux terminal and install the python-dev package. In Ubuntu:
  
```
sudo apt-get install python-dev
```
<br>

Once python-dev is installed, try to install the rPython package in R again:
  
```r
install.packages("rPython")
```
<br>

To install pqgisr, you need to go to the package website and then either download the source code from the [pqgisr repository] at Gitlab or clone the repository: 

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-1.png" alt="pqgisr repository at Gitlab" title=""></a>

For the instructions below I assume you just downloaded the zipped file which is the simplest option, especially for users not familiarized with using a control versioning system such as Git.

Once you have downloaded pqgisr from its repository, unzip it and then load pqgisr in an R session with the `devtools::load_all()` command pointing to the unzipped folder:
  
```r
devtools::load_all("~/shared/temp/pqgisr-master-871d81c4617bc5b5c1454a8740f472212cd6e33d")
```

<br>

**How to use pqgisr**

After loading pqgisr, we have to start a QGIS instance using the `init_qgis()` command (Note: you may see some error and warning messages but those errors don't prevent pqgisr from working):
  
```r
init_qgis()
```

<br>

Next we can load layers that will be added to the QGIS map canvas. For basemaps and vector layers we can use the `add_tile_layer()` and `add_ogr_layer()` commands, respectively:

```r
tiles <- add_tile_layer()
 shp <- add_ogr_layer("../../data/llanos_latlon_col_v3.shp")
```

<br>

Then just type `qgis` to launch the canvas with the loaded layers:

```r
qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-2.PNG" alt="Launch QGIS map canvas with pqgisr" title=""></a>

By right-clicking the layer name a context menu will show up giving options for zooming in to the layer extent and for changing the layer style:

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-3.png" alt="Zoom in to the vector layer" title=""></a>

When choosing the second option, the Style Layer window will be open, which is the same as the one launched and used by the corresponding QGIS version installed in the operating system (here QGIS 2.14): 

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-4.png" alt="Change layer style" title=""></a>


Note that users can also turn layers on/off as well as drag them up/down in the Layers panel in the left of the map canvas. The mouse wheel can be used as well to zoom in/out.

To send new commands to the QGIS instance for executing further actions you will have first to close the QGIS canvas either by clicking the x at the top right of the canvas window, by going to the File menu and clicking Exit, or by using the Ctrl+Q keyboard shortcut.

Already-loaded layers can be removed from the canvas with the `remove_layer()` function. Notice that in the next code chunk I'm adding a new layer that is projected in a coordinate reference system different from previous layers. This is not an issue as the layer is automatically reprojected (i.e., on-the-fly projection):

```r
remove_layer(shp)
 shp2 <- add_ogr_layer("../../data/mpios_llanos_col_v3_epsg3117_v1.shp")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-5.png" alt="Load vector layer" title=""></a>

In the previous examples I loaded layers to the canvas by indicating the file path. However, it is also possible to load spatial data that has already been imported into R as objects of class Spatial\*DataFrame (*: Points, Lines, Polygons). This type of objects can be loaded with the `add_sp_layer()` command:

```r
library(raster)
 spdf <- shapefile("../../data/cities.shp")
 shp3 = add_sp_layer(spdf)
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-6.png" alt="Load SpatialPolygonsDataFrame layer" title=""></a>

On the other hand, raster files can be loaded to the map canvas using `add_gdal_layer()`:
  
```r
rst = add_gdal_layer("../../data/mod11a1_2000_4.tif")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-7.png" alt="Load raster data" title=""></a>

To this date, the 'Change Style' option does not work for raster layers. Note that it is possible to modify the style rendering for a raster layer directly in QGIS and save the style file (.qml) before loading the layer in R with the pqgisr package. In the following example the style of a raster file that I modified customized previously in QGIS is loaded by pqgisr as expected:
  
```r
remove_layer(rst)
 rst2 = add_gdal_layer("../../data/c_2000_2001_1000m_epsg4326_clip_rec_2.rst")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-8.png" alt="Load raster with modified style" title=""></a>

In general, the pqgisr package helps users to avoid either spending time on writing lines of code just for changing a colour palette or interrupting their analysis workflow in R only to export and load data into a GIS platform. Despite its limitations (e.g., unsupported style customization for raster layers, dependance on the rPython package that lacks support for Windows), pqgisr provides a very helpful functionality for a quick visualization of spatial data as well as the ability to easily modify the style rendering of vector layers. If you want to give it a try, here is the [link to download the data used in this tutorial] as well as some additional resources. 

If you have any doubts about how to use pqgisr and particularly how to conduct the installation process, watch the video below:

<iframe width="750" height="422" src="https://www.youtube.com/embed/H_mr2JPxmiY" frameborder="0" allowfullscreen></iframe>

<br>

**Subscribe to my YouTube channel!** if you haven't yet. In the next post we'll learn about another R package that allows *remotely* handling the processing and canvas drawing functionalities of QGIS Desktop directly from an R session, so don't miss it! 

<br>

**Get the online course: Analysis of Spatial Data with the R Language** 

Update If you want to develop your skills in processing and analysis geospatial data using the R language I have prepared an *online course* which will be available for free until December 31, 2018. In this course I first cover the basics of the R language and then introduce the ... (spatial data input/output, R classes and functions for spatial data, integration with GIS software, visualization, etc.) tools that will help you to efficiently xxx common GIS tasks and efficiently solve xxx problems. Here is the access for this *free online course*. Enroll now!

<br>


**You may also be interested in:**

&#42; [Advanced QGIS+R integration I: RQGIS]

<a id="comments"></a>

[pqgisr repository]: https://gitlab.com/b-rowlingson/pqgisr
[Oracle VM VirtualBox]: https://www.virtualbox.org/
[OSGeo-Live]: https://live.osgeo.org/en/index.html
[instructions to run OSGeo-Live within a VirtualBox virtual machine]: https://live.osgeo.org/en/quickstart/virtualization_quickstart.html
[link to download the data used in this tutorial]: https://www.dropbox.com/sh/97ggktfh0zd1ghk/AABSfUKbZmY9nH_iQwfb96Gpa?dl=0
[Advanced QGIS+R integration I: RQGIS]: /blog/en/2018/07/22/qgis-r-rqgis.html
