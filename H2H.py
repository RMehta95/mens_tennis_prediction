#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 16 12:55:28 2017

@author: alexmerryman
"""

import pandas as pd
import numpy as np

atp_players = pd.read_csv('atp_players.csv')

matches_2000 = pd.read_csv('atp_matches_2000.csv')
matches_2001 = pd.read_csv('atp_matches_2001.csv')
matches_2002 = pd.read_csv('atp_matches_2002.csv')
matches_2003 = pd.read_csv('atp_matches_2003.csv')
matches_2004 = pd.read_csv('atp_matches_2004.csv')
matches_2005 = pd.read_csv('atp_matches_2005.csv')
matches_2006 = pd.read_csv('atp_matches_2006.csv')
matches_2007 = pd.read_csv('atp_matches_2007.csv')
matches_2008 = pd.read_csv('atp_matches_2008.csv')
matches_2009 = pd.read_csv('atp_matches_2009.csv')
matches_2010 = pd.read_csv('atp_matches_2010.csv')
matches_2011 = pd.read_csv('atp_matches_2011.csv')
matches_2012 = pd.read_csv('atp_matches_2012.csv')
matches_2013 = pd.read_csv('atp_matches_2013.csv')
matches_2014 = pd.read_csv('atp_matches_2014.csv')
matches_2015 = pd.read_csv('atp_matches_2015.csv')
matches_2016 = pd.read_csv('atp_matches_2016.csv')
matches_2017 = pd.read_csv('atp_matches_2017.csv')

matches09_10 = pd.concat([matches_2009, matches_2010])

matches00_17 = pd.concat([matches_2000, matches_2001, matches_2002,
                          matches_2003, matches_2004, matches_2005,
                          matches_2006, matches_2007, matches_2008,
                          matches_2009, matches_2010, matches_2011,
                          matches_2012, matches_2013, matches_2014,
                          matches_2015, matches_2016, matches_2017])


class H2H:
    def __init__(self, player1ID, player2ID):
        self.player1ID = player1ID
        self.player2ID = player2ID

    def player_record(self, matches_df):
        p1winner = matches_df['winner_id'] == self.player1ID
        p1loser = matches_df['loser_id'] == self.player1ID

        p2winner = matches_df['winner_id'] == self.player2ID
        p2loser = matches_df['loser_id'] == self.player2ID

        p1win_p2lose = matches_df[p1winner & p2loser]
        p1wins = p1win_p2lose.shape[0]

        p1lose_p2win = matches_df[p1loser & p2winner]
        p2wins = p1lose_p2win.shape[0]

        H2H_df = pd.concat([p1win_p2lose, p1lose_p2win])
        total_matches = H2H_df.shape[0]

#        p1record = float(p1wins) / float(total_matches)
#        p2record = float(p2wins) / float(total_matches)

        return p1wins, p2wins, total_matches

nadal_vs_federer = H2H(104745, 103819)

print nadal_vs_federer.player_record(matches00_17)
