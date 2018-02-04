
rm(list=ls(all=TRUE)) 

library(choroplethr)
library(dplyr)
library(ggplot2)
library(rgdal)
library(maptools)
library(gpclib)
library(readr)
library(R6)

#setwd("~/achim/statistik_r/geo/plz-gebiete.shp/")
#sf <- readOGR(dsn = ".", layer = "plz-gebiete")
#ari lamstein example
setwd("~/Documents/entwickeln/statistik_r/mapping_r/geo/Supervisor Districts as of April 2012")
sf <- readOGR(dsn = ".", layer = "geo_export_ade8ccf1-8c02-440d-8163-2f9d6c79112e")
#data file

df <- read_csv("~/Documents/entwickeln/statistik_r/mapping_r/Noise_Reports.csv")

plot(sf)
class(sf)
head(sf)

gpclibPermit()

sf@data$id <- rownames(sf@data)
sf.point <- fortify(sf, region="id")
sf.df <- inner_join(sf.point,sf@data, by="id")

head(sf.df)
ggplot(sf.df, aes(long, lat, group=group )) + geom_polygon()



df = df %>%
   select("Supervisor.District", Category) %>%
   filter(Category == "Noise Report")  %>%
  group_by("Supervisor.District")  %>%
   summarise(n = n())

df2 <- select(df, `Supervisor District`, as.integer( df$Category)) %>% 
  filter( df$Category == "Noise Report") %>% 
  group_by(`Supervisor District`) %>% 
  summarise(n = n())

sf.df$region <- sf.df$supervisor
head(sf.df)

SFChoropleth <- R6Class("SFChoropleth", 
                         inherit = choroplethr:::Choropleth,
                         public = list(
                           initialize = function(user.df) {
                             super$initialize(sf.df, user.df)
                           }
                             
                         )
                        )

colnames(df2) = c("region", "value")
c <- SFChoropleth$new(df2)

c$set_num_colors(2)
c$render_with_reference_map()
c$render()
c$title = "abc"
c$legend = "dfg"

