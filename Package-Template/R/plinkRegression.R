#' Call the plink program to test association of a phenotype to SNPs
#' 
#' @param phenoTable a data.frame with the first column corresponding
#' to the endpoint of interest and all the other columns to covariates.
#' @param snpSets a list of SNPs sets. If NULL, ignored.
#' @param mperm number of permutations to be applied when testing
#' SNP sets. Ignored if snpSets is NULL.
#' @param type the regression type: 'logistic' for cohort comparison
#' and linear for quantitative trait association
#' @param command the path to the plink command. Default is "plink"
#' but can be changed if needed.
#' 
#' @return  a list of 2 data.frames: \describe{
#'  \item{\code{snps}}{Association with enpoint of interest.
#'  FDR is computed using p.adjust with "BH" method.
#'  see \url{http://pngu.mgh.harvard.edu/~purcell/plink/anal.shtml#glm}
#'  for the description of the output}
#'  \item{\code{cov}}{Association with covariates}
#'  \item{\code{sets}}{Association at the level of SNP set.
#'  see \url{http://pngu.mgh.harvard.edu/~purcell/plink/anal.shtml#set}
#'  for the description of the output.}
#'  \item{\code{log}}{plink log}
#' }
#' 
#' @seealso \url{http://pngu.mgh.harvard.edu/~purcell/plink/}
#' 
#' @export
#' 
plinkRegression <- function(
    phenoTable,
    snpSets=NULL,
    mperm=1000,
    type=c("logistic", "linear"),
    command="plink --noweb"
){
    
    type <- match.arg(type)
    
    # Moving to temporary directory
    curDir <- getwd()
    on.exit(setwd(curDir))
    tmpDir <- tempdir()
    setwd(tmpDir)
    
    # Exporting phenoTable
    phenoTable[,1] <- as.numeric(phenoTable[,1])
    for(cn in colnames(phenoTable)[-1]){
        if(class(phenoTable[,cn])=="factor"){
            if(nlevels(phenoTable[,cn])<=2){
                phenoTable[,cn] <- as.numeric(phenoTable[,cn])
            }else{
                for(l in levels(phenoTable[,cn])){
                    phenoTable[,paste(cn, l, sep=".")] <- ifelse(
                        phenoTable[,cn]==l, 1, 2
                    )
                }
                phenoTable <- phenoTable[,setdiff(colnames(phenoTable), cn)]
            }
        }
    }
    phenoToWrite <- data.frame(
        family=rownames(phenoTable),
        individual=rownames(phenoTable),
        phenoTable,
        stringsAsFactors=F,
        check.names=T
    )
    write.table(
        phenoToWrite,
        file="tmpPheno.txt",
        sep="\t", row.names=F, col.names=T,
        quote=F
    )
    
    # Covariates
    nCov <- ncol(phenoToWrite)-3
    covNum <- ifelse(
        nCov==0,
        "",
        ifelse(
            nCov==1,
            2,
            paste(2, 1+nCov, sep="-")
        )
    )
    
    # plink if no SNP sets
    pckName <- packageName()
    if(is.null(snpSets)){
        system(
            paste(
                command,
                "--bfile",
                sub("[.]bed$", "", system.file(
                    package=pckName,
                    "extdata", "Genotyping",
                    "ImmunoNeurox-GRCh37.bed"
                )),
                "--pheno", "tmpPheno.txt", "--mpheno 1",
                ifelse(
                    covNum=="",
                    "",
                    paste("--covar", "tmpPheno.txt", "--covar-number", covNum)
                ),
                paste0("--", type),
                "--out tmpRes"
            )
            # show.output.on.console=F
        )
        setRes <- NULL
    }else{
        file.create("tmpSet.txt")
        for(s in names(snpSets)){
            write(s, file="tmpSet.txt", ncolumns=1, append=TRUE)
            write(snpSets[[s]], file="tmpSet.txt", ncolumns=1, append=TRUE)
            write("END", file="tmpSet.txt", ncolumns=1, append=TRUE)
            write("", file="tmpSet.txt", ncolumns=1, append=TRUE)
        }
        system(
            paste(
                command,
                "--bfile",
                sub("[.]bed$", "", system.file(
                    package=pckName,
                    "extdata", "Genotyping",
                    "ImmunoNeurox-GRCh37.bed"
                )),
                "--set-test --set tmpSet.txt",
                "--pheno", "tmpPheno.txt", "--mpheno 1",
                ifelse(
                    covNum=="",
                    "",
                    paste("--covar", "tmpPheno.txt", "--covar-number", covNum)
                ),
                paste0("--", type),
                "--mperm", mperm,
                "--out tmpRes"
            )
            # show.output.on.console=F
        )
        setRes <- read.table(
            sprintf("tmpRes.assoc.%s.set.mperm", type),
            header=T, stringsAsFactors=F,
            quote=""
        )
    }
    snpRes <- read.table(
        sprintf("tmpRes.assoc.%s", type),
        header=T, stringsAsFactors=F,
        quote=""
    )
    snpRes.pheno <- snpRes[which(snpRes$TEST=="ADD"),]
    snpRes.pheno$FDR <- p.adjust(snpRes.pheno$P, method="BH")
    snpRes.cov <- snpRes[which(snpRes$TEST!="ADD"),]
    plinkLog <- readLines("tmpRes.log")
    toRet <- list(
        snps=snpRes.pheno,
        cov=snpRes.cov,
        sets=setRes,
        log=plinkLog
    )
    file.remove(list.files(pattern="^tmp"))
    setwd(curDir)

    #
    return(toRet)
    
}
