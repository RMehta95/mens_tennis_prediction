french_output = read.csv("./OutputFrenchOpen2016.csv",header=TRUE, stringsAsFactors=FALSE)
betting_odds_french = read.csv("./BettingOddsFrenchOpen2016.csv", header=TRUE, stringsAsFactors=FALSE)
betting_odds_french <- betting_odds_french[1:127,]

french_output$AvgW <- 0
french_output$AvgL <- 0
french_output$winnings <- 0

for (i in 1:nrow(betting_odds_french)) {
  winner <- sub(" .*", "", betting_odds_french[i,"Winner"])
  if (winner == "Ramos-Vinolas") winner = "Ramos"
  if (loser == "Ramos-Vinolas") loser = "Ramos"
  loser <- sub(" .*", "", betting_odds_french[i,"Loser"])
  index1 <- which(grepl(winner, french_output$P1_name) & grepl(loser, french_output$P2_name))
  index2 <- which(grepl(winner, french_output$P2_name) & grepl(loser, french_output$P1_name))
  if (length(index1) > 0) { # winner matches P1
    french_output[index1, "AvgW"] <- betting_odds_french[i,"AvgW"]
    french_output[index1, "AvgL"] <- betting_odds_french[i,"AvgL"]
    if (french_output[index1, "actual"] == french_output[index1, "predicted"]) { # prediction is correct
      french_output[index1, "winnings"] <- french_output[index1, "AvgW"] # p1 won and p1 is the winner, so pay out avgW
    }
  } 
  else if (length(index2) > 0) { # winner matches P2
    french_output[index2, "AvgW"] <- betting_odds_french[i,"AvgW"]
    french_output[index2, "AvgL"] <- betting_odds_french[i,"AvgL"]
    if (french_output[index2, "actual"] == french_output[index2, "predicted"]) { # prediction is correct
        french_output[index2, "winnings"] <- french_output[index2, "AvgW"] # p2 won and p2 is the winner, so pay out avgL
    }
  }
}

total_winnings <- sum(french_output$winnings)
total_profit <- total_winnings - nrow(french_output)
ROI <- total_profit/nrow(french_output)

write.csv(x=french_output, file="FrenchOpen2016_CalculatedWinnings.csv")

