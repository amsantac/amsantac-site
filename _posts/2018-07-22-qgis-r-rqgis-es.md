---
layout      : post-es
title       : "Integración avanzada de QGIS y R I: RQGIS"
date        : 2018-07-22 11:02:52
categories  : blog es
tags        : R SIG QGIS 
image       : 2016-12-11-skywatch-r-mini.jpg
published   : false
---

Varias personas me han preguntado sobre cómo lograr mayor integración de R con software SIG, más que todo con QGIS, especialmente para reducir el tiempo de procesamiento de ciertas tareas que pueden tomar demasiado usando solo código de R, así como para automatizar con R la ejecución de algoritmos de procesamiento disponibles en un SIG dado.   

Por ello he escrito un par de posts donde presento algunos de los paquetes más útiles que se han desarrollado recientemente para combinar las capacidades de R y QGIS. En este post presento RQGIS, una herramienta que permite de una manera muy fácil hacer uso de más de 1000 geoalgoritmos de QGIS desde la consola de R.

Aparte de estos posts tambien he preparado un curso online que espero ayude a las personas a aprender y entender cómo manejar datos espaciales con R y cómo integrar R con programas SIG tanto libres/gratuitos como comerciales. Si estás interesado, más abajo en este post encontrarás el *link de acceso para este curso en línea gratuito* (hasta Diciembre 31, 2018), así que sigue leyendo!


<!--more-->

<a href="" class="image full"><img src="/images/2016-12-11-skywatch-r-fig-0.png" alt="Integración avanzada de QGIS y R - RQGIS" title=""></a>

### **RQGIS: Integrando R con QGIS**

Como primer paso instalamos el paquete RQGIS, lo cual lo podemos hacer directamente desde CRAN:
  
```r
install.packages("RQGIS")
```
<br>

Si estás utilizando Linux entonces es posible que salga un error diciendo que la instalación del paquete RQGIS falló debido a que los paquetes v8 y udunits2 no pudieron ser instalados. Para resolverlo abre una terminal de comandos de Linux e instala las librerías libv8 y libudunits2 de la siguiente forma:

```
$ sudo apt-get install libv8-3.14-dev
 $ sudo apt-get install libudunits2-dev
```
<br>

Una vez RQGIS esté instalado, cárgalo: 
  
```r
library(RQGIS)
```
<br>

Luego es necesario establecer las variables de entorno requeridas para ejecutar QGIS desde R. En Linux simplemente:

```r
set_env()
```
<br>

En Windows es mejor definir explícitamente el folder donde se encuentra instalado QGIS asignando esto a un objeto y luego usar éste para correr algún comando, por ejemplo:

```r
myenv <- set_env("C:/Program Files/QGIS 2.18")  # Para QGIS instalado con ejecutable
 find_algorithms("simplify", qgis_env = myenv)   # Prueba 
 myenv2 <- set_env("C:/OSGeo4W64")                # Para QGIS instalado con OSGeoW 
 find_algorithms("simplify", qgis_env = myenv2)
```
<br>

Para el resto de este post asumo que el usuario está trabajando con el sistema operativo Windows. El comando `find_algorithms` mostrado en el anterior fragmento de código busca y enlista todos los algoritmos que concuerdan con el término buscado y que están disponibles no solamente en QGIS mismo sino también en aplicaciones externas como SAGA, GRASS, etc. 

Para el primer ejemplo voy a simplificar la geometría de una capa vectorial usando el módulo `simplifygeometries` disponible en QGIS. Usemos la función `get_args_man` para averiguar cuáles parámetros son necesarios para correrlo: 

```r
params <- get_args_man(alg = "qgis:simplifygeometries", qgis_env = myenv)
 params
```
<br>

`simplifygeometries` requiere tres parámetros: *INPUT* (ie., la capa vector), *TOLERANCE* (ie., umbral de distancia en unidades del mapa) and *OUTPUT* (ie., nombre para la capa vector resultante). Para el ejercicio importemos el shapefile cuya geometría queremos simplificar:
  
```r
library(raster)
 shp1 <- shapefile("data/llanos_col_v3_epsg3117.shp")
```
<br>

Ahora ingresemos el valor para cada parámetro:
  
```r
params$INPUT  <- shp1
 params$TOLERANCE  <- 1000
 params$OUTPUT  <- file.path(tempdir(), "simpl.shp") 
 simpl <- run_qgis(alg = "qgis:simplifygeometries", params = params, load_output = TRUE, qgis_env = myenv)
```
<br>

Visualicemos el resultado (haz zoom y prende y apaga las capas para observar la diferencia):
  
```r
library(mapview)
 mapView(shp1) + simpl
```
<br>

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/2018-07-22-qgis-r-rqgis-simplifygeometries.html"></iframe>

<br>

Además de algoritmos de QGIS es posible ejecutar módulos presentes en distintas aplicaciones externas como SAGA GIS, como lo mencioné antes. Por ejemplo, encontremos qué algoritmos están disponibles para aplicar una operación de diferencia entre dos capas vector:

```r
find_algorithms("difference", qgis_env = myenv)
```
<br>

En este caso SAGA ofrece un algoritmo llamado `difference` que podríamos ejecutar para este propósito. Usando el comando `get_args_man` tu podrías determinar que `saga:difference` solicita tres parámetros, *A*, *B* y *RESULT*:

```r
params <- get_args_man(alg = "saga:difference", qgis_env = myenv)
 params
```
<br>

Importemos entonces dos capas vector para este ejercicio:

```r
shpA <- shapefile("data/mpios_llanos_latlon_col_v3.shp")
 shpB <- shapefile("data/llanos_latlon_col_v3.shp")
```
<br>

Ahora ingresemos cada parámetro, ejecutemos la función y ploteemos el resultado:

```r
params$A  <- shpA
 params$B  <- shpB
 params$RESULT  <- file.path(tempdir(), "diff.shp")
 out <- run_qgis(alg = "saga:difference", params = params, load_output = TRUE, qgis_env = myenv)
 plot(out[1])
```

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-1.png" alt="Difference between vector layers using RQGIS" title=""></a>


**Nota para usuarios de GRASS:** Si los resultados arrojados por `find_algorithms` no muestran comandos de GRASS, entonces en QGIS ve al menu Processing y haz click en Options... - Providers - GRASS commands y marca la casilla Activate:

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-2.PNG" alt="Activa GRASS GIS en QGIS" title=""></a>

Para verificar la activación busca algoritmos que contengan "contour" como palabra clave. En los resultados deberias ver algoritmos suministrados por GRASS, SAGA y GDAL:

```r
find_algorithms("contour", qgis_env = myenv)
```
<br>

Probemos la función `contour` de GDAL. Primero consultemos qué parámetros requiere:

```r
params <- get_args_man(alg = "gdalogr:contour", qgis_env = myenv)
 params
```
<br>

Luego ingresemos el raster con el modelo digital de elevación (*INPUT_RASTER*), el intervalo entre líneas de contornos (*INTERVAL*) y el nombre para la capa de contornos generada (*OUTPUT_VECTOR*) y ejecutemos la función y visualicemos el resultado:

```r
params$INPUT_RASTER  <- "data/AP_26958_FBS_F0060_RT2.dem.tif"
 params$INTERVAL  <- 500
 params$OUTPUT_VECTOR  <- file.path(tempdir(), "contours.shp")
 contours <- run_qgis(alg = "gdalogr:contour", params = params, load_output = TRUE, qgis_env = myenv)
 image(raster("data/AP_26958_FBS_F0060_RT2.dem.tif"))
 lines(as(contours, "Spatial"))
```

<a href="" class="image full"><img src="/images/2018-07-22-qgis-r-rqgis-fig-3.png" alt="Líneas de contorno generadas mediante RQGIS" title=""></a>

Como puedes ver, el paquete RQGIS provee una interfaz de fácil uso que permite acceder a más de 1000 módulos de geoprocesamiento disponibles en QGIS y en aplicaciones externas incluyendo GRASS, SAGA y GDAL, todo desde la misma consola de R. El siguiente video tutorial muestra RQGIS en acción:

<iframe width="750" height="422" src="https://www.youtube.com/embed/H_mr2JPxmiY" frameborder="0" allowfullscreen></iframe>

<br>

Si aún no estás suscrito a mi canal de Youtube, *suscríbete ahora!*. En los próximos posts presentaré otros paquetes avanzados que expanden las capacidades espaciales de R a través de una mayor integración con herramientas asociadas a QGIS, así que no te los pierdas! Los posts ya están listos y estaré publicándolos en las próximas semanas.

**Nota:** 

Si deseas desarrollar tus habilidades para el procesamiento y análisis de datos geoespaciales usando el lenguaje R, he preparado un *curso online* que estará disponible de manera gratuita hasta Diciembre 31, 2018. En este curso primero presento los fundamentos básicos del lenguaje R y luego explico mediante ejercicios prácticos ... (importación/exportación de datos espaciales, clases y funciones de R para datos espaciales, integración con software SIG, visualización, etc.) herramientas que te ayudarán a xxx eficientemente tareas de SIG comunes y resolver problemas xxx eficientemente. Aquí te dejo el *link de acceso a este curso online gratuito*. Regístrate ahora!


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

