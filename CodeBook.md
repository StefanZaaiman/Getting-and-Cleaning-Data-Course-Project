# Accompanying CodeBook.md file for the Getting and Cleaning Data Course Project
## Overview and introduction
This file describes the variables, the data, and any transformations or work that I performed to clean up the data in order to get from the raw datasets provided to the final **"tidyData.txt"** file using the **"run_analysis.R"** script (you can find the **"tidyData.txt"** file [here](https://s3.amazonaws.com/coursera-uploads/user-2e6316f0fe61625b298b2296/975115/asst-3/22e65e90482911e5bd23a10ce0e4b813.txt)). A full walkthrough of the **"run_analysis.R"** scrip is provided in the accompanying **"README.md"** file. To avoid unnecessary duplication the **"CodeBook.md"** and **"README.md"** files are set up to be read in conjunction with each other.

## Original raw data
The original raw data consist of data collected from 30 people wearing waist-mounted smartphones. The data came from the embedded inertial sensors of the smartphones and was specifically captured around 6 activities. For more information please visit the UCI Machine Learning Repository page [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

## Reading in of original raw data and resulting data frame names
The following raw datasets were read into R dataframes (the first name in each line is the raw data set name and the second name in each line is the R data frame name):
* X_train.txt -> rawTrainData
* y-train.txt -> rawTrainActivityCodes
* subject_train.txt -> rawTrainSubjectCodes
* X_test.txt -> rawTestData
* y-test.txt -> rawTestActivityCodes
* subject_test.txt -> rawTestSubjectCodes
* activity_labels.txt -> rawActivityMappings
* features.txt -> rawVariableNames

The activity codes and subject codes for the training and testing datasets were appended to the **"rawTrainData"** and **"rawTestData"** which created the following two data frames:
* TrainData
* TestData

Step 1 of the project requirements (one dataset) was then conducted to create this one dataset in a data frame called:
* TotalData

The data set called **"rawVariableNames"** was appended with **"Activities"** and **"Subject"** to reflect the previously added 2 columns.

The **"TotalData"** data frame's column names are then replaced with the names from **"rawVariableNames"**.

## Reducing the column set of TotalData to only include the means and standard deviations
The following vectors are created to house the index placeholders of the columns that meet the requirements to be kept. The conditions required to be included were to have either **"mean()"**, **"std()"**, **"Mean()"** or **"Std()"** as part of the variable name text:
* ColumnsToKeepMean (checking for **"mean()"**)
* ColumnsToKeepStd (checking for **"std()"**)
* ColumnsToKeepMeanCap (checking for **"Mean()"**)
* ColumnsToKeepStdCap (checking for **"Std()"**)

Note in order for R to search correctly for something like **"mean()"** the search text in R must be entered as follows:
```R
"mean\\(\\)"
```
The 4 vectors above are then combined into one vector called (the activity and subject columns are also added to this vector):
* FinalColumnsToKeep

The **"TotalData"** data frame is then subsetted to only keep the columns in the **"FinalColumnsToKeep"** vector.

## Replacing the activity numbers with their string descriptions
The **"Activities"** variable in the **"TotalData"** data frame is then replaced using the **"mapvalues"** function from the **"plyr"** package and the activity descriptions as provided in the **"activity_labels.txt"** file that was read into the dataframe called **"rawActivityMappings"**. The first variable column in **"rawActivityMappings"** is used as the "from" mapping in and the second variable column in **"rawActivityMappings"** is used as the "to" mapping.

## Making the variable names in TotalData nicer
The following transformations are made to the given column names in order to make them clearer and more descriptive. The first part in each line is the given text and the second part in each line is the text the given text is replaced with. Note that it is assumed the given **"BodyBody"** text was a typo and was corrected to just **"Body"**. The transformations are as follows:
* "Acc" -> "Accelerometer"
* "Gyro" -> "Gyroscope"
* "-X" -> "_X-axis"
* "-Y" -> "_Y-axis"
* "-Z" -> "_Z-axis"
* "std" -> "standardDeviation"
* "BodyBody" -> "Body"
* "tBody" -> "timeDomain_Body"
* "tGravity" -> "timeDomain_Gravity"
* "fBody" -> "frequencyDomain_Body"
* "Mag" -> "_Magnitude"
* "Activities" -> "TypeOfActivity"
* "Subject" -> "IndividualSubjectNumber"
* "Body" -> "Body_"
* "Gravity" -> "Gravity_"
* "-mean" -> "_mean"
* "-standard" -> "_standard"
* "()" -> ""
* "Jerk" -> "_Jerk"

An example of old and new variable names are given in the table below:

| Old variable name           | New variable name                                 |
|-----------------------------|---------------------------------------------------|
| tBodyAcc-mean()-X           | timeDomain_Body_Accelerometer_mean_X-axis         |
| tBodyGyroJerk-mean()-X      | timeDomain_Body_Gyroscope_Jerk_mean_X-axis        |
| tBodyAccJerkMag-mean()      | timeDomain_Body_Accelerometer_Jerk_Magnitude_mean |
| fBodyBodyGyroJerkMag-mean() | frequencyDomain_Body_Gyroscope_Jerk_Magnitude_mean|  
| etc... | etc...| 

## Creating the final tidy dataset

The **"melt"** and **"dcast"** functions from the **"reshape2"** package is used to transform the **"TotalData"** dataset into a tidy data set where all observations are in rows and all variables in columns, with the required means of the variables calculated where each variable, subject and activity intersects. The molten data frame is called **"TotalDataMelt"** and the casted tidy dataset is called **"TotalDataCast"**.

The **"melt"** function is applied to the **"TotalData"** dataset, with the **"IndividualSubjectNumber"** and **"TypeOfActivity"** used as ID variables, and all 66 variables used as the measure variables.

This results of the molten dataframe called **"TotalDataMelt"** looks like this (showing the first 10 rows - the full data frame has 679734 rows and 4 columns):
```R
> head(TotalDataMelt,10)
   IndividualSubjectNumber TypeOfActivity                                  variable     value
1                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2885845
2                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2784188
3                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2796531
4                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2791739
5                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2766288
6                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2771988
7                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2794539
8                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2774325
9                        1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2772934
10                       1       standing timeDomain_Body_Accelerometer_mean_X-axis 0.2805857
```

The molten data frame is then recast into the tidy data called **"TotalDataCast"** with the required means being calculated by using the **"dcast"** function. The **"dcast"** function is applied to the **"TotalDataMelt"** data frame, and the casting formula used casts **"IndividualSubjectNumber"** and **"TypeOfActivity"** onto **"variable"**, with the values being the variable **"value"**, and the **"mean"** function used in the casting as per the project requirements.

This results of the casted dataframe called **"TotalDataCast"** looks like this (showing the first 10 rows and first 3 columns - the full data frame has 180 rows and 68 columns):
```R
> > head(TotalDataCast[,1:3],10)
   IndividualSubjectNumber     TypeOfActivity timeDomain_Body_Accelerometer_mean_X-axis
1                        1             laying                                 0.2215982
2                        1            sitting                                 0.2612376
3                        1           standing                                 0.2789176
4                        1            walking                                 0.2773308
5                        1 walking_downstairs                                 0.2891883
6                        1   walking_upstairs                                 0.2554617
7                        2             laying                                 0.2813734
8                        2            sitting                                 0.2770874
9                        2           standing                                 0.2779115
10                       2            walking                                 0.2764266
```

## Output the tidy data to a text file
The **"write.table()"** command is then used on **"TotalDataCast"** with the option **"row.names=FALSE"** to create the final **"tidyData.txt"** file.

### And we are done!

# End of CodeBook.md file