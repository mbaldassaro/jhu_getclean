### JHU Get Clean: Peer-graded Assignment: Getting and Cleaning Data Course Project

#### About 
This repository contains four files: 

* **README.md** which explains the contents of the run_analysis.R script 
* **run_analysis.R** which is the R script that converts raw data into tidyAnalysis.txt dataset
* **tidyAnalysis.txt** which is the result of running run_analysis.R script 
* **codeook.rmd** which is the CodeBook that corresponds to tidyAnalysis.txt file 

#### Step 0: Automatically download data and load dependencies
The first codeblock in **run_analysis.R** does the following:
* Creates a data sub directory in your working directory (if a data subdirectory does not already exist)
* Downloads the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 
* Installs (if not already installed) and loads the required packages needed to perform the analysis. Note: this script makes use of two R packages: the [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html) and [forcats](https://cran.r-project.org/web/packages/forcats/index.html) packages created by Hadley Wickham.

``` R
if(!file.exists("data")) { dir.create("data") }
fileZip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileZip, destfile="./data/samsungdata.zip", method="curl")
unzip("./data/samsungdata.zip", exdir="./data")
path <- "./data/UCI HAR Dataset/"

list.of.packages <- c("tidyverse", "forcats")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if(length(new.packages)) install.packages(new.packages)
library(tidyverse); library(forcats)
```

#### Step 1: Merge training and test data to create one dataset
The codeblock below does the following:
* Reads seven data files - features.txt, y_test.txt, y_train.txt, X_test.txt, X_train.txt, subject_test.txt, and subject_train.txt - from the original dataset into your R environment using the read.table() function
* Renames the column headers using descriptive subject, activity and training and test data labels
* Merges the training and test data together to create a full dataset

```R
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
```

#### Step 2: Extract only the measurements on the mean and standard deviation for each measurement
The codeblock below does the following:
* Uses the tidyverse::dplyr library to subset subject, activity, mean() and std() data from the merged dataset
* Merges the subsetted data to create a new dataset that joins these variables

```R
dfSubject <- df %>% select(contains("subject")) 
dfActivity <- df %>% select(contains("activity"))
dfMean <- df %>% select(contains("mean()”))
dfSD <- df %>% select(contains("std()”))
dfMS <- cbind(dfSubject, dfActivity, dfMean, dfSD)
```

#### Step 3: Use descriptive activity names to name the activities in the dataset
The codeblock below does the following:
* Converts the values in the activity variable to a factor 
* Uses the forcats library to recode the converted factors using descriptive activity names

```R
dfMS[,'activity'] <- factor(dfMS[,'activity'])
dfMS <- dfMS %>% mutate(activity = fct_recode(activity, 
      "walking" = "1", 
      "walking_upstairs" = "2", 
      "walking_downstairs" = "3", 
      "sitting" = "4", 
      "standing" = "5", 
      "laying" = "6"))
```

#### Step 4: Appropriately label the dataset with descriptive variable names 
The codeblock below does the following:
* Uses the gsub() function to remove metacharacters and rename variables using descriptive names

```R
names(dfMS) <- gsub("^[0-9]+","", names(dfMS))
names(dfMS) <- gsub("tBody", "timeBody", names(dfMS))
names(dfMS) <- gsub("tGravity", "timeGravity", names(dfMS))
names(dfMS) <- gsub("fBody", "freqBody", names(dfMS))
names(dfMS) <- gsub("fGravity", "freqGravity", names(dfMS))
names(dfMS) <- gsub("-mean\\(\\)", "Mean", names(dfMS))
names(dfMS) <- gsub("-std\\(\\)", "SD", names(dfMS))
names(dfMS) <- gsub("\\(\\)", "", names(dfMS))
names(dfMS) <- gsub("-", "", names(dfMS))
```

#### Step 5: Create a second tidy dataset with the average of each variable for each activity 
The codeblock below does the following:
* Uses the tidyverse::dplyr library to group by activity and subject variables and apply the mean function to all other variables in the dataaset
* Writes the resulting dataframe as **tidyAnalysis.txt** to the data subdirectory 

```R
dfMS2 <- dfMS %>% group_by(activity, subject) %>% summarise_all(funs(mean))
write.table(dfMS2, paste(path, "tidyAnalysis.txt"), row.names=F)
```

