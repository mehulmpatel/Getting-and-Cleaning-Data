## Create one R script called : run_analysis.R 

## Functionality as followed below :
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Checking Package: data.table
if (!require("data.table")) {
  install.packages("data.table")
}

# Checking Package: reshape2
if (!require("reshape2")) {
  install.packages("reshape2")
}

# Loading Package: data.table & reshape2
require("data.table")
require("reshape2")

# Load: activity labels
activity.labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract.features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
x.test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y.test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject.test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(x.test) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
x.test = x.test[, extract.features]

# Load activity labels
y.test[, 2] = activity.labels[y.test[, 1]]
names(y.test) = c("Activity_ID", "Activity_Label")
names(subject.test) = "subject"

# Bind data
test.data <- cbind(as.data.table(subject.test), y.test, x.test)

# Load and process X_train & y_train data.
x.train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y.train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject.train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(x.train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
x.train = x.train[,extract.features]

# Load activity data
y.train[,2] = activity.labels[y.train[, 1]]
names(y.train) = c("Activity_ID", "Activity_Label")
names(subject.train) = "subject"

# Bind data
train.data <- cbind(as.data.table(subject.train), y.train, x.train)

# Merge test and train data
data = rbind(test.data, train.data)

id.labels   = c("subject", "Activity_ID", "Activity_Label")
data.labels = setdiff(colnames(data), id.labels)
melt.data   = melt(data, id = id.labels, measure.vars = data.labels)

# Apply mean function to dataset using dcast function
tidy.data   = dcast(melt.data, subject + Activity_Label ~ variable, mean)

write.table(tidy.data, file = "./tidy_data.txt")

