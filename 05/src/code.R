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

View(levels(songdata$artist))

coldplay <- songdata[songdata$artist == 'Coldplay', ]
ABBA <- songdata[songdata$artist == 'ABBA', ]
Enya <- songdata[songdata$artist == 'Enya', ]
Europe <- songdata[songdata$artist == 'Europe', ]
Queen <- songdata[songdata$artist == 'Queen', ]
Neil.Young <- songdata[songdata$artist == 'Neil Young', ]
Pet.Shop.Boys <- songdata[songdata$artist == 'Pet Shop Boys', ]
Bruce.Springsteen <- songdata[songdata$artist == 'Bruce Springsteen', ]
Phil.Collins <- songdata[songdata$artist == 'Phil Collins', ]



Pink.Floyd <- songdata[songdata$artist == 'Pink Floyd', ]
nrow(Pink.Floyd)



### Laura Selection

# View(coldplay[, 1:2])
coldplaySongs = c("3258", "3275", "3290", "3292", "3301", "3321", "3331", "28155", "28169", "28171", "28184", "28188")
coldplayLaura <- coldplay[coldplaySongs, ]

#View(ABBA[, 1:2])
abbaSongs = c("8", "19", "23", "46", "57", "63", "107", "108")
abba.Laura <- ABBA[abbaSongs, ]

enyaSongs = c("5266", "31691", "5256")
enya.Laura <- Enya[enyaSongs, ]

europeSongs <- c("31913", "31926", "31959")
europe.Laura <- Europe[europeSongs, ]

queenSongs <- c("16529", "16545", "16562", "16576", "49281", "49283", "49285", "49299", "49321", "49322", "49377")
queen.Laura <- Queen[queenSongs, ]

neilSongs <- c("13880")
neil.Laura <- Neil.Young[neilSongs, ]

psb <- c("15798", "15800", "15802", "15804", "15811", "15814", "15819", "15821", "15837", "15844", "15858", "47958", "47966", "47968", "47970", "47979", "47986", "47996", "48020", "48021")
psb.Laura <- Pet.Shop.Boys[psb, ]

bruceSongs <- c("2011", "2038", "2053", "26541", "26544", "26584")
bruce.Laura <- Bruce.Springsteen[bruceSongs, ]

philSongs <- c("15942", "15962", "15974", "16003", "48239")
phil.Laura <- Phil.Collins[philSongs, ]


laura.selection = rbind(coldplayLaura, abba.Laura)
laura.selection = rbind(laura.selection, enya.Laura)
laura.selection = rbind(laura.selection, europe.Laura)
laura.selection = rbind(laura.selection, queen.Laura)
laura.selection = rbind(laura.selection, neil.Laura)
laura.selection = rbind(laura.selection, psb.Laura)
laura.selection = rbind(laura.selection, bruce.Laura)
laura.selection = rbind(laura.selection, phil.Laura)
nrow(laura.selection)
