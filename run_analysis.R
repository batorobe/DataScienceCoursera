library(data.table)
library(plyr)

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]

# Load data names
features <- read.table("UCI HAR Dataset/features.txt")[,2]

# Extract mean|std for each of the featyres
extract_mean_std <- grepl("mean|std", features)

# Load and process test and train data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

#X = Features; Y = Activity
x_train <- read.table("UCI HAR Dataset/train/x_train.txt", header = FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

#Bind the data together
data_x <-rbind(x_test, x_train)
data_y <- rbind(y_test, y_train)
data_subject <- rbind(subject_train, subject_test)

#Set names
names(data_subject) <- c("Subject")
names(data_y) <- c("Activity")
names(data_x) <- features

#Merge columns
combined_data <- cbind(data_subject, data_y)
final_data <- cbind(data_x, combined_data)

mean_std_subset <- features[grep("mean|std", features)]

selected_subset <- c(as.character(mean_std_subset), "Subject", "Activity")

final_data <- subset(final_data, select=selected_subset)

#Fix the ambiguous label names
names(final_data)<-gsub("^t", "time", names(final_data))
names(final_data)<-gsub("^f", "frequency", names(final_data))
names(final_data)<-gsub("Acc", "Accelerometer", names(final_data))
names(final_data)<-gsub("Gyro", "Gyroscope", names(final_data))
names(final_data)<-gsub("Mag", "Magnitude", names(final_data))
names(final_data)<-gsub("BodyBody", "Body", names(final_data))

#Create independant tidy data set

tidy_data<-aggregate(. ~Subject + Activity, final_data, mean)
tidy_data<-tidy_data[order(tidy_data$Subject,tidy_data$Activity),]
write.table(tidy_data, file = "tidydata.txt",row.name=FALSE)

