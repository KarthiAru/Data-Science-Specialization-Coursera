run_analysis <- function(){
        
        #Load the library packages
        library(stats)
        library(utils)
        
        #Download the dataset
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        ## Download the file
        if (!file.exists("dataset.zip")){download.file(fileUrl,destfile="dataset.zip",method="curl")}
        ## Unzip the file
        if (!file.exists("UCI HAR Dataset")) {unzip("dataset.zip")}
        
        #Read the data from files
        subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt",header = FALSE)
        subjectTest  <- read.table("UCI HAR Dataset/test/subject_test.txt",header = FALSE)
        
        activityTrain <- read.table("UCI HAR Dataset/train/Y_train.txt",header = FALSE)
        activityTest  <- read.table("UCI HAR Dataset/test/Y_test.txt",header = FALSE)
        activityLabel <- read.table("UCI HAR Dataset/activity_labels.txt",header = FALSE)
        activityLabel[,2] <- as.character(activityLabel[,2])
        
        featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt",header = FALSE)
        featuresTest  <- read.table("UCI HAR Dataset/test/X_test.txt",header = FALSE)
        featureName <- read.table("UCI HAR Dataset/features.txt",header = FALSE)
        featureName[,2] <- as.character(featureName[,2])
        
        #Merges the training and the test sets to create one data set
        dataTrain <- cbind(subjectTrain,activityTrain,featuresTrain)
        dataTest <- cbind(subjectTest,activityTest,featuresTest)
        data <- rbind(dataTrain,dataTest)
        ##Set variable names
        colnames(data)[1] <- "subject"
        colnames(data)[2] <- "activity"
        colnames(data)[3:ncol(data)] <- featureName[,2]
        
        #Extracts only the measurements on the mean and standard deviation for each measurement
        featureSelect <- featureName[,2][grep("(mean|std)\\(\\)", featureName[,2])]
        data <- subset(data,select=c("subject", "activity", as.character(featureSelect)))
        
        #Uses descriptive activity names to name the activities in the data set
        data[,2] <- factor(data[,2], levels = activityLabel[,1], labels = activityLabel[,2])
        data[,1] <- as.factor(data[,1])
        
        #Appropriately labels the data set with descriptive variable names
        names(data)<-gsub("std()", "SD", names(data))
        names(data)<-gsub("mean()", "MEAN", names(data))
        names(data)<-gsub("^t", "time", names(data))
        names(data)<-gsub("^f", "frequency", names(data))
        names(data)<-gsub("Acc", "Accelerometer", names(data))
        names(data)<-gsub("Gyro", "Gyroscope", names(data))
        names(data)<-gsub("Mag", "Magnitude", names(data))
        names(data)<-gsub("BodyBody", "Body", names(data))
        
        #From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
        data2<-aggregate(. ~subject + activity, data, mean)
        data2<-data2[order(data2$subject,data2$activity),]
        write.table(data2, file = "tidy.txt",row.names=FALSE)
        write.csv(data2, file = "tidy.csv",row.names=FALSE)
}