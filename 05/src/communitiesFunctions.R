
computeSummaryTable <- function(g){
    table <- data.table("N" = numeric(),
                        "E" = numeric(),
                        "k" = numeric(),
                        "delta" = numeric(),
                        "diameter" = numeric(),
                        "transitivy" = numeric(),
                        stringsAsFactors = FALSE)
    E = length(E(g))
    N = length(V(g))
    k = 2*E/N
    delta = 2*E/(N * (N-1))
    diameter = diameter(g, directed = FALSE, unconnected = TRUE, weights = NULL)
    transitivity = transitivity(g)
    
    table <- rbind(table, list(N, E, round(k, 2), round(delta, 2), diameter, round(transitivity,2)))
    return(table)
}

computeDiffCommunities <- function(graph, communitiesNames) {
    
    times = list()
    startTime = as.numeric(Sys.time())
    
    fastgreedy = fastgreedy.community(graph)
    times = append(times, as.numeric(Sys.time()) - startTime )
    startTime = as.numeric(Sys.time())
    
    labelProp = label.propagation.community(graph)
    times = append(times, as.numeric(Sys.time()) - startTime )
    startTime = as.numeric(Sys.time())
    
    multilevel = multilevel.community(graph)
    times = append(times, as.numeric(Sys.time()) - startTime )
    startTime = as.numeric(Sys.time())
    
    walktrap = walktrap.community(graph)
    times = append(times, as.numeric(Sys.time()) - startTime )
    startTime = as.numeric(Sys.time())
    
    infomap = infomap.community(graph)
    times = append(times, as.numeric(Sys.time()) - startTime )
    times = round(as.numeric(times), 5)
    df = data.table("Method" = communitiesNames,
                    "Elapsed time" = times,
                    stringsAsFactors = FALSE)
    
    communitiesList = list(fastgreedy, labelProp, multilevel, walktrap, infomap)
    
    return(list(df, communitiesList))
}



computeTableForGraph <- function(graph){
    
    results = computeDiffCommunities(graph, communitiesNames)
    resTable = results[1][[1]] # Dealing with the list messing up w/ the structure
    
    metricsTPT = c()
    metricsExpansion = c()
    metricsConduct = c()
    metricsModularity = c()
    nrSubCommsFound = c()
    
    for(i in seq(length(communitiesNames))){
        
        c <- results[2][[1]][[i]] # Dealing with the list messing up w/ the structure
        
        metrics <- computeMetrics(graph, c)
        metricsTPT = append(metricsTPT, metrics[1])
        metricsExpansion = append(metricsExpansion, metrics[4])
        metricsConduct = append(metricsConduct, metrics[3])
        metricsModularity = append(metricsModularity, metrics[2])
        nrSubCommsFound = append(nrSubCommsFound, metrics[5])
    }
    
    resTable = cbind(resTable, "# C" = nrSubCommsFound)
    resTable = cbind(resTable, "TPT" = round(metricsTPT, 4))
    resTable = cbind(resTable, "Expansion" = round(metricsExpansion, 4))
    resTable = cbind(resTable, "Conduct" = round(metricsConduct, 4))
    resTable = cbind(resTable, "Modularity" = round(metricsModularity, 4))
    return (resTable)
}

communitiesNames = c("fastgreedy",
                     "label",
                     "multilevel",
                     "walktrap",
                     "infomap")





computeMetrics <- function(graph, communityMethod){
    m <- length(E(graph))
    n <- length(V(graph))
    
    numSubComm <- max(communityMethod$membership)
    verticesMembership <- communityMethod$membership
    verticesPos <- seq(n)
    degrees <- degree(graph)
    
    
    triangles = c()
    conductances <- c()
    expansions <- c()
    
    for(subGIdx in seq(numSubComm)){
        # Take the vertices on that subcommunity
        vOfSubComm <- verticesPos[verticesMembership == subGIdx]
        # Create subgraph of subcommunity subGIdx
        subG = induced_subgraph(graph, vids = vOfSubComm)
        mc <- length(E(subG))
        nc <- length(V(subG))
        
        #TRIANGLES
        alltriad = count_triangles(subG)
        tri = length(alltriad[alltriad > 0]) # count vertices that belong to triangles
        tpt = tri / nc
        weightedTPT = tpt * (nc/n)
        triangles = append(triangles, weightedTPT) 
        
        #EXPANSION
        # Number of edges outside the graph
        subdegree <- degree(subG)
        subsetOrgDegrees <- degrees[verticesMembership == subGIdx]
        difdegree <- subsetOrgDegrees - subdegree
        fc <- sum(difdegree)
        expansion <- fc/nc
        weightedExpansion <- expansion * (nc/n)
        expansions <- append(expansions, weightedExpansion)
        
        
        #CONDUCTANCE
        conductance <- fc/(fc + 2*(mc))
        weightedConductance <- conductance*(nc/n)
        conductances <- append(conductances, weightedConductance)
    }
    
    res <- c(sum(triangles), modularity(communityMethod), sum(conductances), sum(expansions), numSubComm)
    return(res)
}



computeCommunitySpecifications <- function(graph, communityMethod){
    
    n <- length(V(graph))
    
    numSubComm <- max(communityMethod$membership)
    verticesMembership <- communityMethod$membership
    verticesPos <- seq(n)
    
    numSubComSeq <- seq(numSubComm)
    ns = c()
    ms = c()
    ks = c()
    deltas = c()
    ds = c()

    for(subGIdx in seq(numSubComm)){
        # Take the vertices on that subcommunity
        vOfSubComm <- verticesPos[verticesMembership == subGIdx]
        # Create subgraph of subcommunity subGIdx
        subG = induced_subgraph(graph, vids = vOfSubComm)
        mc <- length(E(subG))
        nc <- length(V(subG))
    
        k = 2*mc/nc
        delta = 2*mc/(nc * (nc-1))
        diameter = diameter(subG, directed = FALSE, unconnected = TRUE, weights = NULL)
        
        # Appends...
        ns = append(ns, nc)
        ms = append(ms, mc)
        ks = append(ks, k)
        deltas = append(deltas, delta)
        ds = append(ds, diameter)
    }
    
    res <- data.frame(Comm = numSubComSeq, N = ns, E = ms, K = ks, delta = deltas, diameter = ds)
    return(res)
}



plotGraphSetOfCommunities <- function(communities, graph, vecToShow) {
  
  #par(mfrow=c(1,2))
  
  verticesMembership <- communities$membership
  verticesPos <- seq(length(communities$membership))
  
  for(subGIdx in vecToShow){
    # Take the vertices on that subcommunity
    vOfSubComm <- verticesPos[verticesMembership == subGIdx]
    # Create subgraph of subcommunity subGIdx
    subG = induced_subgraph(graph, vids = vOfSubComm)
    plot(subG, main=paste("Plot of community", subGIdx), layout=layout.auto,vertex.size=23,
         vertex.label.color="darkblue",vertex.shape = "sphere",
         vertex.label.font=2,vertex.color=vertex_attr(subG,"chosenBy") ,edge.color="black")
    box(which="plot")
  }
  
}


vocabPrunerCount <- function(lyrics.itoken, thresholds) {
  
    numTerms = c()
    for(t in thresholds){
        vocab = create_vocabulary(lyrics.itoken)
        vocab = prune_vocabulary(vocab, term_count_min = 5, doc_proportion_min = t)
        numTerms = append(numTerms, length(vocab$term))
    }
  
  return(data.frame(thresholds, numTerms))
}

