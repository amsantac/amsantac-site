---
layout      : post-es
title       : "Búsqueda y descarga automatizada de imágenes satelitales con SkyWatch"
date        : 2016-12-11 11:02:52
categories  : blog es
tags        : R PercepcionRemota landsat API 
image       : 2016-12-11-skywatch-r-mini.jpg
published   : true
---

Durante las últimas semanas he estado probando un API desarrollado por [SkyWatch] que ofrece un fácil acceso a varios datasets climáticos y atmosféricos y a imágenes satelitales, incluyendo Landsat-8 y Sentinel-2. El [API de SkyWatch] permite buscar datasets por parámetros como fecha, localización, fuente de datos (ya sea sensor o el satélite) o cobertura de nubes, entre otros.

He desarrollado un paquete de R llamado [SkyWatchr] para facilitar las consultas al API y la descarga de los datasets seleccionados. En este post explico la instalación del paquete SkyWatchr y presento algunos ejemplos del uso de las funciones que he incluido en el paquete hasta ahora.   

<!--more-->

<a href="" class="image full"><img src="/images/2016-12-11-skywatch-r-fig-0.png" alt="Búsqueda y descarga automatizada de imágenes satelitales con SkyWatch" title=""></a>

### **Cómo instalar el paquete SkyWatchr**

SkyWatchr fue aceptado en [CRAN] recientemente, gracias a lo cual la instalación de la versión estable puede ser realizada fácilmente simplemente ejecutando la siguiente línea de comando en una consola de R:

```r
install.packages("SkyWatchr")
```
<br>

La versión en desarrollo puede ser instalada desde el [repositorio del paquete en GitHub]. Una vez instalado, cargamos el paquete:

```r
library(SkyWatchr)
```
<br>

Para usar SkyWatchr, es necesario que antes [solicites una clave de acceso al API]. Una vez la obtengas, la puedes almacenar en un objeto:

```r
api_key <- "tu_clave_personal_de_acceso_al_API"
```
<br>

Ahora puedes empezar a hacer búsquedas en alguno de los [datasets disponibles] los cuales actualmente incluyen Landsat-8, Sentinel-2, ACOS, AIRS, CAI, FTS-SWIR, MOPITT, OCO2 y TES. Para la búsqueda más básica, debes suministrar una localización (en coordenadas geográficas) y una fecha (o un periodo de tiempo):

```r
querySW(api_key, longitude_latitude = "6.566358,3.367358,6.586358,3.387358", time_period = "2015-8")
```
<br>

Los parámetros de búsqueda incluyen la localización (argumento `longitude_latitude`), fecha (argumento `time_period`), fuente de datos (argumento `instrument_satellite`) y las bandas de longitud de onda para las imágenes o el tipo de archivo para aquellos datasets que no son imágenes (argumento `wavelength_band`). Actualmente estos parámetros deben ser ingresados en la función `querySW` del paquete SkyWatchr como texto (e.g., `time_period="2015-8,2016-4"`, `wavelength_band="red,green,blue"`). Parámetros de búsqueda adicionales incluyen el nivel de procesamiento de los datos (argumento `data_level`), resolución espacial máxima en metros (argumento `max_resolution`) y la máxima cobertura de nubes en porcentaje (argumento `max_cloudcover`), todos los cuales son ingresados como valores numéricos.

A continuación puedes ver un par de ejemplos de consultas que se pueden enviar al API de SkyWatch:

```r
querySW(api_key, time_period = "2016-07-11,2016-07-12", 
        longitude_latitude = "-71.1,-42.3,71.1,-42.3,71.1,42.3,-71.1,42.3,-71.1,-42.3",
        instrument_satellite = "Landsat-8", data_level = 1, max_resolution = 30, 
        max_cloudcover = 100, wavelength_band = "Blue")
        
querySW(api_key, time_period = "2009-12-25", 
        longitude_latitude = "-71.1043443253471,-42.3150676015829", data_level = 2)
```
<br>

En la [documentación del paquete] puedes encontrar más ejemplos.

Las búsquedas también se pueden realizar usando objetos de clase `Spatial` (definidas por el paquete sp) con sistema de referencia espacial en coordenadas geográficas. Por ejemplo, podemos importar un shapefile a R y usarlo en el argumento `longitude_latitude`:

```r
library(raster)
my_shp <- shapefile("study_area_latlon.shp") 
querySW(api_key, time_period = "2015-8", longitude_latitude = my_shp)
```
<br>

El resultado de cada consulta es un objeto de clase `data.frame` que contiene seis columnas llamadas *area* (coordenadas del rectángulo envolvente), *level* (nivel de procesamiento de los datos), *cloud_cover* (porcentaje de cobertura de nubes), *download_path* (link para descargar cada dataset), *source* (instrumento o satélite), *band* (banda de la longitud de onda o tipo de archivo), *time* (fecha y hora de adquisición), *resolution* (resolución espacial en metros) y *size_kb* (tamaño del archivo en kilobytes).

He añadido una opción en el argumento `output` para que el data.frame pueda ser mostrado también como html con el fin de facilitar la visualización de los resultados y poder hacer clic en los links de descarga directamente. Para ello tan solo es necesario usar el argumento `output = "html"`, como se muestra a continuación:

```r
querySW(api_key, time_period = "2015-8", longitude_latitude = "6.56635,3.36735,6.58635,3.38735", 
        output = "html")
querySW(api_key, time_period = "2016-07-11,2016-07-12", 
        longitude_latitude = "-71.1,-42.3,71.1,-42.3,71.1,42.3,-71.1,42.3,-71.1,-42.3",
        instrument_satellite = "Landsat-8", data_level = 1, max_resolution = 30, 
        max_cloudcover = 100, wavelength_band = "Blue", output = "html")
```
<br>

Puedes ver un ejemplo de una salida impresa en html [en este link].

Usualmente es muy útil ver cuál es la extensión geográfica que abarca un dataset dado. Por ello he añadido una función llamada `getPolygon` que crea un objeto de clase `SpatialPolygonsDataFrame` el cual muestra el rectángulo envolvente (o boundary box) de un dataset determinado con base en la información extraída de la columna *area* del data.frame de resultados, como se puede ver en el siguiente ejemplo:

```r
res <- querySW(api_key, time_period = "2015-8", longitude_latitude = my_shp)
sppolygon <- getPolygon(res, 24)
```
<br>

Para esta función solamente se necesitan dos argumentos, un data.frame generado por `querySW` y el índice (fila) del dataset correspondiente. Después de que se extrae el polígono, éste puede ser fácilmente visualizado con paquetes como mapview, u otros:

```r
library(mapview)
map <- mapView(sppolygon)
map + my_shp
```
<br>

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/2016-12-10-skywatch-r-mapview.html"></iframe>

<br>

Aquí el polígono rectangular de la izquierda corresponde al polígono extraído para un dataset seleccionado.

Una vez se obtienen los resultados de la búsqueda, los usuarios pueden descargar todos los datasets encontrados o solamente un subconjunto de ellos, usando la función `downloadSW`. El siguiente ejemplo muestra cómo descargar todos los archivos a partir de un data.frame generado tras una consulta:

```r
res <- querySW(api_key, time_period = "2015-06", longitude_latitude = "31.321119,48.676074", 
               data_level = 3)
downloadSW(res)
```
<br>

También es posible descargar un subconjunto de las filas del data.frame o, alternativamente, ingresar una expresión de consulta para seleccionar los archivos a descargar:

```r
# Descargar solamente los archivos de las filas 1 y 3 del data.frame de resultados
downloadSW(res[c(1,3), ])

# Descargar solamente los archivos que cumplen una condición dada
downloadSW(res, source == "MOPITT" & size_kb < 2400)
```
<br>

Estas son las principales funcionalidades que he adicionado al paquete SkyWatchr hasta ahora. En el siguiente video puedes ver cómo instalar y cargar el paquete en R/RStudio y cómo hacer consultas y descargar los datasets deseados: 

<iframe width="750" height="422" src="https://www.youtube.com/embed/_r08A3LPKBs" frameborder="0" allowfullscreen></iframe>

<br>

Puedes encontrar documentación más extensa para cada uno de los argumentos y las funciones de SkyWatchr, así como ejemplos adicionales, tanto en los archivos de ayuda del paquete como en el [repositorio en GitHub].

Los usuarios del API deben tener en cuenta que las consultas están limitadas a 1000 solicitudes por segundo y deben completarse en un lapso de 30 segundos. Si no es así, la consulta devuelve un error, para evitar lo cual los usuarios deberán reducir los criterios de búsqueda para que las consultas se completen en en ese tiempo. También hay que notar que los links de descarga expiran después de una hora.

Planeo seguir desarrollando este nuevo paquete de R por lo que agradecería tus comentarios e ideas para mejorarlo. El API funciona bastante bien y hay planes para proveer acceso a nuevos datasets, incluyendo MODIS y ASTER, con lo que SkyWatch se puede convertir en una muy buena opción para facilitar la búsqueda y descarga automatizada de imágenes satelitales y datasets climáticos y atmosféricos. Gracias a los desarrolladores de SkyWatch por esta excelente herramienta!

<br>


**También te puede interesar:**

&#42; [Clasificación de imágenes con RandomForests en R (y QGIS)]

<a id="comments"></a>

[API de SkyWatch]: https://github.com/skywatchspaceapps/api
[SkyWatch]: http://www.skywatch.co/
[SkyWatchr]: https://cran.r-project.org/package=SkyWatchr
[CRAN]: https://cran.r-project.org/package=SkyWatchr
[repositorio del paquete en GitHub]: https://github.com/amsantac/SkyWatchr
[repositorio en GitHub]: https://github.com/amsantac/SkyWatchr
[repositorio del paquete]: https://github.com/amsantac/SkyWatchr
[datasets disponibles]: http://www.skywatch.co/datasets-index
[documentación del paquete]: https://github.com/amsantac/SkyWatchr
[solicites una clave de acceso al API]: http://www.skywatch.co/request-access
[en este link]: https://amsantac.github.io/SkyWatchr/examples/html_output_example.html
[Clasificación de imágenes con RandomForests en R (y QGIS)]: /blog/es/2015/11/28/classification-r-es.html
[instala la versión en desarrollo 0.5-1 disponible en GitHub]: https://github.com/amsantac/SkyWatchr

