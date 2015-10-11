---
title: "leaflet_mysql"
author: "Ali Santacruz"
date: "October 11, 2015"
output: html_document
---

## Install the required packages

On Linux, you don't need to install sp


```r
install.packages("RMySQL", "sp") 
```

```
## Error in install.packages : Updating loaded packages
```

```r
install.packages("sp") 
```

```
## Error in install.packages : Updating loaded packages
```

```r
install.packages("leaflet")
```

```
## Error in install.packages : Updating loaded packages
```

## Load the packages


```r
library(RMySQL)
library(sp)
library(leaflet)
```

## Connect to the database and read the table into a data.frame


```r
con <- dbConnect(MySQL(),
                 user = 'user',
                 password = 'user',
                 dbname='example')

table1 <- dbReadTable(conn = con, name = 'mydata')
```

## Convert the data.frame into a SpatialPointsDataFrame


```r
table1
```

```
##   id lat longitude population
## 1  1 4.1     -74.4       tall
```

```r
coordinates(table1) <- ~longitude+lat
class(table1)  # check that table1 is now a SpatialPointsDataFrame
```

```
## [1] "SpatialPointsDataFrame"
## attr(,"package")
## [1] "sp"
```

## Convert the data.frame into a SpatialPointsDataFrame


```r
leaflet(data = table1) %>% addTiles() %>% addMarkers(popup = paste0("My data is: ", table1$population)) 
```

<!--html_preserve--><div id="htmlwidget-7544" style="width:504px;height:504px;" class="leaflet"></div>
<script type="application/json" data-for="htmlwidget-7544">{"x":{"calls":[{"method":"addTiles","args":["http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"maxNativeZoom":null,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"continuousWorld":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":null,"unloadInvisibleTiles":null,"updateWhenIdle":null,"detectRetina":false,"reuseTiles":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>"}]},{"method":"addMarkers","args":[4.1,-74.4,null,null,null,{"clickable":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},"My data is: tall",null,null]}],"limits":{"lat":[4.1,4.1],"lng":[-74.4,-74.4]}},"evals":[]}</script><!--/html_preserve-->


