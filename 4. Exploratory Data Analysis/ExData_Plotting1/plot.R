dataFile <- paste(getwd(), "/household_power_consumption.txt", sep="")
data     <- read.table(dataFile, header=FALSE, sep=';', skip=grep("^31/1/2007;23:59:00", readLines(dataFile)), nrows=2880)
# read the column headers and set them as previous read operation skipped all the records until required dates
columnHeaders  <- read.table(dataFile, sep=';', header=TRUE, nrows=1)  # read ONLY 1 record
colnames(data) <- colnames(columnHeaders)

#only select dates of interest
low = 66637
high = 69517
n = high-low
#define data file name and classes
datafile <- "household_power_consumption.txt"
classes <- c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")
#load data
powerdata <- read.table(datafile, header = FALSE, sep = ";", colClasses = classes, 
                        skip =low, nrow=n, na.strings = "?")
#get names
col_names <- read.table(datafile, header = TRUE, sep = ";", colClasses = classes, 
                        nrow=1, na.strings = "?")