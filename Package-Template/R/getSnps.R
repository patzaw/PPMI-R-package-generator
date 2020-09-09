#' Get PPMI SNPs data
#' 
#' @param snps a character vector of SNPs to be extracted
#' @param transcode a logical indicating if the A/B genotypes should
#' be converted according to the SNP allele bases (ATCG).
#' 
#' @return a matrix of character. Columns correspond to selected SNPs.
#' Rows correspond to patients with a genotype.
#' 
#' @export
#' 
getSnps <- function(snps, transcode=FALSE){
    snps <- intersect(snps, colnames(snpData))
    if(length(snps)==0){
        stop("Could not find any SNP among those provided.")
    }
    selection <- as(PPMI::snpData[,snps], "character")
    selection <- ifelse(selection=="NA", NA, selection)
    if(transcode){
        snpInfo <- PPMI::snpInfo
        toRet <- c()
        for(snp in snps){
            a1 <- snpInfo[snp, "allele.1"]
            a2 <- snpInfo[snp, "allele.2"]
            toRet <- cbind(
                toRet,
                ifelse(
                    selection[,snp]=="A/A",
                    paste(a1, a1, sep="/"),
                    ifelse(
                        selection[,snp]=="A/B",
                        paste(a1, a2, sep="/"),
                        ifelse(
                            selection[,snp]=="B/B",
                            paste(a2, a2, sep="/"),
                            NA
                        )
                    )
                )
            )
        }
        colnames(toRet) <- snps
        rownames(toRet) <- rownames(selection)
    }else{
        toRet <- selection
    }
    return(as.data.frame(toRet))
}
