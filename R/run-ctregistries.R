# Run ctregistries tool

# Install remotes if not instelled
# install.packages("remotes")

# As modifications to the tools were added after seeing the data, we generate both a blind and updated version

# Manually specify whether to use "blind" or "updated" package
ctregistries_version <- "blind"
ctregistries_version <- "updated"

# Install and load corresponding package version
ctregistries_ref <- switch(
  ctregistries_version,
  blind = "06c169cfa241ef8feda9e8b78f57b3012c85afd8",
  updated = "HEAD"
)

remotes::install_github("maia-sh/ctregistries", ref = ctregistries_ref)
library(ctregistries)

# Prepare filepaths
filename <- here::here("data", paste0("ctregistries", "-", ctregistries_version, ".csv"))
dir_raw <- here::here("data", "raw", "comparison_set_individual_files", "full_texts")
files <- fs::dir_ls(dir_raw)

# For each file, check text for TRNs and add TRN and PMCID to trn_df
# Then add registry
# Note: Since this takes ~3 minutes for 1.5K records, only run if file doesn't already exist
if (!fs::file_exists(filename)) {

  # Initialize empty dataframe
  trn_df <-
    tibble::tibble(
      pmcid = as.character(),
      trn = as.character(),
    )

  start <- Sys.time()
  for (file in files){

    pmcid <-
      file |>
      fs::path_file() |>
      fs::path_ext_remove()

    text <- readr::read_file(file)
    trn <- ctregistries::which_trn(text)

    new_df <-
      tibble::as_tibble_col(trn, column_name = "trn") |>
      dplyr::mutate(pmcid = pmcid, .before = "trn") |>
      tidyr::drop_na(trn)

    trn_df <- dplyr::bind_rows(trn_df, new_df)

  }
  end <- Sys.time()

  end-start

  # Add registry
  trn_df <-
    trn_df |>
    dplyr::mutate(registry = purrr::map_chr(trn, ctregistries::which_registry))

  readr::write_csv(trn_df, filename)
} else {
  trn_df <- readr::read_csv(filename)
}

# If using updated package, also clean TRNs
# The earlier package version produces are error, since only some registries had implemented cleaning

if (ctregistries_version == "updated"){
  trn_df_clean <-
    trn_df |>
    dplyr::mutate(trn_clean = purrr::map_chr(trn, ctregistries::clean_trn))
}
