# Load and install necessary packages
requiredPackages <- c("igraph", "ggplot2", "ggthemes", "gridExtra", "rlist")

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
    setwd("~/Documents/FEUP/5A/1S/IR/Information-Retrieval/05")
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


#Carolina selection

adele <- songdata[songdata$artist == 'Adele', ]
bowie <- songdata[songdata$artist == 'David Bowie', ]
lana <- songdata[songdata$artist == 'Lana Del Rey', ]
lcohen <- songdata[songdata$artist == 'Leonard Cohen', ]
maroon5 <- songdata[songdata$artist == 'Maroon 5', ]
edsheeran <- songdata[songdata$artist == 'Ed Sheeran', ]

adeleSongs <- c("134", "138", "139", "143", "22952", "22953", "22954", "22960", "22967", "22969", "22971", "22976", "22977", "22984", "22989", "22990", "22991")
adeleC <- adele[adeleSongs, ]

bowieSongs <- c("3763", "3810")
bowieC <- bowie[bowieSongs, ]

lanaSongs <- c("11161", "11167", "11170", "41166", "41169", "41210", "41227", "41234")
lanaC <- lana[lanaSongs, ]

lcohenSongs <- c("11448", "11453", "11456", "11459", "11461", "11496", "41527", "41541", "41541", "41546")
lcohenC <- lcohen[lcohenSongs, ]

maroon5Songs <- c("12534", "43092", "43101", "43139", "43140", "43141", "43134", "43142", "43146", "43156", "43162", "43170", "43171", "43176", "43178")
maroon5C <- maroon5[maroon5Songs, ]

edSongs <- c("30753", "30756", "30758", "30759", "30768", "30777")
edsheeranC <- edsheeran[edSongs, ]

coldplaycSongs <- c("3257", "3260", "3266", "3277", "3307", "3308", "3309", "3319", "3322", "3320", "3325", "28155", "28183", "28188")
coldplayC <- coldplay[coldplaycSongs, ]

abbacSongs <- c("12", "14", "50", "71", "91", "96", "100", "105", "84")
abbaC <- ABBA[abbacSongs, ]

pinkfSongs <- c("48440", "48431")
pinkfC <- Pink.Floyd[pinkfSongs, ]

c.selection = rbind(adeleC, bowieC)
c.selection = rbind(c.selection, lanaC)
c.selection = rbind(c.selection, lcohenC)
c.selection = rbind(c.selection, maroon5C)
c.selection = rbind(c.selection, edsheeranC)
c.selection = rbind(c.selection, coldplayC)
c.selection = rbind(c.selection, abbaC)
c.selection = rbind(c.selection, phil.Laura)
nrow(c.selection)