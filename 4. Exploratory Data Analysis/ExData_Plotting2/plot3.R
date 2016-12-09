#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) {unzip("dataset.zip")}

#Read the contents of the file
NEI <- readRDS("./dataset/summarySCC_PM25.rds")
SCC <- readRDS("./dataset/Source_Classification_Code.rds")

#Plot: Examining Changes in PM2.5 Emissions in Baltimore County By Source: 1999-2008
library(ggplot2)
#Extract Baltimore Data
baltimore <- subset(NEI, fips == "24510")
dataPoints <- aggregate(Emissions ~ type + year, data = baltimore, sum)
#Renaming Column Name
names(dataPoints)[1] <- "Source.Type"

png("plot3.png", width=400, height=400)
ggplot(data=dataPoints, aes(x=year, y=Emissions, color=Source.Type)) + geom_point() + geom_line() + ggtitle("Emission by Source Type in Baltimore: 1999-2008") + xlab("Year") + ylab("PM2.5 Emissions (Tons)")
dev.off()