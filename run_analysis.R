######################################################
# Course Project: Getting and Cleaning Data          #        
# Created: 20201119                                  #
# Last modified:20201222                             # 
######################################################

#rm(list = ls())

### Packages ##############################################

library(reshape2)

### Loading in the data ###################################

setwd("C:/Users/birdi/Desktop/Course_Project")

# Create directory

if(!file.exists ("data"))
{
        dir.create("data")
}

# Download the data, set file destination

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCI_dataset.zip")

# Check directory
list.files("./data")

# extract compressed file
unzip(zipfile = "./data/UCI_dataset.zip", exdir = "./data")

# List files in UCI HAR Dataset

files <- list.files("./data/UCI HAR Dataset", full.names = TRUE)

files

# Change working directory to UCI HAR Dataset

setwd("./data/UCI HAR Dataset")

# read train and test data 

x_train   <- read.table("./train/X_train.txt", header = FALSE) #Training set
x_test   <- read.table("./test/X_test.txt", header = FALSE) #Test set

y_train   <- read.table("./train/Y_train.txt", header = FALSE) #Training labels
y_test   <- read.table("./test/Y_test.txt", header = FALSE) #Test labels


sub_train <- read.table("./train/subject_train.txt", header = FALSE)
sub_test <- read.table("./test/subject_test.txt", header = FALSE)

# read features 

features <- read.table("./features.txt") 

# read activity labels 

activity_labels <- read.table("./activity_labels.txt" , header = FALSE) 

# add column name for label files

names(y_train) <- "activity"
names(y_test) <- "activity"

# add column names using features

names(x_train) <- features$V2
names(x_test) <- features$V2

# add column name for subject files

names(sub_train) <- "subjectID"
names(sub_test) <- "subjectID"


### Merge training and test sets ##########################

train <- cbind(sub_train, y_train, x_train)
test <- cbind(sub_test, y_test, x_test)
combined <- rbind(train, test)


### Extracts only the measurements on the mean and SD #####

# determine which columns contain "mean()" or "std()"

meanstdcols <- grepl("mean\\(\\)", names(combined)) |
        grepl("std\\(\\)", names(combined))

# keep the subjectID and activity columns

meanstdcols[1:2] <- TRUE

# remove unnecessary columns

combined <- combined[, meanstdcols]


### Descriptive Labels ####################################

# convert the activity column from integer to factor

combined$activity <- factor(combined$activity, labels=c("Walking",
                                                        "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))


### Tidy data set with averages ###########################

# create the tidy data set

melted <- melt(combined, id=c("subjectID","activity"))
tidy <- dcast(melted, subjectID+activity ~ variable, mean)

# write the tidy data set to a file

write.csv(tidy, "tidy.csv", row.names=FALSE)

