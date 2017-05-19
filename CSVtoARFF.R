# Before running this, set wd to GitHub Repo folder

library("foreign")

# Load data file
dataset = read.csv("./data/tennis_ATP/atp_consolidated.csv",header=TRUE)
dataset <- dataset[,-c(31:ncol(dataset))]

# Create classifier column
dataset$P1Win <- 1

# Change winners and losers to players
colnames(dataset) <- gsub("winner", "P1", colnames(dataset))
colnames(dataset) <- gsub("loser", "P2", colnames(dataset))

write.arff(x=dataset ,file="train.arff")

