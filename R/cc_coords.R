#' Coordinates of common courts
#'
#' A dataset containing coordinates of all Polish common courts, list of courts 
#' taken from \code{\link[saos]{courts}} and coordinates obtained from Google 
#' Maps API. Names and types of courts are also included.
#'
#' @format A data frame with 291 rows and 5 variables:
#' \describe{
#'   \item{lon}{longitude}
#'   \item{lat}{latitude}
#'   \item{court_id}{court's ID in SAOS repository}
#'   \item{name}{name of the court}
#'   \item{type}{type of the court ("APPEAL", "REGIONAL" or "DISTRICT")}
#' }
#' 
#' @docType data
#' @source \href{https://saos-test.icm.edu.pl}{SAOS}, 
#' \href{http://code.google.com/apis/maps/documentation/geocoding}{Google Maps API}
"cc_coords"