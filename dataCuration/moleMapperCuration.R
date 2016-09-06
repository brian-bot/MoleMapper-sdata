require(synapseClient)
synapseLogin()

# theseTables <- synTableQuery("SELECT DISTINCT originalTable FROM syn4984903")@values
# 
# q <- synQuery('SELECT id, name FROM table WHERE parentId=="syn6126493"')
# q <- q[ q$table.name %in% theseTables$originalTable, ]
# 
# res <- lapply(q$table.id, function(x){
#   synTableQuery(paste0('SELECT * FROM ', x))@values
# })
###################

coreNames <- c("recordId", "healthCode", "createdOn", "appVersion", "phoneInfo")
releaseVersions <- c("version 2.0.1, build 3")
theseZips <- c("036", "692", "878", "059", "790", "879", "063", "821", "884", "102", "823", "890", "203", "830", "893", "556", "831")
outputProjId <- "syn6191002"

#####
## INITIAL DATA
#####
# syn4984908
baselineData <- synTableQuery('SELECT * FROM syn4984908')@values
baselineData$externalId <- NULL
baselineData$dataGroups <- NULL
baselineData$uploadDate <- NULL
baselineData <- baselineData[ baselineData$appVersion %in% releaseVersions, ]
baselineData$appVersion <- NULL
## TAKE THE FIRST SURVEY RESULT - DISCARD THE REST
baselineData <- baselineData[ order(baselineData$createdOn), ]
baselineData <- baselineData[ !duplicated(baselineData$healthCode), ]

## REFORMAT ANSWERS
baselineData$gender <- tolower(sub("HKBiologicalSex", "", baselineData$initialData.json.gender))
baselineData$initialData.json.gender <- NULL

baselineData$eyeColor <- sub("Eyes", "", baselineData$initialData.json.eyeColor)
baselineData$initialData.json.eyeColor <- NULL

baselineData$familyHistory <- baselineData$initialData.json.familyHistory==1
baselineData$initialData.json.familyHistory <- NULL

baselineData$autoImmune <- baselineData$initialData.json.autoImmune==1
baselineData$initialData.json.autoImmune <- NULL

baselineData$hairColor <- sub("Hair", "", baselineData$initialData.json.hairColor)
baselineData$initialData.json.hairColor <- NULL

baselineData$immunocompromised <- baselineData$initialData.json.immunocompromised==1
baselineData$initialData.json.immunocompromised <- NULL

baselineData$melanomaDiagnosis <- baselineData$initialData.json.melanomaDiagnosis==1
baselineData$initialData.json.melanomaDiagnosis <- NULL

baselineData$moleRemoved <- baselineData$initialData.json.moleRemoved==1
baselineData$initialData.json.moleRemoved <- NULL

baselineData$initialData.json.shortenedZip[ baselineData$initialData.json.shortenedZip %in% theseZips ] <- "000"
baselineData$shortenedZip <- as.character(baselineData$initialData.json.shortenedZip)
baselineData$initialData.json.shortenedZip <- NULL

baselineData$profession <- baselineData$initialData.json.profession
baselineData$initialData.json.profession <- NULL

baselineData$birthyear <- as.integer(baselineData$initialData.json.birthyear)
baselineData$initialData.json.birthyear <- NULL
## CENSOR ANY AGES OVER 90 AT 90 (CONSERVATIVELY COVERS BIRTH YEAR 1926) -- THERE ARE NONE
stopifnot(which(baselineData$birthyear < 1926)==0)

baselineData <- baselineData[ order(baselineData$createdOn), ]

## DUE TO AGE RESTRICTIONS, OMIT FROM THE RELEASE ANYONE LESS THAN 18 (BIRTH YEAR 1997 OR MORE RECENT - CONSERVATIVELY COVERS 2015)
tooYoung <- baselineData$healthCode[ which(baselineData$birthyear >= 1997) ]


#####
## FOLLOWUP
#####
# syn4984904
fuData <- synTableQuery('SELECT * FROM syn4984904')@values
fuData$externalId <- NULL
fuData$dataGroups <- NULL
fuData$uploadDate <- NULL
fuData$followup.json.date <- NULL
fuData <- fuData[ fuData$appVersion %in% releaseVersions, ]
fuData$appVersion <- NULL

fuData$sunburn <- fuData$followup.json.sunburn==1
fuData$followup.json.sunburn <- NULL

fuData$moleRemoved <- fuData$followup.json.moleRemoved==1
fuData$followup.json.moleRemoved <- NULL

fuData$sunscreen <- fuData$followup.json.sunscreen==1
fuData$followup.json.sunscreen <- NULL

fuData$sick <- fuData$followup.json.sick==1
fuData$followup.json.sick <- NULL

fuData$tan <- fuData$followup.json.tan==1
fuData$followup.json.tan <- NULL

fuData <- fuData[ order(fuData$createdOn), ]

#####
## REMOVED MOLE
#####
# syn4984906
remDataTable <- synTableQuery('SELECT * FROM syn4984906')
remData <- remDataTable@values
remData$externalId <- NULL
remData$dataGroups <- NULL
remData$uploadDate <- NULL
## THESE FILES ALL JUST SAY 'REMOVED'
remData$removedMoleData.json.diagnoses <- NULL
remData <- remData[ remData$appVersion %in% releaseVersions, ]
remData$appVersion <- NULL

remData$moleID <- remData$removedMoleData.json.moleID
remData$removedMoleData.json.moleID <- NULL

remData <- remData[ order(remData$createdOn), ]

#####
## MOLE MEASUREMENT
#####
# syn4984907
# syn6185364
moleData <- synTableQuery('SELECT * FROM syn4984907')@values
moleData <- moleData[ nrow(moleData):1, ]
moleData <- moleData[ !duplicated(moleData$recordId), ]
moleData$externalId <- NULL
moleData$dataGroups <- NULL
moleData$uploadDate <- NULL
moleData <- moleData[ moleData$appVersion %in% releaseVersions, ]
moleData$appVersion <- NULL
moleData$measurementData.json.dateMeasured <- NULL
moleData$measurementData.json.measurementID <- NULL

moleData$moleID <- moleData$measurementData.json.moleID
moleData$measurementData.json.moleID <- NULL

moleData$zoneID <- moleData$measurementData.json.zoneID
moleData$measurementData.json.zoneID <- NULL

moleData$xCoordinate <- moleData$measurementData.json.xCoordinate
moleData$measurementData.json.xCoordinate <- NULL

moleData$yCoordinate <- moleData$measurementData.json.yCoordinate
moleData$measurementData.json.yCoordinate <- NULL

moleData$diameter <- moleData$measurementData.json.diameter
moleData$measurementData.json.diameter <- NULL

moleData$defaultPenny <- moleData$diameter==5.08
moleData$defaultDime <- moleData$diameter==4.776
moleData$defaultQuarter <- moleData$diameter==6.469334

moleData <- moleData[ order(moleData$createdOn), ]


#####
## SUBSET FUNCTION TO ONLY INCLUDE ELIGIBLE PARTICIPANTS AND THOSE WHO CHOSE TO SHARE BROADLY
#####
## GET THE SHARING SETTINGS
shareData <- read.delim(getFileLocation(synGet("syn6187939")), stringsAsFactors = FALSE)
shareBroadly <- shareData$healthCode[ shareData$sharingScope=="all_qualified_researchers" ]

subsetThis <- function(x){
  ## REMOVE THE INELIGIBLE SELF-REPORTED 'YOUNG' PARTICIPANTS
  x <- x[ !(x$healthCode %in% tooYoung), ]
  ## REMOVE DUPLICATES
  x <- x[ !duplicated(x[, -which(names(x) %in% c("recordId", "createdOn"))]), ]
  ## KEEP ONLY THOSE WHO CHOSE TO SHARE BROADLY
  x <- x[ x$healthCode %in% shareBroadly, ]
  return(x)
}

baselineData <- subsetThis(baselineData)
fuData <- subsetThis(fuData)
remData <- subsetThis(remData)
moleData <- subsetThis(moleData)

## PULL IN CURATION FOR SUBSETTING
curData <- synTableQuery('SELECT * FROM syn6185364')@values
rownames(curData) <- curData$recordId
curData <- curData[ moleData$recordId, ]

## SPLIT OUT THE MOLE DATA INTO THE METADATA AND THE IMAGE FILES
imageData <- moleData[, c("recordId", "measurementPhoto.png")]
moleData$measurementPhoto.png <- NULL
imageData$censored <- curData[imageData$recordId, "combinedCall"]
imageData$measurementPhoto.png[imageData$censored==1] <- NA
imageData$invalid <- curData[imageData$recordId, "danInvalid"]

## RENAME ALL OF THE FILEHANDLES
for(i in 1:nrow(imageData)){
  if(!is.na(imageData$measurementPhoto.png)[i]){
    tmpFh <- synRestGET(paste0('/fileHandle/', imageData$measurementPhoto.png[i]), 
                        endpoint = synapseFileServiceEndpoint())
    tmpFh$fileName <- paste0(imageData$recordId[i], ".png")
    newFh <- synRestPOST(paste0('/fileHandle/', imageData$measurementPhoto.png[i], '/copy'), 
                         body=tmpFh, 
                         endpoint = synapseFileServiceEndpoint())
    imageData$measurementPhoto.png[i] <- newFh$id
  }
}


#####
## STORE IN SYNAPSE
#####
## LOG IN AS BRIDGE EXPORTER

## BASELINE DEMOGRAPHICS
baselineTcs <- as.tableColumns(baselineData)
for(i in 1:length(baselineTcs$tableColumns)){
  if( baselineTcs$tableColumns[[i]]@name == "appVersion" ){
    baselineTcs$tableColumns[[i]]@maximumSize <- as.integer(48)
  }
}
baselineTable <- synStore(Table(tableSchema = TableSchema(name="Baseline Demographics Survey",
                                                          parent = outputProjId,
                                                          columns = baselineTcs$tableColumns),
                                values = baselineTcs$fileHandleId))

## FOLLOWUP SURVEY
fuTcs <- as.tableColumns(fuData)
for(i in 1:length(fuTcs$tableColumns)){
  if( fuTcs$tableColumns[[i]]@name == "appVersion" ){
    fuTcs$tableColumns[[i]]@maximumSize <- as.integer(48)
  }
}
fuTable <- synStore(Table(tableSchema = TableSchema(name="Followup Survey",
                                                    parent = outputProjId,
                                                    columns = fuTcs$tableColumns),
                          values = fuTcs$fileHandleId))

## MOLE REMOVAL INDICATOR
remTcs <- as.tableColumns(remData)
for(i in 1:length(remTcs$tableColumns)){
  if( remTcs$tableColumns[[i]]@name == "appVersion" ){
    remTcs$tableColumns[[i]]@maximumSize <- as.integer(48)
  }
}
remTable <- synStore(Table(tableSchema = TableSchema(name="Mole Removal Indicator",
                                                     parent = outputProjId,
                                                     columns = remTcs$tableColumns),
                           values = remTcs$fileHandleId))

## MOLE MEASUREMENTS
moleTcs <- as.tableColumns(moleData)
for(i in 1:length(moleTcs$tableColumns)){
  if( moleTcs$tableColumns[[i]]@name == "appVersion" ){
    moleTcs$tableColumns[[i]]@maximumSize <- as.integer(48)
  }
}
moleTable <- synStore(Table(tableSchema = TableSchema(name="Mole Measurements",
                                                      parent = outputProjId,
                                                      columns = moleTcs$tableColumns),
                            values = moleTcs$fileHandleId))

## ACTUAL MOLE IMAGES AND CURATION INFO
imageTcs <- as.tableColumns(imageData)
for(i in 1:length(imageTcs$tableColumns)){
  if( imageTcs$tableColumns[[i]]@name == "measurementPhotopng" ){
    imageTcs$tableColumns[[i]]@name <- "measurementPhoto.png"
    imageTcs$tableColumns[[i]]@columnType <- "FILEHANDLEID"
    imageTcs$tableColumns[[i]]@maximumSize <- integer()
  }
  if( imageTcs$tableColumns[[i]]@name == "appVersion" ){
    imageTcs$tableColumns[[i]]@maximumSize <- as.integer(48)
  }
}
imageTable <- synStore(Table(tableSchema = TableSchema(name="Mole Images",
                                                       parent = outputProjId,
                                                       columns = imageTcs$tableColumns),
                             values = imageTcs$fileHandleId))

