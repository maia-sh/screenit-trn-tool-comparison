try(source("https://raw.githubusercontent.com/PeterEckmann1/aswg-pipeline/master/utils/trial-identifier/identifier.R"))
# NOTE: Expect error on line 192, since folder/file don't exist
# https://github.com/PeterEckmann1/aswg-pipeline/blob/master/utils/trial-identifier/identifier.R#L192

filename <- here::here("data", "trnscreener-screenit.csv")
dir_raw <- here::here("data", "raw", "comparison_set_individual_files", "full_texts/")

run_trial_identifier_search(dir_raw, filename)
