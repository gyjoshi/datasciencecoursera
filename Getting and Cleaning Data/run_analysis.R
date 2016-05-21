# R script namely run_analysis.R that does the following:

# i) Merges the training and the test sets to create one data set.
# ii) Extracts only the measurements on the mean and standard deviation for each measurement.
# iii) Uses descriptive activity names to name the activities in the data set
# iv) Appropriately labels the data set with descriptive activity names.
# v) Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Checking and installing required R packages

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Changing the working directory to the location where the UCI HAR Dataset was unzipped

setwd("D:/Data Science Materials/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset")

# Load: activity labels
activity_labels <- read.table("./activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

names(X_test) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

# Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")

subject_train <- read.table("./train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt", row.names=FALSE)