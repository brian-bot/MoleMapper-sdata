a <- read.delim("~/Desktop/participants-2016-08-13.tsv", stringsAsFactors = FALSE)
tmp <- strsplit(a$consentHistories, ",", fixed=TRUE)
tmp <- sapply(tmp, function(x){
  tmp2 <- strsplit(x[1], "=", fixed=TRUE)
  if(length(tmp2[[1]])>1){
    return(as.character(as.Date(tmp2[[1]][2], format="%m/%d/%Y")))
  } else{
    return(NA)
  }
})
a$earlyCohort <- as.Date(tmp) < as.Date("2016-06-01")
# table(as.Date(tmp) < as.Date("2016-06-01"), a$sharingScope, useNA = "ifany")


require(synapseClient)
synapseLogin()

q <- synQuery('SELECT id, name FROM table WHERE parentId=="syn6191002"')
q <- q[ q$table.name != "Mole Images", ]
hc <- lapply(q$table.id, function(x){
  as.character(synTableQuery(paste0('SELECT DISTINCT healthCode FROM ', x))@values$healthCode)
})
hc <- unique(do.call(c, hc))

a$inSynapse <- a$healthCode %in% hc

## OK, MOVE ON
stopifnot(all(a$earlyCohort[ a$inSynapse ]))

table(a$earlyCohort, a$sharingScope, useNA = "ifany")

