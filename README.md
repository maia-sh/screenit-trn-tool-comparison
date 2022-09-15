
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ScreenIT TRN Tool Comparison

This repository compares for two tools for identifying trial
registration number (TRN). Both tools use regular expressions to check
for TRNs in text. This analysis builds part of a tool comparison project
for the [ScreenIT](https://scicrunch.org/ASWG) collaboration.

## [TRNscreener](https://github.com/bgcarlisle/TRNscreener)

`TRNscreener` was originally developed by [Benjamin Gregory
Carlisle](https://github.com/bgcarlisle/) with later additions by [Maia
Salholz–Hillel](https://github.com/maia-sh). The original version of the
tool checked for registrations in ClinicalTrials.gov and the German
Clinical Trials Register (DRKS). Additionally, it checks whether TRNs in
ClinicalTrials.gov resolve. The later addition added an additional 19
clinical trial registries to include all [WHO ICTRP Primary
Registries](https://www.who.int/clinical-trials-registry-platform/network/primary-registries)
and [PubMed Registry Databank
Sources](https://www.nlm.nih.gov/bsd/medline_databank_source.html).
Carlisle (2020) used an earlier version of the tool, built in Python and
hosted on
[codeberg.org](https://codeberg.org/bgcarlisle/Pubmed-NCT-extractor), to
evaluate whether ClinicalTrials.gov identifiers found in abstracts of
PubMed-indexed papers resolved to a valid trial registration.
`TRNscreener` is currently used within the [ScreenIT
pipeline](https://github.com/PeterEckmann1/aswg-pipeline).

### Usage

The tool consists of a single script that provides a R function to check
for TRNs. The function reads in text files from a specified folder and
iteratively writes a csv of detected TRNs.

1.  Source the script from the URL:
    `source("https://raw.githubusercontent.com/bgcarlisle/TRNscreener/main/trial_identifier_search.R")`
2.  Run `run_trial_identifier_search(folder, save_file)` where `folder`
    is the folder of text files and `save_file` is the output csv.

## [TRNscreener ScreenIT pipeline](https://github.com/PeterEckmann1/aswg-pipeline/blob/master/utils/trial-identifier/identifier.R)

Upon further evaluation, I realized that the ScreenIT pipeline actually
uses an older version of the TRNscreener, which was manually
copied-and-pasted into the pipeline. The version includes only
ClinicalTrials.gov and ISRCTN, as well as checking whether TRNs in
ClinicalTrials.gov resolve.

### Usage

The tool consists of a single script that provides a R function to check
for TRNs. The function reads in text files from a specified folder and
iteratively writes a csv of detected TRNs.

1.  Source the script from the URL:
    `source("https://raw.githubusercontent.com/PeterEckmann1/aswg-pipeline/master/utils/trial-identifier/identifier.R")`
2.  Run `run_trial_identifier_search(folder, save_file)` where `folder`
    is the folder of text files and `save_file` is the output csv.

## [ctregistries](https://github.com/maia-sh/ctregistries)

`ctregistries` was developed by [Maia
Salholz–Hillel](https://github.com/maia-sh). It includes regular
expressions for all 21 [WHO ICTRP Primary
Registries](https://www.who.int/clinical-trials-registry-platform/network/primary-registries)
and [PubMed Registry Databank
Sources](https://www.nlm.nih.gov/bsd/medline_databank_source.html);
these were subsequently merged into TRNscreener. Salholz-Hillel, Strech,
and Carlisle (2022) uses `ctregistries` to identify TRNs in the PubMed
metadata, PubMed abstract, and full–text of a cohort of clinical trial
results publications. This tool is in active development and
modifications were made following evaluation of this dataset; to
evaluate tool performance blind to this dataset, we use the package
version at [commit
06c169c](https://github.com/maia-sh/ctregistries/commit/06c169cfa241ef8feda9e8b78f57b3012c85afd8).

### Usage

The tool is organized as an R package and includes functions for
checking TRNs. The package also includes a [csv with all TRN regular
expressions](https://github.com/maia-sh/ctregistries/blob/master/inst/extdata/registries.csv)
which can be copied and used elsewhere.

1.  Install package

``` r
install.packages("remotes")
remotes::install_github("maia-sh/ctregistries")
library(ctregistries)
```

2.  Use functions, such as `which_trn()` to identify TRNs

Documentation about each function can be found by viewing the help page
of each function in R by running `?<function_name>`, such as
`?which_trn`.

## Differences between the tools

Since the regular expressions in ctregistries were integrated into
TRNscreener, the output of these tools is comparable, aside from
TRNscreener checks for whether ClinicalTrials.gov TRNs resolve.

These tools differ notably in their implementation. TRNscreener was
built as a simple, single purpose tool that takes folder of text files
and generates a csv of TRNs in a single function. ctregistries was built
as an extensible and multipurpose package and the functions are more
modularized and are intended to be used within a multi-step script, such
as in `extract-trns.R`. `ctregistries` also includes additional
functions such as “cleaning” TRNs to the correct format, since the
regular expressions allow for the detection of slightly incorrectly
formatted TRNs.

## Method

The
[dataset](https://drive.google.com/file/d/1wk45m_tYXaQYxrhtBOFxX8N8EoEy4S5V/view)
of 1,500 papers from PubMedCentral’s Non-Commercial Open Access Subset
was downloaded and unzipped into the `data` folder. Aside from saving
and unzipping, no additional manipulation (e.g., renaming) was done. The
dataset includes full-text as well as methods only versions; all
analyses were run on the full-text versions.

## Output

csv with one row per pmcid, text extract of trns (separated within a
cell), and boolean

## Reflections/Discussion

This approach has some known limitations. Regular expressions are able
to detect the presence of a pattern, but unlike more complex machine
learning strategies, they do not account for the context beyond the
expression itself. We therefore expect all TRNs to be detected,
regardless of whether they are for the reported study or presented as
background. For example:

-   PMC8006606: “UMIN:000000562”
    -   This TRN refers to a related trial: “The CHART‐2 study is a
        prospective, multicentre, observational cohort study for HF in
        Japan, and the details have been described previously
        (UMIN:000000562, NCT00418041).”

Furthermore, false positives are more likely to be detected for short
TRNs, such as the Netherlands Trial Registry whose ids are “NTR”
followed by either 2 or 3 digits. This may occur in strings such as
chemical names or text-transformed tabular data. For example:

-   PMC8367657: “NL63”
    -   This false positive was detected within a
        word-boundary-separated chemical name: “human coronavirus
        species, four of them (hCoV-29E, hCoV-OC43, hCoV-NL63,
        hCoV-HKU1”)
-   PMC8390327: “NL 111”
    -   This false positive was detected within text-transformed tabular
        data: “−16.44 −65 18 6 NL 111,900 14 1 1”

As `ctregistries` is an actively developed package, additional
modifications to the underlying regular expressions were done after
these tests. This removed certain false positives. For a fair evaluation
of the tool, an earlier version ([commit
06c169c](https://github.com/maia-sh/ctregistries/commit/06c169cfa241ef8feda9e8b78f57b3012c85afd8))
is used. However, subsequent modifications removed the false positives
such as:

-   PMC8367657: “C000003927”
    -   This false positive was detected within a word, “ZINC000052955”.
        The regex was modified to require a preceding word boundary.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-carlisle2020m" class="csl-entry">

Carlisle, Benjamin Gregory. 2020. “Non-Existent ClinicalTrials.gov
Identifiers in Abstracts Indexed by PubMed.” *medRxiv*, February,
2020.02.24.20027300. <https://doi.org/10.1101/2020.02.24.20027300>.

</div>

<div id="ref-salholzhillel2022ct" class="csl-entry">

Salholz-Hillel, Maia, Daniel Strech, and Benjamin Gregory Carlisle.
2022. “Results Publications Are Inadequately Linked to Trial
Registrations: An Automated Pipeline and Evaluation of German University
Medical Centers.” *Clinical Trials*, April, 17407745221087456.
<https://doi.org/10.1177/17407745221087456>.

</div>

</div>
