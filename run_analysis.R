library(dplyr)

PATH_SEP <- .Platform$file.sep
ZIP_FILE <- "project_data.zip"
DATA_DIR <- "UCI HAR Dataset"


buildDatasetReader <- function(dir, dataset) {
    # Creates a function to read files named:
    #
    # [prefix][dataset].txt
    #
    # in the directory specified by dir.
    # Returned function reads files of arbitrary prefix into a data frame

    # Remove any trailing directory separator character
    if (endsWith(PATH_SEP, dir)) {
        dir <- gsub(paste(PATH_SEP, "$", sep=""), "", dir)
    }

    dirReader <- function(prefix) {
        frame <- read.table(
            file.path(dir, paste(prefix, dataset, ".txt", sep="")))

        return(frame)
    }

    return(dirReader)
}

readData <- function(directory){
    # Reads X_[dataset].txt, y_[dataset].txt and subject_[dataset].txt in
    # "directory" and combines them into a single data frame

    # "dataset" is taken as the last element of the directory path.
    # i.e. if directory = foo/bar/, dataset = bar

    # "directory" can be passed with or without a trailing separator character
    # i.e. foo/bar or foo/bar/

    # Determine if we are reading "test" or "train" directory
    dataset <- basename(directory)

    # Get reader for this dataset
    readFile <- buildDatasetReader(directory, dataset)

    # Read data files
    xData <- readFile("X_")
    yData <- readFile("y_")
    subjectData <- readFile("subject_")

    # Combine into single data frame
    data <- cbind(subjectData, yData, xData)

    return(data)
}

columnsBySubStrings <- function(substrings, dataFrame) {
    # Select columns of a data frame whose names contain any of a list of
    # substrings

    # Construct regex pattern
    pattern <- paste(substrings, collapse="|")

    # Subset data frame
    subsetted <- dataFrame[, grepl(pattern, names(dataFrame))]

    return(subsetted)
}

initialiseFiles <- function(url) {
    # Checks if project data file has been downloaded and extracted

    # Download data file if needed
    if (!file.exists(ZIP_FILE)){
        download.file(url, ZIP_FILE)
    }

    # Extract file if needed
    if (!file.exists(DATA_DIR)) {
        unzip(ZIP_FILE)
    }
}

cleanNames <- function(frame, search, replace) {
    # Find columns names in frame that match 'search' and replace with 'replace'
    colnames(frame) <- gsub(search, replace, names(frame))

    return(frame)
}

runAnalysis <- function(fileUrl) {
    # Download and unzip project file if necessary
    initialiseFiles(fileUrl)

    # Read all test and train data
    testData <- readData(paste(DATA_DIR, PATH_SEP, "test", sep=""))
    trainData <- readData(paste(DATA_DIR, PATH_SEP, "train", sep=""))

    # Combine test and train data into single data frame
    data <- rbind(testData, trainData)

    # Read in feature labels
    features <- read.table(paste(DATA_DIR, PATH_SEP, "features.txt", sep=""),
        colClasses=c("NULL", "character"), check.names=FALSE)[,1]
    # Add column names to data frame
    colnames(data) <- c("Subject", "Activity", features)

    # Select "Subject", "Activity", and mean and std dev columns only
    selectCols <- c("Activity", "Subject", "-mean", "-std")
    data <- columnsBySubStrings(selectCols, data)

    # Clean up column names
    data <- cleanNames(data, "-|\\(\\)", "")
    data <- cleanNames(data, "mean", "Mean")
    data <- cleanNames(data, "std", "Std")

    # Read in table mapping activity character labels to integers
    activityKey <- read.table(
        paste(DATA_DIR, PATH_SEP, "activity_labels.txt", sep=""),
        col.names=c("activity_id", "Activity"))

    # Replace activity integers with character labels
    data[["Activity"]] <- activityKey[
        match(data[['Activity']], activityKey[['activity_id']]), 'Activity']

    # Group by Subject and Activity, then calculate mean for measure columns
    tidyData <- data %>%
        group_by(Subject, Activity) %>%
        summarise_all(funs(mean))

    # Write tidyData to file
    write.table(tidyData, "tidy.txt", row.names=FALSE, quote=FALSE)

    return("success")
}
