---
layout: post
title:  "Reproducible spatial analyses with ArcPy and R using Jupyter Notebook"
date:   2016-06-29 11:02:52
categories: blog en
tags: R ArcPy ArcGIS GIS RemoteSensing 
image: 2016-06-29-reproducibility-arcpy-jupyter-notebook-r-mini.jpg
published: false
---

Reproducibility, the ability of an entire study to be replicated, is one of the core concepts in data science. Although preparing data analyses so they are reproducible is not a trivial task, it can bring many benefits and make a researcher's life much easier: it can help to save time by allowing reuse of code and results from past studies or by allowing application of previously defined methodologies on new data.

Among the different tools that have been developed for helping (data) scientists to implement reproducible analyses, web-based notebooks are gaining increased popularity. These are interactive computational environments where code snippets, explanatory text, graphics and media can be integrated. In this post I am going to focus on [Jupyter Notebooks] and particularly on how to use them to create reproducible reports that combine [ArcPy]- and [R]-based geospatial analyses. Below I explain how to install and configure Jupyter Notebook to work with ArcPy and R and later I provide a practical example.
<!--more-->

<a href="" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-0.png" alt="Reproducible spatial analyses with ArcPy and R using Jupyter Notebook" title=""></a>

<br>

### **Install and configure Jupyter Notebook**

The easiest way to get Jupyter Notebook is by installing [Anaconda]. For using Jupyter with ArcPy it is necessary to download the Anaconda distribution that comes with the same Python version installed by ArcGIS. In my case I needed the 32-bit version for Python 2.7. Users that work with ArcGIS Pro may need to download Anaconda for Python 3.x.   

There is one important step to be aware for Anaconda installation: according to [this reference online] the two checkboxes in the Advanced Installation Options dialog must be disabled to avoid breaking ArcGIS. So uncheck both 'Add Anaconda to my PATH environment variable', and uncheck 'Register Anaconda as my default Python':

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-1.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-1.jpg" alt="" title=""></a>

When I made the installation in my computer, I was not able to run Anaconda as the commands were not recognized by the system, probably because the option for adding Anaconda to the Path variable was disabled. I solved that issue by manually adding the path of the Scripts folder in the Anaconda installation folder ('C:\Users\Guest\Anaconda2\Scripts' in my installation) to the Path system variable using the Control Panel on Windows:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-2.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-2.jpg" alt="" title=""></a>

For testing that Jupyter Notebook was successfully installed open a command shell, type `jupyter notebook` and hit enter. You should see the notebook open in your web browser:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-3.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-3.jpg" alt="" title=""></a>


### **Configure Anaconda to work with ArcGIS and R**

**The first step** to configure Anaconda for use with ArcGIS is to find out what versions of numpy and matplotlib ArcGIS is using. So start ArcMap, open a Python window and type the following:

```
>>> import sys, numpy, matplotlib
>>> print(sys.version, numpy.__version__, matplotlib.__version__)
```
<br>

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-4.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-4.JPG" alt="" title=""></a>

Then it is necessary to create an Anaconda environment compatible with the three modules mentioned above. Open an Anaconda command prompt as administrator and type the following: 

```
conda create -n arc1031 python=2.7.10 numpy=1.7.1 matplotlib=1.3.0 pyparsing xlrd xlwt
```
<br>

`arc1031` is the name I gave to the new environment (you can use any name you want). After the installation is finished you can change to this new environment by typing `activate arc1031` in the command shell.

**The second step** is to make sure that Anaconda 'sees' ArcGIS and vice versa. Follow these instructions:

<ul>
<li>
- Find the 'site-packages' folder inside the ArcGIS folder that is created when ArcGIS installs its Python version ('C:\Python27\ArcGIS10.3\Lib\site-packages' in my installation). In this folder create a new path (.pth) file. Include in this file the path to the 'site-packages' folder that is located inside the Anaconda installation folder (e.g., C:\Users\Guest\Anaconda2\Lib\site-packages). 
</li>
<br>
<li>
- Copy the Desktop10.3.pth file located in the 'site-packages' folder ('C:\Python27\ArcGIS10.3\Lib\site-packages') and paste it into the Anaconda installation folder ('C:\Users\Guest\Anaconda2' in my installation). If you are working with ArcGIS Pro, you have to copy the ArcGISPro.pth file instead.
</li>
</ul>

To test if Jupyter effectively sees ArcPy, open a command shell, activate the environment you created and start Jupyter Notebook. Then create a new Python notebook, type `import arcpy` in an empty cell and run the cell (Ctrl+Enter). If you don't get an error, congratulations! That means the set up was successful:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-5.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-5.JPG" alt="" title=""></a>


For the final part, **install the R kernel** to make Jupyter able to execute R commands. Go to [irkernel.github.io], copy the instructions for installing the kernel and paste them into an R console:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-7.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-7.JPG" alt="" title=""></a>

That's it! Next time you start Jupyter Notebook you should see the option to start an R notebook when you click the 'New' button:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-6.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-6.JPG" alt="" title=""></a>

For a more detailed explanation of the whole installation process watch the following video:

<iframe width="750" height="422" src="https://www.youtube.com/embed/wQk-0xETGbc" frameborder="0" allowfullscreen></iframe>

<br>

### **Processing spatial data with ArcPy and R in a Jupyter Notebook: A reproducible example**

Once Jupyter Notebook is configured, we have all the needed tools to apply advanced processing of spatial data using not only Python but also R commands, all in the same environment. The video below shows an example of raster data processing where first R is used to crop a classified image to reduce its spatial extent. Then ArcPy is used to apply a majority filter to remove single cells. Finally the comparison of the histograms of the cropped and filtered images is performed with R again. All the steps are conducted in the same notebook.

<iframe width="750" height="422" src="https://www.youtube.com/embed/fRkmQAYQB3Y" frameborder="0" allowfullscreen></iframe>

<br>

Jupyter Notebooks can be easily shared using email, Dropbox, GitHub and the [Jupyter Notebook Viewer]. You can see how the notebook for the example presented above is appropriately rendered [on GitHub] and [on nbviewer]:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-8.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-8.JPG" alt="" title=""></a>

The rendered products are identical to what we see locally.
 
I've found Jupyter Notebooks really engaging. Their ability for including code output along with narrative in the same document greatly facilitates production of reproducible reports. Furthermore web-based notebooks offer support for interactive widgets which can be used to enhance data manipulation and visualization.

If you create your own reproducible documents with Jupyter Notebook showing spatial data processing please share them in the comments section below. I'd love to see them! 

<br>

**You may also be interested in:**

&#42; [arcgisbinding: Testing the new ArcGIS interface for the R language]

<a id="comments"></a>

[Jupyter Notebooks]: http://jupyter.org/
[ArcPy]: http://desktop.arcgis.com/en/arcmap/10.3/analyze/arcpy/what-is-arcpy-.htm
[R]: https://www.r-project.org/
[Anaconda]: https://www.continuum.io/downloads

[this web page]: https://geonet.esri.com/groups/spatial-data-science/blog/2016/02/11/connecting-arcpy-to-your-jupyter-notebook
[this reference online]: https://my.usgs.gov/confluence/pages/viewpage.action?pageId=540116867
[Jupyter Notebook Viewer]: http://nbviewer.jupyter.org/

[irkernel.github.io]: http://irkernel.github.io/installation/

[nbviewer]: http://nbviewer.jupyter.org/
[their version of notebooks based on RMarkdown]: https://www.youtube.com/watch?v=zNzZ1PfUDNk

[arcgisbinding: Testing the new ArcGIS interface for the R language]: /blog/en/2016/04/30/arcgis-r.html

[on GitHub]: https://github.com/amsantac/extras/blob/master/2016-06-25-reproducibility-arcpy-jupyter-notebook-r/Reproducible%20spatial%20analyses%20with%20ArcPy%20and%20R.ipynb
[on nbviewer]: http://nbviewer.jupyter.org/github/amsantac/extras/blob/master/2016-06-25-reproducibility-arcpy-jupyter-notebook-r/Reproducible%20spatial%20analyses%20with%20ArcPy%20and%20R.ipynb
