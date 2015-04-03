# preparing shapefile for warsaw distrcits

library("rgdal")
library("maptools")
library("rgeos")
library("stringi")

# data downloaded from
# http://www.codgik.gov.pl/index.php/darmowe-dane/prg.html
# WARNING - this file is huge! 400Mb to download, 700Mb after unzipping

shp <- readShapePoly("~/Pobrane/PRG_jednostki_administracyjne_v8/jednostki_ewidencyjne.shp", 
                     proj4string = CRS("+init=epsg:2180"))

shp@data$jpt_nazwa_ <- stri_encode(shp@data$jpt_nazwa_,
                                   from = "windows-1250", to = "UTF-8")

# subset warsaw districts
shp <- shp[which(substr(shp@data$jpt_kod_je, 8, 8) == 8), ]

# remove unnecessary data
shp <- shp[, c("jpt_kod_je", "jpt_nazwa_")]
names(shp@data) <- c("kod", "nazwa")
shp@data <- transform(shp@data, kod = as.character(kod), nazwa = as.character(nazwa))

# transform coordinate system
shp <- spTransform(shp, CRS("+proj=longlat +datum=WGS84"))

# add information about location acording to river (left/right bank)
shp@data$bank <- c("r", "r", "l", "l", "l", "l", "r", "r", "r", "l", "l", "r",
                   "l", "r", "l", "l", "l", "l")

saveRDS(shp, "warsaw_districts_shp.RDS")
