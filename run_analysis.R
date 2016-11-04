# Week 3 Assignment - Tidy Data
# 30 Volunteers 19 -48 years - WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING 

# 1. Creating working directory
library(data.table) #required it for fread to import data
setwd("./Data")
path<- getwd()

#2. download data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Wk3PrjData.zip"
if(!file.exits(path)){dir.create(path)} #if file does not exist create it here
download.file(url,file.path(path,f))    #download file from url to working dir and name it

#3. Create Input folder
pathIn <- file.path(path, "UCI HAR Dataset")

#4. Reading Test & Train files
#Subject Files
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest  <- fread(file.path(pathIn, "test" , "subject_test.txt" ))
#Activity label Files
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest  <- fread(file.path(pathIn, "test" , "Y_test.txt" ))
#data files
filetodatatable <- function(f) {
  df <- read.table(f)
  dt <- data.table(df) #converts dataframe above to a data table
}
dtTrain <- filetodatatable(file.path(pathIn,"train", "X_train.txt"))
dtTest <- filetodatatable(file.path(pathIn, "test", "X_test.txt"))

#Merging the data sets
#Data Tables 
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
#Merging colums
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt) #key middle point. combining all subjects, activities and detected variables

#Set Key
setkey(dt, subject, activityNum) #sorting new dt by subject
#Reading in features file from ReadMe and changing names
dtFeatures <- fread(file.path(pathIn,"features.txt"))
setnames(dtFeatures, names(dtFeatures),c("featureNum","featureName"))

#Looking only for variables that are mean & std
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

#converting the column variable number to match the merged table
dtFeatures$featureCode <- dtFeatures[,paste0("V", featureNum)] #pretty cool way to add new column
head(dtFeatures)
dtFeatures$featureCode #above 2 are just to view data

#Subset data to select columns based on activity names using variables
select <- c(key(dt),dtFeatures$featureCode)
dt2 <- dt[,select,with=FALSE]

#Read in Activity names to read in activity descriptions

dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))

#Merging names into dataset
dt2 <- merge(dt2, dtActivityNames, by="activityNum", all.x=TRUE)

#sorting
setkey(dt2, subject, activityNum, activityName)

#changing orientation
dt2 <- data.table(melt(dt2, key(dt2), variable.name = "featureCode"))

#merging activity name into new table
dt2 <- merge(dt2, dtFeatures[,list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)

#creating new variables to update table
dt2$activity <- factor(dt2$activityName)
dt2$feature <- factor(dt2$featureName)
#Removing feature column
grepthis <- function (regex) {
  grepl(regex, dt2$feature)
}

## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol=nrow(y))
#new column
dt2$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol=nrow(y))
#new column
dt2$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol=nrow(y))
#new column
dt2$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol=nrow(y))
#new column
dt2$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))

## Features with 1 category
dt2$featJerk <- factor(grepthis("Jerk"), labels=c(NA, "Jerk"))
dt2$featMagnitude <- factor(grepthis("Mag"), labels=c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol=nrow(y))
dt2$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))

#Creating Tidy Dataset with required fields
setkey(dt2, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt2[, list(count = .N, average = mean(value)), by=key(dt2)] #summarizing

#Exporting Data
write.table(dt2, "C:/Users/farsyed/Documents/R/Working Dir/Extracts/TidyData.txt", sep="\t")
