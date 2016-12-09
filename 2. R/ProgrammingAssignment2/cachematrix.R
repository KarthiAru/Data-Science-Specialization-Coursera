## Function to cache the inverse of a square matrix

## Sample Results
## > source("cachematrix.R")    load R program
## > a <- makeCacheMatrix()     create functions
## > a$set(matrix(1:4, 2, 2))   create matrix in working environment
## > cacheSolve(a)              1st run returns inverted matrix from working environment
##      [,1] [,2]
## [1,]   -2  1.5
## [2,]    1 -0.5
##
## > cacheSolve(a)              2nd and subsequent runs returns inverted matrix from cache
## getting cached data          
##      [,1] [,2]
## [1,]   -2  1.5
## [2,]    1 -0.5

## Create a matrix object to cache its inverse
makeCacheMatrix <- function(x = matrix()) {
        # Initialize the cache
        c<-NULL
        
        # Store the matrix in working environment
        set<-function(y){
                x<<-y
                c<<-NULL
        }
        # Retrieve the matrix
        get <- function() x
        
        # Compute inverse of the matrix and store in cache
        setInverse <- function(inverse) c <<- inverse
        
        # Retrieve inverse of the matrix from cache
        getInverse <- function() c
        
        # Return a list of the methods to working environment
        list(set = set, get = get, setInverse = setInverse, getInverse = getInverse)
}

## Compute the inverse of the matrix returned by makeCacheMatrix
cacheSolve <- function(x, ...) {
        # Try to retrieve the inverse of matrix if available
        c <- x$getInverse()
        # Return the inverse from cache or create the matrix in working environment
        if( !is.null(c) ) {
                message("getting cached data")
                # Print matrix in console
                return(c)
        }
        # Create matrix if not available
        mat <- x$get()
        # Compute and return the inverse
        c <- solve(mat)
        # Set matrix inverse in cache
        x$setInverse(c)
        # Print matrix in console
        c
}
