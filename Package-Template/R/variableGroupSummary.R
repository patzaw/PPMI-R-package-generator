#' Summarize the number of variables per Sub-group
#' 
#' @export
#' 
variableGroupSummary <- function(){
    toRet <- c()
    gps <- unique(PPMI::varDoc$Group)
    for(gp in gps){
        sgps <- unique(PPMI::varDoc$`Sub-group`[which(PPMI::varDoc$Group==gp)])
        for(sgp in sgps){
            nv <- nrow(
                PPMI::varDoc[
                    which(
                        PPMI::varDoc$Group==gp & PPMI::varDoc$`Sub-group`==sgp
                    ),
                ]
            )
            toAdd <- data.frame(
                "Group"=gp,
                "Sub-group"=sgp,
                "Number of variables"=nv,
                stringsAsFactors=F,
                check.names=F
            )
            toRet <- rbind(toRet, toAdd)
        }
    }
    return(toRet)
}
