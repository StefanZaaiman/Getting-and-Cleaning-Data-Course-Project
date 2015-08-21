# Accompanying README.md file for the Getting and Cleaning Data Course Project
## Overview and introduction
This file explains how the accompanying script **"run_analysis.R"** works. Overall the script reads in the provided datasets for the project, and then tackles the required steps for the project in a step-by-step fashion (clearly labelled below), and then finally creates the final tidy data text file (called **"tidyData.txt"** - you can find the file [here](https://s3.amazonaws.com/coursera-uploads/user-2e6316f0fe61625b298b2296/975115/asst-3/22e65e90482911e5bd23a10ce0e4b813.txt))

To read the **"tidyData.txt"** file I uploaded on Coursera.org back into R you can use the following code:
```R
dataset = read.table("tidyData.txt", header = TRUE)
```
## Explanation of the run_analysis.R script
### Reading in the datasets
The run_analysis.R script assumes that the data is downloaded into the working directory in the standard directory structure as provided on Coursera.org, therefore it assumes the data is in an unzipped folder called **"UCI HAR Dataset"**.

The script also assumes that the following libraries are installed (the script will load these packages):
* plyr
* dplyr
* reshape2

The script starts off by reading in the provided training dataset (to a dataframe called **"rawTrainData"** ) as well as the training data activity codes and training data subject codes into separate datasets (to dataframes called **"rawTrainActivityCodes"** and **"rawTrainSubjectCodes"**, respectively). The classes of the columns are explicitly set as an option in the read.table function to ensure the correct variable types. The data is read in using the following code:
```R
rawTrainData = read.table("UCI HAR Dataset/train/X_train.txt", colClasses = "numeric")
rawTrainActivityCodes = read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "integer")
rawTrainSubjectCodes = read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "integer")
```
The 3 similar test datasets, the activity code mappings (from the **"activity_labels.txt"** file) and raw Variable names (from the **"features.txt"** file) are then read in in exactly the same way. The activity code mappings are read into a dataframe called **"rawActivityMappings"** and the provided variable names are read into a dataframe called **"rawVariableNames"**.

The script then appends the activity codes and subject numbers to the training and testing datasets using the following code:
```R
TrainData = cbind(rawTrainData, rawTrainActivityCodes, rawTrainSubjectCodes)
TestData = cbind(rawTestData, rawTestActivityCodes, rawTestSubjectCodes)
```
### Step 1 of the project requirements (create one dataset)
Step 1 of the project requirements is then performed: combining the training and testing datasets into one dataset called **"TotalData"** using the code:
```R
TotalData = rbind(TrainData, TestData)
```
### Step 2 of the project requirements (only keep the mean and standard deviation columns)
The script then adds the variable names to the **"TotalData"** dataset, by first creating a dataset called **"rawVariableNames"** which is a combination of the variable names as was read in above from the **"features.txt"** file, and adding **"Activities"** and **"Subject"** as the variable names for the appended columns (remember as explained above these two columns were added to the training and testing datasets). The **"TotalData"** dataset column names are then added from the second column of **"rawVariableNames"**. The code for these two actions are:
```R
rawVariableNames = rbind(rawVariableNames, c(562, "Activities"), c(563, "Subject"))
colnames(TotalData) = rawVariableNames$V2
```
The script then creates 4 vectors of column index numbers using the **"grep"** function to identify which columns needs to remain - we need to keep the mean and standard deviation columns. The assumption made here is that only variable names which includes **"mean()"**, **"str()"**, **"Mean()"** or **"Std()"** are included in the final dataset. The **"Mean()"** or **"Std()"** vectors ended up being empty, but I included them initially to ensure I don't miss any columns due to capital letters.

These 4 vectors are then combined into 1 vector and this vector is then used to subset the **"TotalData"** dataset to only keep the abovementioned mean and standard deviation columns (which ended up being 66 columns of means and standard deviations). The code to do this is:
```R
# Decide which columns to keep
ColumnsToKeepMean = grep("mean\\(\\)", rawVariableNames$V2)
ColumnsToKeepStd = grep("std\\(\\)", rawVariableNames$V2)
ColumnsToKeepMeanCap = grep("Mean\\(\\)", rawVariableNames$V2)
ColumnsToKeepStdCap = grep("Std\\(\\)", rawVariableNames$V2)
FinalColumnsToKeep = sort(c(ColumnsToKeepMean, ColumnsToKeepStd, ColumnsToKeepMeanCap, ColumnsToKeepStdCap, 562, 563))

# Do the subsetting based on the above vector of columns to keep
TotalData = TotalData[, FinalColumnsToKeep]
```
### Step 3 of the project requirements (use descriptive activity names)
The script then uses the **"mapvalues"** function from the **"plyr"** package to change the activity codes in the **"TotalData"** dataset to the activity descriptions as provided in the **"activity_labels.txt"** file that was read into a dataset called **"rawActivityMappings"**. Only one line of code was needed to do this (thanks plyr!). The V1 and V2 are  there because the **"rawActivityMappings"** dataset has two columns, the first being the number linked to the activity and the second being the string description of the activity itself. The code is:
```R
TotalData$Activities = tolower(plyr::mapvalues(TotalData$Activities, from = rawActivityMappings$V1, to = rawActivityMappings$V2))
```
### Step 4 of the project requirements (make the variable names nicer)
The script then does some processing on the column names of the **"TotalData"** dataset in order to make the descriptions more clear. It starts off by reading the old variable names into a vector called **"ColumnNames"** and then uses the **"gsub"** function to replace sections of text with better descriptions (I hope!). Finally the column names in the **"TotalData"** dataset are replaced with the improved variable names from this vector. The code to do this is:
```R
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
```
### Step 5 of the project requirements (create a tidy dataset of the mean of the interactions between Subject, Activities and all the variables)
The script then uses the **"melt"** and **"dcast"** functions from the **"reshape2"** package to transform the **"TotalData"** dataset into a tidy data set with observations in rows and variables in columns, and the required means of the variables calculated where each variable, subject and activity intersects. To do this the **"TotalData"** dataset's columns are reordered so that the **"Subject"** and **"Activity"** becomes the first two columns (remember these two columns are now called **"IndividualSubjectNumber"** and **"TypeOfActivity"** after Step 4).  The dataset is then melted into one narrow dataset with **"IndividualSubjectNumber"** and **"TypeOfActivity"** as ID variables and the rest as value variables. The molten dataset is then recast (how cool does that sound!?) to provide the mean of the abovementioned intersections. The code to do all of this is:
```R
# First create a narrow molten dataframe
TotalData = TotalData[c(68,67,1:66)]
TotalDataMelt = melt(TotalData, id=c(1,2), measure.vars = c(3:68))

# Recast the molten dataframe to calculate the mean of the intersection of each subject, activity and all the variables
TotalDataCast = dcast(TotalDataMelt, IndividualSubjectNumber + TypeOfActivity ~ variable, value.var = "value", mean)
```
### Writing the text file output of the final tidy dataset to be loaded onto Coursera.org
The script then finally writes the text output file from the final tidy dataset that is loaded on the Coursera.org assignment page using the following code:
```R
write.table(TotalDataCast, "tidyData.txt", row.names=FALSE)
```
### And we are done!

# End of README.md file