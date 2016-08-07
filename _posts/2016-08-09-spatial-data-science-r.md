---
layout: post
title:  "Intro to Spatial Data Science with R"
date:   2016-08-07 11:02:52
categories: blog en
tags: R DataScience 
image: 2016-08-07-spatial-data-science-r-mini.jpg
published: true
---

As a professional working with spatial data, I've found that many of the principles and good practices proposed in Data Science can be incorporated into the GIScience and remote sensing fields for improving our data handling and analyzing processes. Previous posts in my blog, such as those covering [machine learning application to image classification] and [implementation of reproducible spatial analysis], have been written with the intention of accelerating adoption of Data Science practices into the profession.  

As part of this continuing effort, and thanks to an invitation by [Raul Jimenez], coordinator of the [GeoDevelopers community], I recently gave a talk, in webinar format, about how Data Science can be applied to the analysis of spatial information. [GeoDevelopers] is a very active and friendly online community with more than 800 GIS developers sharing and creating content regarding geospatial apps development, cloud services and data processing, among many other topics.

<!--more-->

<a href="" class="image full"><img src="/images/2016-08-07-spatial-data-science-r-fig-0.png" alt="Spatial Data Science with R" title=""></a>

<br>

### **Webinar content and related materials**

The webinar was recorded on video and is now available on YouTube as you'll find below. In the first section of the talk ([min 2:54]) I start describing what Spatial Data Science is and what skills spatial data scientists need. Then I explain what features R offers for conducting spatial analyses and provide a brief introduction to R classes defined for handling spatial objects.

In the second part ([min 16:37]) each of the phases of a Spatial Data Science process is presented through practical examples using the R language, namely:

<ul>
<li>
+ Data access 
</li>
<li>
+ Data preparation and transformation
</li>
<li>
+ Data exploration
</li>
<li>
+ Data modeling
</li>
<li>
+ Results communication and visualization
</li>
</ul>


In the last part ([min 44:03]) I talk about reproducibility in Spatial Data Science and also provide examples on how to integrate the R language with some of the main GIS software programs, including ArcGIS y QGIS.

Below you find the webinar recording with English subtitles (click the CC button on the bottom right):

<iframe width="750" height="422" src="https://www.youtube.com/embed/EbbSY6EJ4js" frameborder="0" allowfullscreen></iframe>

<br>

Here are the all the slides fully translated to English:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/2Jsm4B9GkmlVuA" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/spatial-data-science-with-r" title="Spatial Data Science with R" target="_blank">Spatial Data Science with R</a> </strong> by <strong><a target="_blank" href="//www.slideshare.net/amsantac">Ali Santacruz</a></strong> </div>

<br>

You can find [in this web page] the examples demonstrating application of the R language to Spatial Data Science, related to slides 14-18, as shown after [minute 16:37] in the video.

The original document written in RMarkdown (.Rmd) for these examples, as well as the sample data, can be downloaded [from this link]. Once you download these materials, you should be able to reproduce all the examples shown in the talk by running the code chunks in the .Rmd file, as explained in the video. The slides can be downloaded [from this link][SlideShare].

Hope this talk brings new insights to you on how to improve geospatial data processing through its sinergy with Data Science. There's plenty of room for discussion regarding the field of Spatial Data Science, so I'd be glad to hear your thoughts on this topic. See you in the comments section!

<br>

**You may also be interested in:**

&#42; [Reproducible spatial analyses with ArcPy and R using Jupyter Notebook]

&#42; [Image Classification with RandomForests in R (and QGIS)]

<a id="comments"></a>

[Raul Jimenez]: https://es.linkedin.com/in/jimenezortegaraul
[GeoDevelopers community]: http://www.geodevelopers.org/
[GeoDevelopers]: http://www.geodevelopers.org/
[machine learning application to image classification]: /blog/en/2015/11/28/classification-r.html
[implementation of reproducible spatial analysis]: /blog/en/2016/06/29/reproducibility-arcpy-jupyter-notebook-r.html
[Reproducible spatial analyses with ArcPy and R using Jupyter Notebook]: /blog/en/2016/06/29/reproducibility-arcpy-jupyter-notebook-r.html
[Image Classification with RandomForests in R (and QGIS)]: /blog/en/2015/11/28/classification-r.html
[R]: https://www.r-project.org/
[min 2:54]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=2m54s
[min 16:37]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=16m37s
[minute 16:37]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=16m37s
[min 44:03]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=44m03s
[in this web page]: http://amsantac.co/other/webinar/2016-07-13/spatial-data-science-r-webinar.html
[from this link]: https://github.com/amsantac/extras/tree/master/2016-07-13-spatial-data-science-r-webinar
[SlideShare]: http://www.slideshare.net/amsantac/spatial-data-science-with-r
