---
layout      : post
title       : "Searching and downloading Earth Observation data programmatically with SkyWatch"
date        : 2016-12-10 11:02:52
categories  : blog en
tags        : R RemoteSensing landsat API 
image       : 2016-12-10-skywatch-r-mini.jpg
published   : false
---

During the last weeks I've been testing an API developed by [SkyWatch] that provides easy access to several climate/atmospheric datasets and satellite imagery, including Landsat-8 and Sentinel-2. The [SkyWatch API] allows searching datasets by parameters such as date, location, data source (either the sensor or the satellite itself) or cloud cover, among others.

I've written an R wrapper called [SkyWatchr] to facilitate querying the API and downloading selected datasets. In this post I explain the installation of the SkyWatchr package and provide usage examples of the functions that I've included in the package so far.   

<!--more-->

<a href="" class="image full"><img src="/images/2016-12-10-skywatch-r-fig-0.png" alt="Improving classification accuracy through model stacking" title=""></a>

### **How to install the SkyWatchr package**

SkyWatchr has been recently released to [CRAN] so the installation of the stable version can be conducted easily just by executing the following command line in an R console:

```r
install.packages("SkyWatchr")
```
<br>

The development version can be installed from the [package repository on GitHub]. Once installed, load the package:

```r
library(SkyWatchr)
```
<br>

For using SkyWatchr, you will need to [request an API key] first. Once you get it, store it in an object:

```r
api_key <- "your_personal_alphanumeric_api_key"
```
<br>

Now you can start searching any of the [available datasets] which currently include Landsat-8, Sentinel-2, ACOS, AIRS, CAI, FTS-SWIR, MOPITT, OCO2 and TES. For the most basic query, you must provide a location (in geographic coordinates) and a date (or a time period):

```r
querySW(api_key, longitude_latitude = "6.566358,3.367358,6.586358,3.387358", time_period = "2015-8")
```
<br>

The search parameters include location (`longitude_latitude` argument), date (`time_period` argument), data source (`instrument_satellite` argument) and wavelength bands for imagery or file type for non-imagery data (`wavelength_band` argument). At the present time these parameters must be entered in the `querySW` function of the SkyWatchr package as character strings (e.g., `time_period="2015-8,2016-4"`, `wavelength_band="red,green,blue"`). Additional search parameters include  data processing level (`data_level` argument), maximum spatial resolution in meters (`max_resolution` argument) and maximum cloud cover in percentage (`max_cloudcover` argument), which are all entered as numeric values.

Here are a couple of sample queries to the SkyWatch API:

```r
querySW(api_key, time_period = "2016-07-11,2016-07-12", 
        longitude_latitude = "-71.1,-42.3,71.1,-42.3,71.1,42.3,-71.1,42.3,-71.1,-42.3",
        instrument_satellite = "Landsat-8", data_level = 1, max_resolution = 30, 
        max_cloudcover = 100, wavelength_band = "Blue")
        
querySW(api_key, time_period = "2009-12-25", 
        longitude_latitude = "-71.1043443253471,-42.3150676015829", data_level = 2)
```
<br>

More examples can be found in the [package documentation].

Queries can also be performed using objects of class `Spatial` (as defined by the sp package) with CRS in geographic coordinates. For example, we could import a shapefile into R and use it in the `longitude_latitude` argument:

```r
library(raster)
my_shp <- shapefile("study_area_latlon.shp") 
querySW(api_key, time_period = "2015-8", longitude_latitude = my_shp)
```
<br>

The result from a query is an object of class `data.frame` containing six columns named *area* (enclosing boundary box coordinates), *level* (data processing level), *cloud_cover* (cloud cover percentage), *download_path* (link for downloading each dataset), *source* (instrument or satellite), *band* (wavelength band or file type), *time* (acquisition date and time), *resolution* (spatial resolution in meters) and *size_kb* (file size in kilobytes).

I've included an output option to print the retrieved data.frame as html to facilitate browsing the results and clicking the download links. One just need to use the `output = "html"` argument, as shown below:

```r
querySW(api_key, time_period = "2015-8", longitude_latitude = "6.56635,3.36735,6.58635,3.38735", 
        output = "html")
querySW(api_key, time_period = "2016-07-11,2016-07-12", 
        longitude_latitude = "-71.1,-42.3,71.1,-42.3,71.1,42.3,-71.1,42.3,-71.1,-42.3",
        instrument_satellite = "Landsat-8", data_level = 1, max_resolution = 30, 
        max_cloudcover = 100, wavelength_band = "Blue", output = "html")
```
<br>

An html output example can be seen [here].

Usually it's quite helpful to see what geographic extent a dataset covers, so I've added a function called `getPolygon` which creates an SpatialPolygonsDataFrame object that displays the boundary box for a given dataset based on info extracted from the *area* column in the results data.frame, as shown in the following example:

```r
res <- querySW(api_key, time_period = "2015-8", longitude_latitude = my_shp)
sppolygon <- getPolygon(res, 24)
```
<br>

For this function, only two arguments are needed, a data.frame resulting from `querySW` and the index (row) for the corresponding dataset. After the polygon is extracted, one can easily visualize it with a package such as mapview, for instance:

```r
library(mapview)
map <- mapView(sppolygon)
map + my_shp
```
<br>

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/2016-12-10-skywatch-r-mapview.html"></iframe>

<br>

Here the rectangular polygon on the left corresponds to the extracted polygon for a selected dataset.

Once the query is carried out, users can download either all the retrieved datasets or just a subset using the `downloadSW` function. For instance, the next example shows how to download all files from a data.frame obtained after a query:

```r
res <- querySW(api_key, time_period = "2015-06", longitude_latitude = "31.321119,48.676074", 
               data_level = 3)
downloadSW(res)
```
<br>

One can also request to download a subset of rows from the data.frame or, alternatively, enter an expression to subset the files to be downloaded:

```r
# Download only files shown in rows 1 and 3 of the resulting data.frame
downloadSW(res[c(1,3), ])

# Download only files that meet a certain condition
downloadSW(res, source == "MOPITT" & size_kb < 2400)
```
<br>

These are the main functionalities added to the SkyWatchr package so far. In the video below you can watch how to install and load the package in R/RStudio and how to issue queries and download selected results:

<iframe width="750" height="422" src="https://www.youtube.com/embed/H_mr2JPxmiY" frameborder="0" allowfullscreen></iframe>

<br>

Extended documentation for each of the arguments and functions in SkyWatchr, as well as additional examples, can be found in both the package help files and the [package repository].

Users must note that calls to the SkyWatch API are limited to 1000 requests per second. API calls must complete within 30 seconds, otherwise the calls will time out. In that case users have to narrow the search criteria such the calls complete within the allowed time. Also notice that the download links expire after one hour.

I'll continue working on this new R package so I'd appreciate any feedback and ideas you'd like to share to improve it. The API works quite well and new datasets are planned to be added in the future, including MODIS and ASTER, so this tool may become a great option for facilitating the automated search and download of imagery and climate datasets. Thanks to the SkyWatch guys for their awesome work! 

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

