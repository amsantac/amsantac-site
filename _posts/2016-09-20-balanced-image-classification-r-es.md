---
layout      : post-es
title       : "Por qué es importante trabajar con datos balanceados para clasificación"
date        : 2016-09-20 11:02:52
categories  : blog es
tags        : R DataScience PercepcionRemota landsat 
image       : 2016-09-20-balanced-image-classification-r-mini.jpg
published   : false
---

Cuando se realiza clasificación supervisada con algoritmos de machine learning como RandomForests, una práctica que se recomienda es trabajar con un dataset de clasificación balanceado. Sin embargo, algunas veces esta recomendación se ignora debido a que se desconoce su relevancia o no se tiene conocimiento sobre cómo llevarla a cabo.

El propósito de este post es, primero, examinar algunas de las consecuencias de trabajar con un dataset desbalanceado usando un ejemplo de clasificación de imágenes, y segundo, probar y sugerir algunas técnicas para corregir este problema. 

<!--more-->

<a href="" class="image full"><img src="/images/2016-09-20-balanced-image-classification-r-fig-0.png" alt="Por qué es importante trabajar con datos balanceados para clasificación" title=""></a>

### **Qué es un dataset desbalanceado**

Desbalance en los datos se refiere a una situación en la que el número de observaciones no es el mismo para todas las clases en un dataset usado para clasificación. En algunas áreas los problemas con datos desbalanceados son muy comunes. Puedes pensar por ejemplo en detección de fraude o el diagnóstico de enfermedades raras, donde la mayoría de los casos pertenecen a la clase "No-Fraude" or "No-Detección" y solo una muy pequeña minoría pertenece a la clase "Fraude" or "Detección", respectivamente. En percepción remota y procesamiento de imágenes se pueden encontrar ejemplos de problemas desbalanceados cuando se lleva a cabo la clasificación de áreas urbanas y no urbanas, o la detección de fragmentos quemados en un paisaje agrícola. Estos ejemplos presentan problemas de clasificación para solo dos clases o categorías. Sin embargo, también se puede hallar situaciones de desbalanceo en clasificaciones con múltiples categorías.

Clasificadores de machine learning como Random Forests no lidian muy bien con datasets de entrenamiento desbalanceados ya que son sensibles a las proporciones de las diferentes clases. Como consecuencia, estos algoritmos tienden a favorecer la clase con la mayor proporción de observaciones (conocida como clase mayoritaria), lo cual puede derivar en métricas de exactitud sesgadas. Esto puede ser particularmente problemático cuando estamos interesados en la clasificación correcta de una clase "rara" (también conocida como clase minoritaria) pero encontramos altos valores de exactitud que son producto realmente de la clasificación correcta de la clase mayoritaria y por tanto son un reflejo de la distribución de clases subyacente. 

Dado que buscan minimizar la tasa de error global en lugar de prestar atención especial a la clase minoritaria, estos algoritmos fallan en realizar una predicción exacta de esta clase si no obtienen la cantidad de información necesaria. Por esto es altamente recomendable llevar a cabo un análisis de sensibilidad del clasificador con respecto a la distribución de los datos de entrenamiento. A continuación presento un análisis básico utilizando para ello datos tomados de una imagen Landsat. 

<br>

### **Un ejemplo práctico de clasificación de imágenes**

Voy a usar los paquetes típicos para manejar datos espaciales y el [paquete caret] para clasificación y evaluación de la exactitud. Igualmente fijo una semilla de números aleatorios para permitir replicabilidad de los resultados:

```r
library(rgdal)
 library(raster)
 library(caret)
 set.seed(123)
```
<br>

Para este ejemplo emplearé una imagen de Landsat 7 ETM+, path 7 row 57, tomada en 2000-03-16, procesada a reflectancia en superficie con el algoritmo LEDAPS y que he descargado desde el [EarthExplorer de USGS]. Del archivo descargado y descomprimido he extraído las bandas de reflectancia en superficie a un folder llamado 'data'. Para los datos de entrenamiento voy a usar un shapefile de polígonos, el cual puedes [descargar desde este link]:

```r
img <- brick(stack(as.list(list.files("data/", "sr_band", full.names = TRUE))))
 names(img) <- c(paste0("B", 1:5, coll = ""), "B7") 
```

```r
 trainData <- shapefile("data/training_15.shp")
 responseCol <- "class"
```
<br>

A continuación extraigo los datos de entrenamiento de las bandas de la imagen usando un fragmento de código que he descrito [en un post previo]:

```r
dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){                          
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  dataSet <- sapply(dataSet, function(x){cbind(x, class = rep(category, nrow(x)))})
  df <- do.call("rbind", dataSet)
  dfAll <- rbind(dfAll, df)  
}
```

```r
dim(dfAll)
```

```
[1] 80943     7
```
<br>

El data.frame `dfAll` contiene los valores para cada una de las seis bandas de reflectancia en superficie de Landsat más el atributo de la clase. Podemos crear una partición entrenamiento/validación con 70% de los datos iendo a entrenamiento:

```r
inBuild <- createDataPartition(y = dfAll$class, p = 0.7, list = FALSE)
 training <- dfAll[inBuild,]
 testing <- dfAll[-inBuild,]
```

```r
table(training$class)
```

```
    1     2     3     5     6     7 
 4753 21626 14866  8093  3535  3789 
```

```r
table(testing$class)
```

```
   1    2    3    5    6    7 
2068 9236 6371 3468 1508 1630 
```
<br>

Para entrenamiento del modelo usaré solamente 2400 observaciones las cuales son aleatoriamente muestreadas del data.frame `dfAll` . En este subconjunto de datos (objeto `training_ub`), el número de observaciones en la clase mayoritaria (clase 2) es aproximadamente seis veces la cantidad de observaciones de las clases minoritarias (clases 6 y 7). Aunque no es excesivamente desbalanceado, este dataset servirá como ejemplo para el propósito de este ejercicio:

```r
training_ub <- training[sample(1:nrow(training), 2400), ]
 table(training_ub$class)
```

```
  1   2   3   5   6   7 
211 904 608 357 149 171 
```
<br>

Entrenemos un modelo de RandomForest (RF) aplicando la función `train` del paquete caret la cual calcula y devuelve la tasa de error de entrenamiento:

```r
mod1_ub <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_ub)
```

```
note: only 2 unique complexity parameters in default grid. Truncating the grid to 2 .
```

```r
mod1_ub$results[, 1:2]
```

```
  mtry  Accuracy
1    2 0.9787367
2    3 0.9758969
```
<br>

Vemos que la exactitud usando el dataset desbalanceado fue 0.9787. A continuación vamos a crear un dataset balanceado y entrenar un modelo RF para que podamos comparar los valores de exactitud entre los dos tipos de datasets.

### **Cómo tratar un dataset desbalanceado**

Hay varios métodos de muestreo que han sido diseñados para tratar datos desbalanceados, los cuales pueden ser agrupados en cuatro categorías: submuestreo, sobremuestreo, generación de datos sintéticos y aprendizaje sensible al costo. Todos estos métodos modifican la proporción de las clases y el tamaño del dataset original.

Los métodos de submuestreo eliminan observaciones de la clase mayoritaria con el fin de igualar los tamaños de las clases. En este post vamos a utilizar este método para la clasificación de la imagen. La función presentada a continuación, la cual aplica la regla de submuestreo, requiere como argumentos un objeto de clase data.frame (`x`), el nombre de la columna que identifica las classes (`classCol`), y el número deseado (entero) de observaciones para cada clase (`nsamples_class`):

```r
undersample_ds <- function(x, classCol, nsamples_class){
  for (i in 1:length(unique(x[, classCol]))){
    class.i <- unique(x[, classCol])[i]
    if((sum(x[, classCol] == class.i) - nsamples_class) != 0){
      x <- x[-sample(which(x[, classCol] == class.i), 
                     sum(x[, classCol] == class.i) - nsamples_class), ]
      }
  }
  return(x)
}
```
<br>

Esta función trata con datasets con múltiples categorías. Si tú estás trabajando específicamente con clasificaciones binarias, te sugiero revises el [paquete ROSE] el cual provee un conjunto apropiado de funciones para el balanceo de datos. Igualmente si estas interesado en conocer sobre los otros métodos de muestreo por favor [mira este post].

Apliquemos la función `undersample_ds` al dataset `training` requiriendo un número de 400 observaciones para cada clase:

```r
(nsamples_class <- 400) 
```

```
[1] 400
```

```r
training_bc <- undersample_ds(training, "class", nsamples_class)
 table(training_bc$class)
```

```
  1   2   3   5   6   7 
400 400 400 400 400 400 
```
<br>

Ahora entrenemos el modelo RF y evaluemos la exactitud resultante:

```r
mod1_bc <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_bc)
```

```
note: only 2 unique complexity parameters in default grid. Truncating the grid to 2 .
```

```r
mod1_bc$results[, 1:2]
```

```
  mtry  Accuracy
1    2 0.9814680
2    3 0.9775064
```
<br>

Podemos ver el clasificador RandomForest tiene un desempeño ligeramente mejor con el dataset balanceado que con el desbalanceado, incluso aunque este dataset no es excesivamente desbalanceado como se mencionó antes.

Cuando se trabaja con datos desbalanceados, sin embargo, usar la exactitud como medida de desempeño puede conducir a conclusiones erróneas debido a que las clases minoritarias solo tienen un efecto pequeño en esta métrica. Por lo tanto es recomendable examinar más cuidadosamente la matriz de confusión y analizar otras métricas más adecuadas para evaluar la exactitud del modelo en estas situaciones, como pueden ser la [precisión], la [sensibilidad] o el [F-score]. Es posible que conozcas estas métricas por diferentes nombres: la precisión también es llamada valor predictivo positivo o *exactitud del usuario* en percepción remota; la sensibilidad también es conocida como recall, tasa positiva verdadera o como *exactitud del productor* en percepción remota.

Para la parte final de este ejercicio trabajemos preferiblemente con el dataset de validación que creamos previamente, dado que es un conjunto de datos independiente (no usado para el entrenamiento de los modelos mostrados arriba), y examinemos la exactitud del productor (llamada sensibilidad en el paquete caret) para el modelo ajustado con datos desbalanceados:

```r
pred1_ub <- predict(mod1_ub, testing)
 confusionMatrix(pred1_ub, testing$class)$overall[1]
```

```
 Accuracy 
0.9840204 
```

```r
confusionMatrix(pred1_ub, testing$class)$byClass[, 1]
```

```
 Class: 1  Class: 2  Class: 3  Class: 5  Class: 6  Class: 7 
0.9946809 0.9785621 0.9811647 0.9919262 1.0000000 0.9809816 
```
<br>

...y para el modelo ajustado con datos balanceados:

```r
pred1_bc <- predict(mod1_bc, testing)
 confusionMatrix(pred1_bc, testing$class)$overall[1]
```

```
 Accuracy 
0.9779251 
```

```r
confusionMatrix(pred1_bc, testing$class)$byClass[, 1]
```

```
 Class: 1  Class: 2  Class: 3  Class: 5  Class: 6  Class: 7 
0.9845261 0.9671936 0.9704913 0.9976932 1.0000000 0.9969325 
```
<br>

En primer lugar encontramos que la exactitud total del *modelo desbalanceado* fue mayor que la del *modelo balanceado* cuando se hace la predicción en el dataset de validación, lo cual se explica por la proporción desigual de clases en ese dataset. Este resultado muestra claramente el efecto de la mayor proporción de la clase mayoritaria en la medida de exactitud global, como se describió previamente. En segundo lugar vemos que la exactitud del productor de la clase 2 fue menor en el *modelo balanceado* que en el *modelo desbalanceado*, mientras que ocurrió lo opuesto con la clase 7, lo cual muestra cómo los algoritmos de machine learning como RandomForests buscan aumentar la exactitud total (ie, minimizar el error total). En el dataset balanceado, los errores de la clase 7 tienen el mismo costo que aquellos de la clase 2, lo que lleva al algoritmo a buscar maximizar la exactitud de todas las clases de manera equilibrada.

En este ejemplo particular la case con el menor número de observaciones, la clase 6, que está relacionada con cuerpos de agua, demostró ser muy fácil de predecir de manera perfecta por el algoritmo de RF en ambos escenarios. Por ello podemos ignorarla y considerar la clase 7 como la clase minoritaria.

El siguiente video describe este tema de clasificación desbalanceada a partir del ejemplo de procesamiento de imágenes mostrado en este post: 

<iframe width="750" height="422" src="https://www.youtube.com/embed/JjTg8gs1dzs" frameborder="0" allowfullscreen></iframe>

<br>

A continuación puedes ver las diapositivas del video:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/3KaENmteLbqeN3" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/el-problema-de-datos-desbalanceados-en-clasificacin-un-ejemplo-de-procesamiento-de-imgenes" title="El problema de datos desbalanceados en clasificación: Un ejemplo de procesamiento de imágenes" target="_blank">El problema de datos desbalanceados en clasificación: Un ejemplo de procesamiento de imágenes</a> </strong> por <strong><a href="//www.slideshare.net/amsantac" target="_blank">Alí Santacruz</a></strong> </div>

<br>

El código fuente para las diapositivas está disponible para [descarga desde este link] y [en GitHub]. Espero que este post te de un par de cosas para pensar con respecto a la relevancia de la distribución de los datos empleados para clasificación. [Suscríbete a mi blog] para más posts sobre Data Science aplicado al procesamiento de imágenes!

<br>

**También te puede interesar**

&#42; [Clasificación de imágenes con RandomForests en R (y QGIS)]

&#42; [Introducción a Spatial Data Science con R]

<a id="comments"></a>

[Clasificación de imágenes con RandomForests en R (y QGIS)]: /blog/es/2015/11/28/classification-r-es.html
[EarthExplorer de USGS]: http://earthexplorer.usgs.gov/
[paquete caret]: https://cran.r-project.org/package=caret
[paquete ROSE]: https://cran.r-project.org/package=ROSE
[en un post previo]: /blog/en/2015/11/28/classification-r.html
[descargar desde este link]: https://www.dropbox.com/sh/6l572eieht0rerw/AADnWuTyvneKa8D-dIPbKnJQa?dl=0
[descarga desde este link]: https://www.dropbox.com/sh/6l572eieht0rerw/AADnWuTyvneKa8D-dIPbKnJQa?dl=0
[mira este post]: https://www.analyticsvidhya.com/blog/2016/03/practical-guide-deal-imbalanced-classification-problems/
[precisión]: https://en.wikipedia.org/wiki/Precision_and_recall
[sensibilidad]: https://en.wikipedia.org/wiki/Precision_and_recall
[F-score]: https://en.wikipedia.org/wiki/F1_score
[en GitHub]: https://github.com/amsantac/extras/tree/master/2016-09-20-balanced-image-classification-r
[Introducción a Spatial Data Science con R]: /blog/es/2016/08/07/spatial-data-science-r-es.html
[Suscríbete a mi blog]: /es/subscribe.html
[link1]: http://statistics.berkeley.edu/sites/default/files/tech-reports/666.pdf
[link2]: http://machinelearningmastery.com/tactics-to-combat-imbalanced-classes-in-your-machine-learning-dataset/
[link3]: http://machinelearningmastery.com/classification-accuracy-is-not-enough-more-performance-measures-you-can-use/
