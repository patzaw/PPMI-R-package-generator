#' Extract variable values for a set of patients and a set of events.
#' 
#' @param patients the patients IDs to focus on.
#' @param variables the variables to extract.
#' @param events the events to focus on. Not taken into account if variables
#' are not followed-up at the different visits.
#' @param snps SNP data to be extracted. Default is NULL ==> no SNP data
#' are extracted.
#' @param transcode a logical indicating if the A/B genotypes should
#' be converted according to the SNP allele bases (ATCG).
#' 
#' @return \describe{
#'  \item{If several events are provided}{a list of data.frames:
#'  one data.frame per followed up variable and one data.frame for all
#'  patient variables. The row names
#'  of the data frames are the patients IDs (PATNO). The column names of the
#'  data frames are the events IDs.}
#'  \item{If only one event is provided}{a data.frame. The row names
#'  of the data frames are the patients IDs (PATNO). The column names of the
#'  data frames are the variables.}
#' }
#' 
#' @export
#'
extractVariables <- function(
    patients, variables, events=NA,
    snps=NULL, transcode=FALSE){
    
    patients <- as.character(patients)
    variables <- as.character(variables)
    events <- as.character(events)

    ## Check variables
    if(length(variables)==0){
        stop("At least one variable name should be provided")
    }
    varNotInPpmi <- setdiff(variables, rownames(PPMI::varDoc))
    if(length(varNotInPpmi)!=0){
        stop(
            "The following variables were not found: ",
            paste(varNotInPpmi, collapse=", ")
        )
    }
    pVar <- intersect(variables, colnames(PPMI::patientData))
    eVar <- intersect(variables, colnames(PPMI::visitData))
    
    ## Patient variables
    if(length(pVar) > 0){
        pToRet <- PPMI::patientData[
            match(patients, rownames(PPMI::patientData)), pVar, drop=F
        ]
        rownames(pToRet) <- patients
    }else{
        pToRet <- data.frame(row.names=patients)
    }
    
    ## SNP data
    if(length(snps)>0){
        toAdd <- getSnps(snps=snps, transcode=transcode)
        toAdd <- toAdd[patients, , drop=FALSE]
        rownames(toAdd) <- patients
        pToRet <- cbind(pToRet, toAdd)
    }
    
    ## Check events
    if(length(eVar)==0){
        return(pToRet)
    }
    if(length(events)==0){
        stop(
            "At least one event should be provided",
            " to extract followed-up variables"
        )
    }
    eventNotInPpmi <- setdiff(events, PPMI::visitInfo$EVENT_ID)
    if(length(eventNotInPpmi)!=0){
        stop(
            "The following events were not found: ",
            paste(eventNotInPpmi, collapse=", ")
        )
    }
    
    ## Followed-up variables
    eData <- list()
    for(eid in events){
        toGet <- paste(patients, eid, sep=".")
        toAdd <- PPMI::visitData[toGet, eVar, drop=F]
        rownames(toAdd) <- patients
        eData <- c(eData, list(toAdd))
    }
    names(eData) <- events
    if(length(eData)==1){
        eToRet <- eData[[1]]
        toRet <- cbind(pToRet, eToRet)
        return(toRet)
    }
    
    ## Aggregating by variable
    eToRet <- list()
    for(v in eVar){
        toAdd <- do.call(cbind, lapply(
            eData,
            function(d) return(d[, v, drop=F])
        ))
        colnames(toAdd) <- names(eData)
        eToRet <- c(eToRet, list(toAdd))
    }
    names(eToRet) <- eVar
    if(ncol(pToRet)>0){
        toRet <- c(list("Patient"=pToRet), eToRet)
    }else{
        toRet <- eToRet
    }
    return(toRet)
    
}
