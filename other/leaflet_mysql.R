install.packages("RMySQL", "sp")

library("RMySQL")
con <- dbConnect(MySQL(),
                 user = 'user',
                 password = 'user',
                 dbname='example')

table1 <- dbReadTable(conn = con, name = 'mydata')

library(sp)
coordinates(table1) <- ~longitude+lat

table1

