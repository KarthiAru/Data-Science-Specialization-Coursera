#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) {unzip("dataset.zip")}

#Read the contents of the file
NEI <- readRDS("./dataset/summarySCC_PM25.rds")
SCC <- readRDS("./dataset/Source_Classification_Code.rds")

#Plot: Examining changes in Motor-Vehicle Emissions in Baltimore: 1999-2008
library(ggplot2)
#Extract all Data from SCC by EI.Sector
tmp <- subset(SCC, select=c(SCC,EI.Sector))
#Extract all Baltimore and ON-ROAD Emission Source Data
baltimore <- subset(NEI, fips == "24510" & type=="ON-ROAD")
#Merge Datasets
mergedData <- merge(x=baltimore, y=tmp, by="SCC")
dataPoints <- aggregate(Emissions ~ EI.Sector + year, data=mergedData, sum)
#Renaming Column Names
dataPoints$EI.Sector<-gsub("Mobile - On-Road ", "", dataPoints$EI.Sector)
names(dataPoints)[1] <- "Vehicle.Type"

png("plot5.png", width=450, height=450)
ggplot(data=dataPoints, aes(x=year, y=Emissions, color=Vehicle.Type)) + geom_point() +geom_line() + ggtitle("Motor-Vehicle Emissions in Baltimore: 1999-2008") + xlab("Year") + ylab("PM2.5 Emissions (Tons)")
dev.off()