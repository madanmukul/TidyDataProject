# run_analysis.R
# Programming Assignment for Get and Clean Data Coursera course
#
library(dplyr)
# the zip file in working directory
zipFileName = "getdata-projectfiles-UCI HAR Dataset.zip"
# pre-load activity and the 561 variable name data from zip file
# 6 activity names are in activity_labels.txt
zipActivityNames = "UCI HAR Dataset/activity_labels.txt"
con <- unz(description = zipFileName, filename = zipActivityNames)
IndexedActivityNames <- read.table(con)
#
# 561 set Variable Names are in features.txt
zipVarNames = "UCI HAR Dataset/features.txt"
con <- unz(description = zipFileName, filename = zipVarNames)
IndexedVarNames <- read.table(con)
#
# select(TsetRd,contains("mean()" or "std()"))
x1 <- grep("mean()",IndexedVarNames[,"V2"])
x2 <- grep("std()",IndexedVarNames[,"V2"])
sIndexedVarNames <- IndexedVarNames[c(x1,x2),]
#
# First process Test files
# location of test file(s) in zip file
zipTestSubject = "UCI HAR Dataset/test/subject_test.txt"
zipTestSet = "UCI HAR Dataset/test/X_test.txt"
zipTestLabels = "UCI HAR Dataset/test/y_test.txt"
#
con <- unz(description = zipFileName, filename = zipTestSubject)
TsubjRd <- read.table(con)
# Put in a meaningful header
names(TsubjRd) <- "SubjectID"
#
con <- unz(description = zipFileName, filename = zipTestLabels)
TlabelsRd <- read.table(con)
# Put in a meaningful header
names(TlabelsRd) <- "ActivityCode"
#
con <- unz(description = zipFileName, filename = zipTestSet)
TsetRd <- read.table(con)
# select only the variables with means and std
sTsetRd <- select(TsetRd,c(x1,x2))
# put in headers
names(sTsetRd) <- sIndexedVarNames[,"V2"]
# Create the combined data set for Test Data
TestDataSet <- cbind(TsubjRd,TlabelsRd,sTsetRd)
#
# Next process Train files
# location of train file(s) in zip file
zipTrainSubject = "UCI HAR Dataset/train/subject_train.txt"
zipTrainSet = "UCI HAR Dataset/train/X_train.txt"
zipTrainLabels = "UCI HAR Dataset/train/y_train.txt"
#
con <- unz(description = zipFileName, filename = zipTrainSubject)
RsubjRd <- read.table(con)
# Put in a meaningful header
names(RsubjRd) <- "SubjectID"
#
con <- unz(description = zipFileName, filename = zipTrainLabels)
RlabelsRd <- read.table(con)
# Put in a meaningful header
names(RlabelsRd) <- "ActivityCode"
#
con <- unz(description = zipFileName, filename = zipTrainSet)
RsetRd <- read.table(con)
# select only the variables with means and std
sRsetRd <- select(RsetRd,c(x1,x2))
# put in headers
names(sRsetRd) <- sIndexedVarNames[,"V2"]
# Create the combined data set for Test Data
TrainDataSet <- cbind(RsubjRd,RlabelsRd,sRsetRd)
#
#  Combine Test & Train Data Sets
#
FullDataSet <- rbind(TestDataSet, TrainDataSet)
#
# Adding in Descriptive Label Names
FullDataSet <- mutate(FullDataSet, 
            ActivityCode = IndexedActivityNames[FullDataSet$ActivityCode,2])
#
#
groupedDataSet <- group_by(FullDataSet, SubjectID, ActivityCode)
#
newTidyData <- summarise_each(groupedDataSet, funs(mean))
#
# write to the text file
tidyPath = "./newTidyData.txt"
con <- file(description = tidyPath, open = "w")
write.table(newTidyData, con, sep = " ")
close(con)
# the end