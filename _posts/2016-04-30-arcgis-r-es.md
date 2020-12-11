---
layout: post-es
title:  "arcgisbinding: Evaluando la nueva interfaz de ArcGIS para el lenguaje R"
date:   2016-04-30 11:02:52
categories: blog es
tags: R ArcGIS SIG
image: 2016-04-30-arcgis-r-mini.jpg
published: true
---

Hace un par de meses ESRI hizo pública una nueva librería para conectar ArcGIS y R, la cual fue diseñada con el propósito de facilitar el manejo y procesamiento de datos de ArcGIS para los usuarios de R, y al mismo tiempo, hacer más sencillo para los usuarios de ArcGIS la incorporación de las poderosas herramientas de análisis de R en sus flujos de trabajo.

Esta nueva librería parece bastante prometedora, por lo cual he escrito un breve tutorial para aprender, e igualmente para probar, las capacidades de la misma para integrar dos de los más importantes proyectos de los campos de los SIG y el análisis de datos. En este post describo cómo instalar la librería y cómo crear y ejecutar una herramienta que combina datasets de ArcGIS con las funcionalidades existentes en algunos paquetes de R para abordar el modelamiento de distribución de especies dentro del ambiente de ArcGIS. Arranquemos! 

<!--more-->

<img src="/images/2016-04-30-arcgis-r-fig-0.png" alt="" title="" style="width:750px">

<br>

### **Instala la librería puente entre ArcGIS y R**

Primero, ingresa a [https://r-arcgis.github.io/] y luego entra a [r-bridge-install]. Haz click en el botón ‘Download ZIP’ para descargar el contenido del repositorio en el archivo 'r-bridge-install-master.zip' y descomprímelo en una carpeta en tu computador.

Inicia ArcMap (para versiones ArcGIS 10.3.1 o superior) como administrador y usa la ventana de Catálogo para navegar a la carpeta donde se encuentra el archivo descomprimido. Allí debes encontrar el toolbox llamado ‘R Integration Python Toolbox’, el cual contiene cuatro scripts. Haz doble click en el script 'Install R bindings' y luego simplemente presiona OK para ejecutarlo. Este script descarga e instala la [más reciente versión de un paquete de R llamado ‘arcgisbinding’], el cual provee clases y funciones para importar, manejar y exportar datos de ArcGIS usando el lenguaje R. Para verificar que la librería de conexión entre ArcGIS y R ha sido instalada exitosamente, puedes ejecutar los scripts 'R Version' y 'R Installation Details'.

Si abres el programa de R o RStudio vas a encontrar que el paquete ‘arcgisbinding’ fue instalado en tu librería de paquetes de R. Ten en cuenta que el puente entre ArcGIS y R también puede ser instalado usando ArcGIS Pro 1.1 (o superior).

El siguiente video muestra la instalación paso a paso de la librería puente entre ArcGIS y R: 

<iframe width="750" height="422" src="https://www.youtube.com/embed/7Tft6yubEts" frameborder="0" allowfullscreen></iframe>

<br>

Ten presente también que, como alternativa, puedes descargar el [archivo zip binario para Windows] del paquete ‘arcgisbinding’ e instalarlo en R manualmente.


### **Crea un script de R**

Vamos a seguir las plantillas disponibles en la carpeta ‘scripts’ en el repositorio [r-sample-tools] para crear un script para modelación de distribución de especies usando la funcionalidad suministrada por los paquetes ‘arcgisbinding’ y [dismo]. Primero necesitamos cargar los paquetes requeridos y leer los parámetros de entrada y salida:

```
tool_exec <- function(in_params, out_params)
{
  if (!requireNamespace("dismo", quietly = TRUE))
    install.packages("dismo")
  if (!requireNamespace("raster", quietly = TRUE))
    install.packages("raster")
  require(dismo)
  require(raster)
  
  occurrence_dataset = in_params[[1]]
  continuous_rasters_folder = in_params[[2]]
  biome_raster = in_params[[3]]
  model = in_params[[4]]
  
  out_raster = out_params[[1]]
  out_table = out_params[[2]]
  out_shp = out_params[[3]]
```
<br>

Luego vamos a abrir el shapefile (de puntos) de entrada (por ejemplo, datos de presencia de una especie de interes) usando la funcion `arc.open` del paquete ‘arcgisbinding’, y convertimos el dataset resultante en un objeto SpatialPointsDataFrame usando `arc.select` and `arc.data2sp`: 

```
  d <- arc.open(occurrence_dataset)
   occurrence <- arc.data2sp(arc.select(d))
```
<br>

A continuación procederemos a leer los archivos raster. Como `arc.open` aún no permite abrir capas raster (hasta la versión 1.0.0.118 de 'arcgisbinding'), voy a implementar la siguiente solución: los archivos raster que representan variables continuas (por ej., temperatura, precipitación) van a ser leídos de una carpeta que los contiene, mientras que un raster de una variable categórica (por ej., bioma) va a ser leído de un archivo aparte. 

```
  # lee los rasters de variables continuas desde una carpeta
  rfiles1 <- list.files(path = continuous_rasters_folder, full.names = TRUE)  
  rasters1 <- stack(rfiles1[-grep(".aux", rfiles1)])

  # lee el raster categórico (bioma) desde un archivo aparte 
  raster2 <- raster(gsub("/", "\\\\", biome_raster))
```
<br>

Después necesitamos crear un objeto de clase RasterStack con todas las capas raster continuas y categóricas que van a ser usadas como variables predictoras en el modelo, y luego extraemos los valores del RasterStack en las localizaciones (de punto) de ocurrencia o presencia de la especie: 

```
  predictors <- stack(rasters1, raster2)
   presvals <- as.data.frame(extract(predictors, occurrence))
```
<br>

Existen varios modelos que pueden ser implementados para modelación de distribución de especies. Para el modelo ‘bioclim’, por ejemplo, podemos usar el siguiente código:  

```
  if(model == "bioclim"){
    fitmodel <- bioclim(subset(presvals, select = -c(biome)))
    p <- predict(predictors, fitmodel)
  }
```
<br>

Para la implementación de los modelos ’domain’, ‘glm’ (modelos lineales generalizados) y ‘mahal’ (Mahalanobis), puedes mirar el [script completo en este link]. Otros métodos de modelación como MaxEnt o randomForests pueden ser implementados fácilmente de manera similar en este script.

Finalmente, vamos a usar `arc.write` para exportar como tabla y como shapefile unas salidas resultantes del paso ‘extract’ ejecutado previamente. Para exportar el raster con la distribución de especies predicha por el modelo, vamos a tener que usar la función `writeRaster` del paquete ‘raster’: 

```
  if (!is.null(out_raster) && out_raster != "NA")
    writeRaster(p, out_raster)
  if (!is.null(out_table) && out_table != "NA")
    arc.write(out_table, presvals)
  if (!is.null(out_shp) && out_shp != "NA")
    arc.write(out_shp, presvals, coords = coordinates(occurrence), shape_info = arc.shapeinfo(d))
  return(out_params)
}

```
<br>

Este script muestra el uso de algunas de las funciones disponibles para cargar y manejar datos entre ArcGIS y R, tales como `arc.open`, `arc.select`, `arc.data2sp`, `arc.shapeinfo` y  `arc.write`. Para información sobre otras funcionalidades, puedes revisar la [documentación del paquete ‘arcgisbinding’].

### **Crea un toolbox de ArcGIS**

Ahora creemos un toolbox en ArcGIS para poder ejecutar nuestro script de manera interactiva. En la ventana del Catalog en ArcGIS, navega a 'Toolboxes' - 'My Toolboxes' y haz click derecho en 'My Toolboxes'. Ve a 'New', haz click en 'Toolbox' y suministra un nombre para el nuevo toolbox.

Luego haz click derecho en el nuevo toolbox, y ve a 'Add' - 'Script...'. En las ventanas 'Add Script', ingresa un nombre y una etiqueta, y selecciona el script que creamos previamente.

<a href="/images/2016-04-30-classification-r-fig-1.jpg" class="image centered"><img src="/images/2016-04-30-arcgis-r-fig-1.jpg" alt="" title="Crea un toolbox de ArcGIS" style="width:750px"></a>

En la última ventana de ‘Add Script’ es necesario ingresar las propiedades de los parámetros de entrada y salida de nuestro script. En este caso tenemos cuatro parámetros de entrada y tres de salida. Ingresa las propiedades de nombre (‘Display Name’) y  tipo de datos (‘Data Type’) de cada parámetro como se muestra en la imagen siguiente. También asegúrate de definir la propiedad de dirección (‘Direction’) de cada parámetro (es decir, 'Input' o 'Output') de manera apropiada. Cuando termines haz click en ‘Finish’.

<a href="/images/2016-04-30-classification-r-fig-2.jpg" class="image centered"><img src="/images/2016-04-30-arcgis-r-fig-2.jpg" alt="" title="Ingresa la información de los parámetros de entrada y de salida"></a>

<br>

### **Carga los datos y ejecuta la herramienta de R ArcGIS**

Para este tutorial vamos a usar unos [datos de ejemplo] que consisten de un conjunto de ocho archivos raster que representan variables continuas (variables bioclimáticas de la [base de datos WorldClim], incluyendo temperatura y precipitación), un archivo raster de una variable categórica (correspondiente a datos de biomas terrestres de [WWF]), y un shapefile de puntos que contiene registros de presencia del Perezoso de tres dedos (*Bradypus sp.*), una especie de mamífero arbóreo que habita en Suramérica y Centroamérica. El shapefile fue generado a partir de datos que vienen incluidos en el paquete ‘dismo’. El objetivo de este ejercicio es modelar la distribución espacial de *Bradypus sp.* usando los datos de clima y bioma como predictores.

Después de cargar los datos en ArcMap, debes ir en la ventana del Catalog al toolbox creado previamente. Haz click derecho en el script y luego haz click en ‘Open...’ (o simplemente haz doble click). En la interfaz que se abre, selecciona el shapefile de datos de presencia de la especie (‘bradypus.shp’), la carpeta que contiene los rasters continuos, y el archivo raster del bioma. Luego ingresa el modelo que deseas ejecutar y suministra los parámetros para los archivos de salida (el raster con la predicción del modelo, y la tabla y shapefile resultantes). Corre el script haciendo click en OK. En las rutas que definiste previamente debes encontrar los archivos resultantes esperados una vez el script finalice su ejecución.

<a href="/images/2016-04-30-arcgis-r-fig-3.jpg" class="image centered"><img src="/images/2016-04-30-arcgis-r-fig-3.jpg" alt="" title="Ejecuta la herramienta de ArcGIS R" style="width:750px"></a>

Eso es todo! Para más información puedes ver el siguiente video que explica la creación y ejecución de la herramienta de R ArcGIS para modelación de distribución de especies:

<iframe width="750" height="422" src="https://www.youtube.com/embed/MMgBvRrBtBg" frameborder="0" allowfullscreen></iframe>

<br>


### **Observaciones finales**

La nueva librería publicada por ESRI ofrece varias características interesantes que permiten la integración entre ArcGIS y el lenguaje R. Primero, la instalación de paquetes se puede realizar desde la herramienta  de R ArcGIS, lo cual elimina trabajo adicional por parte del usuario. Una segunda funcionalidad atractiva es la habilidad de generar varios productos de salida simultáneamente, lo cual incrementa la eficiencia de estas herramientas al permitir la posible creación de varias tablas, gráficas y datasets a partir del mismo script. Adicionalmente, encontrar problemas en el script se facilita mediante la impresión y despliegue de los errores en las típicas ventanas de ejecución de scripts de ArcGIS.

Quizá la principal desventaja de las herramientas de R ArcGIS a la fecha es la falta de soporte para leer y escribir archivos raster de manera nativa a través de `arc.open` y `arc.write` respectivamente, aunque existen alternativas como la que presenté anteriormente. Es de esperar que los desarrolladores de ESRI incorporen esta característica en las próximas versiones del paquete ‘arcgisbinding’. Por otra parte, [crear una interfaz gráfica para un script de R en QGIS] es mucho más simple que en ArcGIS, pero la creación de un toolbox en ArcGIS no es complicado y ofrece una gran flexibilidad.

Para aprender más acerca de modelación de distribución de especies y de los modelos implementados en el script, te invito a leer el vignette [Species distribution modeling with R] del paquete ‘dismo’. Puedes encontrar el script completo de este post [en este link] y puedes descargar el toolbox y los datos de ejemplo usados en este tutorial [desde este repositorio de GitHub].

El paquete ‘arcgisbinding’ está todavía en versión beta por lo que puede ser un poco inestable. Si intentas este tutorial cuéntame qué tal te va. Buena suerte!

<br>

**También te puede interesar:**

&#42; [Integración de QGIS y R: Un ejemplo con muestreo espacial estratificado]

<a id="comments"></a>

[https://r-arcgis.github.io/]: https://r-arcgis.github.io/
[r-sample-tools]:  https://github.com/R-ArcGIS/r-sample-tools
[dismo]: https://cran.r-project.org/web/packages/dismo/index.html
[r-bridge-install]: https://github.com/R-ArcGIS/r-bridge-install
[más reciente versión de un paquete de R llamado ‘arcgisbinding’]: https://github.com/R-ArcGIS/r-bridge/releases/latest
[archivo zip binario para Windows]: https://github.com/R-ArcGIS/r-bridge/releases/latest
[script completo en este link]: https://gist.github.com/amsantac/63884509591810bdd6d9fbafa407ae2e
[Species distribution modeling with R]: https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf
[documentación del paquete ‘arcgisbinding’]: https://github.com/R-ArcGIS/r-bridge
[base de datos WorldClim]: http://www.worldclim.org/bioclim
[WWF]: http://www.worldwildlife.org/pages/conservation-science-data-and-tools
[datos de ejemplo]: https://github.com/amsantac/extras
[en este link]: https://gist.github.com/amsantac/63884509591810bdd6d9fbafa407ae2e
[crear una interfaz gráfica para un script de R en QGIS]: /blog/en/2015/10/31/qgis-r.html
[Integración de QGIS y R: Un ejemplo con muestreo espacial estratificado]: /blog/en/2015/10/31/qgis-r.html
[desde este repositorio de GitHub]: https://github.com/amsantac/extras

