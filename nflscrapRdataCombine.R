require(dplyr)
nfl_seasons <- 2009:2018
base_dir <- "C:/Users/Mike/Documents/Programming/R/nflscrapR-data/play_by_play_data/regular_season"
full_df <- data.frame()
for (ss in nfl_seasons) {
  full_df <- full_df %>%
    bind_rows(
      readr::read_csv(paste0(base_dir, "/reg_pbp_", ss, ".csv"), guess_max = 75000) %>%
        mutate(season = ss)
    )
}
full_df <- full_df %>%
  rename(
    scoring_play = sp,
    yards_to_go = ydstogo,
    yardline = yrdln,
    quarter = qtr,
    yards_net = ydsnet,
    description = desc
  ) %>%
  mutate(
    time = hms::hms(seconds = lubridate::minute(time), minutes = lubridate::hour(time)),
    quarter = factor(
      c("1st", "2nd", "3rd", "4th", "overtime")[quarter],
      levels = c("1st", "2nd", "3rd", "4th", "overtime")
    ),
    down = factor(
      c("1st", "2nd", "3rd", "4th")[down],
      levels = c("1st", "2nd", "3rd", "4th")
    ),
    game_half = factor(
      c("1st", "2nd", "Overtime")[match(game_half, c("Half1", "Half2", "Overtime"))],
      levels = c("1st", "2nd", "Overtime")
    )
  ) %>%
  mutate_at(
    .vars = c(
      "play_type", "posteam_type",
      "pass_length", "pass_location",
      "run_location", "run_gap",
      "field_goal_result", "two_point_conv_result", "extra_point_result",
      "penalty_type", "replay_or_challenge_result"
    ),
    .funs = factor
  ) %>%
  mutate_if(
    .predicate = function(x) (is.numeric(x) && all(as.integer(x) == x, na.rm = TRUE)),
    .funs = as.integer
  ) %>%
  mutate_if(
    .predicate = function(x) (is.integer(x) && all(x %in% c(0L, 1L, NA_integer_))),
    .funs = as.logical
  )
feather::write_feather(full_df, "C:/datasets/NFL/NFLreg_pbpt.feather")
readr::write_csv(full_df, "C:/datasets/NFL/NFLreg_pbpt.csv")
saveRDS(full_df, "C:/datasets/NFL/NFLreg_pbp.rds")
