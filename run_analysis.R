##Getting and Cleaning Data Project

##The purpose of this project is to demonstrate your ability to collect,
##work with, and clean a data set. The goal is to prepare tidy data that
##can be used for later analysis.

##You should create one R script called run_analysis.R that does the following.

## 1. Merges the training and the test sets to create one data set.


regr <- getwd()
zip_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip_name <- "getdata_dataset.zip"
ruta <- "C:/Users/HectorLP/Documents/Getting and Cleaning Data/Project/"
ruta_zip <- paste0(ruta,zip_name)
setwd(ruta_zip)
## Descarga zip:
if (!file.exists(ruta_zip)){dir.create(ruta_zip)}


download.file(zip_URL, destfile = zip_name, method = "curl")

file_work <- "UCI HAR Dataset"
if (!file.exists(file_work)) { 
  unzip(zip_name) 
}

# read training data
trainingSubjects <- read.table(file.path(file_work, "train", "subject_train.txt"))
trainingValues <- read.table(file.path(file_work, "train", "X_train.txt"))
trainingActivity <- read.table(file.path(file_work, "train", "y_train.txt"))

# read test data
testSubjects <- read.table(file.path(file_work, "test", "subject_test.txt"))
testValues <- read.table(file.path(file_work, "test", "X_test.txt"))
testActivity <- read.table(file.path(file_work, "test", "y_test.txt"))

# read features, don't convert text labels to factors
features <- read.table(file.path(file_work, "features.txt"), as.is = TRUE)

# read activity labels
activities <- read.table(file.path(file_work, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")

# concatenate individual data tables to make single data table
humanActivity <- rbind(
  cbind(trainingSubjects, trainingValues, trainingActivity),
  cbind(testSubjects, testValues, testActivity)
)

# assign column names
colnames(humanActivity) <- c("subject", features[, 2], "activity")

str(humanActivity)

##2. Extracts only the measurements on the mean and standard deviation for each measurement.

subData <- grepl("subject|activity|mean|std", colnames(humanActivity))
humanActivity <- humanActivity[, subData]


##3. Uses descriptive activity names to name the activities in the data set

head(humanActivity$activity)
humanActivity$activity <- factor(humanActivity$activity, levels = activities[, 1], labels = activities[, 2])


##4. Appropriately labels the data set with descriptive variable names.

humanActivityCols <- colnames(humanActivity)

humanActivityCols <- gsub("[\\(\\)-]", "", humanActivityCols)
humanActivityCols <- gsub("^f", "frequencyDomain", humanActivityCols)
humanActivityCols <- gsub("^t", "timeDomain", humanActivityCols)
humanActivityCols <- gsub("Acc", "Accelerometer", humanActivityCols)
humanActivityCols <- gsub("Gyro", "Gyroscope", humanActivityCols)
humanActivityCols <- gsub("Mag", "Magnitude", humanActivityCols)
humanActivityCols <- gsub("Freq", "Frequency", humanActivityCols)
humanActivityCols <- gsub("mean", "Mean", humanActivityCols)
humanActivityCols <- gsub("std", "StandardDeviation", humanActivityCols)
humanActivityCols <- gsub("BodyBody", "Body", humanActivityCols)

# use new labels as column names
colnames(humanActivity) <- humanActivityCols

##5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Final_humanActivity <-aggregate(. ~subject + activity, humanActivity, mean)
Final_humanActivity<-Final_humanActivity[order(Final_humanActivity$subject,Final_humanActivity$activity),]
write.table(Final_humanActivity, file = "tidydata.txt",row.name=FALSE)
  
#Produce CodeBook

install.packages("knitr")
library(knitr)
knit("CodeBook.Rmd")

