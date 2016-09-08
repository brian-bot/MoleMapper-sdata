require(synapseClient)
synapseLogin()

## GET THE DEMOGRAPHICS DATA
tq <- synTableQuery('SELECT * FROM syn6829807')
aa <- tq@values

## LOOK AT DISTRIBUTIONS OF RISK FACTORS
for(i in c("melanomaDiagnosis", "hairColor", "gender", "eyeColor", "familyHistory", "immunocompromised", "autoImmune", "moleRemoved")){
  cat("--------------\n")
  print(table(aa[[i]]))
  print(table(aa[[i]])/sum(!is.na(aa[[i]])))
  cat("--------------\n")
}

## LOOK AT DISTRIBUTIONS OF RISK FACTORS BY MELANOMA DIAGNOSIS
for(i in c("hairColor", "gender", "eyeColor", "familyHistory", "immunocompromised", "autoImmune")){
  cat("--------------\n")
  print(table(aa[[i]], aa[["melanomaDiagnosis"]]))
  print(prop.table(table(aa[[i]], aa[["melanomaDiagnosis"]]), 2))
  print(chisq.test(aa[[i]], aa[["melanomaDiagnosis"]]))
  cat("--------------\n")
}

