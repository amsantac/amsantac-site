## Script 1

## path to folder to look for all "_refl" files
fPath <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"

## create destiny folder 
destFolder <- paste0(fPath, "/", "refl_CLmasked")
dir.create(destFolder)

## years to move files for
years <- 2001:2014

for (year in years){
  print(paste0("saving year ", year, "..."))
  
  ## search for "_refl" files in the source folder (a given year)
  sourceFolder <- paste0(fPath, "/", year)
  reflFiles <- list.files(sourceFolder, pattern = "_refl", recursive = TRUE)
  
  ## absolute path for all "_refl" files
  filesPaths <- paste0(sourceFolder, "/", reflFiles)
  
  ## create destiny folder
  destFolderYear <- paste0(destFolder, "/", year)
  dir.create(destFolderYear)
  
  ## copy files to destiny folder
  file.copy(filesPaths, destFolderYear)
  
  ## remove files from source folder
  file.remove(filesPaths)
}

## Script 2 (deprecated)

## path to folder to look for all "_refl" files
fPath <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"

## find relative file path for all "_refl" files
reflFiles <- list.files(fPath, pattern = "_refl", recursive = TRUE)

## absolute path for all "_refl" files
filesPaths <- paste0(fPath, "/", reflFiles)

for (i in 1:(length(filesPaths)/2)){ 
  
  print(paste0(i, " of ", length(filesPaths)/2))
  
  ## extract folder path for every 2 files to be copied
  filePathElem <- unlist(strsplit(filesPaths[2 * (i-1) + 1], "/"))
  folderPath <- paste(filePathElem[1:(length(filePathElem) - 1)], collapse = "/")
  reflFolderPath <- paste0(folderPath, "/refl_CLmasked")
  
  ## create folder if it does not exist yet
  if(!dir.exists(reflFolderPath)){
  dir.create(reflFolderPath)
    }
  
  ## copy "_refl" files to "refl_CLmasked" folder
  file.copy(filesPaths[2 * (i-1) + 1:2], reflFolderPath)
  
  ## delete files from source folder
  file.remove(filesPaths[2 * (i-1) + 1:2])
}