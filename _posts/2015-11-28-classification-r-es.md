---
layout: post-es
title:  "Clasificación de imágenes con RandomForests en R (y QGIS)"
date:   2015-11-28 11:02:52
categories: blog es
tags: R PercepcionRemota landsat QGIS SIG
image: 2015-11-28-classification-r-mini.jpg
published: true
---

El objetivo de este post es demostrar las capacidades de R para clasificar imágenes multiespectrales usando los [algoritmos conocidos como RandomForests]. Estos algoritmos son actualmente una de las técnicas que producen mejores resultados para la regresión y clasificación de datos. Aunque su interpretabilidad puede ser un tanto difícil, estos algoritmos son ampliamente populares debido a su habilidad para clasificar grandes cantidades de datos con una alta exactitud.

En las secciones siguientes describo cómo importar en R una imagen Landsat y cómo extraer los valores de los pixeles para entrenar y ajustar un modelo de RandomForests. También explico cómo acelerar la clasificación de las imágenes mediante procesamiento en paralelo. Finalmente presento cómo implementar estos algoritmos para clasificación de imágenes en [QGIS] usando los paquetes de R.

<!--more-->

<img src="/images/2015-11-28-classification-r-fig-0.png" alt="" title="" style="width:750px">

<br>

### **Importación de datos en R**

Para el propósito de este post, voy a realizar una clasificación de coberturas terrestres en una imagen de Landsat 7 (path 7 row 57, seis bandas) tomada en el año 2000 para la cual se ha efectuado la corrección por distorsiones atmosféricas, como se explica [en un post anterior en mi blog]. Se van a necesitar varios paquetes de R instalados, incluyendo: [rgdal], [raster], [caret], [randomForest] y [e1071]. Después de instalarlos carguemos los paquetes:

```
library(rgdal)
 library(raster)
 library(caret)
```
<br>

Ahora importemos la imagen Landsat en R como un objeto `RasterBrick` usando la función `brick` del [paquete ‘raster’]. Igualmente reemplacemos los nombres originales de las bandas (e.g., 'X485.0.Nanometers') con nombres más cortos (‘B1’ a ‘B5’, y ‘B7’): 

```
img <- brick("C:/data/landsat/images/2000/LE70070572000076EDC00/L7007057_20000316_refl")
 names(img) <- paste0("B", c(1:5, 7))  
```
<br>

Podemos generar una visualización RGB de la imagen Landsat en R usando el comando `plotRGB` para, por ejemplo, crear una composición en falso color RGB 4:5:3 (Infrarojo cercano - Infrarojo de onda corta - Rojo). Voy a usar la expresión `img * (img >= 0)` para convertir los valores negativos a cero:

```
plotRGB(img * (img >= 0), r = 4, g = 5, b = 3, scale = 10000)
```

<a href="/images/2015-11-28-classification-r-fig-1.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-1.JPG" alt="" title="Ploteando una imagen Landsat en RStudio"></a>

Previamente creé un conjunto de áreas de entrenamiento en un shapefile de polígonos (‘training_15.shp’), el cual contiene los identificadores para cada tipo de cobertura en una columna en la tabla de atributos llamada ‘class’ como se muestra a continuación:

<a href="/images/2015-11-28-classification-r-fig-2.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-2.JPG" alt="" title="Areas de entrenamiento para la clasificación"></a>

Usemos la función `shapefile` del paquete ‘raster’ para importar este archivo en R como un objeto de clase `SpatialPolygonsDataFrame` y creemos una variable para almacenar el nombre de la columna ‘class’:

```
trainData <- shapefile("C:/data/landsat/shps/UTM18N_32618/training_15.shp")
 responseCol <- "class"
```
<br>

### **Extracción de valores de los pixeles para la calibración del modelo**

Ahora extraigamos los valores de los pixeles en las áreas de entrenamiento para cada banda en la imagen Landsat y almacenémoslos en una data frame (llamado aquí `dfAll`) junto con el correspondiente identificador de la clase de cobertura:

```
dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  dataSet <- dataSet[!unlist(lapply(dataSet, is.null))]
  if(is(trainData, "SpatialPointsDataFrame")){
    dataSet <- cbind(dataSet, class = as.numeric(category))
    dfAll <- rbind(dfAll, dataSet)
  }
  if(is(trainData, "SpatialPolygonsDataFrame")){
    dataSet <- lapply(dataSet, function(x){cbind(x, class = as.numeric(rep(category, nrow(x))))})
    df <- do.call("rbind", dataSet)
    dfAll <- rbind(dfAll, df)
  }
}
```
<br>

El data frame resultante del paso anterior realizado con mis datos tiene cerca de 80 mil registros. Es necesario trabajar con un dataset más pequeño ya que puede tomar un tiempo bastante largo el entrenamiento y ajuste de un modelo de RandomForests con un dataset de este tamaño. Para comenzar, creemos un subconjunto de datos tomando 1000 muestras aleatorias: 

```
nsamples <- 1000
 sdfAll <- dfAll[sample(1:nrow(dfAll), nsamples), ]
```
<br>

### **Ajuste del modelo y clasificación de la imagen**

A continuación debemos definir y ajustar el modelo RandomForests usando la función `train` del paquete ‘caret’. Primero especifiquemos el modelo como una fórmula con la variable dependiente (i.e., identificadores de los tipos de cobertura) codificada como factores. Para este ejercicio solamente voy a usar tres bandas como variables explicatorias (Rojo, Infrarrojo cercano e Infrarrojo de onda corta). Luego definimos el método como ‘rf’, es decir, los algoritmos de RandomForests. (Nota: puedes usar el comando `names(getModelInfo())` para ver una lista completa de todos los métodos de regresión y clasificación disponibles en el paquete ‘caret’). 

```
modFit_rf <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = sdfAll)
```
<br>

En este punto podríamos simplemente usar el comando `predict` para crear un raster con las predicciones usando el objeto del modelo ajustado (i.e., `modFit_rf`). Sin embargo, es posible acelerar el proceso de clasificación usando la función `clusterR` del paquete ‘raster’ el cual soporta procesamiento en paralelo para funciones como `predict` y otras (Nota: el [paquete 'snow'] debe estar instalado). Solamente necesitamos agregar una línea para crear el objeto cluster y otra para eliminarlo después de que finalice la operación:

```
beginCluster()
 preds_rf <- clusterR(img, raster::predict, args = list(model = modFit_rf))
 endCluster()
```
<br>

La implementación del cálculo en paralelo en mi PC con procesador de 8 núcleos produjo una mejora de aproximadamente 70% en términos de tiempo de procesamiento (~14.2 minutos sin paralelización vs. ~4.1 minutos del procesamiento en paralelo). En el siguiente pantallazo puedes ver la imagen clasificada resultante:

<a href="/images/2015-11-28-classification-r-fig-3.JPG" class="image full"><img src="/images/2015-11-28-classification-r-fig-3.JPG" alt="" title="Imagen Landsat clasificada en RStudio"></a>

Es posible modificar o adicionar otros argumentos al modelo con el fin de hacer un mejor ajuste de los parámetros que se le proporcionan. Estos parámetros incluyen por ejemplo el número de árboles (el valor por defecto es 500), el tamaño mínimo de los nodos terminales o el número máximo de árboles con nodos terminales. Para mayor información puedes examinar la documentación de los paquetes ‘randomForests’ y ‘caret’. 

El siguiente video muestra los comandos de R descritos previamente siendo ejecutados en RStudio:

<iframe width="750" height="422" src="https://www.youtube.com/embed/GyaIdqoUJ14" frameborder="0" allowfullscreen></iframe>

<br>

### **Cómo realizar una clasificación con RandomForests en QGIS usando R**

Para correr la versión del script de R descrito arriba en QGIS, puedes descargar el script disponible en el siguiente link y guardarlo en el folder R Scripts de QGIS (o copiar y pegar el contenido en el editor de scripts de QGIS) como expliqué [en mi anterior post]:

&#42; [Script de R para clasificación con RandomForests en QGIS]

En el siguiente video puedes ver cómo realizar la clasificación con RandomForests de una imagen Landsat en QGIS usando R:

<iframe width="750" height="422" src="https://www.youtube.com/embed/z_ZyzcgieRo" frameborder="0" allowfullscreen></iframe>

<br>

### **Recursos adicionales**

Para profundizar en el proceso de creación de modelos predictivos, te sugiero visitar el [sitio web del paquete ‘caret’], el cual contiene extensa documentación sobre preprocesamiento y partición de datos, evaluación de la importancia de las variables y ajuste de parámetros y del modelo. También te recomiendo chequear un nuevo paquete de R llamado [RStoolbox] que ofrece un conjunto de herramientas para el procesamiento de datos tomados por sensores remotos. 

La integración R+QGIS demostrada en este post amplía los métodos de clasificación de imágenes disponibles en QGIS. Existen otras técnicas de procesamiento de imágenes incluidas en QGIS como las que se encuentran en el [Plugin de Clasificación Semi-Automática], el [plugin para GRASS GIS] y en [Orfeo Toolbox]. Te sugiero explorar también estas opciones.

En un próximo post estaré escribiendo sobre prácticas recomendadas para la evaluación de la exactitud de imágenes clasificadas a través de la comparación de datos de referencia versus los correspondientes resultados de la clasificación. Hasta pronto!

<br>

**También te puede interesar:**

&#42; [Integración de QGIS y R: Un ejemplo con muestreo espacial estratificado]

&#42; [Prepara archivos para creación de imágenes de reflectancia en CLASlite usando R]

<a id="comments"></a>

[algoritmos conocidos como RandomForests]:              https://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm
[en un post anterior en mi blog]:         /blog/es/2015/10/03/reflectance-R-es.html
[Prepara archivos para creación de imágenes de reflectancia en CLASlite usando R]:         /blog/es/2015/10/03/reflectance-R-es.html
[rgdal]:                                 http://cran.r-project.org/package=rgdal
[raster]:                                http://cran.r-project.org/package=raster
[caret]:                                 http://cran.r-project.org/package=caret
[randomForest]:                          http://cran.r-project.org/package=randomForest
[e1071]:                                 http://cran.r-project.org/package=e1071
[paquete 'snow']:                        http://cran.r-project.org/package=snow
[paquete ‘raster’]:                      http://cran.r-project.org/package=raster
[QGIS]:                                  http://www.qgis.org/
[en mi anterior post]:                   /blog/es/2015/10/31/qgis-r-es.html
[Integración de QGIS y R: Un ejemplo con muestreo espacial estratificado]:       /blog/es/2015/10/31/qgis-r-es.html 
[Script de R para clasificación con RandomForests en QGIS]:  https://gist.github.com/amsantac/5183c0c71a8dcbc27a4f
[Plugin de Clasificación Semi-Automática]:  http://fromgistors.blogspot.com/
[RStoolbox]:                             http://bleutner.github.io/RStoolbox/
[sitio web del paquete ‘caret’]:         http://topepo.github.io/caret/index.html
[plugin para GRASS GIS]:                 https://docs.qgis.org/2.8/en/docs/user_manual/grass_integration/grass_integration.html
[Orfeo Toolbox]:                         https://www.orfeo-toolbox.org/



