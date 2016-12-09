#Download the dataset
url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if (!file.exists("dataset.zip")){download.file(url,destfile="dataset.zip",method="curl")}
#Unzip the file
if (!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) {unzip("dataset.zip")}

#Read the contents of the file
NEI <- readRDS("./dataset/summarySCC_PM25.rds")
SCC <- readRDS("./dataset/Source_Classification_Code.rds")

#Plot6
library(ggplot2)
#Extract all Data from SCC by EI.Sector
tmp <- subset(SCC, select=c(SCC,EI.Sector))
#Extract all Baltimore and ON-ROAD Emission Source Data
baltimore <- subset(NEI, fips == "24510" & type=="ON-ROAD")
#Merge Datasets
mergedData <- merge(x=baltimore, y=tmp, by="SCC")
dataPoints <- aggregate(Emissions ~ EI.Sector + year + fips, data=mergedData, sum)

#Extract all Los Angeles and ON-ROAD Emission Source Data
losangeles <- subset(NEI, fips == "06037" & type=="ON-ROAD")
#Merge Datasets
mergedData <- merge(x=losangeles, y=tmp, by="SCC")
dataPoints <- rbind(dataPoints,aggregate(Emissions ~ EI.Sector + year + fips, data=mergedData, sum))

#Renaming fips Factor
dataPoints$fips<-gsub("24510", "Baltimore", dataPoints$fips)
dataPoints$fips<-gsub("06037", "Los Angeles", dataPoints$fips)
#Renaming Column Names
dataPoints$EI.Sector<-gsub("Mobile - On-Road ", "", dataPoints$EI.Sector)
names(dataPoints)[1] <- "Vehicle.Type"

png("plot6.png", width=550, height=550)
ggplot(data=dataPoints, aes(x=year, y=Emissions, color=Vehicle.Type)) + geom_point() +geom_line() + facet_grid(.~fips)+ ggtitle(expression(atop("Two City Motor-Vehicle Emission Comparison",atop(italic("Baltimore and Los Angeles: 1999-2008"))))) + xlab("Year") + ylab("PM2.5 Emissions (Tons)")
dev.off()