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

# Cleaning up data and converting everything to the write type
dataset = dataset[-c(18522:1048575),]
dataset = read.csv("./dataset_modified.csv",header=TRUE, stringsAsFactors=FALSE)
sapply(dataset, function(x) sum(x=="")) # find number of empty string attributes
sapply(dataset, function(x) sum(is.na(x))) # find number of NA attributes

sapply(dataset,class) # find class of each column

dataset <- dataset[-c(14203),]
dataset$X <- NULL
dataset$tourney_name[which(dataset$tourney_name=="Us Open")] <- "US Open"
dataset$tourney_name <- as.factor(dataset$tourney_name)
dataset$surface <- as.factor(dataset$surface)
dataset$draw_size <- as.factor(dataset$draw_size)
dataset$tourney_level <- as.factor(dataset$tourney_level)
dataset$tourney_date <- as.Date(dataset$tourney_date, "%Y%m%d")
dataset$P1_id <- as.factor(dataset$P1_id)
dataset$P2_id <- as.factor(dataset$P2_id)
dataset$P1_name <- as.factor(dataset$P1_name)
dataset$P2_name <- as.factor(dataset$P2_name)
dataset$P1_hand <- as.factor(dataset$P1_hand)
dataset$P2_hand <- as.factor(dataset$P2_hand)

# Dealing with empty values in height
dataset$P1_ht <- as.numeric(dataset$P1_ht)
dataset$P2_ht <- as.numeric(dataset$P2_ht)
avgHeight <- round(mean(dataset$P1_ht, na.rm=TRUE))
dataset$P1_ht[is.na(dataset$P1_ht)] <- avgHeight
dataset$P2_ht[is.na(dataset$P2_ht)] <- avgHeight


dataset$P1_ioc <- as.factor(dataset$P1_ioc)
dataset$P2_ioc <- as.factor(dataset$P2_ioc)

dataset$P1_age <- as.numeric(dataset$P1_age)
dataset$P2_age <- as.numeric(dataset$P2_age)

dataset$P1_rank <- as.integer(dataset$P1_rank)
dataset$P2_rank <- as.integer(dataset$P2_rank)
dataset$P1_rank_points <- as.integer(dataset$P1_rank_points)
dataset$P2_rank_points <- as.integer(dataset$P2_rank_points)
dataset$best_of <- as.factor(dataset$best_of)
dataset$p1wins <- as.factor(dataset$p1wins)

dataset <- dataset[-which(is.na(dataset$P1_rank)),]
dataset <- dataset[-which(is.na(dataset$P2_rank)),]

dataset$p1vp2winpercentage <- 0.50
dataset <- dataset[,c(1:22,24,23)]

# H2H win percentage calculation (only on previous data)
alldata = read.csv("./data/tennis_ATP/atp_consolidated.csv",header=TRUE, stringsAsFactors=FALSE)
alldata$tourney_date <- as.Date(alldata$tourney_date, "%Y%m%d")

for (i in 1:nrow(dataset)) {
  numP1wins <- 0
  numP1losses <- 0
  numP1wins <- sum(alldata$winner_id == dataset[i,"P1_id"] & alldata$loser_id == dataset[i,"P2_id"] & alldata$tourney_date < dataset[i,"tourney_date"])
  numP1losses <- sum(alldata$loser_id == dataset[i,"P1_id"] & alldata$winner_id == dataset[i,"P2_id"] & alldata$tourney_date < dataset[i,"tourney_date"])
  if (numP1wins + numP1losses > 0) {
    dataset[i, "p1vp2winpercentage"] <- numP1wins/(numP1wins+numP1losses)
  }
}

playerNames <- union(unique(dataset$P1_id), unique(dataset$P2_id))
dataset[playerNames] <- 0
for (i in 1:nrow(dataset)) {
  dataset[i,toString(dataset[i,"P1_id"])] <- 1
  dataset[i,toString(dataset[i,"P2_id"])] <- -1
}

dataset[playerNames] <- lapply(dataset[playerNames], factor)

# Creating log of ranking & ranking points differentials
dataset$p1vp2LogRankDiff <- NA
dataset$p1vp2LogRankPointsDiff <- NA

for (i in 1:nrow(dataset)) {
  dataset[i,"p1vp2LogRankDiff"] <- log(dataset[i,"P2_rank"]) - log(dataset[i,"P1_rank"]) # flipped order to keep it positive
  dataset[i,"p1vp2LogRankPointsDiff"] <- log(dataset[i,"P1_rank_points"]) - log(dataset[i,"P2_rank_points"])
}

dataset$p1vp2LogRankDiff <- as.numeric(dataset$p1vp2LogRankDiff)
dataset$p1vp2LogRankPointsDiff <- as.numeric(dataset$p1vp2LogRankPointsDiff)

dataset2 <- dataset[ ,-which(names(dataset) %in% playerNames)]
dataset2 <- dataset2[,c(1:23,25,26,24)]

# Write the new files
write.csv(x=dataset2, file="dataset_modified_V5.csv")
write.arff(x=dataset2[1:18267,], file="train_with_rank_points.arff")
write.arff(x=dataset2[18268:18500,], file="test_with_rank_points.arff") # Use years 2015 & 2016 for testing