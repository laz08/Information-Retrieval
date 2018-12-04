# Load and install necessary packages
requiredPackages <- c("igraph", "ggplot2", "ggthemes", "gridExtra", "rlist", "compare")

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


LOAD_MERGED_SELECTION = TRUE

if(!LOAD_MERGED_SELECTION){
    #################
    songdata <- read.csv("./datasets/songdata.csv", encoding="851", stringsAsFactors=FALSE)
    songdata$link <- NULL
    songdata$artist <- as.factor(songdata$artist)
    
    #View(levels(songdata$artist))
    
    coldplay <- songdata[songdata$artist == 'Coldplay', ]
    ABBA <- songdata[songdata$artist == 'ABBA', ]
    Enya <- songdata[songdata$artist == 'Enya', ]
    Europe <- songdata[songdata$artist == 'Europe', ]
    Queen <- songdata[songdata$artist == 'Queen', ]
    Neil.Young <- songdata[songdata$artist == 'Neil Young', ]
    Pet.Shop.Boys <- songdata[songdata$artist == 'Pet Shop Boys', ]
    Bruce.Springsteen <- songdata[songdata$artist == 'Bruce Springsteen', ]
    Phil.Collins <- songdata[songdata$artist == 'Phil Collins', ]
    aerosmith <- songdata[songdata$artist == 'Aerosmith', ]
    elo <- songdata[songdata$artist == 'Electric Light Orchestra', ]
    Elton.John <- songdata[songdata$artist == 'Elton John', ]
    Evanescense <- songdata[songdata$artist == 'Evanescence',]
    Grease <- songdata[songdata$artist == 'Grease',]
    
    
    adele <- songdata[songdata$artist == 'Adele', ]
    bowie <- songdata[songdata$artist == 'David Bowie', ]
    lana <- songdata[songdata$artist == 'Lana Del Rey', ]
    lcohen <- songdata[songdata$artist == 'Leonard Cohen', ]
    maroon5 <- songdata[songdata$artist == 'Maroon 5', ]
    edsheeran <- songdata[songdata$artist == 'Ed Sheeran', ]
    beatles <- songdata[songdata$artist == 'The Beatles', ]
    
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
    
    beatles.Laura.Songs <- c("1209", "24693", "24695", "24696", "1224", "24750", "24748", "24802", "24818", "24820", "24823")
    beatles.Laura<- beatles[beatles.Laura.Songs, ]
    
    maroon5.L.songs <- c("43092", "12523", "12534")
    maroon5Laura <- maroon5[maroon5.L.songs, ]
    
    aerosmithSongs <- c("23017", "22995")
    aerosmith.Laura <- aerosmith[aerosmithSongs, ]
    
    eloSongs <- c("4744", "30861", "30871", "30891", "30928", "30947")
    elo.Laura <- elo[eloSongs, ]
    
    eltonSongs <- c("4879", "31144")
    Elton.John.Laura <- Elton.John[eltonSongs, ]
    
    EvanescenseSongs <- c("5543")
    Ev.Laura <- Evanescense[EvanescenseSongs, ]
    
    GreaseSongs <- c("34585", "7201", "34578", "34592", "34591")
    Grease.Laura <- Grease[GreaseSongs, ]
    
    
    laura.selection = rbind(coldplayLaura, abba.Laura)
    laura.selection = rbind(laura.selection, enya.Laura)
    laura.selection = rbind(laura.selection, europe.Laura)
    laura.selection = rbind(laura.selection, queen.Laura)
    laura.selection = rbind(laura.selection, neil.Laura)
    laura.selection = rbind(laura.selection, psb.Laura)
    laura.selection = rbind(laura.selection, bruce.Laura)
    laura.selection = rbind(laura.selection, phil.Laura)
    laura.selection = rbind(laura.selection, beatles.Laura)
    laura.selection = rbind(laura.selection, maroon5Laura)
    laura.selection = rbind(laura.selection, aerosmith.Laura)
    laura.selection = rbind(laura.selection, elo.Laura)
    laura.selection = rbind(laura.selection, Elton.John.Laura)
    laura.selection = rbind(laura.selection, Ev.Laura)
    laura.selection = rbind(laura.selection, Grease.Laura)
    nrow(laura.selection)
    
    
    #Carolina selection
    
    adeleSongs <- c("134", "138", "139", "143", "22952", "22953", "22954", "22960", "22967", "22969", "22971", "22976", "22977", "22984", "22989", "22990", "22991")
    adeleC <- adele[adeleSongs, ]
    
    bowieSongs <- c("3763", "3810")
    bowieC <- bowie[bowieSongs, ]
    
    lanaSongs <- c("11161", "11167", "11170", "41166", "41169", "41210", "41227", "41234")
    lanaC <- lana[lanaSongs, ]
    
    lcohenSongs <- c("11448", "11453", "11456", "11459", "11461", "11496", "41527", "41541", "41546")
    lcohenC <- lcohen[lcohenSongs, ]
    
    maroon5Songs <- c("12534", "43092", "43101", "43139", "43140", "43141", "43134", "43142", "43146", "43156", "43162", "43170", "43171", "43176", "43178")
    maroon5C <- maroon5[maroon5Songs, ]
    
    edSongs <- c("30753", "30756", "30758", "30759", "30768", "30777")
    edsheeranC <- edsheeran[edSongs, ]
    
    coldplaycSongs <- c("3257", "3260", "3266", "3277", "3307", "3308", "3309", "3319", "3322", "3320", "3325", "28155", "28183", "28188")
    coldplayC <- coldplay[coldplaycSongs, ]
    
    abbacSongs <- c("12", "14", "50", "71", "91", "96", "100", "105", "84")
    abbaC <- ABBA[abbacSongs, ]
    
    pinkfSongs <- c("48440", "48431", "16098")
    pinkfC <- Pink.Floyd[pinkfSongs, ]
    
    beatlesSongs <- c("1209", "1211", "1214", "1223", "1224", "24693", "24695", "24696", "24708", "24748", "24750", "24762", "24764", "24792", "24802", "24806", "24811")
    beatlesC <- beatles[beatlesSongs, ]
    
    c.selection = rbind(adeleC, bowieC)
    c.selection = rbind(c.selection, lanaC)
    c.selection = rbind(c.selection, lcohenC)
    c.selection = rbind(c.selection, maroon5C)
    c.selection = rbind(c.selection, edsheeranC)
    c.selection = rbind(c.selection, coldplayC)
    c.selection = rbind(c.selection, abbaC)
    c.selection = rbind(c.selection, pinkfC)
    c.selection = rbind(c.selection, beatlesC)
    nrow(c.selection)
    
    # Tmp songs to check for duplicates
    all.songs <- rbind(c.selection, laura.selection)
    
    # Check there are no duplicated rows.
    (duplicated.rows = which(duplicated(all.songs) | duplicated(all.songs[nrow(all.songs):1, ])[nrow(all.songs):1]))
    all.songs[37, -3] # 12534
    all.songs[38, -3] # 43092
    
    
    c.selection$Carolina <- TRUE
    laura.selection$Laura <- TRUE
    all.songs2 <- merge(c.selection, laura.selection, all=TRUE)
    
    all.songs2[is.na(all.songs2$Carolina), ]$Carolina <- FALSE
    all.songs2[is.na(all.songs2$Laura), ]$Laura <- FALSE
    
    # View(all.songs2)
    # write.csv(all.songs2, "./datasets/merged_songs.csv")
} else {
    merged_songs <- read.csv("./datasets/merged_songs.csv", stringsAsFactors = FALSE,)
    merged_songs$X <- NULL
}



# TODO: Stemming and stopword removal on lyrics (column 3)
ENGLISH_STOPWORDS = c("i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now", "\n", "")

i = 1
for (lyrics in merged_songs[, 3]) {
    lyrics.words = strsplit(lyrics, " ")  
    lyrics.without.stopwords = c()
    for (word in lyrics.words) {
        if(!(word %in% ENGLISH_STOPWORDS)){
            lyrics.without.stopwords = append(lyrics.without.stopwords, word)
        }
    }
    merged_songs[i, 3] <- paste(lyrics.without.stopwords, collapse = " ")
    i = i + 1
}
