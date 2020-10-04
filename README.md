### Getting-and-Cleaning-Data-Course-Project
Here is my final project for this course

This repo made for Coursera's 'Getting and Cleaning Data Course Project' based
on 'Human Activity Recognition Using Smartphones Data Set' (see details on 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphone ). AggregatedDV contains average of mean and standard deviation measures broken by subjects and activites (later whithin subjects).

**Task was:**
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

**Explanation of .R script:**

I used the following libraries: tidyverse, stringr, sjlabelled

** 0. Get and unzip data**
Setting the work directory to the source of .R, then downloading the .zip of data.

** 1. Merges the training and the test sets to create one data set **
Getting the two samples (test and train), apply variable labels and add sample type variable. CSV was read as fixed width file - I'm sure there is a most efficient (and faster) way to do it.

** 2. Extracts only the measurements on the mean and standard deviation for each measurement.**

** 3. Uses descriptive activity names to name the activities in the data set**
I've used the activity_labels.txt as source of labels.

** 4. Appropriately labels the data set with descriptive variable names.**

** 5. From the data set in step 4, creates a second, independent tidy data set 
with the average of each variable for each activity and each subject.**
Get the Subject and Sample type variables (for later analysis) then aggregate the dataset with Subject and Activity break variables. It results 30 rows (for each subjects) and six activity columns per measure. Stored in AggregatedDB.
