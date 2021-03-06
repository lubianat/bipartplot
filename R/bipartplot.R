# this code is a function to plot a bipartite plot from an edgelist
library(igraph)
library(ggnetwork)
#' bipartplot
#'
#' Takes an edge list (from a bipartite network)
#' And plots a railway bipartite plot
#' using ggplot2
#'
#' @param edgelist The edgelist corresponding to the bipartite network
#' @param return_ggplot Flag to return a ggplot2 object instead of plotting
#' @import ggnetwork
#' @import igraph
#' @import network
#' @import ggplot2
#' @export

bipartplot <- function(edgelist){
r <- edgelist[,1]
l <- edgelist[,2]
g <- igraph::graph_from_edgelist(edgelist)

adj <- as.matrix(get.adjacency(g))
adj <- adj[rowSums(adj[,-1]) != 0,]
adj <- adj[,colSums(adj) != 0]
adj
g <- graph.incidence(adj, weighted = T)

V(g)$type
# Get layout from igraph
lb <-as.data.frame(layout_as_bipartite(g))

# see simple igraph layout
plotcord <- data.frame(layout_as_bipartite(g))
colnames(plotcord) = c("X1","X2")
rownames(plotcord) = c(rownames(adj), colnames(adj))

#get edges, which are pairs of node IDs
edgelist <- get.edgelist(g)

#convert to a four column edge data frame with source and destination coordinates
edges <- data.frame(plotcord[edgelist[,1],], plotcord[edgelist[,2],])
colnames(edges) <- c("X1","Y1","X2","Y2")
plotcord$label = rownames(plotcord)

n <- network(edgelist)
bla <- ggnetwork(n)

# add coordinates to ggnetwork generated data frame
bla[is.na(bla$na.y),]$x <- plotcord$X1
bla[is.na(bla$na.y),]$xend <- plotcord$X1
bla[is.na(bla$na.y),]$y <- plotcord$X2
bla[is.na(bla$na.y),]$yend <- plotcord$X2

bla[!is.na(bla$na.y),]$x <- edges$X1
bla[!is.na(bla$na.y),]$xend <- edges$X2
bla[!is.na(bla$na.y),]$y <- edges$Y1
bla[!is.na(bla$na.y),]$yend <- edges$Y2

#assign family coloes
n <-bla
n$family <- ifelse(n$y==1, 'blue', 'red')

#get the right positions for the names
node_names <- c(unique(r), unique(l))

n$vertex.names[1:length(node_names)] <- node_names

ggplot(n, aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(color = "black") +
  geom_nodes(aes(color=family), size = 8) +
  geom_nodetext(aes(label = vertex.names), data = n[1:15,]) +
  theme_blank()
}
