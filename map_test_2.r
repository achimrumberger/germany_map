
rm(list=ls(all=TRUE)) 
#shapefile from https://datahub.io/de/dataset/postal-codes-de
#http://www.suche-postleitzahl.org/downloads?download=zuordnung_plz_ort.csv
#post questions here: http://gis.stackexchange.com/
library(choroplethr)
library(dplyr)
library(ggplot2)
library(rgdal)
library(maptools)
library(gpclib)
library(readr)
library(R6)

setwd("~/Documents/entwickeln/statistik_r/mapping_r/geo/plz-gebiete.shp/")
ger_plz <- readOGR(dsn = ".", layer = "plz-gebiete")

gpclibPermit()

ger_plz@data$id <- rownames(ger_plz@data)
ger_plz.point <- fortify(ger_plz, region="id")
ger_plz.df <- inner_join(ger_plz.point,ger_plz@data, by="id")

head(ger_plz.df)
ggplot(ger_plz.df, aes(long, lat, group=group )) + geom_polygon()

#data file
df <- read_csv("~/Documents/entwickeln/statistik_r/mapping_r/de_plz_einwohner.csv")
ger_plz.df$region <- as.integer(ger_plz.df$plz)
ger_plz.df$region <- ger_plz.df$plz
head(ger_plz.df)

GERPLZChoropleth <- R6Class("GERPLZChoropleth", 
                        inherit = choroplethr:::Choropleth,
                        public = list(
                          initialize = function(user.df) {
                            super$initialize(ger_plz.df, user.df)
                          }
                        )
)

colnames(df) = c("region", "value")
c <- GERPLZChoropleth$new(df)
c$ggplot_polygon = geom_polygon(aes(fill = value), color = NA)
c$title = "Comparison of number of Inhabitants per Zipcode in Germany"
c$legend= "Number of Inhabitants per Zipcode"
c$set_num_colors(9)
c$render()
c$render_with_reference_map()
