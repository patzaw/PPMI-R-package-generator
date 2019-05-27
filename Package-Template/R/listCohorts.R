#' List available cohort in the PPMI
#' 
#' @export
#' 
listCohorts <- function(){
    toRet <- unique(patientData[,c("ENROLL_CAT", "APPRDX")])
    toRet <- toRet[which(!is.na(toRet$ENROLL_CAT)),]
    toAdd <- table(patientData[, c("ENROLL_CAT", "ENROLL_STATUS")])
    class(toAdd) <- "matrix"
    toAdd <- as.data.frame(toAdd[,c("Enrolled", "Withdrew")])
    toRet <- merge(toRet, toAdd, by.x="ENROLL_CAT", by.y=0)
    colnames(toRet) <- c(
        "Enrollment Category", "Appropriate Diagnosis",
        "Enrolled and not withdrew", "Enrolled and withdrew"
    )
    return(toRet)
}
