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

coldplay <- songdata[songdata$artist == 'Coldplay', ]
nrow(coldplay)

ABBA <- songdata[songdata$artist == 'ABBA', ]
nrow(ABBA)

Enya <- songdata[songdata$artist == 'Enya', ]
nrow(Enya)

Europe <- songdata[songdata$artist == 'Europe', ]
nrow(Europe)

Queen <- songdata[songdata$artist == 'Queen', ]
nrow(Queen)

Neil.Young <- songdata[songdata$artist == 'Neil Young', ]
nrow(Neil.Young)

Pet.Shop.Boys <- songdata[songdata$artist == 'Pet Shop Boys', ]
nrow(Pet.Shop.Boys)

Pink.Floyd <- songdata[songdata$artist == 'Pink Floyd', ]
nrow(Pink.Floyd)


