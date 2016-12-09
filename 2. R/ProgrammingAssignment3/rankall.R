rankall <- function(outcome,num="best"){
        # Read data from outcome-of-care-measures.csv file 
        data <- read.csv("outcome-of-care-measures.csv", colClasses="character")
 
        # Check for validity of 'outcome' input
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
        else if (outcome=="pneumonia"){
                set1 <- data[,c(2,7,23)]
                suppressWarnings(set1[,3] <- as.numeric(set1[,3]))
                set1 <- set1[complete.cases(set1[,3]),]
        }
        
        # Get the unique set of States from column 7 of 'data' and sort it
        s <- sort(unique(data[,7]))
        # Create a empty data frame to hold the hospital names and state names (abbreviated)
        output <- data.frame(matrix(NA, nrow = length(s), ncol = 2))
        colnames(output) <- c("hospital", "state")
        # Push the sorted state names (abbreviated) into 'state' variable
        output[2] <- s
        
        ## Run a loop to return hospital name in that state with the given rank for 30-day death rate
        for (i in 1:length(s)){
                # Create a subset of hospitals from that state for the outcome
                temp <- subset(set1,State==s[i])
                # Sort by 30-day mortality rate and then by hospital name
                temp <- temp[order(temp[,3],temp[,1]), ]
                
                # Assign rank based on string keywords
                if(num =="best") rank <- 1
                else if (num =="worst") rank <- nrow(temp)
                else rank <- num
                
                # Push the hospital name into the respective row of 'output' data frame
                output[i,1] <- temp[rank,1]
        }
        # Return the 2 column data frame with hospital names and states
        output
}