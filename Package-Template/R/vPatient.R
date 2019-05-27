#' Return the patients IDs (PATNO) of a Patient/Visit table
#' 
#' @param d the table from which PATNO should be extracted
#' 
#' @export
#' 
vPatient <- function(d){
    sub("[.].*$", "", rownames(d))
}
