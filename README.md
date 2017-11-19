# Getting and Cleaning Data Project

This is the project for the Getting and Cleaning Data Coursera course.

The purpose of the project is to collect, work with and tidy a dataset. The
`runAnalysis` function in the `run_analysis.R` script will:

1. Download and/or extract the project data if it doesn't already exist.

2. Merge the training and test sets into a single dataset.

3. Apply appropriate column names from the provided `features.txt` file.

4. Filter out columns that aren't measures of mean and standard deviation

5. Create a tidy dataset with the average of each variable for each subject
and activity pair.

# Usage

Source the `run_analysis.R` script:

```
source('run_analysis.R')
```

Call `runAnalysis` with the url pointing to the project data:

```
runAnalysis("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
```

Upon completion, a file called `tidy.txt` containing a tidy dataset will be
created. The code book for this file is included in this repository as
CodeBook.md
