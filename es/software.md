---
layout: default-soft-es
title:  "Software de amsantac.co"
date:   2015-09-11 11:02:52
---
<header>
<h2>Software</h2>
<br>
<span class="byline">Algunos programas y aplicaciones web que pueden serte útiles!</span>
</header>
<br>
<h2 style= "color:#1e6bb8">PAQUETES DE R</h2>
<br>
## El paquete geospt
<br>
Este paquete de R contiene un conjunto de técnicas para el análisis geoestadístico y para el diseño de redes espaciales de muestreo óptimas. Incluye la estimación del variograma a través de la media recortada, estadísticas de resumen para validación cruzada, y el diseño de redes óptimas de muestreo a través de los métodos de puntos secuenciales y puntos simultáneos usando algoritmos genéticos, además de otras funcionalidades. El paquete se encuentra disponible en [CRAN][geospt_CRAN] y [GitHub][geospt_github]. 

<br>
## El paquete diffeR
<br>
El paquete diffeR implementa un conjunto de métricas de diferencia para comparar pares de mapas que representen variables categóricas o reales, a la resolución original o a múltiples resoluciones. Este paquete puede ser descargado e instalado desde [CRAN][differ_CRAN] o [GitHub][differ_github]. 

<br>
## El paquete TOC
<br>
Este paquete de R permite la construcción de la curva ROC (i.e., Receiver (aka Relative) Operating Characteristic) y la curva TOC (i.e., Total Operating Characteristic) para datos espaciales y no espaciales. La curva ROC es una técnica estadística muy popular usada para evaluar el comportamiento de un sistema clasificador binario a medida que el umbral de discriminación varía. El método TOC es una modificación novedosa de la técnica ROC que ha sido desarrollado recientemente por el profesor [Gil Pontius] de Clark University. El paquete TOC puede ser instalado desde [CRAN][toc_CRAN] o [GitHub][toc_github].

<br>
<hr>
<br>
<h2 style= "color:#1e6bb8">APLICACIONES WEB</h2>
<br>
## Aplicación TOC implementada con Shiny
<br>
Esta aplicación web desarrollada con [Shiny] permite la construcción de la curva ROC y la curva TOC para datos espaciales y no espaciales a través de una interfaz gráfica de usuario. <a href="https://amsantac.shinyapps.io/TOCapp" target="_blank">Haz clic aquí</a> para lanzar esta aplicación en pantalla completa.

<br>
## Aplicación de Los Llanos implementada con Google Earth Engine
<br>
Esta aplicación muestra imágenes Landsat (Landsat 5 TM, Landsat 7 ETM+ y Landsat 8 OLI) en composición de falso color (RGB: infrarrojo cercano/ infrarrojo de onda corta/ rojo) desde el año 2000 hasta el año 2014 para la ecoregión tropical conocida como Los Llanos localizada en Colombia, Suramérica. Las nubes y las líneas sin informacion producidas por la falla del Scan Line Corrector (SLC-off) en las imágenes de Landsat 7 ETM+ han sido enmascaradas y rellenadas siguiendo una metodología basada en una composición anual de máximo NDVI. Esta aplicación está implementada con [Google Earth Engine]. <a href="https://llanos-app-v2.appspot.com/" target="_blank">Haz clic aquí</a> para lanzar la aplicación en pantalla completa (puede tomar alrededor de 20 segundos para cargar).

<br>
### *Interesado en colaboración para el desarrollo de herramientas de software similares? Escríbeme a través de [mi página de contacto].*


[geospt_CRAN]: http://cran.r-project.org/web/packages/geospt/
[geospt_github]: https://github.com/amsantac/geospt
[differ_CRAN]: http://cran.r-project.org/web/packages/diffeR/
[differ_github]: https://github.com/amsantac/diffeR
[toc_CRAN]: http://cran.r-project.org/web/packages/TOC/
[toc_github]: https://github.com/amsantac/TOC
[Gil Pontius]: http://www.clarku.edu/~rpontius/
[Google Earth Engine]: https://earthengine.google.org
[mi página de contacto]: /es/contact.html
[Shiny]: http://shiny.rstudio.com/

