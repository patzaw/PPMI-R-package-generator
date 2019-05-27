#' Find variables corresponding to a search text in group and sub-group
#' 
#' @param txt the text to search in group and sub-group names
#' 
#' @export
#' 
findVarByGroup <- function(txt){
    toRet <- union(
        grep(txt, PPMI::varDoc$Group, ignore.case=T, value=F),
        grep(txt, PPMI::varDoc$`Sub-group`, ignore.case=T, value=F)
    )
    return(varDoc[toRet,])
}
