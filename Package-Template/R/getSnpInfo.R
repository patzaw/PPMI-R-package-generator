#' Get information about PPMI SNPs
#' 
#' @param snps a character vector of SNP IDs
#' 
#' @return a data.frame with SNP information. ID which were not found
#' are available in the 'Not found' attribute (\code{attr(toRet, "Not found")).
#' 
#' @export
#' 
getSnpInfo <- function(snps){
    toRet <- snpInfo[intersect(snps, rownames(snpInfo)),]
    attr(toRet, "Not found") <- setdiff(snps, rownames(snpInfo))
    return(toRet)
}
