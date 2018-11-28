# Load and install necessary packages
requiredPackages <- c("igraph", "ggplot2", "ggthemes", "gridExtra")

for (pac in requiredPackages) {
    if(!require(pac,  character.only=TRUE)){
        install.packages(pac, repos="http://cran.rstudio.com")
        library(pac,  character.only=TRUE)
    } 
}
rm(pac)
rm(requiredPackages)


# Set WD and load data
wd = getwd()
if(grepl("nora", wd)) {
    setwd("~/Documents/18-19/IR/LABS/05/")
} else {
    # Set Carolina Working directory
    setwd("")
}
rm(wd)

#################
songdata <- read.csv("./datasets/songdata.csv", encoding="851", stringsAsFactors=FALSE)
songdata$link <- NULL
songdata$artist <- as.factor(songdata$artist)

levels(songdata$artist)
