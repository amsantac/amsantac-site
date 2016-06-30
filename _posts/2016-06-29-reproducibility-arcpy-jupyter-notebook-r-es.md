---
layout: post-es
title:  "Análisis espaciales reproducibles con ArcPy y R usando Jupyter Notebook"
date:   2016-06-29 11:02:52
categories: blog es
tags: R ArcPy ArcGIS SIG PercepcionRemota 
image: 2016-06-29-reproducibility-arcpy-jupyter-notebook-r-mini.jpg
published: true
---

Reproducibilidad, la capacidad de un estudio de ser replicado, es uno de los conceptos centrales en lo que se conoce como ciencia de datos (o *Data Science*). Si bien preparar análisis de datos de tal forma que sean reproducibles no es una tarea trivial, hacerlo puede conducir a un conjunto de beneficios para el analista o investigador haciendo su trabajo mucho más eficiente: puede ayudar a ahorrar tiempo a través de la reutilización de código y de resultados de estudios anteriores al igual que a través de la aplicación sobre datos nuevos de metodologías establecidas previamente.

Entre las diferentes herramientas que han sido desarrolladas para ayudar a la implementación de análisis reproducibles, los notebooks interactivos han ido ganando en popularidad y aceptación. Estos son ambientes computacionales basados en la web en los cuales es posible integrar fragmentos de código, texto descriptivo, gráficos y multimedia. En este post me enfoco en la herramienta [Jupyter Notebook] y describo particularmente cómo usarla para crear reportes reproducibles que combinen análisis geoespaciales basados en [ArcPy] y [R]. En las siguientes secciones explico cómo instalar y configurar Jupyter Notebook para trabajar con ArcPy y R, y posteriormente presento un ejemplo práctico.
<!--more-->

<a href="" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-0.png" alt="Análisis espaciales reproducibles con ArcPy y R usando Jupyter Notebook" title=""></a>

<br>

### **Instalación y configuración de Jupyter Notebook**

La forma más fácil de instalar Jupyter Notebook es a través de [Anaconda]. Para usar Jupyter con ArcPy es necesario descargar la distribución de Anaconda que venga con la misma versión de Python instalada por ArcGIS. En mi caso necesité la versión de 32 bits para Python 2.7. Aquellos usuarios que trabajen con ArcGIS Pro pueden necesitar descargar Anaconda para Python 3.x.

En la instalación de Anaconda hay un paso importante que se debe tener en cuenta: de acuerdo con [esta referencia en internet], las dos casillas en el cuadro de diálogo ‘Advanced Installation Options’ deben ser deshabilitadas para evitar desconfigurar ArcGIS. Por lo tanto debes desactivar ambas opciones, 'Add Anaconda to my PATH environment variable', y 'Register Anaconda as my default Python':

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-1.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-1.jpg" alt="" title=""></a>

Cuando realicé la instalación en mi computador no fue posible ejecutar Anaconda ya que los comandos no fueron reconocidos por el sistema, probablemente debido a que la opción para adicionar Anaconda a la variable Path del sistema fue deshabilitada. Si encuentras el mismo problema puedes intentar adicionar manualmente la ruta de la carpeta Scripts que se halla dentro del folder de instalación de Anaconda ('C:\Users\Guest\Anaconda2\Scripts' en mi instalación) a la variable Path del sistema usando el Panel de Control de Windows:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-2.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-2.jpg" alt="" title=""></a>

Para probar que Jupyter Notebook se instaló exitosamente, abre una consola de comandos de Windows (cmd, también llamado símbolo del sistema), teclea `jupyter notebook` y pulsa Enter. Deberías ver que el notebook se abre en tu navegador de internet:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-3.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-3.jpg" alt="" title=""></a>


### **Configuración de Anaconda para trabajar con ArcGIS y R**

**El primer paso** para configurar Anaconda tal que se pueda usar con ArcGIS es averiguar cuál versión de numpy y matplotlib está usando ArcGIS. Para ello inicia ArcMap, abre una ventana de Python y ejecuta las siguientes líneas:

```
>>> import sys, numpy, matplotlib
>>> print(sys.version, numpy.__version__, matplotlib.__version__)
```
<br>

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-4.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-4.JPG" alt="" title=""></a>

Luego es necesario crear un ambiente de Anaconda que sea compatible con los tres módulos mencionados arriba. Inicia una consola de comandos de Anaconda como administrador y corre la siguiente orden: 

```
conda create -n arc1031 python=2.7.10 numpy=1.7.1 matplotlib=1.3.0 pyparsing xlrd xlwt
```
<br>

`arc1031` es el nombre que yo le he dado al nuevo ambiente (tú puedes usar cualquier nombre que desees). Después de que finalice la instalación puedes cambiar al nuevo ambiente ejecutando `activate arc1031` en la consola de comandos.

**El segundo paso** es hacer que Anaconda ‘vea’ a ArcGIS y viceversa. Sigue estas instrucciones:

<ul>
<li>
Busca la carpeta ‘site-packages’ dentro de la carpeta de ArcGIS que se crea cuando ArcGIS instala su versión de Python ('C:\Python27\ArcGIS10.3\Lib\site-packages' en mi instalación). En esta carpeta crea un nuevo archivo path (.pth). Incluye en este archivo la ruta a la carpeta ‘site-packages’ que se encuentra localizada dentro de la carpeta de instalación de Anaconda (e.g., C:\Users\Guest\Anaconda2\Lib\site-packages). 
</li>
<br>
<li>
Copia el archivo Desktop10.3.pth que se encuentra en la carpeta ‘site-packages’ y ('C:\Python27\ArcGIS10.3\Lib\site-packages') y pégalo en la carpeta de instalación de Anaconda ('C:\Users\Guest\Anaconda2' en mi instalación). Si trabajas con ArcGIS Pro, entonces debes copiar el archivo ArcGISPro.pth.
</li>
</ul>

Para probar si Jupyter efectivamente es capaz de ver ArcPy, abre una consola de comandos, activa el ambiente que creastes e inicia Jupyter Notebook. Luego crea un nuevo notebook de Python, escribe `import arcpy` en una celda vacía y corre la celda (Ctrl+Enter). Si no te sale error, felicidades! Eso significa que el proceso de configuración fue exitoso:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-5.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-5.JPG" alt="" title=""></a>

Para la parte final, **instala el kernel para R** para hacer que Jupyter sea capaz de ejecutar comandos de R. Para ello ingresa a [irkernel.github.io], copia las instrucciones para la instalación del kernel, y pégalas en una consola de R:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-7.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-7.jpg" alt="" title=""></a>

Eso es todo! La próxima vez que inicies Jupyter Notebook deberías ver la opción para iniciar un notebook de R cuando hagas clic en el botón ‘New’:

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-6.JPG" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-6.JPG" alt="" title=""></a>

Para una explicación más detallada del proceso de instalación mira el siguiente video:

<iframe width="750" height="422" src="https://www.youtube.com/embed/mPkC0FJJRvw" frameborder="0" allowfullscreen></iframe>

<br>

### **Ejemplo reproducible de procesamiento de datos espaciales con ArcPy y R en un Jupyter Notebook**

Una vez hayamos configurado Jupyter Notebook tendremos todas las herramientas necesarias para realizar procesamiento avanzado de datos espaciales usando no solamente Python sino también R todo desde el mismo ambiente. El video siguiente muestra un ejemplo de procesamiento de datos raster donde en primer lugar R es utilizado para recortar la extensión de una imagen clasificada. Luego ArcPy se usa para aplicar un filtro espacial (majority) para remover celdas aisladas. Finalmente se hace una comparación de los histogramas de la imagen recortada vs. la imagen con filtro usando R nuevamente. Todos los pasos se ejecutan en el mismo notebook.

<iframe width="750" height="422" src="https://www.youtube.com/embed/bbjp0qYbyAQ" frameborder="0" allowfullscreen></iframe>

<br>

Los notebooks de Jupyter se pueden compartir muy fácilmente a través de email, Dropbox, GitHub y [Jupyter Notebook Viewer]. Puedes ver cómo el notebook del ejemplo presentado arriba es visualizado apropiadamente [en GitHub] y [en nbviewer].

<a href="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-8.jpg" class="image full"><img src="/images/2016-06-29-reproducibility-arcpy-jupyter-notebook-r-fig-8.jpg" alt="" title=""></a>

Los productos generados son idénticos a como se ven en nuestro computador.

Puedo decir que estos notebooks de Jupyter me han llamado bastante la atención. Su capacidad de incorporar el código y sus salidas justo al lado del texto explicativo en el mismo documento realmente facilita la generación de reportes reproducibles. Además estos notebooks permiten incluir elementos interactivos (widgets) que pueden ser utilizados para potenciar la manipulación y visualización de datos.

Si llegas a crear tus propios documentos reproducibles con Jupyter Notebook demostrando el procesamiento de datos espaciales por favor compártelos en la sección de comentarios de este post. Me encantaría verlos! 

<br>

**También te puede interesar:**

&#42; [arcgisbinding: Evaluando la nueva interfaz de ArcGIS para el lenguaje R]

<a id="comments"></a>

[Jupyter Notebook]: http://jupyter.org/
[ArcPy]: http://desktop.arcgis.com/es/arcmap/10.3/analyze/arcpy/what-is-arcpy-.htm
[R]: https://www.r-project.org/
[Anaconda]: https://www.continuum.io/downloads

[this web page]: https://geonet.esri.com/groups/spatial-data-science/blog/2016/02/11/connecting-arcpy-to-your-jupyter-notebook
[esta referencia en internet]: https://my.usgs.gov/confluence/pages/viewpage.action?pageId=540116867
[Jupyter Notebook Viewer]: http://nbviewer.jupyter.org/

[irkernel.github.io]: http://irkernel.github.io/installation/

[nbviewer]: http://nbviewer.jupyter.org/

[arcgisbinding: Evaluando la nueva interfaz de ArcGIS para el lenguaje R]: /blog/es/2016/04/30/arcgis-r-es.html

[en GitHub]: https://github.com/amsantac/extras/blob/master/2016-06-29-reproducibility-arcpy-jupyter-notebook-r/Reproducible%20spatial%20analyses%20with%20ArcPy%20and%20R.ipynb
[en nbviewer]: http://nbviewer.jupyter.org/github/amsantac/extras/blob/master/2016-06-29-reproducibility-arcpy-jupyter-notebook-r/Reproducible%20spatial%20analyses%20with%20ArcPy%20and%20R.ipynb
