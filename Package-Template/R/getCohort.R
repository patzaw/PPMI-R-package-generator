#' Get patient IDs of a cohort
#' 
#' @param cohort the name of the cohort to extract
#' @param enrolled_or_complete_only if TRUE (default) only patients
#' with an "Enrolled" or a "Complete" status are returned
#' 
#' @export
#' 
getCohort <- function(cohort, enrolled_or_complete_only=TRUE){
    if(enrolled_or_complete_only){
        return(
            rownames(PPMI::patientData)[which(
                PPMI::patientData$ENROLL_CAT %in% cohort &
                    (PPMI::patientData$ENROLL_STATUS %in%
                    c("Enrolled", "Complete"))
            )]
        )
    }else{
        return(
            rownames(PPMI::patientData)[which(
                PPMI::patientData$ENROLL_CAT %in% cohort
            )]
        )
    }
}
