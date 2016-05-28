---
layout: post-es
title:  "Mapeando tweets: Cómo crear tu propia aplicación web"
date:   2016-05-28 11:02:52
categories: blog es
tags: R Twitter Shiny mapeoweb 
image: 2016-05-28-twitter-r-mini.jpg
published: true
---

Una de las razones por las cuales [Twitter] es tan popular es porque se ha convertido en un excelente medio para obtener datos para proyectos y aplicaciones web. A través de su interfaz de programación de aplicaciones (API) para búsquedas ([Search API]), es posible encontrar contenido a partir de consultas en Twitter con base en términos de búsqueda. Los resultados pueden ser analizados o visualizados posteriormente usando herramientas de software complementarias.

El propósito de este tutorial es aprender cómo crear una aplicación web interactiva que obtenga tweets geocodificados y los muestre en un mapa. Suena interesante? Para facilitar la creación de la aplicación vamos a usar [Shiny], un paquete de R útil para desarrollar aplicaciones web. Veamos cómo podemos crear nuestra app de una manera sencilla.    

<!--more-->

<a href="" class="image centered"><img src="/images/2016-05-28-twitter-r-fig-0.png" alt="" title="" ></a>

<br>

### **Obtén acceso a la API de Twitter**

Para comenzar [crea una cuenta en Twitter]. Una vez te registres, ve a [apps.twitter.com] y crea una nueva aplicación para que puedas tener acceso a la [API de Twitter]. En la ventana ‘Keys and Access Tokens’ de la nueva aplicación vas a obtener lo siguiente: Consumer Key, Consumer Secret, Access Token, y Access Token Secret.

Ten en cuenta que Twitter ha establecido unos [límites para el uso de su Search API]. Además también debes tener en cuenta que sólo un pequeño porcentaje de los tweets públicos están geocodificados (cerca de 3-5%) por lo cual es posible que no se obtenga la misma cantidad de tweets que se solicite en la consulta. 


### **Prepara el código para tu aplicación**

Primero abre una sesión de R (preferiblemente en RStudio) e instala los siguientes paquetes: [twitteR], [shiny] y [leaflet]. Luego crea un nuevo script. Para hacerlo lo más simple posible, vamos a poner todo el código de R necesario en un único archivo que vamos a llamar [app.R].

Una aplicación hecha con Shiny tiene dos componentes. La primera parte, llamada *ui*, define la interfaz de usuario (o apariencia visual) de la aplicación. Démosle una mirada al código: 

```
library(leaflet)
 library(twitteR)

shinyApp(
  ui = fluidPage(
    fluidRow(
      column(4, textInput("searchkw", label = "search:", value = "#movie")),
      column(4, textInput("lat", label = "lat:", value = 40.75)),
      column(4, textInput("long", label = "long:", value = -74)),
      column(8, leafletOutput("myMap")),
      column(12, tableOutput('table'))
    )
  ),
```
<br>

`fluidPage` y `fluidRow` se usan para determinar cómo se posicionan los elementos en la página. Vamos a incluir tres controles de entrada de texto en nuestra app: uno para el término de búsqueda y otros dos para las coordenadas de latitud y longitud. Adicionalmente, nuestra app va incluir dos productos de salida: un [mapa de leaflet] y una tabla con los tweets resultantes.

El segundo componente de una aplicación de Shiny se denomina *server* y contiene las instrucciones para construir la aplicación. Miremos el código:

```
  server = function(input, output) {
    
    # Autenticación OAuth
    consumer_key <- readLines("tokens.txt")[1]
    consumer_secret <- readLines("tokens.txt")[2]
    access_token <- readLines("tokens.txt")[3]
    access_secret <- readLines("tokens.txt")[4]
    options(httr_oauth_cache = TRUE) # enable using a local file to cache OAuth access credentials between R sessions
    setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
    
    # Enviar consulta a Twitter
    dataInput <- reactive({  
      tweets <- twListToDF(searchTwitter(input$searchkw, n = 100, 
                                        geocode = paste0(input$lat, ",", input$long, ",10km"))) 
      tweets$created <- as.character(tweets$created)
      tweets <- tweets[!is.na(tweets[, "longitude"]), ]
    })
    
    # Crear un mapa leaflet reactivo
    mapTweets <- reactive({
      map = leaflet() %>% addTiles() %>%
        addMarkers(dataInput()$longitude, dataInput()$latitude, popup = dataInput()$screenName) %>%
        setView(input$long, input$lat, zoom = 11)
    })
    output$myMap = renderLeaflet(mapTweets())
    
    # Crear una tabla reactiva 
    output$table <- renderTable(
      dataInput()[, c("text", "screenName", "longitude", "latitude", "created")]
    )
  }
)
```
<br>

En primer lugar, todos los parámetros de autenticación (*consumer key*, *consumer secret*, *access token* y *access secret*) son leídos desde un archivo de texto y utilizados para la autenticación con `setup_twitter_oauth`. Yo llamé ‘tokens.txt’ al archivo de texto y lo guardé en la misma carpeta donde se encuentra el archivo app.R.

Luego viene la parte central de nuestra app. `dataInput` es una [función reactiva] que envía una consulta a Twitter a partir de unos términos de búsqueda (`input$searchkw`) suministrados por el usuario. Como estamos interesados en tweets geocodificados, es necesario ingresar el radio de búsqueda y las coordenadas de latitud/longitud siguiendo el formato `latitud,longitud,radio`. Por simplicidad, el número máximo de tweets solicitados (`n = 100`) y el radio de búsqueda (`10km`) en nuestra app son parámetros fijos, pero esto puede ser modificado fácilmente, así que siéntete libre de hacer cambios y experimentar. Nota que la última línea de `dataInput`: `!is.na()` es utilizada para remover aquellos tweets que no están geocodificados.

En la parte final se crean el mapa de leaflet y la tabla a partir de los resultados de la consulta que se encuentran almacenados en `dataInput`. Los popups en el mapa leaflet muestran el nombre de usuario de Twitter, mientras que la tabla contiene el tweet, la localización y la fecha en que fue creado el tweet, además del usuario. Para una explicación detallada de la creación de mapas leaflet usando R [mira este post].

Quieres probar la aplicación? Simplemente haz click en el botón ‘Run App’ en RStudio. Deberías ver algo como esto:

<img src="/images/2016-05-28-twitter-r-fig-1.JPG" alt="" title="Probando la aplicación en RStudio" style="width:750px">

<br>

### **Publica/Comparte tu app**

La forma más sencilla de compartir tus aplicaciones Shiny en Internet es usar [shinyapps.io de RStudio] (como alternativa puedes usar [Shiny Server] si posees un servidor o tienes acceso a uno). Con shinyapps.io puedes subir tu aplicación directamente desde una sesión de R a un servidor de RStudio.

En síntesis, necesitas crear una cuenta en shinyapps.io y luego instalar y configurar un paquete de R llamado [rsconnect]. La descripción detallada de cada uno de los pasos la puedes encontrar en [este excelente tutorial] así que no voy a profundizar en ese procedimiento en este post.

Una vez hayas configurado correctamente tu cuenta de shinyapps.io, puedes publicar tu app usando el botón ‘Publish’ en la IDE de RStudio, o si lo prefieres puedes publicarla ejecutando los siguientes comandos:

```
library(rsconnect)
 deployApp()
```
<br>

Después del paso anterior, la aplicación es lanzada automáticamente y se despliega en tu navegador de Internet en una dirección similar a "https://nombre-de-tu-cuenta.shinyapps.io/nombre-de-tu-app/".

Eso es básicamente todo lo que necesitas para crear una aplicación web funcional para mapear datos de Twitter. Mira el siguiente video para que veas el proceso completo de creación y publicación de nuestra aplicación desarrollada con Shiny:

<iframe width="750" height="422" src="https://www.youtube.com/embed/2hygVpz3m3k" frameborder="0" allowfullscreen></iframe>

<br>

### **Pasos adicionales**

Para este tutorial mantuve solamente los elementos necesarios en la interfaz de usuario de la aplicación. Sin embargo, es muy fácil crear aplicaciones Shiny elegantes con solo un poco más de trabajo. Para inspirarte puedes ver los ejemplos y catálogos en [esta página web]. Con respecto a aplicaciones que usen datos de Twitter mira [esta app de la Liga Nacional de Rugby de Australia]. Los datos de Twitter pueden ser procesados para análisis más avanzados como se muestra [en este ejemplo] para predecir el éxito de una película a partir de un análisis de sentimientos de tweets.

Espero que este post te motive a crear pronto tu propia aplicación web!

<br>

**You may also be interested in:**

&#42; [Mapeo web con Leaflet y R]

<a id="comments"></a>

[Twitter]: https://twitter.com/
[crea una cuenta en Twitter]: https://twitter.com/
[apps.twitter.com]: https://apps.twitter.com/
[Shiny]: http://shiny.rstudio.com/ 
[shinyapps.io de RStudio]: http://www.shinyapps.io/
[mira este post]: /blog/en/r/2015/08/11/leaflet-R.html
[Mapeo web con Leaflet y R]: /blog/es/r/2015/08/11/leaflet-R-es.html
[app.R]: https://gist.github.com/amsantac/9e25680ccbbccfa5a25adced04dc9e04
[twitteR]: https://cloud.r-project.org/web/packages/twitteR/index.html
[shiny]: https://cloud.r-project.org/web/packages/shiny/index.html
[leaflet]: https://cloud.r-project.org/web/packages/leaflet/index.html
[función reactiva]: http://shiny.rstudio.com/tutorial/lesson6/
[Shiny Server]: https://www.rstudio.com/products/shiny/shiny-server/
[este excelente tutorial]: http://shiny.rstudio.com/articles/shinyapps.html
[esta app de la Liga Nacional de Rugby de Australia]: https://shamiri.shinyapps.io/NRLdashboard/
[en este ejemplo]: https://insanelyanalytics.wordpress.com/2016/04/04/my-new-r-shiny-web-application-prediction-of-success-of-a-movie-with-twitter-corpus-check-it-out-and-spread-the-word/
[esta página web]: https://www.rstudio.com/products/shiny/shiny-user-showcase/
[límites para el uso de su Search API]: https://support.twitter.com/articles/160385
[API de Twitter]: https://dev.twitter.com/rest/public
[Search API]: https://dev.twitter.com/rest/public
[rsconnect]: https://cran.r-project.org/web/packages/rsconnect/index.html
[mapa de leaflet]: http://leafletjs.com/
