# Before running this, set wd to GitHub Repo folder

library("foreign")

# Load data file
dataset = read.csv("./data/tennis_ATP/atp_consolidated_trimmed.csv",header=TRUE, stringsAsFactors=FALSE)
dataset <- dataset[,-c(31:ncol(dataset)-1)]

# Remove attributes
dataset <- dataset[,-c(which(colnames(dataset) == "score"))]
dataset <- dataset[,-c(which(colnames(dataset) == "winner_seed"))]
dataset <- dataset[,-c(which(colnames(dataset) == "winner_entry"))]
dataset <- dataset[,-c(which(colnames(dataset) == "loser_seed"))]
dataset <- dataset[,-c(which(colnames(dataset) == "loser_entry"))]

# Change winners and losers to players
colnames(dataset) <- gsub("winner", "P1", colnames(dataset))
colnames(dataset) <- gsub("loser", "P2", colnames(dataset))

for (i in 1:nrow(dataset)) {
  if (round(runif(1))) {
    P1Attributes <- dataset[i, 8:15]
    P2Attributes <- dataset[i, 16:23]
    dataset[i, 8:15] <- P2Attributes
    dataset[i, 16:23] <- P1Attributes
    dataset[i, "p1wins"] = "N"
  }
}

dataset = dataset[-c(18522:1048575),]
write.csv(x=dataset, file="dataset_modified.csv")
write.arff(x=dataset[1:18267,], file="train.arff")
write.arff(x=dataset[18267:18521,], file="test.arff") # Use years 2015 & 2016 for testing