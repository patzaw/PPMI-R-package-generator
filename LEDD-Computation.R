library(tidyverse)
library(glue)

###############################################################################@
## 0. Load the data and merge visit info ----
load("PPMI-Parsed.rda")
cmed <- as_tibble(cmed) %>% 
   mutate(PATNO=as.character(PATNO))
cmed <- left_join(
   rename(cmed, "RECORD_EVENT"="EVENT_ID"),
   visitInfo, by="PATNO"
)

### Identify correct value per visit according to dates----
cmed <- filter(cmed, !is.na(INFODT))
cmed <- cmed %>% filter(
   (is.na(STARTDT) | STARTDT < INFODT) &
      (is.na(STOPDT) | STOPDT >= INFODT),
)

vd <- visitData %>%
   as_tibble(rownames="vid") %>%
   left_join(
      as_tibble(visitInfo, rownames="vid"),
      by="vid"
   ) %>% 
   mutate(
      PD_MED_USE.rec=ifelse(is.na(PD_MED_USE), PD_MED_USE.post, PD_MED_USE)
   )
patd <- as_tibble(patientData, rownames="PATNO")

###############################################################################@
## 1.	Select concomitant medication data: PD medication only ----
pdmed <- filter(cmed, PD_MOTOR_MED==1) %>% 
   left_join(
      vd %>%
         select(
            "PATNO", "EVENT_ID",
            "PDMEDYN", "ONLDOPA", "ONDOPAG", "ONOTHER",
            "PD_MED_USE.rec"
         ),
      by=c("PATNO", "EVENT_ID")
   )

###############################################################################@
## 2.	Create new PD medication variable called GENERIC  ----
generic <- readxl::read_xlsx(
   "~/Shared/Data-Science/PPMI/LEDD/PD_meds_generic_names--NM_02.06.21-FINAL.xlsx"
)
ugeneric <- select(
   generic,
   "GENERIC",
   "LDOPA", "DOPAG", "COMT", "MAO-B I", "OTHER",
   "LEDD_per_DOSE_UNIT", "LEDD_COMT_multiplier"
) %>% distinct()
pdmed <- left_join(
   pdmed,
   select(generic, "WHODRUG", "WHO_GEN"="GENERIC") %>% distinct(),
   by="WHODRUG"
) %>% 
   left_join(
      select(generic, "CMTRT", "CMTRT_GEN"="GENERIC") %>% distinct(),
      by="CMTRT"
   ) %>% 
   mutate(
      GENERIC=ifelse(!is.na(WHO_GEN), WHO_GEN, CMTRT_GEN)
   )

###############################################################################@
## 3.	Normalize CMDOSFRQ to CMDOSFRQ_NORM ----
dosfrq <- readxl::read_xlsx(
   "~/Shared/Data-Science/PPMI/LEDD/CMDOSFRQ_NORM--NM_27.05.21.xlsx",
   range="A1:B5000" 
) %>% 
   filter(!is.na(CMDOSFRQ))
stopifnot(nrow(dosfrq) < 1000)

## 4.	Transform CMDOSFRQ_NORM in an integer CMDOSFRQ_NUM ----
dosfrq <- dosfrq %>% mutate(
   CMDOSFRQ_NUM=case_when(
      CMDOSFRQ_NORM == "QOD" ~ 0.5,
      CMDOSFRQ_NORM == "QD" ~ 1,
      CMDOSFRQ_NORM == "BID" ~ 2,
      CMDOSFRQ_NORM == "TID" ~ 3,
      CMDOSFRQ_NORM == "QID" ~ 4,
      CMDOSFRQ_NORM == "delete row" ~ as.numeric(NA),
      TRUE ~ -1
   )
) %>% 
   mutate(
      CMDOSFRQ_NUM=ifelse(
         CMDOSFRQ_NUM==-1,
         str_remove_all(CMDOSFRQ_NORM, "[QD]") %>% as.numeric(),
         CMDOSFRQ_NUM
      )
   ) %>% 
   distinct()

pdmed <- pdmed %>% left_join(dosfrq, by="CMDOSFRQ") %>% 
   filter(CMDOSFRQ_NORM!="delete row")

###############################################################################@
## 5/6. Clean up data with PDMEDYN == NA | No (but LEDD == X) ----

### vii.  If GENERIC == AMANTADINE ----
##    then assign PDMEDYN=Yes & ONOTHER=TRUE
tocorrect <- which(
   (is.na(pdmed$PDMEDYN) | pdmed$PDMEDYN=="No") & !is.na(pdmed$LEDD) &
      pdmed$GENERIC=="Amantadine"
)
pdmed$PDMEDYN[tocorrect] <- "Yes"
pdmed$ONLDOPA[tocorrect] <- FALSE
pdmed$ONDOPAG[tocorrect] <- FALSE
pdmed$ONOTHER[tocorrect] <- TRUE

### viii. If GENERIC == LEVODOPA* ----
##    then assign PDMEDYN=Yes & ONLDOPA=TRUE
tocorrect <- which(
   (is.na(pdmed$PDMEDYN) | pdmed$PDMEDYN=="No") & !is.na(pdmed$LEDD)
) %>% intersect(
   str_detect(pdmed$GENERIC, "Levodopa") %>% which()
)
pdmed$PDMEDYN[tocorrect] <- "Yes"
pdmed$ONLDOPA[tocorrect] <- TRUE
pdmed$ONDOPAG[tocorrect] <- FALSE
pdmed$ONOTHER[tocorrect] <- FALSE

### ix. If GENERIC == RASAGILINE ----
##    and assign PDMEDYN=Yes & ONOTHER=TRUE
tocorrect <- which(
   (is.na(pdmed$PDMEDYN) | pdmed$PDMEDYN=="No") & !is.na(pdmed$LEDD) &
      pdmed$GENERIC=="Rasagiline"
)
pdmed$PDMEDYN[tocorrect] <- "Yes"
pdmed$ONLDOPA[tocorrect] <- FALSE
pdmed$ONDOPAG[tocorrect] <- FALSE
pdmed$ONOTHER[tocorrect] <- TRUE

### x. GENERIC == Apomorphine, Pramipexole or Ropinirole ----
##    should be set to PDMEDYN == YES AND ONLDOPA == FALSE, ONDOPAG == TRUE,
##    ONOTHER == FALSE
tocorrect <- which(
   (is.na(pdmed$PDMEDYN) | pdmed$PDMEDYN=="No") & !is.na(pdmed$LEDD) &
      pdmed$GENERIC %in% c("Apomorphine", "Pramipexole", "Ropinirole")
)
pdmed$PDMEDYN[tocorrect] <- "Yes"
pdmed$ONLDOPA[tocorrect] <- FALSE
pdmed$ONDOPAG[tocorrect] <- TRUE
pdmed$ONOTHER[tocorrect] <- FALSE

### xi. The rest ----
##    should be set to PDMEDYN == YES and ONLDOPA == FALSE,
##    or ONDOPAG == FALSE, or ONOTHER == TRUE
tocorrect <- which(
   (is.na(pdmed$PDMEDYN) | pdmed$PDMEDYN=="No")
)
pdmed$PDMEDYN[tocorrect] <- "Yes"
pdmed$ONLDOPA[tocorrect] <- FALSE
pdmed$ONDOPAG[tocorrect] <- FALSE
pdmed$ONOTHER[tocorrect] <- TRUE

## 7. Clean up data with PDMEDYN == YES & LEDD == NA ----
### xii. Need to calculate LEDD by Patient / Visit (see below) ----

## 8. Clean up data with GENERIC == CARBIDOPA (only) ----
##    Check LEDD == NA for all
pdmed %>%
   filter(GENERIC=="Carbidopa") %>% pull(LEDD) %>% is.na() %>% all() %>% 
   stopifnot()


## 9. Aggregate the data per patient and visit ----
##    Compute total LEDD and adjust for COMT inhibitor

## Example
# pdmed[which(pdmed$GENERIC=="Carbidopa" & pdmed$PATNO %in% pd),] %>% select("PATNO", "EVENT_ID") %>% View()
# x <- pdmed %>% filter(PATNO=="3231" & EVENT_ID=="V04")

carbTr <- c(
   grep("Carbidopa", unique(pdmed$GENERIC), value=TRUE, ignore.case=TRUE),
   "Entacapone"
)
agpdmed <- do.call(bind_rows, by(
   pdmed,
   paste(pdmed$PATNO, pdmed$EVENT_ID),
   function(x){
      mult.3 <- any(x$GENERIC %in% carbTr) |
         any(x$LEDD=="LD x 0.33", na.rm=TRUE)
      mult.5 <- any(x$GENERIC %in% c("Tolcapone")) |
         any(x$LEDD=="LD x 0.5", na.rm=TRUE)
      if(mult.3 & mult.5){
         stop(paste(x$PATNO[1], x$EVENT_ID[1]))
      }
      toRet <- tibble(
         PATNO=x$PATNO[1],
         EVENT_ID=x$EVENT_ID[1],
         MED_WITH_LEDD=sum(!is.na(x$LEDD_num)),
         LEDD_TOT=sum(x$LEDD_num, na.rm=TRUE),
         MULT=case_when(
            mult.5 ~ 1.5,
            mult.3 ~ 1.33,
            TRUE ~ 1
         )
      ) %>% 
         mutate(
            LEDD_TOT_MULT=LEDD_TOT * MULT
         )
      return(toRet)
   }
))

write_tsv(
   pdmed,
   glue("~/Shared/Data-Science/PPMI/LEDD/PDMED_DETAILS-{Sys.Date()}.txt")
)
write_tsv(
   agpdmed,
   glue("~/Shared/Data-Science/PPMI/LEDD/LEDD_SCORE-{Sys.Date()}.txt")
)
