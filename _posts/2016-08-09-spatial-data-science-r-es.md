---
layout: post-es
title:  "Introducción a Spatial Data Science con R"
date:   2016-08-07 11:02:52
categories: blog es
tags: R DataScience 
image: 2016-08-07-spatial-data-science-r-mini.jpg
published: true
---

Como profesional involucrado con el procesamiento de datos espaciales, he encontrado que muchos de los principios y buenas prácticas propuestos en Data Science pueden ser incorporados en el campo de los SIG y el procesamiento de imágenes para lograr mejorar los procesos de manejo y análisis de datos. Por ello, algunos de los posts que he publicado previamente en mi blog, entre ellos el de la [aplicación de Machine Learning a la clasificación de imágenes] y el de la [implementación de análisis espaciales reproducibles], han sido escritos con el propósito de acelerar la adopción de prácticas de Data Science en la profesión de la geomática.

Como parte de este esfuerzo continuo, y gracias a la invitación de [Raúl Jiménez], coordinador de la [comunidad de GeoDevelopers], recientemente di una charla, en formato webinar, sobre cómo Data Science puede ser aplicado a los datos espaciales. [GeoDevelopers] es una comunidad virtual muy activa y colaboradora con más de 800 desarrolladores SIG que comparten y crean contenido en temas como el desarrollo de apps geoespaciales, servicios en la nube y el procesamiento de datos, entre muchos otros.

<!--more-->

<a href="" class="image full"><img src="/images/2016-08-07-spatial-data-science-r-fig-0.png" alt="Spatial Data Science con R" title=""></a>

<br>

### **Contenido del webinar y materiales relacionados**

El webinar fue grabado en video y ya está disponible en YouTube como lo puedes ver más abajo. En la primera sección de la charla ([min. 2:54]) empiezo describiendo qué es Spatial Data Science y qué habilidades necesita tener un científico de datos espaciales. Luego explico qué características ofrece R para la realización de análisis espaciales y hago una breve introducción de las clases de R definidas para manejar datos espaciales.

En la segunda parte ([min. 16:37]) se presentan cada una de las fases de un proceso de Spatial Data Science a través de ejemplos prácticos ejecutados usando el lenguaje R, a saber:

<ul>
<li>
+ Acceso a los datos
</li>
<li>
+ Preparación y transformación de los datos
</li>
<li>
+ Exploración de datos
</li>
<li>
+ Modelación de datos
</li>
<li>
+ Visualización y comunicación de resultados
</li>
</ul>


En la última parte ([min. 44:03]) hablo sobre reproducibilidad en Spatial Data Science y presento ejemplos de cómo integrar el lenguaje R con algunos de los principales software SIG, incluyendo ArcGIS y QGIS.

A continuación puedes ver el video del webinar:

<iframe width="750" height="422" src="https://www.youtube.com/embed/EbbSY6EJ4js" frameborder="0" allowfullscreen></iframe>

<br>

Aquí puedes ver las diapositivas de la presentación:

<iframe src="//www.slideshare.net/slideshow/embed_code/key/bJKCQMK0hsH5b8" width="750" height="422" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/amsantac/spatial-data-science-con-r" title="Spatial Data Science con R" target="_blank">Spatial Data Science con R</a> </strong> por <strong><a target="_blank" href="//www.slideshare.net/amsantac">Alí Santacruz</a></strong> </div>

<br>

[En esta página] puedes encontrar los ejemplos de demostración de la aplicación del lenguaje R a Spatial Data Science, que están relacionados con las diapositivas 14 a 18, como se muestra después del [minuto 16:37] en el video.

El documento original escrito en RMarkdown (.Rmd) para estos ejemplos, así como los datos de muestra, se pueden descargar [desde este link]. Una vez descargues los materiales, deberías poder reproducir todos los ejemplos presentados en la charla ejecutando los fragmentos de código del archivo .Rmd, como se explica en el video. Las diapositivas del webinar pueden ser descargadas [desde este link][SlideShare].

Espero que esta charla te brinde nuevas ideas sobre cómo mejorar el procesamiento de datos geospaciales a través de la sinergia con Data Science. Hay mucho sobre qué discutir respecto a Spatial Data Science, asi que me encantaría conocer tus opiniones sobre este tema. Nos vemos en la sección de comentarios!

<br>

**También te puede interesar:**

&#42; [Análisis espaciales reproducibles con ArcPy y R usando Jupyter Notebook]

&#42; [Clasificación de imágenes con RandomForests en R (y QGIS)]

<a id="comments"></a>

[Raúl Jiménez]: https://es.linkedin.com/in/jimenezortegaraul/es
[comunidad de GeoDevelopers]: http://www.geodevelopers.org/
[GeoDevelopers]: http://www.geodevelopers.org/
[aplicación de Machine Learning a la clasificación de imágenes]: /blog/es/2015/11/28/classification-r-es.html
[implementación de análisis espaciales reproducibles]: /blog/es/2016/06/29/reproducibility-arcpy-jupyter-notebook-r-es.html
[Análisis espaciales reproducibles con ArcPy y R usando Jupyter Notebook]: /blog/en/2016/06/29/reproducibility-arcpy-jupyter-notebook-r.html
[Clasificación de imágenes con RandomForests en R (y QGIS)]: /blog/es/2015/11/28/classification-r-es.html
[R]: https://www.r-project.org/
[min. 2:54]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=2m54s
[min. 16:37]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=16m37s
[minuto 16:37]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=16m37s
[min. 44:03]: https://www.youtube.com/watch?v=EbbSY6EJ4js&t=44m03s
[En esta página]: http://amsantac.co/other/webinar/2016-07-13/spatial-data-science-r-webinar-es.html
[desde este link]: https://github.com/amsantac/extras/tree/master/2016-07-13-spatial-data-science-r-webinar
[SlideShare]: http://www.slideshare.net/amsantac/spatial-data-science-con-r

