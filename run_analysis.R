#Date: 04 Jun 2016
#Name: Fu Chit Yaw
#Title: Week 4 Assignment

setwd('c:/MYDS')
if (!file.exists("data")) {
        dir.create("data")
}

#Example of loading multiple packages
packages<-c("plyr","dplyr","lubridate")
sapply(packages,require,character.only=TRUE,quietly=TRUE)



#STEP 1: Download & unzip the file
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest1="./data/dataset.zip"
download.file(Url, destfile = dest1)
dateDownloaded <- now()
unzip(zipfile=dest1,exdir="./data")

#STEP 2. Get the list of file
fp1<-file.path("./data","UCI HAR DATASET")
files<-list.files(fp1,recursive=TRUE) # to list out all files inside folder


#STEP 3. Read the files

#3a.Read the class labels of test & train data
fp2<-file.path(fp1,"test","y_test.txt")
fp3<-file.path(fp1,"train","y_train.txt")
yTest<-read.table(fp2,header=FALSE)
yTrain<-read.table(fp3,header=FALSE)


#3b.Read the subjects of test & train data
fp4<-file.path(fp1,"test","subject_test.txt")
fp5<-file.path(fp1,"train","subject_train.txt")
subTest<-read.table(fp4,header=FALSE)
subTrain<-read.table(fp5,header=FALSE)

#3c.Read the feature vectors of test & train data
fp6<-file.path(fp1,"test","X_test.txt")
fp7<-file.path(fp1,"train","X_train.txt")
xTest<-read.table(fp6,header=FALSE)
xTrain<-read.table(fp7,header=FALSE)


#STEP 4: Merges the train & test sets

#4a. Concatenate the data tables by row
ydat<-rbind(yTrain,yTest)
xdat<-rbind(xTrain,xTest)
subdat<-rbind(subTrain,subTest)

#4b. Set names to variables above
names(ydat)<-"activity" #try to use small letter
names(subdat)<-"subject"
fp8<-file.path(fp1,"features.txt")
xinfo<-read.table(fp8,header=FALSE) #read feature description
names(xdat)<-xinfo$V2
View(xdat)

#4c. Merge all info
dat<-cbind(xdat,subdat,ydat)

#STEP 5: Extract features on mean and std measurement only
search1="mean\\(\\)|std\\(\\)" #regular expression
idx<-grep(search1,names(dat)) #selected column
col_sel<-names(dat)[idx]
col_sel<-c(col_sel,"subject","activity")
dat_sel<-subset(dat,select=col_sel)


#STEP 6: Rename the activities & features in the data set
fp9=file.path(fp1,"activity_labels.txt")
temp<-read.table(fp9,header=FALSE)
act_label<-temp$V2
dat_sel<-mutate(dat_sel,activity=factor(activity,labels=act_label))

names(dat_sel)<-gsub("^t", "time", names(dat_sel))
names(dat_sel)<-gsub("^f", "frequency", names(dat_sel))
names(dat_sel)<-gsub("Acc", "Accelerometer", names(dat_sel))
names(dat_sel)<-gsub("Gyro", "Gyroscope", names(dat_sel))
names(dat_sel)<-gsub("Mag", "Magnitude", names(dat_sel))
names(dat_sel)<-gsub("BodyBody", "Body", names(dat_sel))

#STEP7: Create and save tidy data set with the average of each variable for each activity and subject
dat_sel2<-aggregate(. ~subject + activity, dat_sel, mean) 
dat_sel3<-arrange(dat_sel2,subject,activity)
#dat_sel2<-dat_sel2[order(dat_sel2$subject,dat_sel2$activity),] #alternative method
View(dat_sel3)

write.table(dat_sel3, file = "tidydata.txt",row.names = FALSE)
