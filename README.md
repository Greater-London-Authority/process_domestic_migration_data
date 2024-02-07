
# process_domestic_migration_data

This project contains scripts for downloading detailed
origin-destination domestic migration estimates, published by ONS, and
combining these into a consistent time series in the format required for
use in the GLA’s projection models.

As of November 2023, revised data for 2011-12 onward is published on the
ONS website
[here](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/internalmigrationinenglandandwales/).
The data is published in individual files for each year and the format
is *mostly* consistent between years.

Data for 2001-02 to 2010-11 was unchanged and this project makes use of
previously processed versions of the data that the GLA has published on
the London Datastore
[here](https://data.london.gov.uk/dataset/modelled-population-backseries).

## Usage

**1_fetch_published_data.R** downloads the individual files from the ONS
website and saves them in data/raw/

**2_clean_published_data.R** takes the files saved in data/raw, extracts
the data for the geography selected by the user, processes the data into
the format used in the GLA’s models, and saves the output in
data/intermediate/ as .rds files

**3_create_lad_series_file.R** takes the cleaned individual year files
and combines them into a single file covering 2011-12 onward, which is
saved in data/processed/

**4_combine_with_earlier_series.R** downloads an older version of the
series previously processed and published by the GLA to data/processed/,
combines data from this file for years up to 2010-11 with the latest
series, saves the combined output in data/processed/
