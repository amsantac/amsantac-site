---
layout: post
title:  "Mapping tweets: How to create your own web app"
date:   2016-05-28 11:02:52
categories: blog en
tags: R Twitter Shiny webmapping 
image: 2016-04-30-arcgis-r-mini.jpg
published: false
---

A couple of months ago, ESRI released a bridge library to connect A

Shiny is an R package that makes it easy to build interactive web applications (apps) straight from R.

<!--more-->

<img src="/images/2016-04-30-arcgis-r-fig-0.png" alt="" title="" style="width:750px">

<br>

### **Install the R ArcGIS Bridge**

First, 

<ol>
<li>1. Create an account on Twitter</li>
<li>2. Create an app on twitter</li>
<li>3. Get the tokens of your app on twitter</li>
<li>4. Install the required packages and prepare and test the R code of your app</li>
<li>5. Deploy/Share your app create an account on shinyapps</li>
</ol>

http://www.r-bloggers.com/mapping-twitter-followers-in-r/

1.  create an account on twitter
  * [Twitter]


* create an app in twitter

[Twitter apps]

- get the tokens

> Keys and Access Tokens tab in the 

Consumer Key (API Key), Consumer Secret (API Secret), Access Token, Access Token Secret

To access the Twitter API, the first thing you'll need to do is register with them via apps.twitter.com. Once you do so, you'll be given the following: Consumer Key (API Key), Consumer Secret (API Secret), Access Token, and an Access Token Secret. You can then move into R. There, you'll want to install and load the twitteR package


- write the code for your app and test it

Only about 3% of tweets are geocoded, 


<br>

### **Prepare the code for your app**

First open an R session and install the following packages: [twitteR], [shiny] and [leaflet]. Then create a new R script. For keeping it simple, we are going to put all the necessary R code in just one file that we are going to name [app.R]. 

A Shiny app has two components. The first part, called *ui*, defines the visual appearance or user-interface of the app. Let's take a look at the code:

```
library(leaflet)
 library(twitteR)

shinyApp(
  ui = fluidPage(
    fluidRow(
      column(4, textInput("searchkw", label = "search:", value = "#CaptainAmerica")),
      column(4, textInput("lat", label = "lat:", value = 40.75)),
      column(4, textInput("long", label = "long:", value = -74)),
      column(8, leafletOutput("myMap")),
      column(12, tableOutput('table'))
    )
  ),
```

<br>

`fluidPage` and `fluidRow` are used for creating a fluid page layout. We are going to include three text input controls: one for a search keyword and two other for lat/long coordinates. Additionaly, our app will include two outputs: a leaflet map and a table with the resulting tweets.

The second component of a Shiny app is the *server* which contains the instructions for building the app. Let's examine the code:

```
  server = function(input, output) {

    #
    consumer_key <- readLines("tokens.txt")[1]
    consumer_secret <- readLines("tokens.txt")[2]
    access_token <- readLines("tokens.txt")[3]
    access_secret <- readLines("tokens.txt")[4]
    options(httr_oauth_cache = TRUE) # enable using a local file to cache OAuth access credentials between R sessions
    setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
    
    #
    dataInput <- reactive({  
      datos <- twListToDF(searchTwitter(input$searchkw, n = 100, 
                                        geocode = paste0(input$lat, ",", input$long, ",10km"))) 
      #datos <- datos[, c("text", "screenName", "longitude", "latitude")]
      datos$created <- as.character(as.Date(datos$created))
      datos <- datos[!is.na(datos[, "longitude"]), ]
    })
    
    #datos <- dataInput()[, c("text", "screenName", "longitude", "latitude")]
    
    # 
    mapa <- reactive({
      map = leaflet() %>% addTiles() %>%
        addMarkers(dataInput()$longitude, dataInput()$latitude, popup = dataInput()$screenName) %>%
        setView(input$long, input$lat, zoom = 11)
      #output$myMap = renderLeaflet(map)
    })
    output$myMap = renderLeaflet(mapa())
    
    #  
    output$table <- renderTable(
      #datos
      dataInput()[, c("text", "screenName", "longitude", "latitude", "created")]
      #dataInput()
    )
  }
)
```
<br>

First, all the four authentication parameters (*consumer key*, *consumer secret*, *access token* and *access secret*) are read from a text file and supplied to the OAuth authentication. I named the text file 'tokens.txt' and saved it in the same folder where the app.R file is stored.

Then comes the central part of our app. `dataInput` is a [reactive function] that issues a query to Twitter based on a search string (`input$searchkw`) provided by the user. As we are interested in geocoded tweets, it is necessary to provide search radius and latitude/longitude coordinates in the format `latitude,longitude,radius`. In this sample app, the maximum number of tweets to return (`n = 100`) and the search radius (`10km`) are fixed for simplicity, but this could be easily modified, so feel free to experiment. Notice the last line of `dataInput`: `!is.na` is used to remove those tweets that are not geocoded.

In the final part, a leaflet map and a table are created based on query results stored in `dataInput`. Popups in the leaflet map show the screen name (i.e., twitter username) while the output table contains the tweet, the location and the date the tweet was created, besides the username. For an extended explanation about the creation of the leaflet map [see this post]. 

Want to try the app? Just click the 'Run App' button in RStudio. Easy ah? 

<img src="/images/2016-05-28-twitter-r-fig-1.JPG" alt="" title="" style="width:750px">

<br>

### **Deploy/Share your app**

The easiest approach for sharing your Shiny apps online is to use [shinyapps.io by RStudio] (alternatively, you can use [Shiny Server] if you own a server or have access to one). With shinyapps.io, you can upload your app directly from an R session to an RStudio server. 

In short, you need to create a shinyapps.io account and then install and configure an R package called 'rsconnect'. The complete set of instructions is provided in [this excellent tutorial] so I'm not going into details in this post.

After your shinyapps.io account is correctly configured, you'll be able to deploy your app by clicking the Publish button in the RStudio IDE, or by executing the following command lines:

```
library(rsconnect)
 deployApp()
```
<br>

After deployment, the app is automatically launched and opened in your web browser pointing to a web address similar to "https://your-account-name.shinyapps.io/your-app-name/".

That's basically all you need to do to create a working web app for mapping twitter data. Watch the following video to see the whole process for creating and deploying this Shiny *tweet-mapping* app:

<iframe width="750" height="422" src="https://www.youtube.com/embed/CUIEVk5icR8" frameborder="0" allowfullscreen></iframe>

<br>

### **Further steps**

For this tutorial I kept the user interface of the app to the minimal. However, it is quite easy to create elegant apps with some additional work, such as [this NRL dashboard app]. Twitter data can be processed for more advanced analyses, such as [predicting movie success based on sentiment analysis of tweets]. For more examples of Shiny apps, see the examples and catalogs in [this web page]. Hope you give it a try!

- create an account in shinyapps

[shinyapps.io by RStudio]

- deploy the app to shinyapps


instructions for setting up a shiny account
http://shiny.rstudio.com/articles/shinyapps.html


deploy your app to shinyapps
deployApp()


The 'arcgisbinding' package is still in beta release and some issues may be found, so let me know about your experience with the R ArcGIS bridge if you try this tutorial. Have fun!

Now you have a fancy web map with legend, layers controls and popups:

<iframe width="785" height="500" src="http://amsantac.github.io/extras/www/landsat_scenes.html"></iframe>


<div font style="BACKGROUND-COLOR:#f5f5f5;line-height:0.8">
<xmp font style="border:1px solid;border-color:#d1d1d1;black;border-radius:3px;padding: 0em 0 0.3em 0.3em">
<iframe id="map_id" width=700 height=500 src="http://mywebsite.com/my_map.html"></iframe>
</xmp>
</font></div>

```
<iframe id="map_id" width=700 height=500 src="http://mywebsite.com/my_map.html"></iframe>
```

<br>
**You may also be interested in:**

&#42; [Web mapping with Leaflet and R]

<a id="comments"></a>

[Twitter]: https://twitter.com/
[Twitter apps]: https://apps.twitter.com/
[shinyapps.io by RStudio]: http://www.shinyapps.io/
[see this post]: /blog/en/r/2015/08/11/leaflet-R.html
[Web mapping with Leaflet and R]: /blog/en/r/2015/08/11/leaflet-R.html 
[app.R]: https://gist.github.com/amsantac/9e25680ccbbccfa5a25adced04dc9e04
[twitteR]: https://cloud.r-project.org/web/packages/twitteR/index.html
[shiny]: https://cloud.r-project.org/web/packages/shiny/index.html
[leaflet]: https://cloud.r-project.org/web/packages/leaflet/index.html
[reactive function]: http://shiny.rstudio.com/tutorial/lesson6/
[Shiny Server]: https://www.rstudio.com/products/shiny/shiny-server/
[this excellent tutorial]: http://shiny.rstudio.com/articles/shinyapps.html
[this NRL dashboard app]: https://shamiri.shinyapps.io/NRLdashboard/
[predicting movie success based on sentiment analysis of tweets]: https://insanelyanalytics.wordpress.com/2016/04/04/my-new-r-shiny-web-application-prediction-of-success-of-a-movie-with-twitter-corpus-check-it-out-and-spread-the-word/
[this web page]: https://www.rstudio.com/products/shiny/shiny-user-showcase/
