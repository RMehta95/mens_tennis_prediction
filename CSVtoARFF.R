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
dataset$tourney_name <- as.factor(dataset$tourney_name)
dataset$tourney_name[which(dataset$tourney_name=="Us Open")] <- "US Open"
dataset$surface <- as.factor(dataset$surface)
dataset$draw_size <- as.factor(dataset$draw_size)
dataset$tourney_level <- as.factor(dataset$tourney_level)
dataset$tourney_date <- as.Date(dataset$tourney_date, "%Y%m%d")
dataset$match_num <- NULL
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


# Write the new files
write.csv(x=dataset, file="dataset_modified_V2.csv")
write.arff(x=dataset[1:18267,], file="train.arff")
write.arff(x=dataset[18268:18500,], file="test.arff") # Use years 2015 & 2016 for testing