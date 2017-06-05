#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 16 12:55:28 2017

@author: alexmerryman
"""

import pandas as pd
import numpy as np
import os

matches_data = pd.read_csv('dataset_modified_V2.csv')

cwd = os.getcwd()
ATP_data_dir = cwd + '/data/tennis_ATP'
os.chdir(ATP_data_dir)
#print os.listdir(ATP_data_dir)

atp_players = pd.read_csv('atp_players.csv', names=['player_id', 'last_name',
                                                    'first_name', 'hand',
                                                    'DOB', 'country'])


def H2H(player1ID, player2ID, matches_df):
    p1_vs_p2 = matches_df[((matches_df['P1_id'] == player1ID) & (matches_df['P2_id'] == player2ID))]
    p2_vs_p1 = matches_df[(matches_df['P1_id'] == player2ID) & (matches_df['P2_id'] == player1ID)]

    h2h_matches = pd.concat([p1_vs_p2, p2_vs_p1])

    if h2h_matches.shape[0] <= 10:
        print h2h_matches[['tourney_date', 'P1_id', 'P2_id', 'p1wins']]

    p1wins = (h2h_matches[(h2h_matches['P1_id'] == player1ID) & (h2h_matches['p1wins'] == 'Y')]).shape[0]
    p1lose = (h2h_matches[(h2h_matches['P1_id'] == player1ID) & (h2h_matches['p1wins'] == 'N')]).shape[0]

    p2wins = (h2h_matches[(h2h_matches['P1_id'] == player2ID) & (h2h_matches['p1wins'] == 'Y')]).shape[0]
    p2lose = (h2h_matches[(h2h_matches['P1_id'] == player2ID) & (h2h_matches['p1wins'] == 'N')]).shape[0]

    p1wins = p1wins + p2lose
    p2wins= p2wins + p1lose

    total_matches = h2h_matches.shape[0]

    if (p1wins + p2wins) != total_matches:
        p1wins = 'error'
        p2wins = 'error'

    return p1wins, p2wins, total_matches


print '-------- Nadal vs. Federer --------'
nadal_win, fed_win, num_matches = H2H(104745, 103819, matches_data)
print 'Federer wins:', fed_win, '({}%)'.format(100*float(fed_win)/float(num_matches))
print 'Nadal wins:', nadal_win, '({}%)'.format(100*float(nadal_win)/float(num_matches))
print ''

print '-------- Evans vs. Federer --------'
evans_win, fed_win, num_matches = H2H(105554, 103819, matches_data)
print 'Federer wins:', fed_win, '({}%)'.format(100*float(fed_win)/float(num_matches))
print 'Evans wins:', evans_win, '({}%)'.format(100*float(evans_win)/float(num_matches))


def number_of_games(playerID, matches_df):
    '''
    Calculates the total number of games a given player has competed in.
    '''
    wins = pd.DataFrame(matches_df['winner_id'] == playerID)
    losses = pd.DataFrame(matches_df['loser_id'] == playerID)
    total_matches = (wins.size + losses.size)
    return total_matches


#top_100_players =


H2H_df = pd.DataFrame(columns=['Player1', 'Player1Wins',
                               'Player2', 'Player2Wins', 'TotalGames'])

#print atp_players.head
#print atp_players[1:10]

#for i in atp_players['player_id']:
#    player1entries = []
#    for j in atp_players['player_id']:
#        if i == j:
#            entry = ('NA', 'NA', 'NA', 'NA', 'NA')
#        else:
#            p1wins, p2wins, total_matches = H2H(i, j)
#            entry = (i, p1wins, j, p2wins, total_matches)
#            player1entries.append(entry)
#
#print player1entries
#
# |---------|-------------|---------|-------------|------------|
# | Player1 | Player1Wins | Player2 | Player2Wins | TotalGames |
# |=========|=============|=========|=============|============|
# |  Nadal  |      12     | Federer |      23     |     35     |
# |---------|-------------|---------|-------------|------------|
# |  Nadal  |      8      | Murray  |      8      |-----x+y----|
