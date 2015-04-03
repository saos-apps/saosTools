#' Updating data
#' 
#' Update your database (in any format) with the latest judgments loaded into
#' repository. Basically it only downloads judgments since provided time and
#' runs updating fucntion, which you have to provide by yourself. See 
#' vignette for an example framework. Note that the time of judgment isn't 
#' necessary identical to the time of loading (or modification) in repository, 
#' therefore this function, makes use of 'sinceModificationDate' argument.
#' 
#' @param time time in POSIXct format passed to 'sinceModificationDate' argument
#' @param update_function function which performs actual update, must be provided by
#'  a user


update_all <- function(time, update_function) {
  
  new_judgments <- saos::get_dump_judgments(sinceModificationDate = time)
  
  if (length(new_judgments) > 0) {
    update_function(new_judgments)
  } else {
    message("No new judgments")
  }
  return()
}