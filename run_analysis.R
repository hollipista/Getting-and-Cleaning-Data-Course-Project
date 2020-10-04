library("tidyverse")
library(stringr)
library(sjlabelled) #for variable labeling

# 0. Get and unzip data
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

ifelse(!dir.exists(file.path(getwd(), "zip")), 
       dir.create(file.path(getwd(), "zip")), FALSE)

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "zip/getdata_projectfiles_UCI HAR Dataset.zip","curl")
unzip("zip/getdata_projectfiles_UCI HAR Dataset.zip", 
      files = NULL, list = FALSE, overwrite = TRUE,
      junkpaths = FALSE, exdir = ".", unzip = "internal",
      setTimes = FALSE)


# 1. Merges the training and the test sets to create one data set
Label<-read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep=" ")
ColCount<-length(as.list(Label$V2))
TempWidth<-rep(16, ColCount)

X_test<-read.fwf("UCI HAR Dataset/test/X_test.txt", widths=TempWidth,
                 col.names=as.list(Label$V2))
sub_test<-read.csv("UCI HAR Dataset/test/subject_test.txt",
                   header = FALSE)$V1
y_test<-read.csv("UCI HAR Dataset/test/y_test.txt",
                 header = FALSE)$V1
test <- cbind(X_test,sub_test)
test <- cbind(test,y_test)
test <- cbind(test,rep("test",length(sub_test)))
colnames(test)[562:564]<-c("Subject","Activity","SampleType")
rm(X_test,sub_test,y_test)

X_train<-read.fwf("UCI HAR Dataset/train/X_train.txt", 
                  widths=TempWidth,col.names=as.list(Label$V2))
sub_train<-read.csv("UCI HAR Dataset/train/subject_train.txt",
                    header = FALSE)$V1
y_train<-read.csv("UCI HAR Dataset/train/y_train.txt",
                  header = FALSE)$V1
train <- cbind(X_train,sub_train)
train <- cbind(train,y_train)
train <- cbind(train,rep("train",length(sub_train)))
colnames(train)[562:564]<-c("Subject","Activity","SampleType")
rm(X_train,sub_train,y_train,TempWidth)

ActivityDB<-rbind(test,train)
rm(Label,test,train,ColCount)


# 2. Extracts only the measurements on the mean and standard deviation for each 
# measurement.

ActivityDB<-select(ActivityDB,matches("(\\.mean\\.)|(\\.std\\.)|(Subject)|(Activity)|(SampleType)"))


# 3. Uses descriptive activity names to name the activities in the data set

ActLabel<-read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep=" ")
ActivityDB$Activity <- factor(ActivityDB$Activity,levels = ActLabel$V1,
                              labels = ActLabel$V2)
rm(ActLabel)


# 4. Appropriately labels the data set with descriptive variable names.

VarLabs<-c("Body acceleration X - MEAN","Body acceleration Y - MEAN",
           "Body acceleration Z - MEAN","Body acceleration X - STD",
           "Body acceleration Y - STD","Body acceleration Z - STD",
           "Gravity acceleration X - MEAN","Gravity acceleration Y - MEAN",
           "Gravity acceleration Z - MEAN","Gravity acceleration X - STD",
           "Gravity acceleration Y - STD","Gravity acceleration Z - STD",
           "Body Jerk acceleration X - MEAN","Body Jerk acceleration Y - MEAN",
           "Body Jerk acceleration Z - MEAN","Body Jerk acceleration X - STD",
           "Body Jerk acceleration Y - STD","Body Jerk acceleration Z - STD",
           "Body gyroscope X - MEAN","Body gyroscope Y - MEAN",
           "Body gyroscope Z - MEAN","Body gyroscope X - STD",
           "Body gyroscope Y - STD","Body gyroscope Z - STD",
           "Body Jerk gyroscope X - MEAN","Body Jerk gyroscope Y - MEAN",
           "Body Jerk gyroscope Z - MEAN","Body Jerk gyroscope X - STD",
           "Body Jerk gyroscope Y - STD","Body Jerk gyroscope Z - STD",
           "Body acceleration magnitude - MEAN","Body acceleration magnitude - STD",
           "Gravity acceleration magnitude - MEAN","Gravity acceleration magnitude - STD",
           "Body Jerk acceleration magnitude - MEAN","Body Jerk acceleration magnitude - STD",
           "Body gyroscope magnitude - MEAN","Body gyroscope magnitude - STD",
           "Body Jerk gyroscope magnitude - MEAN","Body Jerk gyroscope magnitude - STD",
           "FFT Body acceleration X - MEAN","FFT Body acceleration Y - MEAN",
           "FFT Body acceleration Z - MEAN","FFT Body acceleration X - STD",
           "FFT Body acceleration Y - STD","FFT Body acceleration Z - STD",
           "FFT Body Jerk acceleration X - MEAN","FFT Body Jerk acceleration Y - MEAN",
           "FFT Body Jerk acceleration Z - MEAN","FFT Body Jerk acceleration X - STD",
           "FFT Body Jerk acceleration Y - STD","FFT Body Jerk acceleration Z - STD",
           "FFT Body gyroscope X - MEAN","FFT Body gyroscope Y - MEAN",
           "FFT Body gyroscope Z - MEAN","FFT Body gyroscope X - STD",
           "FFT Body gyroscope Y - STD","FFT Body gyroscope Z - STD",
           "FFT Body acceleration magnitude - MEAN","FFT Body acceleration magnitude - STD",
           "FFT Body Jerk acceleration magnitude - MEAN","FFT Body Jerk acceleration magnitude - STD",
           "FFT Body gyroscope magnitude - MEAN","FFT Body gyroscope magnitude - STD",
           "FFT Body Jerk gyroscope magnitude - MEAN","FFT Body Jerk gyroscope magnitude - STD",
           "Subject","Activity","SampleType")
ActivityDB<-set_label(ActivityDB, label = VarLabs)


# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

AggregatedDB<-data.frame(Subject=seq(1:30))
AggregatedDB<-left_join(AggregatedDB, 
                        ActivityDB[c('Subject','SampleType')],by='Subject')
AggregatedDB<-filter(AggregatedDB,!duplicated(AggregatedDB$Subject))

z=length(names(ActivityDB))-3

for (i in names(ActivityDB[1:z])){
  temp <- ActivityDB %>%
    select(Subject,Activity,c(i)) %>% 
    group_by(Subject, Activity) %>% 
    summarise_each(funs(mean(., na.rm = TRUE))) %>%
    spread(Activity,i) %>%
    ungroup()
  
  temp<-select(temp,-Subject)
  colnames(temp)<-paste(i, colnames(temp), sep = "_")
  
  AggregatedDB<-cbind(AggregatedDB,temp)
  rm(temp)
}


# Write out.

write.table(AggregatedDB, file="AggregatedDB.txt",row.names=FALSE)
