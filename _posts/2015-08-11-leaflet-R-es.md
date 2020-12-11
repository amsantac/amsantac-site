---
layout: post-es
title:  "Mapeo web con Leaflet y R"
date:   2015-08-11 11:02:52
categories: blog es R
tags: R SIG leaflet mapeoweb
image: 2015-08-11-leaflet-R-mini.png
published: true
---

[Leaflet] es una librería de JavaScript my popular para la creación de mapas interactivos. Una forma de crear un mapa usando la librería JavaScript de Leaflet es incluir los archivos de la librería Leaflet y los archivos de estilo (CSS) en la cabecera de la página y luego definir la configuración del mapa en el cuerpo de la página html. 

Una forma alternativa es crear el mapa web usando un paquete desarrollado para el [lenguaje R] llamado [leaflet], desarrollado por la gente de [RStudio], el cual permite controlar e integrar mapas de Leaflet en R. En esta entrada del blog explico cómo leer en R un mapa vectorial en formato [shapefile] y cómo crear un mapa web con leaflet personalizando la forma en que el mapa vectorial es presentado. También describo cómo adicionar una legenda, un control para las capas y popups para desplegar datos de la tabla de atributos. <!--more--> Para el propósito de este tutorial recomiendo utilizar el programa [RStudio].

Primero necesitamos instalar el paquete leaflet en R ingresando la siguiente línea de comando en la consola de R:

```
install.packages("leaflet")
```
<br>

El siguiente paso es importar en R los mapas que deseamos visualizar en nuestro mapa web. Existen varias funciones disponibles en diferentes paquetes de R (ver [rgdal], [maptools], [shapefiles], y [otros]). Aquí voy a utilizar el paquete [raster], así que primero necesitamos instalarlo:

```
install.packages("raster")
```
<br>

Ahora carguemos los dos paquetes:

```
library(raster)
 library(leaflet)
```
<br>

Para este ejemplo voy a importar en R un shapefile de polígonos que abarca el área de estudio de uno de mis proyectos. La proyección de este mapa está definida en coordenadas geográficas (latitud/longitud). Usemos la función `shapefile` del paquete raster para leer el archivo:

```
llanos <- shapefile("C:/my_dir/llanos.shp")
```
<br>

En este caso el archivo ha sido leído en R como un objeto de clase [SpatialPolygonsDataFrame] que he llamado `llanos`. Ahora vamos a crear un mapa leaflet usando este objeto para el argumento `data` en la función `leaflet`. Podemos hacer eso en una sola línea de código concatenando varios comandos con el operador `%>%`. Primero creamos un *widget* para un mapa Leaflet (con el comando `leaflet`) y luego adicionamos la capa de referencia de fondo (con `addTiles`), el mapa vectorial como un polígono (`addPolygons`) y una leyenda (`addLegend`).

```
leaflet(data = llanos) %>% addTiles() %>% addProviderTiles(providers$OpenStreetMap) %>% 
  addPolygons(fill = FALSE, stroke = TRUE, color = "#03F") %>% addLegend("bottomright", colors = "#03F", labels = "Llanos ecoregion")
```
<br>

Los argumentos `fill`, `stroke` y `color` permiten personalizar si deseamos rellenar el polígono con color, si deseamos dibujar el borde del polígono, y definir el color del borde, respectivamente. Para el comando `addLegend`, definimos la posición, los colores y las etiquetas de la leyenda. Si estás trabajando en RStudio, deberías ver tu mapa desplegado en la pestaña 'Viewer' una vez presiones la tecla Enter:

<img src="/images/2015-08-11-leaflet-R-fig-1.png" alt="Web map with leaflet" style="width:785px">

Leaflet despliega una capa de [OpenStreetMap (OSM)] por defecto pero puedes usar cualquier servicio proveedor de mapas base (e.g., [MapQuest Open], [MapBox], [Bing Maps], etc.) en tanto que aceptes los términos de uso correspondientes. Si lo necesitas puedes revisar la página de ayuda de la función `addTiles` ingresando `?addTiles` en la consola de R.

Es posible visualizar más de un mapa a la vez con leaflet. Para este ejemplo voy a superponer otro mapa de polígonos que muestra las escenas de [Landsat] que cubren mi área de estudio con base en la [grilla de referencia WRS2]. Importemos este segundo shapefile: 

```
wrs2 <- shapefile("C:/my_dir/wrs2_desc.shp")
```
<br>

Como lo hicimos anteriormente, creamos el widget del mapa Leaflet, adicionamos la capa OSM y añadimos los polígonos. Para incluir los controles de las capas, necesitamos indicar el nombre del grupo a los cuales pertenecen las nuevas capas. Por ejemplo, voy a crear el grupo "Study area" para la capa `llanos`, y el grupo "Landsat scenes" para la capa `wrs2`. En cuanto a los popups, el argumento `popup` en la función `addPolygons` es utilizado para desplegar datos de la tabla de atributos del mapa vectorial. En este caso, estoy usando una columna llamada 'PATH_ROW' que indica las propiedades 'path' y 'row' de la correspondiente escena de Landsat.

Con respecto a la leyenda, debemos adicionar parejas de valores para los argumentos `colors` y `labels` para los valores correspondientes de las dos capas de mapas. Finalmente, la función `addLayersControl` realiza la adición de controles para la interfaz de usuario para permitir prender y apagar las capas. Debemos ingresar el nombre del grupo al cual pertenece cada capa en el argumento `overlayGroups` y luego debemos definir si deseamos que el control de las capas esté colapsado o no, usando el argumento `options`. El fragmento completo del código lo puedes ver a continuación:

```
leaflet() %>% addTiles() %>% addProviderTiles(providers$OpenStreetMap) %>%   
  addPolygons(data = llanos, fill = FALSE, stroke = TRUE, color = "#03F", group = "Study area") %>% 
  addPolygons(data = wrs2, fill = TRUE, stroke = TRUE, color = "#f93", 
              popup = paste0("Scene: ", as.character(wrs2$PATH_ROW)), group = "Landsat scenes") %>% 
  # add a legend
  addLegend("bottomright", colors = c("#03F", "#f93"), labels = c("Study area", "Landsat scenes (path - row)")) %>%   
  # add layers control
  addLayersControl(
    overlayGroups = c("Study area", "Landsat scenes"),
    options = layersControlOptions(collapsed = FALSE)
  )
```
<br>

Finalmente podemos exportar el mapa como una página html. En la pestaña 'Viewer' de RStudio, haz click en el botón 'Export' y luego en 'Save as Web page...'. Posteriormente ya solo necesitas subir la página html que guardaste a tu sitio web para hacer que tu mapa esté disponible en internet. Puedes ver un ejemplo de un mapa creado con leaflet en este [link][web map]. 

Una vez subido a la web, puedes incrustar tu mapa en otras páginas web insertando un fragmento de código como el que presento a continuación donde sea que desees mostrar tu mapa: 

```
<iframe width="700" height="500" src="http://mywebsite.com/my_map.html"></iframe>
```
<br>

Si has seguido estos pasos, ahora debes tener un muy elegante mapa web con leyenda, controles de capas y popups:

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/landsat_scenes.html"></iframe>

<br>

Eso es todo. Felicitaciones por completar este primer tutorial! 


<a id="comments"></a>

[Leaflet]:                   http://leafletjs.com/
[RStudio]:                   https://www.rstudio.com/
[RStudio IDE]:               https://www.rstudio.com/products/rstudio/ 
[leaflet]:                   https://rstudio.github.io/leaflet/
[R environment]:             https://www.r-project.org/
[lenguaje R]:                https://www.r-project.org/
[rstudio_ss]:                /images/2015-08-11-leaflet-R-fig-1.png "Web map with leaflet"
[web map]:                   http://amsantac.github.io/extras/www/landsat_scenes.html
[OpenStreetMap (OSM)]:       http://www.openstreetmap.org/
[MapQuest Open]:             http://www.mapquest.com/
[MapBox]:                    https://www.mapbox.com/
[Bing Maps]:                 http://www.microsoft.com/maps/choose-your-bing-maps-API.aspx
[Leaflet Quick Start Guide]: http://leafletjs.com/examples/quick-start.html
[shapefile]:                 https://doc.arcgis.com/en/arcgis-online/reference/shapefiles.htm
[rgdal]:                     https://cran.r-project.org/package=rgdal
[maptools]:                  https://cran.r-project.org/package=maptools
[shapefiles]:                https://cran.r-project.org/package=shapefiles
[otros]:                     http://gis.stackexchange.com/questions/118077/read-esri-shape-file-polygon-or-polyline-in-r-environment
[raster]:                    https://cran.r-project.org/package=raster
[SpatialPolygonsDataFrame]:  https://www.rdocumentation.org/packages/sp/versions/1.2-7/topics/SpatialPolygonsDataFrame-class
[Landsat]:                   http://landsat.usgs.gov/
[grilla de referencia WRS2]: http://landsat.usgs.gov/tools_wrs-2_shapefile.php
