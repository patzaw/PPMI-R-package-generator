library(PPMI)
library(tidyverse)

enrDate <- patientData %>%
   mutate(PATNO=rownames(patientData)) %>%
   select(PATNO, ENROLL_DATE)

visDate <- visitInfo %>%
   mutate(ID=paste(PATNO, EVENT_ID, sep=".")) %>%
   filter(EVENT_ID %in% scheduledVisits$Visit) %>%
   left_join(scheduledVisits, by=c("EVENT_ID"="Visit")) %>%
   left_join(enrDate, by="PATNO") %>%
   mutate(time=as.numeric((INFODT-ENROLL_DATE))/30) %>%
   mutate(diff=time-Month) %>%
   as_tibble()


toPlot <- visDate
par(mfrow=c(2,1))
boxplot(
   diff~Month, data=toPlot,
   main="Visit time after enrollment for all subjects/visits",
   ylab="Computed-Scheduled",
   xlab="Scheduled time (months)"
)
boxplot(
   diff~Month, data=toPlot,
   outline=FALSE,
   ylab="Computed-Scheduled",
   xlab="Scheduled time (months)"
)
vtext <- toPlot %>%
   select(EVENT_ID, "Month") %>% unique() %>% arrange(Month) %>%
   mutate(order=1:length(Month))
mtext(vtext$EVENT_ID, at=vtext$order)

## Visits with SBR

withSBR <- visitData %>%
   mutate(rownames=rownames(visitData)) %>%
   as_tibble() %>%
   select(rownames, CAUDATE_R) %>%
   filter(!is.na(CAUDATE_R))

toPlot <- visDate %>% filter(ID %in% withSBR$rownames) 
par(mfrow=c(2,1))
boxplot(
   diff~Month, data=toPlot,
   main="Visit time after enrollment for subjects/visits with SBR values",
   ylab="Computed-Scheduled",
   xlab="Scheduled time (months)"
)
boxplot(
   diff~Month, data=toPlot,
   outline=FALSE,
   ylab="Computed-Scheduled",
   xlab="Scheduled time (months)"
)
vtext <- toPlot %>%
   select(EVENT_ID, "Month") %>% unique() %>% arrange(Month) %>%
   mutate(order=1:length(Month))
mtext(vtext$EVENT_ID, at=vtext$order)
