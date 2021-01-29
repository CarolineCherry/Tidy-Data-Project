#Tidy-Data-Project
Getting & Cleaning Data Final Course Project

The following files form a part of this project:

R Script file tidying the data and creating the final tidy data set
The final tidy data set as a .csv file "Tidy.csv"
"Codebook.md" explaining the process followed and the code used to tidy the data
This README.md file detailing the entire project
The variables, the data, and any transformations or work that were performed to clean up the data contained in the following archive:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

A description on the purpose of this data and the collection methodology can be read at:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

In order to tidy this dataset the following was performed:

The data was available in numerous text files.

A merge of all the training and the test sets to create one data set was performed as follows:

Step 1: Merge the data set:
1. Download the data files using the following:
##if(!file.exists("./data")){dir.create("./data")}
##URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##download.file(URL,destfile = "./data/samsung.zip",method="curl")
data <- unzip("./data/samsung.zip")
data
2. Read the description of the data and the collection methodology to determine how to best merge this data.
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Summary: 30 people (2 groups: 70% training data. 30% test data) activities:

Walking
Walking_upstairs
Walking_downstairs
Sitting
Standing
Laying
captured for each activity:

3-axial linear acceleration
3-axial angular velocity
In each file the following exists:

Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
Triaxial Angular velocity from the gyroscope.
A 561-feature vector with time and frequency domain variables.
Its activity label.
An identifier of the subject who carried out the experiment
Using the read.lines(data[5]) (the readme.txt file) read the information on the study which gave a description of what was included in each of the files:

features_info.txt: Shows information about the variables used on the feature vector.

features.txt: List of all features.

activity_labels.txt: Links the class labels with their activity name.

train/X_train.txt: Training set.

test/X_test.txt: Test set.

test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent.

train/subject_train.txt: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.

train/Inertial Signals/total_acc_x_train.txt: The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis.

train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration.

train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.

3. Go through each file using read.table(data[1]) etc
Understand the data available and determine how to best merge it together into a tidydata set.

4. After evaluating the data in each table the following was identified.
Two sets of subjects exist. The "train" set and the "test" set. For each of these subjects 561 tests (features) were captured. Some text files record these individually but the combined file will be used to merge the data. The activities relating to each feature captured such as walking etc are also included in txt file which will be merged into the data set. The following txt files were therefore selected which contain all the relevant data to be merged:

[1] "./UCI HAR Dataset/activity_labels.txt" (activity such as walking etc)
[2] "./UCI HAR Dataset/features.txt" (the 561 features for which data was collected)

For test data subjects:

[14] "./UCI HAR Dataset/test/subject_test.txt" (the subjects tested)
[15] "./UCI HAR Dataset/test/X_test.txt" (the feature data for each subject) [16] "./UCI HAR Dataset/test/y_test.txt" (the activity relating to each feature)

For train data subjects:

[26] "./UCI HAR Dataset/train/subject_train.txt"
[27] "./UCI HAR Dataset/train/X_train.txt"
[28] "./UCI HAR Dataset/train/y_train.txt"

The following libraries were used in order to facilitate the reading of large tables and the easy merging of data library(data.table) and library(dplyr)

The required individual text files were then read in as data tables as follows:


## Read in activity and features data

featureNames <- read.table(data[2])
activityLabels <- read.table(data[1], header = FALSE)

## Read in the training data
subjectTrain <- read.table(data[26], header = FALSE)
activityTrain <- read.table(data[28], header = FALSE)
featuresTrain <- read.table(data[27], header = FALSE)

## Read in the test data
subjectTest <- read.table(data[14], header = FALSE)
activityTest <- read.table(data[16], header = FALSE)
featuresTest <- read.table(data[15], header = FALSE)
The "train" and "test" data sets for each subgroup being "subject", "activity" and "features" were merged by binding the rows using an rbind as follows:


subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)
Names were then allocated to the columns

colnames(features) <- t(featureNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
Now the data set can be fully merged by merging the columns using a cbind:

completeData <- cbind(features,activity,subject)
completeData
Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
Firstly a grep function was used to extract all columns that included the phrase "Mean" or "STD" in it.

The "activity" and "subject" columns were then added to the set to complete the extract of the required data.

colMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)

## add subject and activity to "mean" & "SD" data

reqCols <- c(colMeanSTD, 562, 563)

## create a data table with only the required data

reqData <- completeData[,reqCols]
dim(reqData)
Step 3: Uses descriptive activity names to name the activities in the data set
Use a for function to replace each number included in the data being 1-6 with the corresponding activity being "walking" etc as included in the activityLabels data set read in in above.

reqData$Activity <- as.character(reqData$Activity)
for (i in 1:6){
  reqData$Activity[reqData$Activity == i] <- as.character(activityLabels[i,2])
}

## turn activity label back to a factor

reqData$Activity <- as.factor(reqData$Activity)
Step 4: Appropriately labels the data set with descriptive variable names.
First determine what the column names are currently:

names(reqData)

To make the column names more user friendly replace the following using a gsub:

Acc can be replaced with Accelerometer

Gyro can be replaced with Gyroscope

BodyBody can be replaced with Body

Mag can be replaced with Magnitude

Character f can be replaced with Frequency

Character t can be replaced with Time

names(reqData)<-gsub("Acc", "Accelerometer", names(reqData))
names(reqData)<-gsub("Gyro", "Gyroscope", names(reqData))
names(reqData)<-gsub("BodyBody", "Body", names(reqData))
names(reqData)<-gsub("Mag", "Magnitude", names(reqData))
names(reqData)<-gsub("^t", "Time", names(reqData))
names(reqData)<-gsub("^f", "Frequency", names(reqData))
names(reqData)<-gsub("tBody", "TimeBody", names(reqData))
names(reqData)<-gsub("-mean()", "Mean", names(reqData), ignore.case = TRUE)
names(reqData)<-gsub("-std()", "STD", names(reqData), ignore.case = TRUE)
names(reqData)<-gsub("-freq()", "Frequency", names(reqData), ignore.case = TRUE)
names(reqData)<-gsub("angle", "Angle", names(reqData))
names(reqData)<-gsub("gravity", "Gravity", names(reqData))

names(reqData)
Step 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
Used the aggregate function to combine return the average for each variable for each subject and each activity and used the select function in the dplyr package to reoder the columns.

as.factor(reqData$Subject)
as.factor(reqData$Activity)
tidyDat <- reqData %>% select(Subject,Activity,everything())
tidyDat
FinalTidy <- aggregate(. ~ Activity+Subject, tidyDat, mean)
FinalTidy[1:5,1:3]
