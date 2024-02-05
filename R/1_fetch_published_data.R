library(lubridate)
library(xml2)
library(rvest)
library(stringr)
library(httr)

#download ONS published internal migration data for 2012-onward

save_dir = "data/raw/"

if(!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE)

base_url <- "https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/internalmigrationinenglandandwales/"
link_pattern = "detailedinternalmigrationestimates"

pg <- read_html(base_url)
links <- html_attr(html_nodes(pg, "a"), "href")
data_links <- paste0("https://www.ons.gov.uk/", links[grepl(link_pattern, links)])


if(length(data_links) > 0) {

  fp_destfiles <- file.path(paste0(save_dir, basename(data_links)))

  for(i in 1:length(data_links)){
    message(paste("Writing file: ", fp_destfiles[i]))
    download.file(data_links[i], destfile = fp_destfiles[i], mode = "wb")
  }
}
