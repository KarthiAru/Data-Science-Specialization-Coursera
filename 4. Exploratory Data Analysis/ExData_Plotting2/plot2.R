#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) {unzip("dataset.zip")}

#Read the contents of the file
NEI <- readRDS("./dataset/summarySCC_PM25.rds")
SCC <- readRDS("./dataset/Source_Classification_Code.rds")

#Plot: Examining Changes in PM2.5 Emissions in Baltimore County: 1999-2008
#Extract Baltimore Data
baltimore <- subset(NEI, fips == "24510")
dataPoints <- with(baltimore,(aggregate(Emissions, by = list(year), sum)))

png("plot2.png", width=400, height=400)
plot(dataPoints, type="o", main = "Total PM2.5 Emissions in Baltimore: 1999-2008", xlab = "Year", ylab = "PM2.5 Emissions (Tons)",pch = 19, col = "grey")
dev.off()