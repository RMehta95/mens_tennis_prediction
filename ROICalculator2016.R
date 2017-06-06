all_output = read.csv("./test_with_rank_points_and_prediction_all.csv",header=TRUE, stringsAsFactors=FALSE)
betting_odds = read.csv("./BettingOdds2016.csv", header=TRUE, stringsAsFactors=FALSE)
all_output <- all_output[order(as.Date(all_output$tourney_date, format="%Y%m%d")),]
grand_slam_betting <- betting_odds[betting_odds$Series == "Grand Slam",]
grand_slam_output <- all_output[1073:2145,]
grand_slam_output <- grand_slam_output[grand_slam_output$tourney_level == "G",]
grand_slam_output$tourney_name[grand_slam_output$tourney_name == "Roland Garros"] <- "French Open"

grand_slam_output$AvgW <- NA
grand_slam_output$AvgL <- NA
grand_slam_output$winnings <- NA

for (i in 1:nrow(grand_slam_betting)) {
  winner <- sub(" .*", "", grand_slam_betting[i,"Winner"])
  winner <- sub("-", " ", winner)

  loser <- sub(" .*", "", grand_slam_betting[i,"Loser"])
  loser <- sub("-", " ", loser)

  if (winner == "Ramos Vinolas") {
    winner = "Ramos"
  }
  if (loser == "Ramos Vinolas") {
    loser = "Ramos"
  }

  index1 <- which(grepl(winner, grand_slam_output$P1_name) & grepl(loser, grand_slam_output$P2_name) & grand_slam_betting$Tournament[i]==grand_slam_output$tourney_name)
  index2 <- which(grepl(winner, grand_slam_output$P2_name) & grepl(loser, grand_slam_output$P1_name) & grand_slam_betting$Tournament[i]==grand_slam_output$tourney_name)
  if (length(index1) > 0) { # winner matches P1
    grand_slam_output[index1, "AvgW"] <- grand_slam_betting[i,"AvgW"]
    grand_slam_output[index1, "AvgL"] <- grand_slam_betting[i,"AvgL"]
    if (grand_slam_output[index1, "actual"] == grand_slam_output[index1, "predicted"]) { # prediction is correct
      grand_slam_output[index1, "winnings"] <- grand_slam_output[index1, "AvgW"] # p1 won and p1 is the winner, so pay out avgW
    }
    else {
      grand_slam_output[index1, "winnings"] <- 0
    }
  } 
  else if (length(index2) > 0) { # winner matches P2
    grand_slam_output[index2, "AvgW"] <- grand_slam_betting[i,"AvgW"]
    grand_slam_output[index2, "AvgL"] <- grand_slam_betting[i,"AvgL"]
    if (grand_slam_output[index2, "actual"] == grand_slam_output[index2, "predicted"]) { # prediction is correct
        grand_slam_output[index2, "winnings"] <- grand_slam_output[index2, "AvgW"] # p2 won and p2 is the winner, so pay out avgL
    }
    else {
      grand_slam_output[index2, "winnings"] <- 0
    }
  }
}

total_winnings <- sum(grand_slam_output$winnings)
total_profit <- total_winnings - nrow(grand_slam_output)
ROI <- total_profit/nrow(grand_slam_output)

write.csv(x=grand_slam_output, file="ATP2016_CalculatedWinnings.csv")

