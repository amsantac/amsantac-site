library(knitr)

setwd("C:/amsantac/other/git/cuproject")

## files to be processed
files <- c("index", "phase1")
header <- "www/header.html"
footer <- "www/footer.html"

for (file_i in files){ 
  
  ## knit md file
  mdFile <- paste0("md/", file_i, ".md")
  htmlFile <- paste0(file_i, ".html")
  knit2html(mdFile, htmlFile)
  
  ## read temporary html file
  htmlLines <- readLines(htmlFile)
  
  ## replace header and footer in temporary html file
  suppressWarnings(newHTML <- c(readLines(header), htmlLines[(which(htmlLines == "<body>") + 1) : 
                                                             (which(htmlLines == "</body>") - 1)], readLines(footer)))
  
  ## write output html file
  writeLines(newHTML, htmlFile)
  if(file.exists(paste0(file_i, ".txt"))) file.remove(paste0(file_i, ".txt"))
}
