#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!file.exists("household_power_consumption.txt")) {unzip("dataset.zip")}

#Read the contents of the file
data <- read.table("./household_power_consumption.txt",sep=";", header=TRUE, colClasses=c("character","character","double","double","double","double","double","double","numeric"),na.strings="?")
#Join Date and Time to create a Timestamp
data$DT <- paste(data$Date, data$Time)
#Format Timestamp
data$DT <- strptime(data$DT, format="%d/%m/%Y %H:%M:%S")
data$Date <- strptime(data$Date, format="%d/%m/%Y")
#Subset Data only for 2007-02-01 and 2007-02-02
dat <- subset(data, Date == "2007-02-01" | Date == "2007-02-02")

#Create Plot
png("plot1.png",  width = 480, height = 480, units = "px")
hist(dat$Global_active_power, main="Global Active Power", xlab="Global Active Power (Kilowatts)", col="red")
dev.off()
