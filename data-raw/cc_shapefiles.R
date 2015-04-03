library("rgdal")
library("maptools")
library("rgeos")

# download file if necessary
if (!file.exists("data-raw/powiaty/")) {
  temp <- tempfile(fileext = ".zip")
  download.file("http://www.gis-support.pl/downloads/powiaty.zip",
                temp)
  # now unzip the boundary data
  unzip(temp)
}


# regions
shp <- readShapePoly("data-raw/powiaty/powiaty.shp", proj4string = CRS("+init=epsg:2180"))
# dropping unused attributes
shp <- shp[, c("jpt_kod_je", "jpt_nazwa_")]
names(shp@data) <- c("kod", "nazwa")
# remove factors
shp@data <- transform(shp@data, kod = as.character(kod), nazwa = as.character(nazwa))

# coordinates system transformation
shp <- spTransform(shp, CRS("+proj=longlat +datum=WGS84"))



## split warsaw into two parts - left and right bank
# remove warsaw from spatialpolygons
shp <- shp[!grepl("Warszawa", shp@data$nazwa), ]

# load shapefile fow warsaw districts and merge them into desired parts
warsaw <- readRDS("data-raw/warsaw_districts_shp.RDS")
warsaw <- unionSpatialPolygons(warsaw, warsaw@data$bank)
warsaw <- spChFIDs(warsaw, c("380", "381"))
tmp_data <- data.frame(kod = c("1465", "1466"),
                       nazwa = c("Warszawa Zachód", "Warszawa Wschód"),
                       row.names = row.names(warsaw),
                       stringsAsFactors = FALSE)
warsaw <- SpatialPolygonsDataFrame(warsaw, tmp_data)

# add to shp
shp <- spRbind(shp, warsaw)


# map between coverage of regional courts and administrative regions
# based on 
# http://orka.sejm.gov.pl/proc7.nsf/ustawy/804_u.htm#_ftn1
# it is not binding regulation, but serves well as first approximation
# official regulation:
# http://isap.sejm.gov.pl/DetailsServlet?id=WDU20120001121
# warsaw districts were added by hand

map_court_district <- read.csv("data-raw/map_court_district.csv", colClasses = "character")
# add id for convenience
region_id <- data.frame(id = seq_along(unique(map_court_district$region)),
                        region = unique(map_court_district$region),
                        stringsAsFactors = FALSE)

load("data-raw/cc_hierarchy_mapping.RData")
# combine districts within the same region using appropiate map
# WARNING - the order of polygons is based on row.names !!!!!!
tmp_map <- match(shp@data$kod, map_court_district$kod)
regions <- unionSpatialPolygons(shp, map_court_district$region[tmp_map])

# add data frame so it would be easy to add variables
tmp_map <- match(row.names(regions), map_regional_appeal$region)
tmp_data <- data.frame(region = row.names(regions),
                       region_name = map_regional_appeal$region_name[tmp_map],
                       appeal = map_regional_appeal$appeal[tmp_map],
                       appeal_name = map_regional_appeal$appeal_name[tmp_map],
                       row.names = row.names(regions),
                       stringsAsFactors = FALSE)
regions <- SpatialPolygonsDataFrame(regions, tmp_data)

# combine regions within the same appeal area
# we need map from region to appeal
tmp_map <- match(row.names(regions), map_regional_appeal$region)
appeals <- unionSpatialPolygons(regions, map_regional_appeal$appeal[tmp_map])

# add data frame so it would be easy to add variables
tmp_data <- map_appeal[order(map_appeal$appeal),]
row.names(tmp_data) <- tmp_data$appeal
appeals <- SpatialPolygonsDataFrame(appeals, tmp_data)

# a few regions are mismatched - for example gmina tarczyn and gmina jaktorów
# however as first approximation it is ok



## simplifying
# tolerance values was chosen experimentally

regions_simp <- gSimplify(regions, tol = 0.005, topologyPreserve = TRUE)
regions_simp <- SpatialPolygonsDataFrame(regions_simp, regions@data)
cc_sp_region <- regions_simp
save(cc_sp_region, file = "data/cc_sp_region.rda")

appeals_simp <- gSimplify(appeals, tol = 0.005, topologyPreserve = TRUE)
appeals_simp <- SpatialPolygonsDataFrame(appeals_simp, appeals@data)
cc_sp_appeal <- appeals_simp
save(cc_sp_appeal, file = "data/cc_sp_appeal.rda")
