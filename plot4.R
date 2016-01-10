##
## this code may require package sqldf.
## sqldf allows us to easily restrict data being
## read in from a large dataset when there are
## memory considerations, by allowing a filter to
## be applied when reading the data into memory
##
## this section ensures the subset of two days worth
## of data exists and stored in  file 'SubsetData.txt'
##
print("Checking SubsetData.txt exists")
if (!file.exists("SubsetData.txt")) {
	print("SubsetData.txt does not exist - checking household_power_consumption.txt exists")
	if (!file.exists("household_power_consumption.txt")) {
		print("household_power_consumption.txt does not exist - checking household_power_consumption.zip exists")
		if (!file.exists("household_power_consumption.zip")) {
			##
			## download data as a zip file
			##
			print("household_power_consumption.zip does not exist - downloading zip file")
			fileUrl = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
			download.file(fileUrl, destfile="household_power_consumption.zip")
			rm("fileUrl")
		}
		##
		## unzip the data from the downloaded file
		##
		print("household_power_consumption.zip exists - unzipping household_power_consumption.txt")
		unzip("household_power_consumption.zip")
	}
	##
	## subset the data to reduce memory resources
	## and store in file 'SubsetData.txt'
	##
	library(sqldf)
	print("household_power_consumption.txt exists - reading in and subsetting household_power_consumption.txt")
	file = "household_power_consumption.txt"
	data <- read.csv.sql(file, sql="select * from file where Date in('1/2/2007', '2/2/2007')", header=TRUE, sep=";")
	print("Writing to file SubsetData.txt")
	write.table(data, file="SubsetData.txt", quote=FALSE, sep=";", na="?", row.names=FALSE, col.names=TRUE)
	rm(list=c("file", "data"))
}
##
## read in subset data for analysis
##
print("Reading from file SubsetData.txt")
data <- read.table("SubsetData.txt", header=TRUE, sep=";", na.strings="?")
##
## paste date and time to create extra column DateTime of type POSIZct
##
print("Pasting Date and Time to create DateTime variable of type POSIXct")
data$DateTime <- as.POSIXct(paste(data$Date, data$Time), format="%d/%m/%Y %H:%M:%S")
##
## set graphics device to png file, setting size
##
print("Setting graphics device to file 'plot4.png'")
png(file="plot4.png", width=480, height=480)
##
## plot data to graphic device
##
print("Plotting to png file")
par(mfcol=c(2,2))
print("Plotting 1st graphic")
with(data, plot(DateTime, Global_active_power, xlab="", ylab="Global Active Power (kilowatts)", type="l"))
print("Plotting 2nd graphic")
with(data, plot(DateTime, Sub_metering_1, xlab="", ylab="Energy sub metering", type="l"))
points(data$DateTime, data$Sub_metering_2, col="red", type="l")
points(data$DateTime, data$Sub_metering_3, col="blue", type="l")
legend("topright", col=c("black", "red", "blue"), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty=1, bty="n")
print("Plotting 3rd graphic")
with(data, plot(DateTime, Voltage, xlab="datetime", ylab="Voltage", type="l"))
print("Plotting 4th graphic")
with(data, plot(DateTime, Global_reactive_power, xlab="datetime", ylab="Global_reactive_power", type="l"))
##
## close connection to the graphics device file
##
print("Closing connection to png file")
dev.off()
##
## clean up user objects
##
rm(list=c("data"))
