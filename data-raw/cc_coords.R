library("saos")
library("ggmap")
library("dplyr")
library("RgoogleMaps")

# load data about courts
data(courts)

# coordinates of courts
cc_coords <- lapply(courts$name, function(court) {
  res <- geocode(court)
  if (any(is.na(res))) res <- geocode(strsplit(court, " (w|we) ")[[1]][2])
  if (any(is.na(res))) res <- getGeoCode(court)
  if (any(is.na(res))) res <- getGeoCode(strsplit(court, " (w|we) ")[[1]][2])
  Sys.sleep(runif(1) + 0.2)
  res
})

# unify data
cc_coords <- lapply(cc_coords, function(x) {
  if (is.numeric(x)) {
    data.frame(lon = x["lon"], lat = x["lat"])
  } else x
})

# bind into data.frame
cc_coords <- bind_rows(cc_coords)

# add ID, name and type
cc_coords$court_id <- courts$id
cc_coords$name <- courts$name
cc_coords$type <- courts$type

save(as.data.frame(cc_coords), file = "data/cc_coords.rda")
