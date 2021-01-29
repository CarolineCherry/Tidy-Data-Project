if(!file.exists("./data")){dir.create("./data")}
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL,destfile = "./data/samsung.zip",method="curl")
data <- unzip("./data/samsung.zip")
data
summary(read.table(tail(data[2])))
read.table(data[14])
tail(read.table(data[15]))
dim(read.table(data[2]))

library(data.table)
library(dplyr)

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

## merge the data sets into one combined data set using an rbind
##1. combine each set

subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)

##2. label the columns

colnames(features) <- t(featureNames[2])

## Merge the data using a cbind

colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
completeData <- cbind(features,activity,subject)
completeData

## PART 2: extract on "mean' and "SD" data

colMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)

## add subject and activity to "mean" & "SD" data

reqCols <- c(colMeanSTD, 562, 563)

## create a data table with only the required data

reqData <- completeData[,reqCols]
dim(reqData)

## Part 4: Name the activities appropriately

reqData$Activity <- as.character(reqData$Activity)
for (i in 1:6){
  reqData$Activity[reqData$Activity == i] <- as.character(activityLabels[i,2])
}

## turn activity label back to a factor

reqData$Activity <- as.factor(reqData$Activity)

##Part5: Give the columns descriptive names

names(reqData)

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
reqData

#Step 5: 
#average of each variable for each activity and each subject.
as.factor(reqData$Subject)
as.factor(reqData$Activity)
tidyDat <- reqData %>% select(Subject,Activity,everything())
tidyDat
FinalTidy <- aggregate(. ~ Activity+Subject, tidyDat, mean)
FinalTidy[1:5,1:3]
write.table(FinalTidy,file="Tidy.csv",row.names = FALSE)
