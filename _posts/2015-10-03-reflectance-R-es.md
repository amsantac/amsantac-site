---
layout: post-es
title:  "Prepara archivos para creación de imágenes de reflectancia en CLASlite usando R"
date:   2015-10-03 11:02:52
categories: blog es
tags: R PercepcionRemota CLASlite reflectancia landsat
image: 2015-10-03-reflectance-r-mini.jpg
published: true
---

Una tarea muy común cuando se procesan imágenes satelitales para producir mapas de cobertura o analizar cambios multitemporales es la conversión de los datos registrados en cada píxel de la imagen a valores de reflectancia en la superficie. Este proceso se conoce como calibración a valores de reflectancia en superficie e involucra la calibración radiométrica y la corrección de distorsiones causadas por la atmósfera. 
  
Como se mencionó en la [anterior entrada de mi blog], estas labores de procesamiento se pueden llevar a cabo con el [programa CLASlite]. En este post explico cómo automatizar la creación de los archivos de textos requeridos por CLASLite para la calibración de la imagen.

<!--more-->

<img src="/images/2015-10-03-reflectance-r-fig-0.jpg" alt="" title="" style="width:800px">
  
Para la conversión a reflectancia en superficie mediante el procesamiento por lotes, es necesario preparar un archivo de texto en formato CSV con 18 columnas con los siguientes nombres: "Input_FileName", "Date", "Time", "Gain_Settings", "Satellite", "Lead_File", "Therm_File", "QA_File", "Output_File", "GeoTIFF", "Proc_sys", "Reduce_masking", "no_masking", "fmask", "cldpix", "sdpix", "snpix" y "cldprob". En el folder "templates" que se encuentra dentro del directorio donde fue instalado CLASlite se puede encontrar el archivo 'step1_template.csv' con la plantilla para crear este archivo.

"Input_FileName" se refiere a las rutas absolutas de las carpetas que contienen las imágenes a ser procesadas. "Gain_Settings" se refiere a la configuración de la ganancia (alta o baja) usada para la optimización de la sensibilidad del sensor en el satélite. "Therm_File" y "QA_File" se refieren a las rutas absolutas de los archivos de las bandas termicas y de la calidad de la imagen (e.g., para Landsat 8). "Output_File" se refiere al nombre que se desea para el archivo resultante de la reflectancia en superficie, mientras que "Proc_sys" se refiere a la versión del software de procesamiento (e.g., LPGS o NLAPS usado por [USGS]). La descripción de las otras columnas del archivo requeridas por CLASlite pueden [verse aquí].

En [este link] puedes encontrar un script en lenguaje R llamado [reflectanceImgTable4csv.R] que preparé para facilitar la creación del archivo CSV para CLASLite. El script lee desde el archivo de metadatos la información requerida para la correspondiente imagen. En la siguiente sección describo cómo correr el script y cómo usar en CLASlite el archivo CSV resultante para producir imágenes con valores digitales convertidos a reflectancia en superficie.

### **Cómo correr el script**

Primero es necesario crear una lista de las carpetas que contienen las imágenes Landsat ([ya apiladas]) que van a ser procesadas. Asumamos que tenemos un grupo de imágenes Landsat para un conjunto de años para los cuales ya hemos creado con CLASlite los archivos ‘raw’ (archivos crudos) y ‘therm’ (bandas en el rango térmico del espectro) como se muestra en [mi anterior post]:

<img src="/images/2015-10-03-reflectance-r-fig-1.png" alt="Input folder" title="Input folder" style="width:800px">

Usemos R para crear la lista de carpetas:

```
setwd("C:/images/2000")   # define el directorio de trabajo
 foldersList <- normalizePath(list.dirs(full.names = TRUE, recursive = FALSE))  # crea la lista de rutas absolutas a las carpetas
```
<br>

Leamos desde el [link en internet] el código fuente de la función `reflectanceImgTable4csv`:

```
source("https://raw.githubusercontent.com/amsantac/extras/gh-pages/code/reflectanceImgTable4csv.R")
```
<br>

Ahora necesitamos correr la función suministrando la lista de carpetas como primer parámetro. Para este ejemplo voy a establecer el valor del parámetro `no_masking` como 1, con el fin de ordenar a CLASlite que no enmascare las nubes y las sombras de nubes. Para los otros parámetros voy a usar los valores por defecto. Como último paso en R, tenemos que exportar el objeto de clase `data.frame` resultante como un archivo en formato CSV (i.e., comma separated values). Indicamos que los nombres de las filas no deben ser incluidos en el archivo y que las cadenas de caracteres no deben ser rodeadas por comillas:

```
outDF <- reflectanceImgTable4csv(foldersList, no_masking = 1)
 write.table(outDF, "reflectance_2000.csv", row.names = FALSE, quote = FALSE, sep = ", ")
```
<br>

### **De vuelta en CLASlite**

Abre CLASlite y haz click en "1. Calibrate Image". Navega en las carpetas e ingresa el directorio de entrada ('Input Directory') y el directorio de salida ('Output Directory'), los cuales pueden ser iguales y corresponden a la carpeta para cada año, en este ejemplo. Haz click en "Load". En el nuevo cuadro de diálogo selecciona el número de imágenes a ser procesadas (e.g., 12) y haz click en "OK". 

<img src="/images/2015-10-03-reflectance-r-fig-2.png" alt="Calibrar imagen en CLASlite 1" title="Calibrar imagen en CLASlite 1" style="width:800px">

En la siguiente ventana haz click en "Load Table" para cargar la tabla. Busca y selecciona el archivo csv generado con R, y haz click en "Select". Los datos de los parámetros deben ser llenados automáticamente en la tabla mostrada en esa ventana:  

<img src="/images/2015-10-03-reflectance-r-fig-3.png" alt="Calibrar imagen en CLASlite 2" title="Calibrar imagen en CLASlite 2" style="width:800px">

Finalmente haz click en "Run" para crear las imágenes con valores convertidos a reflectancia en superficie para la lista de imágenes que suministraste. Después de que CLASlite procese todos los archivos, tu deberías ver en cada carpeta una nueva imagen marcada con "refl" al final del nombre la cual corresponde a la imagen con corrección por distorsiones debidas a la atmósfera: 

<img src="/images/2015-10-03-reflectance-r-fig-4.png" alt="Output folder" title="Output folder" style="width:800px">

<br>

### **Lo que el script de R hace**

En las siguientes líneas voy a dar un breve resumen acerca de lo que hace el [script reflectanceImgTable4csv.R].

Primero se crea un objeto de clase `data.frame` con las 18 columnas requeridas por CLASlite:

```
outDF <- data.frame(matrix(data = NA, nrow = length(foldersList), ncol = 18))
 colnames(outDF) <- c("Input_FileName", "Date", "Time", "Gain_Settings", "Satellite", "Lead_File", "Therm_File",
                              "QA_File", "Output_File", "GeoTIFF", "Proc_sys", "Reduce_masking", "no_masking", "fmask", 
                               "cldpix", "sdpix", "snpix", "cldprob")
```
<br>

Luego se asignan los valores para los parámetros `GeoTIFF`, `Reduce_masking`, `no_masking`, `fmask`, `cldpix`, `sdpix`, `snpix` y `cldprob` con base en lo que defina el usuario o se toman los valores por defecto si el usuario no indica algo diferente:

```
outDF[, "GeoTIFF"] <- GeoTIFF
 outDF[, 12:18] <- t(apply(outDF[, 12:18], 1, function(x){c(Reduce_masking, no_masking, fmask, cldpix, sdpix, snpix,
                                                                                           cldprob)}))
```
<br>

Para cada carpeta en la lista de carpetas, la ruta absoluta de cada archivo original de la imagen es almacenada en la columna `Input_FileName` del data frame: 

```
rawImg1 <- grep("raw", list.files(folder, full.names = TRUE), value = TRUE)[1] 
 outDF[i, "Input_FileName"] <- gsub("/", "\\", rawImg1, fixed = TRUE)
```
<br>

El archivo que contiene los metadatos de la imagen es leído para extraer la fecha de adquisición de la imagen...

```
mtlTxt <- grep("MTL.txt", list.files(folder, full.names = TRUE), value = TRUE)  
 mtl <- readLines(mtlTxt)
 date1 <- strsplit(mtl[grep("DATE_ACQUIRED", mtl)], "= ")[[1]][2]
 outDF[i, "Date"] <- format(as.Date(date1), "%d%m%Y")
```
<br>

... y la hora exacta de la toma:

```
time1 <- strsplit(mtl[grep("SCENE_CENTER_TIME", mtl)], "= ")[[1]][2]
 time2 <- paste(unlist(strsplit(time1, ":"))[1:2], collapse = "")
 outDF[i, "Time"] <- gsub("\"", "", time2)
```
<br>

Luego se extrae la plataforma satelital del archivo de metadatos:

```
sid1 <- strsplit(mtl[grep("SPACECRAFT_ID", mtl)], "= ")[[1]][2]
 sid2 <- gsub("\"", "", sid1)
 if(sid2 == "LANDSAT_8") Satellitei <- 0
 if(sid2 == "LANDSAT_7") Satellitei <- 1
 if(sid2 == "LANDSAT_5") Satellitei <- 2
 if(sid2 == "LANDSAT_4") Satellitei <- 3
 if(sid2 == "ALI") Satellitei <- 4
 if(sid2 == "ASTER") Satellitei <- 5
 if(sid2 == "SPOT4") Satellitei <- 6
 if(sid2 == "SPOT5") Satellitei <- 7
 outDF[i, "Satellite"] <- Satellitei
```
<br>

A continuación se extrae la configuración de la ganancia para las bandas 1 a 5 y la banda 7 para las imágenes de Landsat 7:

```
gains <- NULL
 if (Satellitei == 1){
  for (band in c(1:5, 7)){
   bandGain_1 <- strsplit(mtl[grep(paste0(" GAIN_BAND_", band), mtl)], "= ")[[1]][2]
   bandGain_2 <- gsub("\"", "", bandGain_1)
   gains <- c(gains, bandGain_2)
  }
  outDF[i, "Gain_Settings"] <- paste(gains, collapse="")
}
```    
<br>

La versión del software de procesamiento se lee y se trata como una variable booleana (i.e., 0 para LPGS, 1 para NLAPS):

```
sys1 <- strsplit(mtl[grep("PROCESSING_SOFTWARE_VERSION", mtl)], "= ")[[1]][2]
 sys2 <- strsplit(gsub("\"", "", sys1), "_")[[1]][1]
 if(sys2 == "LPGS") outDF[i, "Proc_sys"] <- 0
 if(sys2 == "NLAPS") outDF[i, "Proc_sys"] <- 1
```
<br>

Luego se leen los nombres de los archivos con las bandas térmicas de la imagen y se almacenan en la columna `Therm_File` del data frame:

```
ThermImg1 <- grep("therm", list.files(folder, full.names = TRUE), value = TRUE)[1]
 outDF[i, "Therm_File"] <- gsub("/", "\\", ThermImg1, fixed = TRUE)
```    
<br>

Para imágenes de Landsat 8 también se extrae la ruta absoluta del archivo de calidad de la imagen:

```
if (Satellitei == 0){
   QAImg1 <- grep("_QA", list.files(folder, full.names = TRUE), value = TRUE)[1]
   outDF[i, "QA_File"] <- gsub("/", "\\", QAImg1, fixed = TRUE)
}
```    
<br>

Finalmente se asignan los nombres de los archivos de salida:

```
outDF[i, "Output_File"] <- sub("_therm", "_refl", outDF[i, "Therm_File"])
```    
<br>

El propósito de este script de R es hacer más eficiente la creación de los archivos de texto requeridos por el programa CLASlite para producir imágenes de reflectancia en superficie. Este script ha sido probado con imágenes Landsat en un sistema operativo Windows. Si llegas a utilizar el script, agradezco tu retroalimentación para mejorarlo. Espero que este post te haya sido útil! 

<br>

**También te puede interesar:**

&#42; [Usando R para el apilamiento de imágenes en CLASlite]

<a id="comments"></a>

[anterior entrada de mi blog]:      /blog/es/r/2015/09/05/stacking-R-es.html
[mi anterior post]:                 /blog/es/r/2015/09/05/stacking-R-es.html 
[programa CLASlite]:                http://claslite.carnegiescience.edu/
[R language]:                       http://r-project.org
[USGS]:                             http://www.usgs.gov
[verse aquí]:                       https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[link en internet]:                 https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[Usando R para el apilamiento de imágenes en CLASlite]:                 /blog/es/r/2015/09/05/stacking-R-es.html
[este link]:                        https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[reflectanceImgTable4csv.R]:        https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
[script reflectanceImgTable4csv.R]: https://github.com/amsantac/extras/blob/gh-pages/code/reflectanceImgTable4csv.R
