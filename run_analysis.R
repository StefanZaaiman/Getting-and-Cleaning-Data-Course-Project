## This script assumes the data is downloaded to the working directory and that
## the working directory is set in the R environment, and that the package "plyr"
## and "dplyr" and "reshape2" is installed.

 
## Load required libraries
library(plyr)
library(dplyr)
library(reshape2)
 
## Read in all the required datasets for the assingment

# First the training datasets
rawTrainData = read.table("UCI HAR Dataset/train/X_train.txt", colClasses = "numeric")
rawTrainActivityCodes = read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "integer")
rawTrainSubjectCodes = read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "integer")

# Then the testing datasets
rawTestData = read.table("UCI HAR Dataset/test/X_test.txt", colClasses = "numeric")
rawTestActivityCodes = read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "integer")
rawTestSubjectCodes = read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "integer")

# Read in the activity codes mappings
rawActivityMappings = read.table("UCI HAR Dataset/activity_labels.txt", colClasses = c("integer", "character"))

# Finally read in the names of the 561 elements of the vectors in the training and testing sets
rawVariableNames = read.table("UCI HAR Dataset/features.txt", colClasses = "character")

 
## Add the Activity Codes and Subject codes to the training and testing datasets
TrainData = cbind(rawTrainData, rawTrainActivityCodes, rawTrainSubjectCodes)
TestData = cbind(rawTestData, rawTestActivityCodes, rawTestSubjectCodes)

 
## Create a combined training and testing dataset (Step 1)
TotalData = rbind(TrainData, TestData)

 
## Add the variable names to the TotalData dataset

# Add Activities and Subject to the rest of the variablenames dataset
rawVariableNames = rbind(rawVariableNames, c(562, "Activities"), c(563, "Subject"))

# Add the variablenames to the TotalData data frame
colnames(TotalData) = rawVariableNames$V2

 
## Extract only the measurements on the mean and standard deviation for each measurement (Step 2)

# Decide which columns to keep
ColumnsToKeepMean = grep("mean\\(\\)", rawVariableNames$V2)
ColumnsToKeepStd = grep("std\\(\\)", rawVariableNames$V2)
ColumnsToKeepMeanCap = grep("Mean\\(\\)", rawVariableNames$V2)
ColumnsToKeepStdCap = grep("Std\\(\\)", rawVariableNames$V2)
FinalColumnsToKeep = sort(c(ColumnsToKeepMean, ColumnsToKeepStd, ColumnsToKeepMeanCap, ColumnsToKeepStdCap, 562, 563))

# Do the subsetting based on the above vector of columns to keep
TotalData = TotalData[, FinalColumnsToKeep]

 
## Uses descriptive activity names to name the activities in the data set (Step 3)
TotalData$Activities = tolower(plyr::mapvalues(TotalData$Activities, from = rawActivityMappings$V1, to = rawActivityMappings$V2))

 
## Appropriately labels the data set with descriptive variable names (Step 4)

# Put the old column names in a vector
ColumnNames = colnames(TotalData)

# Use gsub to make the names more descriptive
ColumnNames = gsub("Acc", "Accelerometer", ColumnNames)
ColumnNames = gsub("Gyro", "Gyroscope", ColumnNames)
ColumnNames = gsub("-X", "_X-axis", ColumnNames)
ColumnNames = gsub("-Y", "_Y-axis", ColumnNames)
ColumnNames = gsub("-Z", "_Z-axis", ColumnNames)
ColumnNames = gsub("std", "standardDeviation", ColumnNames)
ColumnNames = gsub("BodyBody", "Body", ColumnNames)
ColumnNames = gsub("tBody", "timeDomain_Body", ColumnNames)
ColumnNames = gsub("tGravity", "timeDomain_Gravity", ColumnNames)
ColumnNames = gsub("fBody", "frequencyDomain_Body", ColumnNames)
ColumnNames = gsub("Mag", "_Magnitude", ColumnNames)
ColumnNames = gsub("Activities", "TypeOfActivity", ColumnNames)
ColumnNames = gsub("Subject", "IndividualSubjectNumber", ColumnNames)
ColumnNames = gsub("Body", "Body_", ColumnNames)
ColumnNames = gsub("Gravity", "Gravity_", ColumnNames)
ColumnNames = gsub("-mean", "_mean", ColumnNames)
ColumnNames = gsub("-standard", "_standard", ColumnNames)
ColumnNames = gsub("\\(\\)", "", ColumnNames)
ColumnNames = gsub("Jerk", "_Jerk", ColumnNames)

# add the new variable descriptions to the data frame
colnames(TotalData) = ColumnNames


## Create a second, independent tidy data set with the average of each variable for each activity and each subject (Step 5)

# First create a narrow molten dataframe
TotalData = TotalData[c(68,67,1:66)]
TotalDataMelt = melt(TotalData, id=c(1,2), measure.vars = c(3:68))

# Recast the molten dataframe to calculate the mean of the intersection of each subject, activity and all the variables
TotalDataCast = dcast(TotalDataMelt, IndividualSubjectNumber + TypeOfActivity ~ variable, value.var = "value", mean)

# Write the tidy data frame to a text file
write.table(TotalDataCast, "tidyData.txt", row.names=FALSE)