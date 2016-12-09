# Code Book
This code book describes the data used in this project and the processing required to create the resulting tidy data set.

## About the Data Source

"Human Activity Recognition Using Smartphones Data Set"

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

30 volunteers (19-48 years) wore a smartphone on the waist and performed six activities (`WALKING`, `WALKING_UPSTAIRS`, `WALKING_DOWNSTAIRS`, `SITTING`, `STANDING`, `LAYING`). The embedded accelerometer and gyroscope of the smartphone captured the 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz.

The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

## About the Dataset 

The run_analysis.R script downloads the necessary data files to the working directory, if it doesn't exist.

The variable-data structure uses the below files from the `UCI HAR Dataset` dataset:

`subject`:

* data from `subject_train.txt` (A vector of 7352 integers, denoting the ID of the volunteer related to each of the observations in `X_train.txt`)

* data from `subject_test.txt` (A vector of 2947 integers, denoting the ID of the volunteer related to each of the observations in `X_test.txt`)

`activity`:

* data from `Y_train.txt` (A vector of 7352 integers, denoting the ID of the activity related to each of the observations in `X_train.txt`)

* data from `Y_test.txt` (A vector of 2947 integers, denoting the ID of the activity related to each of the observations in `X_test.txt`)

* levels from `activity_labels.txt` (Names and IDs for each of the 6 activities)

`features`:

* data from `X_train.txt` (7352 observations of the 561 features, for 21 of the 30 volunteers)

* data from `X_test.txt` (2947 observations of the 561 features, for 9 of the 30 volunteers)

* names from `features.txt` (Names of the 561 features)

More information about the files is available in `README.txt`. More information about the features is available in `features_info.txt`

This analysis was performed using only the above files and did not use the raw signal data. Therefore, the data files in the "Inertial Signals" folders were ignored.

## About the Variables

`subject` - The ID of the test subject

`activity` - The type of activity performed when the corresponding measurements were taken

* `WALKING` (value `1`): subject was walking during the test

* `WALKING_UPSTAIRS` (value `2`): subject was walking up a staircase during the test

* `WALKING_DOWNSTAIRS` (value `3`): subject was walking down a staircase during the test

* `SITTING` (value `4`): subject was sitting during the test

* `STANDING` (value `5`): subject was standing during the test

* `LAYING` (value `6`): subject was laying down during the test

`features` - The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix `t` to denote time) were captured at a constant rate of 50 Hz. and the acceleration signal was then separated into body and gravity acceleration signals (`tBodyAcc-XYZ` and `tGravityAcc-XYZ`), both using a low pass Butterworth filter.

The body linear acceleration and angular velocity were derived in time to obtain Jerk signals (`tBodyAccJerk-XYZ` and `tBodyGyroJerk-XYZ`). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (`tBodyAccMag`, `tGravityAccMag`, `tBodyAccJerkMag`, `tBodyGyroMag`, `tBodyGyroJerkMag`).

A Fast Fourier Transform (FFT) was applied to some of these signals producing `fBodyAcc-XYZ`, `fBodyAccJerk-XYZ`, `fBodyGyro-XYZ`, `fBodyAccJerkMag`, `fBodyGyroMag`, `fBodyGyroJerkMag`. (`f` indicates frequency domain signals).

Note: features are normalized and bounded within [-1,1] 

###Description of abbreviations of feature measurements

* leading `t` or `f` is based on `time` or `frequency` measurements

* `Body` = related to body movement

* `Gravity` = acceleration of gravity

* `Acc` = accelerometer measurement

* `Gyro` = gyroscopic measurements

* `Jerk` = sudden movement acceleration

* `Mag` = magnitude of movement

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions. They total 33 measurements including the 3 dimensions - the X,Y, and Z axes.

Mean and SD values for each subject for each activity among all measurements were retained. Other estimates have been removed for the purpose of this project.

## Transformation
The R script, `run_analysis.R`, does the following:

1. Downloads the dataset if it does not already exist in the working directory.

2. Loads the data from all the files mentioned above into respective data frames.

3. Merges the `training` and the `test` sets to create one data set and renames the column names as required from arbitrary values.

3. Overwrites the dataset keeping only those columns which are a mean or a standard deviation by matching the regex `mean()` or `std()`. (Note: This ignores the features with the words `meanFreq()`).

4. Converts `subject` and `activty` columns to factor type to use descriptive names in the data set.

5. Labels the data set with descriptive variable names such as replacing `t` with `time`, `f` with `frequency`, etc. Refer Codebook for more details.

6. Computes the average (mean) value of each variable for each subject and activity pair and sorts it based on `subject` and `activity`. This reduces 10299 instances into 180 groups with 68 variables - 1 subject + 1 activity + 33 mean + 33 standard deviation variables.

7. The end result with 180 rows and 68 columns is exported to the files `tidy.txt` and `tidy.csv`.

