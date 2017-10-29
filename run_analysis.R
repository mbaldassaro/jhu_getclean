#0 - Automatically download of data + loading of dependencies 

if(!file.exists("data")) { dir.create("data") }
fileZip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileZip, destfile="./data/samsungdata.zip", method="curl")
unzip("./data/samsungdata.zip", exdir="./data")
path <- "./data/UCI HAR Dataset/"

list.of.packages <- c("tidyverse", "forcats")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if(length(new.packages)) install.packages(new.packages)
library(tidyverse); library(forcats)

#1. Merge training and test data to create one dataset 
features <- read_table(paste(path, "features.txt", sep=""), col_names = FALSE, skip=-1)
dfYtest <- read_table(paste(path, "test/y_test.txt", sep=""), col_names = FALSE); dfYtest <- rename(dfYtest, activity=X1) 
dfYtrain <- read_table(paste(path, "train/y_train.txt", sep=""), col_names = FALSE); dfYtrain <- rename(dfYtrain, activity=X1) 
dfXtest <- read_table(paste(path, "test/X_test.txt", sep=""), col_names = FALSE); names(dfXtest) <- t(features)
dfXtrain <- read_table(paste(path, "train/X_train.txt", sep=""), col_names = FALSE); names(dfXtrain) <- t(features)
dfSubtest <- read_table(paste(path, "test/subject_test.txt", sep=""), col_names = FALSE); dfSubtest <- rename(dfSubtest, subject="X1")
dfSubtrain <- read_table(paste(path, "train/subject_train.txt", sep=""), col_names = FALSE); dfSubtrain <- rename(dfSubtrain, subject="X1")  
dfTrain <- cbind(dfSubtrain, dfYtrain, dfXtrain)
dfTest <- cbind(dfSubtest, dfYtest, dfXtest)
df <- rbind(dfTrain, dfTest)

#2. Extract only the measurements on the mean and standard deviation for each measurement (<- select(grep))
dfSubject <- df %>% select(contains("subject")) 
dfActivity <- df %>% select(contains("activity"))
dfMean <- df %>% select(contains("mean()"))
dfSD <- df %>% select(contains("std()"))
dfMS <- cbind(dfSubject, dfActivity, dfMean, dfSD)

#3. Use descriptive activity names to name the activities in the dataset 
dfMS[,'activity'] <- factor(dfMS[,'activity'])
dfMS <- dfMS %>% mutate(activity = fct_recode(activity, 
      "walking" = "1", 
      "walking_upstairs" = "2", 
      "walking_downstairs" = "3", 
      "sitting" = "4", 
      "standing" = "5", 
      "laying" = "6"))

#4. Appropriately label the dataset with descriptive variable names 
names(dfMS) <- gsub("^[0-9]+","", names(dfMS))
names(dfMS) <- gsub("tBody", "timeBody", names(dfMS))
names(dfMS) <- gsub("tGravity", "timeGravity", names(dfMS))
names(dfMS) <- gsub("fBody", "freqBody", names(dfMS))
names(dfMS) <- gsub("fGravity", "freqGravity", names(dfMS))
names(dfMS) <- gsub("-mean\\(\\)", "Mean", names(dfMS))
names(dfMS) <- gsub("-std\\(\\)", "SD", names(dfMS))
names(dfMS) <- gsub("\\(\\)", "", names(dfMS))
names(dfMS) <- gsub("-", "", names(dfMS))

#5. Create a second tidy dataset with the average of each variable for each activity 
dfMS2 <- dfMS %>% group_by(activity, subject) %>% summarise_all(funs(mean))

#Automatically opens tidy dataset in R Studio 
View(dfMS2)
#Writes csv file to directory path location
write_csv(dfMS2, paste(path, "tidyAnalysis.csv"))
