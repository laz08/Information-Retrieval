rm(list = ls())

# Load and install necessary packages
requiredPackages <- c("igraph", "ggplot2", "ggthemes", "gridExtra", "rlist", "compare", "corpus", "tm", "text2vec", "data.table")

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


#########################
LOAD_MERGED_SELECTION = TRUE
PLOT = FALSE
source("src/songsLoading.R")
source("src/communitiesFunctions.R")
#########################

merged_songs <- loadSongs()

#########################
####### STOPWORD ########
####### REMOVAL #########
#########################
mystopwords <- list.append(stopwords_en, c("vers", "verse", "oh"))

myfilter <- text_filter(
            stemmer = "en",
            drop_letter = FALSE,
            drop_number = TRUE, drop_punct = TRUE,
            drop_symbol = TRUE,
            drop = mystopwords)

# This is only to know how much we have reduced the text
lyrics.itoken.tmp = itoken(merged_songs$text, progressbar = FALSE)
vocab.tmp = create_vocabulary(lyrics.itoken.tmp)

# Performing stopword removal...
tokens <- text_tokens(merged_songs$text, filter = myfilter) 
for (x in seq(nrow(merged_songs))) {
    merged_songs[x, ]$text <- paste(tokens[[x]], collapse=" ")
}


### Similarity
lyrics.itoken = itoken(merged_songs$text, progressbar = FALSE)
vocab = create_vocabulary(lyrics.itoken)
#kable(vocab)
# Many words that only appear once... Let's prune the vocab
vocab = prune_vocabulary(vocab, term_count_min = 5, doc_proportion_min = 0.15)
vectorizer = vocab_vectorizer(vocab)
mean(vocab$term_count)
median(vocab$term_count)

time = Sys.time()
doc.term.mat = create_dtm(lyrics.itoken, vectorizer)
print(difftime(Sys.time(), time, units = 'sec'))

dim(doc.term.mat) # 287 songs. 2659 unique terms. Pruning: 257

tfidf = TfIdf$new()
dtm_tfidf = fit_transform(doc.term.mat, tfidf)

dim(doc.term.mat)
dim(dtm_tfidf)

global_cos_sim = sim2(x = dtm_tfidf, method = "cosine", norm = "l2")
global_cos_sim[1:2, 1:5]


threshold = 0.35
thresholdRes = which(global_cos_sim[1, ] >= threshold); length(thresholdRes)
# Nr. of results is greater than 205. 

##############################
###### Adj. matrix ###########
##############################

n.max = nrow(global_cos_sim)
adj.mat = matrix(0, ncol = n.max, nrow = n.max)
for (x in seq(n.max)) {
    for (y in x:n.max) {
        val = ifelse(x == y, 0, ifelse((global_cos_sim[x, y] + 1) == 2, 0,
                                 ifelse((global_cos_sim[x, y] + 1) >= (1 + threshold), 1, 0)))
        
        adj.mat[x, y] = val
        adj.mat[y, x] = val
    }
}

##############################
###### Vertices names#########
##############################
chosenByNames = c("Carolina", "Laura", "Both")
chosen = c()
songNames = c()
for (x in seq(nrow(merged_songs))) {
    songNames = append(songNames, paste(merged_songs[x, ]$artist, merged_songs[x, ]$song, sep = " - "))
    chosen = append(chosen, ifelse(merged_songs[x, ]$Carolina & merged_songs[x, ]$Laura, chosenByNames[3],
                                   ifelse(merged_songs[x, ]$Carolina, chosenByNames[1], chosenByNames[2])))
}

colnames(adj.mat) = songNames; rownames(adj.mat) = songNames
chosen <- as.factor(chosen)
chosen <- as.numeric(chosen)

##############################
###### Create graph ##########
##############################

sums <- apply(adj.mat, 1, sum)
(disconnected <- rev(sort(which(sums == 0))))
length(disconnected) # 12 disconnected nodes

songsGraph = graph_from_adjacency_matrix(adj.mat, mode = "undirected")
vertex_attr(songsGraph, "chosenBy", index = V(songsGraph)) <- chosen

is_connected(songsGraph)
plot(songsGraph, vertex.color = vertex_attr(songsGraph,"chosenBy"))

##############################
######  Communities ##########
##############################

# Metrics
degreeSeq = degree(songsGraph, V(songsGraph)); degreeSeq = as.data.frame(degreeSeq)

# This below should be on the report
if(PLOT){
    computeSummaryTable(songsGraph)
    computeTableForGraph(songsGraph)
    
    vocabPrunerCount(lyrics.itoken, seq(0, 1, by = 0.05))
    
    tkplot(songsGraph, vertex.color = vertex_attr(songsGraph,"chosenBy"))
    
    subset.songs <- induced.subgraph(songsGraph, V(songsGraph)[degree(songsGraph) >= 5 & degree(songsGraph) <= 10]); E(subset.songs)
    tkplot(subset.songs, vertex.color = vertex_attr(subset.songs,"chosenBy"))
    
    
    ## Walktrap
    walktrap <- walktrap.community(songsGraph)
    
    subset.songs <- induced.subgraph(songsGraph, V(songsGraph)[degree(songsGraph) >= 5 & degree(songsGraph) <= 10]); E(subset.songs)
    tkplot(subset.songs, vertex.color = vertex_attr(subset.songs,"chosenBy"))
    
    
    plot(walktrap, songsGraph, vertex.label.cex=0.5, vertex.size=5)
    plot(walktrap, songsGraph, vertex.label=NA, vertex.size=5)
    
    plotGraphSetOfCommunities(walktrap, songsGraph, seq(max(walktrap$membership)))
    
   ########## Comparison of words
    #merged_songs[which(merged_songs$song == "Woman"), ] # Row nr 137
    #merged_songs[which(merged_songs$song == "The Final Countdown"), ] # row nr 92
    
    vocab.cmp.table = t(as.matrix(doc.term.mat[c(92, 137),]))
    
    vocab.cmp.table = vocab.cmp.table[rowSums(vocab.cmp.table != 0) > 0, ]
    vocab.cmp.table = cbind(seq(nrow(vocab.cmp.table)), vocab.cmp.table)
    
    
}


###############################
###### Network Analysis #######
###############################

#pagerank
pagerank <- page_rank(songsGraph, directed=FALSE)
pagerank.sorted <- rev(sort(pagerank$vector))

top10PR = (pagerank.sorted[1:10])
topSongsVals = as.vector(top10PR)
topPR = data.frame(names(top10PR), topSongsVals)


