---
layout      : post-es
title       : "Mejorando la exactitud en la clasificación mediante ensamble de modelos"
date        : 2016-10-22 11:02:52
categories  : blog es
tags        : R DataScience PercepcionRemota landsat 
image       : 2016-10-22-model-stacking-classification-r-mini.jpg
published   : true
---

Cuando tomé los cursos de la especialización de Data Science en Coursera, uno de los métodos que me pareció más interesante fue el ensamble de modelos, el cual busca incrementar la exactitud a partir de la combinación de las predicciones de múltiples modelos.

En estos días que he estado trabajando en el procesamiento de algunas imágenes Landsat para la investigación de mi tesis, ha sido la oportunidad perfecta para probar esta técnica y evaluar si puede ayudar a mejorar los resultados de las clasificaciones de coberturas que tengo que realizar. En los siguientes párrafos explico los pasos que seguí y algunas de las lecciones que aprendí durante mi primer experiencia de ensamble de modelos.

<!--more-->

<a href="" class="image full"><img src="/images/2016-10-22-model-stacking-classification-r-fig-0.png" alt="Mejorando la exactitud en la clasificación mediante ensamble de modelos" title=""></a>

### **Combinando predictores mediante métodos de ensamble**

Existen varios tipos de métodos de ensamble que se pueden implementar cuando se está llevando a cabo procesamiento con algoritmos de Machine Learning. Esos tipos de ensamble se pueden categorizar de diferentes maneras, pero podemos pensar básicamente en dos tipos de aproximaciones para la combinación de clasificadores: una aproximación es usar clasificadores *similares* y combinarlos usando técnicas como bagging, boosting o random forests. Una segunda aproximación es combinar *diferentes* clasificadores usando model stacking.

Para las pruebas que realicé me enfoqué en model stacking. En este método lo que hacemos básicamente es construir varios modelos de diferentes tipos y luego combinamos las predicciones de esos modelos primarios para construir un modelo supervisor que aprende la mejor manera de combinar esas predicciones.

Este método lo probé para el procesamiento de una imagen Landsat (convertida a reflectancia en superficie y suministrada por el USGS) que ya he usado en [tutoriales previos en mi blog]. Esta imagen y [los datos de entrenamiento] los importé en R y luego extraje los valores de cada banda correspondientes a los polígonos de entrenamiento como lo he descrito en posts anteriores:


```r
# Carga los paquetes requeridos
library(rgdal)
library(raster)
library(caret)
set.seed(123)

# Carga la imagen Landsat y los datos de entrenamiento
img <- brick(stack(as.list(list.files("data/", "sr_band", full.names = TRUE))))
names(img) <- c(paste0("B", 1:5, coll = ""), "B7") 
trainData <- shapefile("data/training_15.shp")
responseCol <- "class"

# Extrae los valores de los datos de entrenamiento de las bandas de la imagen
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
<br>

A continuación, con base en el objeto `dfAll` creé tres subconjuntos de datos: uno para entrenamiento, otro para calibración y otro más para validación:


```r
# Crea el dataset de validación
inBuild <- createDataPartition(y = dfAll$class, p = 0.7, list = FALSE)
validation <- dfAll[-inBuild,]
buildData <- dfAll[inBuild,]

# Crea los datasets de entrenamiento y calibración
inTrain <- createDataPartition(y = buildData$class, p = 0.7, list = FALSE)
training <- buildData[inTrain,]
testing <- buildData[-inTrain,]
```
<br>

Luego realicé el balanceo de los datasets usando la función `undersample_ds` descrita [en mi último post], solicitando un número de 600 observaciones para cada clase:


```r
nsamples_class <- 600

# Balancea el dataset de entrenamiento
training_bc <- undersample_ds(training, "class", nsamples_class)
```
<br>

Posteriormente construí dos modelos separados con base en los datos entrenamiento, uno con Random Forests (RF) y otro con Support Vector Machines (SVM), para predecir la clase de cobertura terrestre usando tres bandas espectrales:


```r
# Modelo Random Forests
set.seed(123)
mod.rf <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_bc)
pred.rf <- predict(mod.rf, testing)
# Modelo SVM
set.seed(123)
mod.svm <- train(as.factor(class) ~ B3 + B4 + B5, method = "svmRadial", data = training_bc)
pred.svm <- predict(mod.svm, testing)
```
<br>

La exactitud total de cada uno de estos algoritmos de Machine Learning evaluada en el dataset de calibración fue bastante alta:


```r
# Exactitud del modelo RF 
confusionMatrix(pred.rf, testing$class)$overall[1]
```

```
 Accuracy 
0.9812897 
```

```r
# Exactitud del modelo SVM
confusionMatrix(pred.svm, testing$class)$overall[1]
```

```
Accuracy 
0.967816 
```
<br>

Es aconsejable que las predicciones hechas por los modelos separados tengan una baja correlación (< 0.75) cuando se desea aplicar un método de stacking. Para evaluar la correlación utilicé las funciones `resamples` y `modelCor` del [paquete caret] y encontré una muy baja correlación entre mis dos modelos:


```r
results <- resamples(list(mod1 = mod.rf, mod2 = mod.svm)) 
 modelCor(results) 
```

```
            mod1        mod2
mod1  1.00000000 -0.02574656
mod2 -0.02574656  1.00000000
```
<br>

En el siguiente paso ajusté un modelo que combinara los dos predictores. Para ese propósito primero construí un nuevo dataset que consistía de las predicciones del primer modelo (RF), las predicciones del segundo modelo (SVM), y la variable `class` del dataset de calibración:


```r
predDF <- data.frame(pred.rf, pred.svm, class = testing$class)
 predDF_bc <- undersample_ds(predDF, "class", nsamples_class)
```
<br>

Luego ajusté un nuevo modelo con el algoritmo Stochastic Gradient Boosting para relacionar esta variable `class` con las dos predicciones y usé este modelo para predecir la clase de las observaciones en el objeto `predDF`:


```r
set.seed(123)
 combModFit.gbm <- train(as.factor(class) ~ ., method = "gbm", data = predDF_bc, distribution = "multinomial")
 combPred.gbm <- predict(combModFit.gbm, predDF)
```
<br>

Al evaluar el comportamiento de este modelo con respecto al dataset de calibración, encontré que la exactitud total del predictor combinado fue mayor que la exactitud de tanto el primero como del segundo predictor (0.9813 and 0.9678, respectivamente):


```r
confusionMatrix(combPred.gbm, testing$class)$overall[1]
```

```
 Accuracy 
0.9838786 
```
<br>

Como el dataset de calibración fue usado para combinar los dos modelos iniciales, este no ofrece una buena estimación del error. Por lo tanto, para la evaluación de la exactitud del modelo final utilicé el dataset de validación creado al comienzo. Para ello hice predicción de la clase aplicando al dataset de validación inicialmente el primer modelo y luego el segundo modelo. Después creé un dataframe que contuviera esas dos predicciones e hice la predicción de la clase aplicando el modelo combinado a las predicciones en el dataset de validación:


```r
pred1V <- predict(mod.rf, validation)
 pred2V <- predict(mod.svm, validation)
 predVDF <- data.frame(pred.rf = pred1V, pred.svm = pred2V)
 combPredV <- predict(combModFit.gbm, predVDF)
```
<br>

La exactitud total del primer modelo (RF) y del segundo modelo (SVM) fue 0.9817 y 0.9659, respectivamente, mientras que el modelo combinado arrojó una mayor exactitud en el dataset de validación igual a 0.983, como se ve a continuación:


```r
accuracy <- rbind(confusionMatrix(pred1V, validation$class)$overall[1], 
                  confusionMatrix(pred2V, validation$class)$overall[1], 
                  confusionMatrix(combPredV, validation$class)$overall[1])
 row.names(accuracy) <- c("RF", "SVM", "Stack")
 accuracy 
```

```
       Accuracy
RF    0.9817141
SVM   0.9658993
Stack 0.9830320
```
<br>

Una forma de entender de qué manera el predictor combinado alcanza una mayor exactitud total es examinar la exactitud del productor (también llamada sensibilidad) para las clases en el dataset:


```r
prod_acc <- rbind(confusionMatrix(pred1V, validation$class)$byClass[, 1],
                  confusionMatrix(pred2V, validation$class)$byClass[, 1],
                  confusionMatrix(combPredV, validation$class)$byClass[, 1])
 row.names(prod_acc) <- c("RF", "SVM", "Stack")
 htmlTable::htmlTable(round(prod_acc, 4))
```

<table class='gmisc_table' style='border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;' >
<thead>
<tr>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey;'> </th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 1</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 2</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 3</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 5</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 6</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: center;'>Class: 7</th>
</tr>
</thead>
<tbody>
<tr>
<td style='text-align: left;'>RF</td>
<td style='text-align: center;'>0.9927</td>
<td style='text-align: center;'>0.9748</td>
<td style='text-align: center;'>0.9769</td>
<td style='text-align: center;'>0.9867</td>
<td style='text-align: center;'>1</td>
<td style='text-align: center;'>0.9982</td>
</tr>
<tr>
<td style='text-align: left;'>SVM</td>
<td style='text-align: center;'>0.9913</td>
<td style='text-align: center;'>0.9439</td>
<td style='text-align: center;'>0.9615</td>
<td style='text-align: center;'>0.9905</td>
<td style='text-align: center;'>1</td>
<td style='text-align: center;'>0.9914</td>
</tr>
<tr>
<td style='border-bottom: 2px solid grey; text-align: left;'>Stack</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>0.9927</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>0.9752</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>0.9779</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>0.9963</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>1</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>0.9914</td>
</tr>
</tbody>
</table>
<br>

Para algunas clases (clases 2, 3 y 5), el modelo combinado mostró una exactitud del productor mayor que cualquiera de los modelos separados. Para la clase 1, la exactitud del productor del modelo combinado fue tan alta como la del mejor modelo separado (RF), mientras que para la clase 7 fue igual que la del modelo con menor exactitud (SVM). En general, el modelo resultante de la combinación de los predictores arrojó una exactitud superior a la de los modelos separados, lo cual muestra cómo esta técnica trata de mezclar la fortalezas de cada uno de los diferentes modelos. 

En este video de Youtube puedes ver la descripción del método de combinación de modelos presentado en este post:

<iframe width="750" height="422" src="https://www.youtube.com/embed/HitS4nNcJhQ" frameborder="0" allowfullscreen></iframe>

<br>

Acá encuentras las diapositivas del video:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/l72C9tmDoVvLGn" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/mejorando-la-exactitud-en-la-clasificacin-mediante-ensamble-de-modelos" title="Mejorando la exactitud en la clasificación mediante ensamble de modelos" target="_blank">Mejorando la exactitud en la clasificación mediante ensamble de modelos</a> </strong> por <strong><a href="//www.slideshare.net/amsantac" target="_blank">Alí Santacruz</a></strong> </div>

<br>

El código fuente de las diapositivas y la rutina en R los puedes [descargar desde este link].
  
En general, la combinación de modelos mediante model stacking me pareció una técnica bastante útil para mejorar la exactitud en la clasificación, aunque para lograrlo necesité probar distintas combinaciones antes de encontrar una solución que me satisficiera. Si te interesa avanzar más en este tema hay un paquete de R llamado [caretEnsemble] el cual provee un conjunto de herramientas para evaluar combinaciones de varios modelos tanto para clasificación como para regresión usando el [paquete caret]. 

Bueno, espero que hayas aprendido algo nuevo con este post como yo lo hice! 

<br>


**También te puede interesar**

&#42; [Clasificación de imágenes con RandomForests en R (y QGIS)]

&#42; [Por qué es importante trabajar con datos balanceados para clasificación]

<a id="comments"></a>

[tutoriales previos en mi blog]: /blog/es/2015/11/28/classification-r-es.html
[Clasificación de imágenes con RandomForests en R (y QGIS)]: /blog/es/2015/11/28/classification-r-es.html
[Por qué es importante trabajar con datos balanceados para clasificación]: /blog/es/2016/09/20/balanced-image-classification-r-es.html
[en mi último post]: /blog/es/2016/09/20/balanced-image-classification-r-es.html
[USGS EarthExplorer]: http://earthexplorer.usgs.gov/
[paquete caret]: https://cran.r-project.org/package=caret
[caretEnsemble]: https://cran.r-project.org/package=caretEnsemble
[a previous post]: /blog/es/2015/11/28/classification-r-es.html
[GitHub]: https://github.com/amsantac/extras/tree/master/2016-09-20-balanced-image-classification-r
[los datos de entrenamiento]: https://www.dropbox.com/sh/5sa8udavzumm66a/AAABoa-POOSNorcVIagX2Pu0a?dl=0
[descargar desde este link]: https://www.dropbox.com/sh/5sa8udavzumm66a/AAABoa-POOSNorcVIagX2Pu0a?dl=0

