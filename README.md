# Getting-and-Cleaning-Data-Assignment
Contains Readme, scripts for Data Science Getting and Cleaning Data Week 4 assignment

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

You should create one R script called run_analysis.R that does the following.

Merges the training and the test sets to create one data set.
Extracts only the measurements on the mean and standard deviation for each measurement.
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names.
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Faraz Syed's README - 

the data was downloaded from: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

files which were used: 
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.
- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample.Range is from 1 to 30. 

Procedure Followed: 

1. Data was downloaded and unziped
2. R code was used to set working drive to that location
3. Using the data.table package used fread to import data into R
4. The Test and Training data were then combined on the subject and activity level
5. The Device data was brought in with all variables
6. The feature mapping was used to subselect the relevant mean and standard deviation variables
7. The mapping was merged with the default column headers "V1" to have descriptive variable names
8. This data was then melted to get into tidy format
9. descriptions were cleaned up using string manipulation to pull out the type of variable - Acceleration, axis and other descriptive features. 
10. Tidy data exported to .txt file ("TidyData.txt")
