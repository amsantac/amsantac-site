---
layout      : post
title       : "Improving classification accuracy through model stacking"
date        : 2016-10-22 11:02:52
categories  : blog en
tags        : R DataScience RemoteSensing landsat 
image       : 2016-10-22-model-stacking-classification-r-mini.jpg
published   : true
---

When I took the courses of the Data Science specialization in Coursera, one of the methods that I found most interesting was model ensembling which aims to increase accuracy by combining the predictions of multiple models together. 

These days I've been working on processing some Landsat images for my dissertation research, so it has been the perfect time to test this technique and assess whether it can help to improve the results for the multi-category land-cover classification I have to conduct. In the paragraphs below I explain the steps I followed and some of the lessons I learned during my first ensembling experience. 

<!--more-->

<a href="" class="image full"><img src="/images/2016-10-22-model-stacking-classification-r-fig-0.png" alt="Improving classification accuracy through model stacking" title=""></a>

### **Combining predictors through ensemble methods**

There are several types of ensemble methods that can be implemented when conducting a Machine Learning task. These types of ensemble may be categorized in different ways but we can think of basically two approaches for combining classifiers: one approach is to use *similar* classifiers and to combine them together using techniques such as bagging, boosting or random forests. A second approach is to combine *different* classifiers using model stacking.

For my tests I focused on model stacking. In this method we basically build several models of different types and then combine the predictions of these primary models to build a supervisor model that learns how to best combine those predictions. 

I tried this method for processing a Landsat image (converted to surface reflectance and provided by USGS) that I've used for tutorials in [previous posts in my blog]. So first I imported into R the image and [the training data], and extracted in a data frame (called `dfAll`) the values from each band corresponding to the training polygons, as usual:


```r
# Load required packages
library(rgdal)
library(raster)
library(caret)
set.seed(123)

# Load the Landsat image and the training data
img <- brick(stack(as.list(list.files("data/", "sr_band", full.names = TRUE))))
names(img) <- c(paste0("B", 1:5, coll = ""), "B7") 
trainData <- shapefile("data/training_15.shp")
responseCol <- "class"

# Extract training data values from the image bands
dfAll = data.frame(matrix(vector(), nrow = 0, ncol = length(names(img)) + 1))   
 for (i in 1:length(unique(trainData[[responseCol]]))){                          
  category <- unique(trainData[[responseCol]])[i]
  categorymap <- trainData[trainData[[responseCol]] == category,]
  dataSet <- extract(img, categorymap)
  dataSet <- lapply(dataSet, function(x){cbind(x, class = as.numeric(rep(category, nrow(x))))})
  df <- do.call("rbind", dataSet)
  dfAll <- rbind(dfAll, df)  
}
```
<br>

Next, based on the `dfAll` object, I created three data subsets: one for training, one for testing and another one for validation:


```r
# Create validation dataset
inBuild <- createDataPartition(y = dfAll$class, p = 0.7, list = FALSE)
validation <- dfAll[-inBuild,]
buildData <- dfAll[inBuild,]

# Create training and testing datasets
inTrain <- createDataPartition(y = buildData$class, p = 0.7, list = FALSE)
training <- buildData[inTrain,]
testing <- buildData[-inTrain,]
```
<br>

Then I balanced these datasets using the `undersample_ds` function I described [in my last post], requesting a number of 600 observations for each class:




```r
nsamples_class <- 600

# balance training dataset
training_bc <- undersample_ds(training, "class", nsamples_class)
```
<br>

Next I built in the training data two separate models, one with Random Forests and another with Support Vector Machines (SVM), to predict land cover class using three spectral bands:


```r
# Random Forests model
set.seed(123)
mod.rf <- train(as.factor(class) ~ B3 + B4 + B5, method = "rf", data = training_bc)
pred.rf <- predict(mod.rf, testing)
# SVM model
set.seed(123)
mod.svm <- train(as.factor(class) ~ B3 + B4 + B5, method = "svmRadial", data = training_bc)
pred.svm <- predict(mod.svm, testing)
```
<br>

The overall accuracy of each of these Machine Learning algorithms assessed on the testing set was quite high:


```r
# RF model accuracy
confusionMatrix(pred.rf, testing$class)$overall[1]
```

```
 Accuracy 
0.9812897 
```

```r
# SVM model accuracy
confusionMatrix(pred.svm, testing$class)$overall[1]
```

```
Accuracy 
0.967816 
```
<br>

It is advisable that the predictions made by separate models have a low correlation (< 0.75) when one desires to apply an stacking method. For testing correlation I used the `resamples` and `modelCor` functions from the [caret package] and found a very low correlation between my two models:


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

In the next step I fitted a model that combined the two predictors. For that purpose I first built a new dataset consisting of the predictions for the first model (RF), the predictions for the second model (SVM), and the `class` variable from the test dataset:


```r
predDF <- data.frame(pred.rf, pred.svm, class = testing$class)
 predDF_bc <- undersample_ds(predDF, "class", nsamples_class)
```
<br>

I fitted a new model with the Stochastic Gradient Boosting algorithm to relate this `class` variable to the two predictions and then I used it to predict on new samples:


```r
set.seed(123)
 combModFit.gbm <- train(as.factor(class) ~ ., method = "gbm", data = predDF_bc, distribution = "multinomial")
 combPred.gbm <- predict(combModFit.gbm, predDF)
```
<br>

By evaluating model performance on the test set, I found that the overall accuracy of the combined predictor was greater than the accuracy of both the first and the second predictors (0.9813 and 0.9678, respectively):


```r
confusionMatrix(combPred.gbm, testing$class)$overall[1]
```

```
 Accuracy 
0.9838786 
```
<br>

As the test set was used to blend the two models together, it does not offer a good representation of the out of sample error. Therefore I used the validation set, which is an independent dataset, to assess accuracy of the stacked model. So I created a prediction of my first model on the validation set and a prediction of my second model on this same validation set. Then I created a data frame that contained those two predictions and predicted using my combined model on the predictions in the validation dataset:


```r
pred1V <- predict(mod.rf, validation)
 pred2V <- predict(mod.svm, validation)
 predVDF <- data.frame(pred.rf = pred1V, pred.svm = pred2V)
 combPredV <- predict(combModFit.gbm, predVDF)
```
<br>

The overall accuracy from model 1 (RF) and model 2 (SVM) were 0.9817 and 0.9659, respectively, while the stacked model had a greater accuracy even on the validation dataset equal to 0.983, as shown below:


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

One way to try to understand how the combined predictor achieves a higher overall accuracy is to take a look at the producer's accuracy (aka sensitivity or recall) for the classes in the dataset:


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

For some classes (classes 2, 3 and 5), the stacked model showed a producer's accuracy higher than that of any of the separate models. For class 1, producer's accuracy of the stacked model was as high as that of the best separate model (RF), while for class 7 it was equal to the lowest (SVM). Overall, the model resulting from combining predictors showed greater accuracy over using RF or SVM alone which was achieved by blending the strenghts of different models together. 

Here is a Youtube video where you can watch the description of the steps shown above:

<iframe width="750" height="422" src="https://www.youtube.com/embed/8XWoBzwQ-m4" frameborder="0" allowfullscreen></iframe>

<br>

Here are the slides from the video:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/AwpnhGsdnDDugK" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/improving-classification-accuracy-through-model-stacking" title="Improving classification accuracy through model stacking" target="_blank">Improving classification accuracy through model stacking</a> </strong> by <strong><a href="//www.slideshare.net/amsantac" target="_blank">Ali Santacruz</a></strong> </div>

<br>

You can find the source code for the slides and the R script for this post available for [download from this link]. 

In general, I found model stacking to be a helpful technique for improving classification accuracy, although it may require several tries before finding a good model combination. If you're interested in further testing, there is an R package called [caretEnsemble] which provides several tools for assessing combinations of several classification or regression caret models. 

Well, hope you've learned something new with this post as I did. Happy coding and ensembling!

<br>


**You may also be interested in:**

&#42; [Image Classification with RandomForests in R (and QGIS)]

&#42; [Why it is important to work with a balanced classification dataset]

<a id="comments"></a>

[previous posts in my blog]: /blog/en/2015/11/28/classification-r.html
[Image Classification with RandomForests in R (and QGIS)]: /blog/en/2015/11/28/classification-r.html
[Why it is important to work with a balanced classification dataset]: /blog/en/2016/09/20/balanced-image-classification-r.html
[in my last post]: /blog/en/2016/09/20/balanced-image-classification-r.html
[USGS EarthExplorer]: http://earthexplorer.usgs.gov/
[caret package]: https://cran.r-project.org/package=caret
[caretEnsemble]: https://cran.r-project.org/package=caretEnsemble
[a previous post]: /blog/en/2015/11/28/classification-r.html
[the training data]: https://www.dropbox.com/sh/5sa8udavzumm66a/AAABoa-POOSNorcVIagX2Pu0a?dl=0
[download from this link]: https://www.dropbox.com/sh/5sa8udavzumm66a/AAABoa-POOSNorcVIagX2Pu0a?dl=0
[on GitHub]: https://github.com/amsantac/extras/tree/master/2016-09-20-balanced-image-classification-r
