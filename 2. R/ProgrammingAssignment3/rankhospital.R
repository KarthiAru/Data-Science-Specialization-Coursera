rankhospital <- function(state,outcome,num){
        # Read data from outcome-of-care-measures.csv file
        data <- read.csv("outcome-of-care-measures.csv", colClasses="character")
        
        # Get the unique set of States from column 7 of 'data' and sort it
        s <- unique(data[,7])   
        
        # Check for validity of 'state' and 'outcome' input
        if (!(any(s == state))) stop("invalid state")
        if (!(any(outcome == c("heart attack","heart failure","pneumonia")))) stop("invalid outcome")
        if(class(num) == "character"){
                if (! (num == "best" || num == "worst")){
                        stop("invalid rank")
                }
        }
        # Subset respective outcome data into a new data frame
        if (outcome=="heart attack"){
                set1 <- data[,c(2,7,11)]
                # Convert 30-day mortality data in columns 3 to numeric
                suppressWarnings(set1[,3] <- as.numeric(set1[,3]))
                # Removing NAs
                set1 <- set1[complete.cases(set1[,3]),]
        }
        else if (outcome=="heart failure"){
                set1 <- data[,c(2,7,17)]
                suppressWarnings(set1[,3] <- as.numeric(set1[,3]))
                set1 <- set1[complete.cases(set1[,3]),]
        }
        else {
                set1 <- data[,c(2,7,23)]
                suppressWarnings(set1[,3] <- as.numeric(set1[,3]))
                set1 <- set1[complete.cases(set1[,3]),]
        }
        
        # Create a subset of hospitals from that state for the outcome
        output <- subset(set1,State==state)
        
        # Sort by 30-day mortality rate and then by hospital name
        output <- output[order(output[,3],output[,1]), ]
        # [Optional] Create a new variable 'Rank' in the data frame and store integer 'row' values
        output[,4] <- 1:nrow(output)
        colnames(output)[4] <- "Rank"
        
        # Assign rank based on string keywords
        if(num =="best") rank <- 1
        else if (num =="worst") rank <- nrow(output)
        else rank <- num
        
        # Return hospital name in that state with the given rank for 30-day death rate
        output[rank,1]
}