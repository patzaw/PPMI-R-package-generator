#' Return the visit IDs (EVENT_ID) of a Patient/Visit table
#' 
#' @param d the table from which EVENT_ID should be extracted
#' 
#' @export
#' 
vEvent <- function(d){
    sub("^.*[.]", "", rownames(d))
}
