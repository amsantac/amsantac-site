Go to Processing - Options...

Go to Providers and click R scripts. Then mark the checkbox for activating R scripts. Note the folder for the R scripts.

At the bottom of the Processing Toolbox select "Advanced interface" instead of "Simplified interface"

Go to R scripts - Tools and click "Create new R script"

Copy and paste the following code:

##polyg=vector
##numpoints=number 10
##output=output vector
##sp=group
pts=spsample(polyg,numpoints,type="random")
output=SpatialPointsDataFrame(pts, as.data.frame(pts))

Then click the icon to save the script. In the new window you will see that you are located at the rscripts folder (e.g., /user/.qgis2/processing/rscripts) and that the file will be saved as a 'Processing R script'. Provide a name for the file and click 'Save'. The file will be saved with a '.rsx' extension.

Click the 'Run algorithm' button. You should a new dialog with three tabs: 'Parameters', 'Log' and 'Help'. 


## A raster example

##showplots
##index=raster
##boolean=raster
##mask=raster
##nthres=number 10
##TOC=group
library(TOC)
>plot(TOC(raster(index, 1), raster(boolean, 1), raster(mask, 1), nthres))

Click the 'Run algorithm' button. You should a new dialog with three tabs: 'Parameters', 'Log' and 'Help'. 
