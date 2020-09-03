library(PPMI)
library(SASxport)

write.xport(
   varDoc, patientData, visitDoc, visitInfo, scheduledVisits, visitData,
   file=sprintf("PPMI-%s.dat", packageDate("PPMI"))
)

for(n in c("varDoc", "patientData", "visitDoc", "visitInfo", "scheduledVisits", "visitData")){
   write.table(
      get(n),
      file=sprintf("%s-%s.csv", n, packageDate("PPMI")),
      sep=",",
      row.names=TRUE, col.names=NA,
      na="",
      quote=T, qmethod="double"
   )
}
