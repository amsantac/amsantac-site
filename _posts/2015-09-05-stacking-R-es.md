---
layout: post-es
title:  "Usando R para el apilamiento de imágenes en CLASlite"
date:   2015-09-05 11:02:52
categories: blog es r
tags: R PercepcionRemota CLASlite stacking landsat
image: 2015-09-05-stacking-R-mini.png
published: false
---

[CLASlite] es un poderoso software de procesamiento de imágenes desarrollado por [Carnegie Institution for Science] que contiene herramientas para la calibración, preprocesamiento, corrección atmosférica, enmascaramiento de nubes, análisis de mezclas espectrales y clasificación. 

En este post describo cómo usar el [lenguaje R] para crear los archivos de texto requeridos por CLASlite para realizar el apilamiento (stacking) de imágenes a través de procesamiento por lotes. Esta es una aplicación simple para mostrarle a aquellos que están iniciando con R cómo hacer uso de funciones básicas de R tales como el listado de archivos y la implementación de bucles con el comando `for`.

<!--more-->

Usualmente el primer paso para el procesamiento de imágenes obtenidas en formato crudo es el apilamiento de las bandas individuales en un archivo único. CLASlite permite el apilamiento de bandas de imágenes Landsat a través de la herramienta ‘Prepare Landsat’, la cual puede ser accesada desde el menú 'Tools' - 'Prepare Landsat' en la interfaz gráfica de CLASlite:

<img src="/images/2015-09-05-stacking-R-fig-1.png" alt="Prepare Landsat Tool in CLASlite" title="Herramienta Landsat Tool en CLASlite" style="width:600px">

Una característica muy útil de CLASlite es la posibilidad de ejecutar diferentes tareas de preprocesamiento y procesamiento para varios archivos al tiempo a través de procesamiento por lotes. Por ejemplo, el procesamiento por lotes de la herramienta ‘Prepare Landsat’ requiere que el usuario suministre un archivo de texto en formato CSV que contenga una lista con las rutas absolutas de las carpetas de cada imagen Landsat a ser procesada. Cada carpeta debe contener todos los archivos individuales (ya descomprimidos) de las bandas de cada imagen, las cuales se obtienen usualmente de un proveedor como el [USGS].

CLASlite requiere que el archivo CSV contenga el texto "LANDSAT_Folder_Names" en la primera fila y la ruta absoluta de la carpeta de cada imagen en las siguientes filas, como se puede ver a continuación:

<img src="/images/2015-09-05-stacking-R-fig-2.png" alt="Prepare Landsat template" title="Plantilla de 'Prepare Landsat'" style="width:400px">

Puedes encontrar esta plantilla en la carpeta ‘templates’ dentro del directorio donde se realizó la instalación de CLASlite. Podemos crear una pequeña rutina en R que nos ayude a automatizar la creación de este archivo CSV evitando por tanto desperdiciar tiempo en una acción repetitiva como lo es copiar y pegar manualmente en un archivo de texto. Asumamos que tenemos un conjunto de imágenes de una región determinada que hemos almacenado separadamente por año, como sería el caso para un estudio de cambio de coberturas terrestres:

<img src="/images/2015-09-05-stacking-R-fig-3.png" alt="Folder structure" title="Folder structure" style="width:800px">

El propósito de nuestro script en R será listar todas las carpetas dentro de la carpeta de cada año que están contenidas en la carpeta ‘images’. Asumamos que hemos almacenado imágenes desde el año 2000 hasta el año 2014 en nuestro ejemplo, así que creemos un objeto de clase `integer` que liste la secuencia de años en este intervalo. Creemos también un objeto nulo donde iterativamente adicionaremos la lista de carpetas para cada año, y un objeto de clase `character` para almacenar la ruta con respecto la carpeta ‘images’:

```
years <- 2000:2014
 foldersList <- NULL
 path <- "C:/images"
```
<br>

Ahora podemos usar el comando `for` con el fin de crear un bucle para, primero, crear la ruta absoluta para la carpeta de cada año (`path_year`), listar las carpetas dentro de la carpeta `path_year` usando la función `list.dirs`, y luego añadir esta lista de carpetas al objeto `foldersList`. Esto será realizado iterativamente para cada año en la secuencia que llamamos `years`. Suena complicado ah? Pues la verdad el código es bastante simple:

```
for (year in years){
  path_year <- paste0(path, "/", year)
  foldersList <- c(foldersList, list.dirs(path_year, recursive = FALSE))
}
```
<br>

Finalmente podemos crear un objeto de clase `data.frame` para almacenar la lista de carpetas asignando el nombre requerido a la columna de datos (i.e., "LANDSAT_Folder_Names"):

```
foldersListDF <- data.frame("LANDSAT_Folder_Names" = foldersList)
```
<br>

Usualmente es recomendable escribir las rutinas como una función para facilitar su uso en el futuro. Esto requiere la definición de los parámetros requeridos que la función necesita para ser ejecutada. En este caso sólo dos parámetros son necesarios, la ruta a la carpeta superior y la secuencia de años. De esta forma, nuestra función, que he llamado aquí como `stackImgTable4csv`, puede ser definida de la siguiente forma:

```
stackImgTable4csv <- function(path, years){
  foldersList <- NULL
    for (year in years){
      path_year <- paste0(path, "/", year)
      foldersList <- c(foldersList, list.dirs(path_year, recursive = FALSE))
    }
  foldersListDF <- data.frame("LANDSAT_Folder_Names" = foldersList)
  return(foldersListDF)
}
```
<br>

Una vez definida la función de esta manera, ya sólo necesitamos llamar la función y suministrar los argumentos para cada uno de los parámetros y el nombre del objeto de salida (e.g., `outDDF`):

```
path <- "C:/images"
 years <- 2000:2014
 outDF <- stackImgTable4csv(path, years)
```
<br>

Luego podemos exportar el objeto resultante a un archivo CSV que será utilizado posteriormente en CLASlite. Para la función `write.csv` debemos indicar los datos que van a ser escritos y el nombre del archivo de salida (e.g., "stack_2000_2014.csv"). También debemos indicar que los nombres de las filas no deben ser escritos y que los textos no deben ser rodeados por comillas dobles. Lo anterior es muy importante para que el archivo CSV pueda ser leído correctamente por CLASlite:

```
write.csv(outDF, file = "stack_2000_2014.csv", row.names = FALSE, quote = FALSE)
```
<br>

Ahora podemos regresar a CLASlite y usar el archivo CSV que acabamos de crear. Abre CLASlite y haz click en ‘Tools’ - ‘Prepare Landsat’. Selecciona 'Batch Process' y haz clic en el botón 'Load File' para navegar y seleccionar el archivo CSV creado previamente. Finalmente haz clic en el botón 'Stack'. Como resultado del proceso de apilamiento, en la carpeta de cada imagen deberías encontrar archivos marcados con ‘raw’ (archivos crudos) y ‘therm’ (bandas en el rango térmico del espectro) al final del nombre:

<img src="/images/2015-09-05-stacking-R-fig-4.png" alt="Output folder" title="Ouput folder" style="width:800px">

Espero que este post te sea útil! En la siguiente entrada del blog explicaré cómo podemos usar R para crear automáticamente los archivos de texto requeridos por CLASlite para producir imágenes con correcciones por distorsión atmosférica. Hasta entonces! 



<a id="comments"></a>

[CLASlite]:                         http://claslite.carnegiescience.edu/
[lenguaje R]:                       http://r-project.org
[Carnegie Institution for Science]: https://carnegiescience.edu/
[USGS]:                             http://www.usgs.gov
[Prepare files for production of atmospherically-corrected imagery in CLASlite using R]: /blog/en/r/claslite/reflectance/landsat/2015/10/03/reflectance-R.html

