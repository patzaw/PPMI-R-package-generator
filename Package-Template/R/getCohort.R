#' Get patient IDs of a cohort
#' 
#' @param cohort the name of the cohort to extract
#' @param enrolledOnly if TRUE (default) only patients with an "Enrolled"
#' status are returned
#' 
#' @export
#' 
getCohort <- function(cohort, enrolledOnly=TRUE){
    if(enrolledOnly){
        return(
            rownames(PPMI::patientData)[which(
                PPMI::patientData$ENROLL_CAT %in% cohort &
                    PPMI::patientData$ENROLL_STATUS=="Enrolled"
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
