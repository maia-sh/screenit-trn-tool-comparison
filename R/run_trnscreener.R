source(here::here("R", "trial_identifier_search.R"))

filename <- here::here("data", "trnscreener.csv")
dir_raw <- here::here("data", "raw", "comparison_set_individual_files", "full_texts")

run_trial_identifier_search(dir_raw, filename)
