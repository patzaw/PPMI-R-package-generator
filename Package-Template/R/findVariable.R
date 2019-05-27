#' Find variables corresponding to a search text.
#' 
#' @param txt the text to search in variable names and description
#' 
#' @export
#' 
findVariable <- function(txt){
    toRet <- union(
        grep(txt, rownames(PPMI::varDoc), ignore.case=T, value=F),
        grep(txt, PPMI::varDoc$Description, ignore.case=T, value=F)
    )
    return(varDoc[toRet,])
}
