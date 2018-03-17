---
layout      : post-es
title       : "Integración avanzada de QGIS y R II: pqgisr"
date        : 2018-08-22 11:02:52
categories  : blog es
tags        : R SIG QGIS 
image       : 2016-12-11-skywatch-r-mini.jpg
published   : false
---

Continuando con esta serie de posts sobre cómo integrar QGIS con el lenguaje R, en esta entrada vamos a aprender sobre `pqgisr`, un paquete experimental de R que nos ayuda a visualizar datos geospaciales de manera rápida y sencilla usando el canvas (o ventana) de QGIS típico, desde una sesión de R. Primero veremos cómo hacer la instalación de pqgisr, que es un poco diferente al proceso usual de instalación de paquetes en R. Luego miraremos varios ejemplos demostrando las principales funcionalidades de pqgisr y conoceremos sus ventajas y desventajas.

No olvides que mi **curso online gratuito sobre Análisis de Datos Espaciales con el Lenguaje R** va a comenzar muy pronto! El curso iniciará en septiembre 1 de este año y estará disponible **gratis solo hasta diciembre 31**. Este curso amplía el tema de esta entrada del blog y explica también las distintas facilidades de R para manejo y procesamiento de datos geoespaciales. Al final de este post puedes encontrar el link para acceder a este curso gratuito.

Ahora aprendamos sobre pqgisr!

<!--more-->

<a href="" class="image full"><img src="/images/2016-12-11-skywatch-r-fig-0.png" alt="Integración avanzada de QGIS y R - pqgisr" title=""></a>

### **pqgisr: Qgis from Python via rPython package**

`pqgisr` tiene algunos requerimientos particularidades que debemos tener en cuenta. Este paquete solamente corre en Linux (y posiblemente en Mac) ya que depende del paquete rPython que no está disponible para Windows. Si eres un usuario de Windows y deseas probar pqgisr, te sugiero que intentes correr Linux usando una máquina virtual. Mi favorita es [OSGeo-Live] que corre sobre Lubuntu, una distribución basada en Ubuntu, y contiene varias aplicaciones geoespaciales open source ya preinstaladas.

Para instalar y correr OSGeo-Live necesitarás un software de virtualización como por ejemplo [Oracle VM VirtualBox] que igualmente es libre y open source. Las [instrucciones para correr OSGeo-Live en VirtualBox] son fáciles de seguir y siempre me han funcionado sin ningún problema.

**Instalación del paquete pqgisr**

Antes de instalar y ejecutar pqgisr es necesario instalar en R algunos paquetes auxiliares:

```r
install.packages(c("devtools", "pathological", "wkb", "base64enc"))
```
<br>

Luego necesitas instalar el paquete rPython:
  
```r
install.packages("rPython")
```
<br>

Es posible que si la configuración del paquete rPython falla aparezca un error como el que se muestra a continuación:
  
```
** package 'rPython' successfully unpacked and MD5 sums checked
 a specific python version to use was not provided
 defaulting to the standard python in the system
 could not locate python-config
 ERROR: configuration failed for package 'rPython'
 * removing '/usr/local/lib/R/site-library/rPython'
```
<br>

En ese caso abre una terminal de comandos de Linux e instala el paquete python-dev. En Ubuntu:
  
```
sudo apt-get install python-dev
```
<br>

Una vez instalado python-dev, intenta instalar el paquete rPython package en R de nuevo:
  
```r
install.packages("rPython")
```
<br>

Para instalar pqgisr, necesitas ir al sitio web del paquete y luego descargar el código fuente desde el repositorio de pqgisr in Gitlab o alternativamente clonar el repositorio:

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-1.png" alt="pqgisr repository at Gitlab" title=""></a>

Para las instrucciones que se muestran en seguida asumo que tú simplemente descargaste el archivo comprimido, la cual es la opción más sencilla, especialmente para usuarios que no están familiarizados con el uso de sistemas de control de versionamiento como Git.

Una vez hayas descargado pqgisr desde el repositorio, descomprime el archivo y luego carga pqgisr en una sesión de R con el comando `devtools::load_all()` indicando la carpeta descomprimida:
  
```r
devtools::load_all("~/Downloads/pqgisr-master-871d81c4617bc5b5c1454a8740f472212cd6e33d")
```

<br>


**Cómo usar pqgisr**

Después de cargar pqgisr, debemos iniciar una instancia de QGIS usando el comando `init_qgis()` (Nota: puede que veas algunos mensajes de error y warnings pero estos errores no evitan que pqgisr funcionen):
  
```r
init_qgis()
```

<br>

A continuación podemos cargar capas que van a ser adicionadas al canvas de mapas de QGIS. Para mapas base y capas vector podemos usar los comandos `add_tile_layer()` y `add_ogr_layer()`, respectivamente:

```r
tiles <- add_tile_layer()
 shp <- add_ogr_layer("data/llanos_latlon_col_v3.shp")
```

<br>

Luego simplemente escribimos `qgis` en la consola para desplegar el canvas con las capas cargadas:

```r
qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-2.PNG" alt="Lanzando el canvas de mapas de QGIS con pqgisr" title=""></a>


Haciendo clic derecho sobre el nombre de una capa veremos que aparece un menú contextual mostrando opciones para hacer zoom a la extensión de la capa y para cambiar el estilo o simbología de la misma:

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-3.png" alt="Haciendo zoom a la capa vector" title=""></a>

Cuando se selecciona la segunda opción, se abre la ventana Style Layer que es la misma que se despliega en QGIS. Acá se observa la ventana de Style Layer de QGIS 2.14 que es la versión instalada en OSGeo-Live 10.5: 

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-4.png" alt="Cambia el estilo de renderizado de la capa" title=""></a>

Ten en cuenta además que igualmente es posible prender y apagar las capas y cambiar la posición de una capa arrastrándola hasta la posición deseada en el panel Layers en la parte izquierda del canvas. Así mismo, con la rueda del mouse también se puede hacer acercamiento y alejamiento del zoom.

Para enviar nuevos comandos a la instancia de QGIS para ejecutar otras acciones primero tienes que cerrar el canvas de QGIS, para lo cual hay varias alternativas: hacer clic en la x que aparece en la esquina superior derecha del canvas, ir al menú File y hacer clic en Exit, o usar la combinación de teclas Ctrl+Q.

Las capas que ya están cargadas se pueden remover del canvas con la función `remove_layer()`. En el siguiente fragmento de código nota que estoy adicionando una nueva capa la cual está proyectada en un sistema de referencia de coordenadas diferente del de las capas anteriores. Esto no es problema ya que la capa es automáticamente reproyectada al vuelo:

```r
remove_layer(shp)
 shp2 <- add_ogr_layer("data/mpios_llanos_col_v3_epsg3117_v1.shp")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-5.png" alt="Carga una capa vector" title=""></a>

En los anteriores ejemplos cargué capas al canvas indicando la ruta del archivo. Sin embargo, también es posible cargar datos geoespaciales que han sido importados previamente a R como objetos de clase Spatial\*DataFrame (*: Points, Lines, Polygons). Este tipo de objetos pueden ser cargados mediante la función `add_sp_layer()`:

```r
library(raster)
 spdf <- shapefile("data/cities.shp")
 shp3 = add_sp_layer(spdf)
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-6.png" alt="Cargar un objeto de clase SpatialPolygonsDataFrame" title=""></a>

De otra parte, los archivos raster pueden ser cargados al canvas de mapas usando `add_gdal_layer()`:
  
```r
rst = add_gdal_layer("data/mod11a1_2000_4.tif")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-7.png" alt="Cargar un archivo raster" title=""></a>

A la fecha, la opción 'Change Style' no funciona aún para capas raster. Ten en cuenta que es posible modificar la simbología de una capa raster en QGIS y guardar el archivo de estilo .qml antes de cargar la capa en R con el paquete pqgisr. En el siguiente ejemplo el estilo de una capa raster, que fue modificado previamente en QGIS, es desplegado por pqgisr de la manera esperada:
  
```r
remove_layer(rst)
 rst2 = add_gdal_layer("data/c_2000_2001_1000m_epsg4326_clip_rec_2.rst")
 qgis
```
<br>

<a href="" class="image full"><img src="/images/2018-08-22-qgis-r-pqgisr-fig-8.png" alt="Carga un raster con un estilo modificado" title=""></a>

En general, el paquete pqgisr nos evita el trabajo de tener que gastar tiempo escribiendo líneas de código para cambiar una paleta de colores o interrumpir nuestros flujos de trabajo en R solo para exportar y abrir los datos geográficos en una plataforma SIG. A pesar de sus limitaciones (e.g., dificultad para cambiar el estilo de una capa raster, dependencia del paquete rPython que no está disponible para Windows), pqgisr nos ofrece una ayuda muy útil para la rápida visualización de capas geoespaciales y la personalización de la simbología de capas vectoriales. Si quieres probar el paquete, acá te dejo el [link para descargar los datos usados en el tutorial] con algunos recursos adicionales.

Si tienes dudas sobre cómo funciona pqgisr y particularmente sobre cómo llevar a cabo la instalación, mira el siguiente video: 

<iframe width="750" height="422" src="https://www.youtube.com/embed/H_mr2JPxmiY" frameborder="0" allowfullscreen></iframe>

<br>

**Suscríbete a mi canal de YouTube!** si no lo has hecho aún. En el próximo post aprenderemos sobre otro paquete de R que ofrece la posibilidad de manejar *remotamente* las funcionalidades de procesamiento y visualización de QGIS Desktop directamente desde una sesión de R, así que no te lo pierdas! 

<br>

**Accede al curso en línea de Análisis de Datos Espaciales con el Lenguaje R** 

Si deseas


<br>

**También te puede interesar:**

&#42; [Integración avanzada de QGIS y R I: RQGIS]

<a id="comments"></a>

[pqgisr repository]: https://gitlab.com/b-rowlingson/pqgisr
[Oracle VM VirtualBox]: https://www.virtualbox.org/
[OSGeo-Live]: https://live.osgeo.org/en/index.html
[instrucciones para correr OSGeo-Live en VirtualBox]: https://live.osgeo.org/en/quickstart/virtualization_quickstart.html
[link para descargar los datos usados en el tutorial]: https://www.dropbox.com/sh/97ggktfh0zd1ghk/AABSfUKbZmY9nH_iQwfb96Gpa?dl=0
[Integración avanzada de QGIS y R I: RQGIS]: /blog/es/2018/07/22/qgis-r-rqgis-es.html

