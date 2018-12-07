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
LOAD_MERGED_SELECTION = FALSE
source("src/songsLoading.R")
source("src/communitiesFunctions.R")
#########################

merged_songs <- loadSongs()

#########################
####### STOPWORD ########
####### REMOVAL #########
#########################
mystopwords <- list.append(stopwords_en, c("vers", "verse"))

myfilter <- text_filter(
            stemmer = "en",
            drop_letter = FALSE,
            drop_number = TRUE, drop_punct = TRUE,
            drop_symbol = TRUE,
            drop = mystopwords)

tokens <- text_tokens(merged_songs$text, filter = myfilter) 
for (x in seq(nrow(merged_songs))) {
    merged_songs[x, ]$text <- paste(tokens[[x]], collapse=" ")
}


### Similarity

lyrics.itoken = itoken(merged_songs$text, progressbar = FALSE)
vocab = create_vocabulary(lyrics.itoken)
#kable(vocab)
# Many words that only appear once... Let's prune the vocab
vocab = prune_vocabulary(vocab, term_count_min = 5, doc_proportion_min = 0.1)
vectorizer = vocab_vectorizer(vocab)
mean(vocab$term_count)
median(vocab$term_count)

time = Sys.time()
doc.term.mat = create_dtm(lyrics.itoken, vectorizer)
print(difftime(Sys.time(), time, units = 'sec'))

dim(doc.term.mat) # 287 songs. 2659 unique terms. Pruning: 116

tfidf = TfIdf$new()
dtm_tfidf = fit_transform(doc.term.mat, tfidf)

dim(doc.term.mat)
dim(dtm_tfidf)

global_cos_sim = sim2(x = dtm_tfidf, method = "cosine", norm = "l2")
global_cos_sim[1:2, 1:5]

threshold = which(global_cos_sim[1, ] >= 0.20); length(threshold)


##############################
###### Adj. matrix ###########
##############################

n.max = nrow(global_cos_sim)
adj.mat = matrix(0, ncol = n.max, nrow = n.max)
for (x in seq(n.max)) {
    for (y in seq(n.max)) {
        adj.mat[x, y] = ifelse(x == y, 0, ifelse((global_cos_sim[x, y] + 1) == 2, 0,
               ifelse((global_cos_sim[x, y] + 1) >= 1.2, 1, 0)))
    }
}

##############################
###### Vertices names#########
##############################
songNames = c()
for (x in seq(nrow(merged_songs))) {
    songNames = append(songNames, paste(merged_songs[x, ]$artist, merged_songs[x, ]$song, sep = " - "))
}

colnames(adj.mat) = songNames; rownames(adj.mat) = songNames


chosenByNames = c("Carolina", "Laura", "Both")
chosen = c()
for (x in seq(nrow(merged_songs))) {
    chosen = append(chosen, ifelse(merged_songs[x, ]$Carolina & merged_songs[x, ]$Laura, chosenByNames[3],
                                   ifelse(merged_songs[x, ]$Carolina, chosenByNames[1], chosenByNames[2])))
}

chosen <- as.factor(chosen)
chosen <- as.numeirc(chosen)

##############################
###### Create graph ##########
##############################

sums <- apply(adj.mat, 1, sum)
disconnected <- rev(sort(which(sums == 0)))
#no disconnected nodes


songsGraph = graph_from_adjacency_matrix(adj.mat, mode = "undirected")
plot(songsGraph)

vertex_attr(songsGraph, "chosenBy", index = V(songsGraph)) <- chosen
plot(songsGraph, vertex.color = vertex_attr(songsGraph,"chosenBy"))

##############################
######  Communities ##########
##############################

# This below should be on the report
computeSummaryTable(songsGraph)
computeTableForGraph(songsGraph)

walktrap <- walktrap.community(songsGraph)
plotGraphSetOfCommunities(walktrap, songsGraph, seq(max(walktrap$membership)))


###############################
###### Network Analysis #######
###############################

#pagerank
pagerank <- page_rank(songsGraph)
pagerank.sorted <- rev(sort(pagerank$vector))
pagerank.sorted[1:10]
