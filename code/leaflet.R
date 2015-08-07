# using the leaflet package from RStudio
library(raster)
library(leaflet)
setwd("C:/amsantac/other/temp/borrar")

llanos <- shapefile("C:/amsantac/PhD/Research/dissertation/data/shps/llanos_latlon_col_v3.shp")

## map_llanos.html
leaflet(data = llanos) %>% addTiles() %>%   addPolygons(fill = FALSE, stroke = TRUE, color = "#03F") %>% 
  addLegend("bottomright", colors = "#03F", labels = "Llanos ecoregion")

## landsat_scenes.html
llanos_wrs2 <- shapefile("C:/amsantac/PhD/Research/dissertation/data/landsat/wrs grids/llanos_wrs2_desc.shp")

leaflet() %>% addTiles() %>%   
  addPolygons(data = llanos, fill = FALSE, stroke = TRUE, color = "#03F", group = "Study area") %>% 
  addPolygons(data = llanos_wrs2, fill = TRUE, stroke = TRUE, color = "#f93", 
              popup = paste0("Scene: ", as.character(llanos_wrs2$PATH_ROW)), group = "Landsat scenes") %>% 

  # legend
  addLegend("bottomright", colors = c("#03F", "#f93"), labels = c("Study area", "Landsat scenes (path - row)")) %>%   
  
  # layers control
  addLayersControl(
    overlayGroups = c("Study area", "Landsat scenes"),
    options = layersControlOptions(collapsed = FALSE)
  )

## Finally export the map as html in RStudio. Click the 'Export' button and then click 'Save as Web page...'



# using the leafletR package
library(leafletR)
llanos2 <- spTransform(llanos, CRS("+init=epsg:3857"))
llanos.geojson <- toGeoJSON(llanos2)
llanos.style <- styleSingle(col="darkred", lwd = 4)
leaflet(c(llanos.geojson), style = list(llanos.style), popup = list(c("ISO")), base.map= "osm")
