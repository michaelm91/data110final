require(dplyr)
nfl_seasons <- 2009:2018
base_dir <- "C:/Users/Mike/Documents/Programming/R/nflscrapR-data/games_data/regular_season"
games_df <- data.frame()
for (ss in nfl_seasons) {
  games_df <- games_df %>%
    bind_rows(
      readr::read_csv(paste0(base_dir, "/reg_games_", ss, ".csv"))
    )
}
games_df <- games_df %>% select(game_id,home_team,away_team,week,season,home_score,away_score) %>%
  mutate_if(is.numeric, as.integer) %>%
  rename(home_score_final = home_score, away_score_final = away_score) %>%
  mutate(winner = c(away_team,"TIE",home_team)[1+findInterval(home_score_final - away_score_final,c(-.5,.5))])
feather::write_feather(games_df, "C:/datasets/NFL/NFLreg_games.feather")
readr::write_csv(games_df, "C:/datasets/NFL/NFLreg_games.csv")
saveRDS(games_df, "C:/datasets/NFL/NFLreg_games.rds")