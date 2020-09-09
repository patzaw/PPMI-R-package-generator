library(snpStats)

## Package update information ----
pckName <- "PPMI"
load("PPMI-Derived.rda")
pckDir <- file.path(".", paste(pckName, dumpDate, sep="-"))

## Package documentation ----
library(roxygen2)
roxygenize(package.dir="Package-Template", clean=T)

## Package creation ----
system(paste('rm -rf', pckDir))
dir.create(pckDir)
file.copy("Package-Template/R", pckDir, recursive=T)
file.copy("Package-Template/man", pckDir, recursive=T)
file.copy("Package-Template/NAMESPACE", pckDir, overwrite=T)
file.copy("Package-Template/vignettes", pckDir, recursive=T)

## DESCRIPTION file ----
descFile <- readLines("Package-Template/DESCRIPTION")
descFile <- c(descFile, paste("Date:", dumpDate))
write(descFile, file.path(pckDir, "DESCRIPTION"),ncolumns=1)

## Data files ----
dir.create(file.path(pckDir, "data"))
toSave <- c(
    "visitDoc", "visitInfo", "scheduledVisits",
    "varDoc", "patientData", "visitData"
)
for(dn in toSave){
    save(list=dn, file=file.path(pckDir, "data", paste0(dn, ".rda")))
}

## Genetics data ----
genoOriDir <- "~/Shared/Data-Science/PPMI/Analysis/pgo/2014-07-Genotyping-Arrays"
genoPckDir <- file.path(pckDir, "inst", "extdata", "Genotyping")
dir.create(genoPckDir, recursive=TRUE)
toCopy <- file.path(
    genoOriDir,
    paste(
        "ImmunoNeurox-GRCh37",
        c("bed", "bim", "fam"),
        sep="."
    )
)
for(f in toCopy){
    file.copy(f, genoPckDir)
}
curDir <- getwd()
setwd(genoOriDir)
genPref <- "ImmunoNeurox-GRCh37"
plinkImport <- read.plink(
    bed=paste0(genPref, ".bed"),
    bim=paste0(genPref, ".bim"),
    fam=paste0(genPref, ".fam")
)
setwd(curDir)
snpData <- plinkImport$genotypes
snpInfo <- plinkImport$map
toSave <- c(
    "snpData", "snpInfo"
)
for(dn in toSave){
    save(list=dn, file=file.path(pckDir, "data", paste0(dn, ".rda")))
}

## Install the PPMI package ----
try(detach("package:PPMI", unload=T))
try(remove.packages("PPMI"))
install.packages(pckDir, repos=NULL)
devtools::build_vignettes(pckDir)
file.rename(file.path(pckDir, "doc"), file.path(pckDir, "inst", "doc"))
install.packages(pckDir, repos=NULL)
