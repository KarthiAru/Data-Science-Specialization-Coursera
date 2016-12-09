#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) {unzip("dataset.zip")}

#Read the contents of the file
NEI <- readRDS("./dataset/summarySCC_PM25.rds")
SCC <- readRDS("./dataset/Source_Classification_Code.rds")

#Plot: Examining Changes in Coal-Related Emissions across U.S: 1999-2008
library(ggplot2)
#Extract all Coal Emission Related Data from SCC
tmp <- subset(SCC, select=c(SCC,Short.Name))
tmp <- subset(tmp, grepl("Coal",tmp$Short.Name))
#Merge Datasets
mergedData <- merge(x=NEI, y=tmp, by="SCC")
#Extract all Coal Emission Related Data from Merged Dataset
coal <- subset(mergedData, grepl("Coal",mergedData$Short.Name))
dataPoints <- aggregate(Emissions ~ type + year, data=coal, sum)
#Renaming Column Name
names(dataPoints)[1] <- "Source.Type"

png("plot4.png", width=400, height=400)
ggplot(data=dataPoints, aes(x=year, y=Emissions/10^6, color=Source.Type)) + geom_point() +geom_line() + ggtitle("Coal Combustion Emissions in U.S: 1999-2008") + xlab("Year") + ylab("PM2.5 Emissions (10^6 Tons)")
dev.off()