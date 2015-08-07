## **Phase 1: Spatial dynamics and drivers of land-cover change**

The first phase of this research is the analysis of the spatial dynamic and drivers of land-cover change. The following sections are shown below:

1. [Data sources](#data-sources)
2. [Methods](#methods)
3. [Results](#results)
4. [References](#references)

### <a id="data-sources"></a>Data sources 
* Landsat 5 TM, Landsat 7 ETM+ and Landsat 8 OLI/TIRS imagery from [USGS](http://landsat.usgs.gov/index.php).
* [WRS-2 descending grid](http://landsat.usgs.gov/tools_wrs-2_shapefile.php). 

### <a id="methods"></a>Methods 

#### *Image selection*
* Landsat imagery was selected for <a href="www/landsat_scenes.html" target="_blank">12 scenes</a> for the time period between 2000 and 2016. One Landsat image was selected for each scene for each year, for a total of 204 Landsat scenes. Landsat 5 and Landsat 7 imagery was selected for years 2000 to 2011. Landsat 8 images were used for years 2013 to 2016.
* Landsat scenes with low or none cloud cover over the [study area](index.html#study-area) were preferred. Landsat 5 and Landsat 7 SLC-on scenes were preferred over Landsat 7 SLC-off scenes. Images taken during the dry season (January-March) were preferred over images taken in other months over the year when possible.
* Landsat 5 and Landsat 7 imagery was selected using the [USGS EarthExplorer](http://earthexplorer.usgs.gov/). Landsat 8 imagery was selected using the [Libra browser](https://libra.developmentseed.org/). All the imagery was downloaded using the [Landsat Data Bulk Download utility](http://earthexplorer.usgs.gov/bulk).
* The __complete list of the selected Landsat imagery__ can be seen <a href="https://docs.google.com/spreadsheets/d/1HMtOeW7eo_KRrg6BND2eItIp7VS1p0e_YWS3_YHaYEM/edit?usp=sharing" target="_blank">**here**</a>. This list also shows cloud cover, acquisition date and progress in image processing as well as a link to each scene thumbnail.

#### *Image preparation*
* Landsat bands were stacked for each image using the [CLASlite](http://claslite.carnegiescience.edu/en/) software ([Asner et al., 2009](#asner_etal_2009)). An <a href="https://github.com/amsantac/cuproject/blob/gh-pages/code/stackImgTable4csv.R" target="_blank">R script</a> was used to create the <a href="https://github.com/amsantac/cuproject/blob/gh-pages/other/processing/landsat/CLASliteCSVs/stack_2000_2014.csv" target="_blank">csv file</a> required for stacking the Landsat images through batch processing in CLASlite.
* Radiometric calibration and atmospheric correction were conducted on every Landsat image using CLASlite. CLASlite uses conversion factors (aka gains) to convert units of digital numbers into units of radiance. Then CLASlite uses the 6S radiative transfer model ([Vermote et al., 1997](#vermote_etal_1997)) to simulate the Earth's atmospheric atmosphere in each satellite image and to covert the radiance values to surface reflectance. No masking of clouds/cloud shadows/water was conducted with CLASlite at this step. An <a href="https://github.com/amsantac/cuproject/blob/gh-pages/code/reflectanceImgTable4csv.R" target="_blank">R script</a> was used to create the <a href="https://github.com/amsantac/cuproject/blob/gh-pages/other/processing/landsat/CLASliteCSVs/reflectance" target="_blank">csv files</a> required for image calibration through batch processing in CLASlite.    

### <a id="results"></a>Results 
* In progress.

Table 1

<iframe id="lp_t1" frameborder="0" scrolling="no" width=700 height=460 marginheight="0" marginwidth="0" src="https://docs.google.com/spreadsheets/d/1HMtOeW7eo_KRrg6BND2eItIp7VS1p0e_YWS3_YHaYEM/pubhtml?gid=1294784214&single=true"></iframe>

Table 2

<iframe id="lp_t2" frameborder="0" scrolling="no" width=700 height=400 marginheight="0" marginwidth="0" src="https://docs.google.com/spreadsheets/d/1HMtOeW7eo_KRrg6BND2eItIp7VS1p0e_YWS3_YHaYEM/pubhtml?gid=1521379850&single=true"></iframe>

video


### <a id="references"></a>References 
* <a id="asner_etal_2009"></a>Asner, G.P., Knapp, D.E., Balaji, A., Paez-Acosta, G. 2009. Automated mapping of tropical deforestation and forest degradation: CLASlite. Journal of Applied Remote Sensing 3: 033543.
* <a id="vermote_etal_1997"></a>Vermote, E.F., Tanre, D., Deuze, J.L., Herman, M., Morcrette, J.-J. 1997. Second Simulation of the Satellite Signal in the Solar Spectrum, 6S: An Overview. IEEE Transactions on Geoscience and Remote Sensing 35 (3), 675-686.
