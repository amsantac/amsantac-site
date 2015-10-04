---
layout: post
title:  "Using R for file stacking in CLASlite"
date:   2015-09-05 11:02:52
categories: blog en R 
tags: R CLASlite stacking landsat
published: true
---

[CLASlite] is a powerful image processing software developed by the [Carnegie Institution for Science] that provides functionality for calibration, pre-processing, atmospheric correction, cloud masking, Monte Carlo Spectral Mixture Analysis and classification. I describe in this post how to use the [R language] for creating the text files required by CLASlite for stacking imagery through batch processing. This is a simple application that shows R beginners how to make use of basic R functions such as file listing and for loops.

Usually the first step for processing imagery obtained in raw format is to stack the individual layers into a single file. CLASlite allows stacking Landsat imagery using the 'Prepare Landsat' tool which can be accessed from the Tools - Prepare Landsat menu in the CLASlite graphical user interface:

<img src="/images/2015-09-05-stacking-R-fig-1.png" alt="Prepare Landsat Tool in CLASlite" title="Prepare Landsat Tool in CLASlite" style="width:600px">

One pretty useful feature of CLASlite is that a number of processing and preprocessing tasks can be executed for several files at a time through batch processing. For example, the batched 'Prepare Landsat' tool requires the user to enter a CSV file that lists the absolute path of the folder of each Landsat image to be processed. Each folder must contain all the (unzipped) individual files (bands), which are usually obtained from a provider such as the [USGS].

CLASlite requires that the CSV file contains the character string: "LANDSAT_Folder_Names" in the first row, and the absolute path of the folder of each image in the following rows as can be seen below:

<img src="/images/2015-09-05-stacking-R-fig-2.png" alt="Prepare Landsat template" title="Prepare Landsat template" style="width:400px">

This template can be found in the 'templates' folder inside the directory where CLASlite is installed. We can create a small R script that help us to automate the creation of this CSV file avoiding therefore to waste time on a repetitive action such as manually copying/pasting to a text file. Let's assume that we have a set of images of a given region that have been stored separately by year, as it would be the case for a land cover change study:

<img src="/images/2015-09-05-stacking-R-fig-3.png" alt="Folder structure" title="Folder structure" style="width:800px">

The purpose of our R script will be to list all the folders inside each year folders which are contained in the 'images' folder. Let's assume that we have stored images from 2000 to 2015 in our example, so let's create an integer object in R that lists the sequence of years. Let's also create a null object where we will iteratively add the list of folders for each year, and a character object to store the path to our top-level folder 'images':

```
years <- 2000:2014
foldersList <- NULL
path <- "C:/images"
```
<br>
Now we can use a `for` loop to, first, create the absolute path to the folder of each year (`path_year`), list the folders inside the `path_year` folder using the `list.dirs` function, and then add this list of folders to the `foldersList` object. This will be done iteratively for each year in the `years` sequence. Sounds complicated uh? Well, the actual code is quite simple:

```
for (year in years){
  path_year <- paste0(path, "/", year)
  foldersList <- c(foldersList, list.dirs(path_year, recursive = FALSE))
}
```
<br>
Finally we can create a data frame to store the folders list giving the required name to the data column (i.e., "LANDSAT_Folder_Names"):

```
foldersListDF <- data.frame("LANDSAT_Folder_Names" = foldersList)
```
<br>
Usually it is advisable to write a script as a function to facilitate its use in the future. This requires the definition of the required parameters that the function needs to be run. Only two parameters are required in this case, the path to the top-level folder and the sequence of years. Thus, our function, which I have named here as `stackImgTable4csv`, can be defined as:

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
With a function defined this way, we just need to call the function and provide the arguments for each of the parameters and the name for the output object (e.g., `outDF`):

```
path <- "C:/images"
years <- 2000:2014
outDF <- stackImgTable4csv(path, years)
```
<br>
Then we can write the ouput data frame to a CSV file that will be loaded into CLASlite. For the `write.csv` function, we must enter the data to be written and the name of the ouput file (e.g., "stack_2000_2014.csv"). We also have to indicate that the row names must not be written and that the character strings must not be surrounded by double quotes in the ouput file. This is quite important for the CSV file to be read correctly by CLASlite:

```
write.csv(outDF, file = "stack_2000_2014.csv", row.names = FALSE, quote = FALSE)
```
<br>
Finally we can go back to CLASlite and use the CSV file that we just created. Open CLASlite and click "Tools" - "Prepare Landsat". Select "Batch Process" and click the "Load File" button to browse and select the output CSV file created previously. Finally click the "Stack" button. As a result of the stacking process, you should find raw and thermal files in each image folder:

<img src="/images/2015-09-05-stacking-R-fig-4.png" alt="Output folder" title="Ouput folder" style="width:800px">

Hope you found this post helpful! In the next post I will explain how we can use R to automatically create the text files required by CLASlite for producing atmospherically-corrected imagery. See you then! 

<br>
<br>
**You may be also interested in:**

&#42; [Prepare files for production of atmospherically-corrected imagery in CLASlite using R]

<a id="comments"></a>

[CLASlite]:                         http://claslite.carnegiescience.edu/
[R language]:                       http://r-project.org
[Carnegie Institution for Science]: https://carnegiescience.edu/
[USGS]:                             http://www.usgs.gov
[Prepare files for production of atmospherically-corrected imagery in CLASlite using R]: /blog/en/r/claslite/reflectance/landsat/2015/10/03/reflectance-R.html

