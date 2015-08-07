## load the Google Sheet with landsat imagery data 
library(gsheet)
url <- 'docs.google.com/spreadsheets/d/1HMtOeW7eo_KRrg6BND2eItIp7VS1p0e_YWS3_YHaYEM'
dat <- gsheet2tbl(url)
years <- 2000:2014

## get list of images per year as a string
images <- NULL
for (year in years){
images <- c(images, year, paste(unlist(subset(dat, Year == year, select = LID)), collapse = ", "))
}
images
write.csv(images, "images.csv", quote = FALSE, row.names = FALSE)

## create lines to add landsat images on GEE js
lines <- NULL
for (year in years){
subyear <- subset(dat, Year == year, select = c(Path, Row, LID, Landsat.type))
ltype <- function(x, type) {
  switch(x,
         "Landsat 5" = "LT5",
         "Landsat 7 SLC-off" = "LE7",
         "Landsat 7 SLC-on" = "LE7",
         "Landsat 8" = "LC8"
  )
}
# lines <- c(lines, year, paste0("var image", 1:dim(subyear)[1], "_", subyear[[1]], "_", subyear[[2]], " = ee.Image('LEDAPS/",  
#       apply(subyear[4], 1, ltype), "_L1T_SR/", subyear[[3]], "');")) 
lines <- c(lines, year, paste0("var image", 1:dim(subyear)[1], " = ee.Image('LEDAPS/",  
       apply(subyear[4], 1, ltype), "_L1T_SR/", subyear[[3]], "');")) 
}
lines
write.csv(lines, "lines.csv", quote = FALSE, row.names = FALSE)
