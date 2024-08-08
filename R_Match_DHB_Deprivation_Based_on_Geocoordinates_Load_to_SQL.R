# load the libraries
packages <- c("readr", "sp", "rgdal", "ggplot2","tidyverse", "readxl", "DBI", "dplyr")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

setwd("xxxxxxxx") # YOUR OWN WORK DIRECTORY !!!
# read the data 
data <- read.csv("xxxxxxxx") # YOUR OWN FILE NAME WHICH NEEDS TO BE JOINED BY GEOCOORDINATES !!!
df <- data %>% filter(lat != 0)


# ------------------ Match DHB --------------------------
file_folder <- "xxxxxxxx" # FOLDER WHERE THE SHAPE FILES ARE LOCATED !!!
dhb <- readOGR(paste0(file_folder, "./statsnzdistrict-health-board-2015-SHP/district-health-board-2015.shp")) # dhb shape file
coordsDf <- data.frame(id = df$id, 
                       Latitude = df$lat,
                       Longitude = df$lng)
coordinates(coordsDf) <- ~ Longitude + Latitude
proj4string(coordsDf) <- proj4string(dhb)
match_dhb <- cbind(coordsDf, over(coordsDf, dhb))
match_dhb_df <- as.data.frame(match_dhb)

# ------------------------ Match Mshblock & Deprivation  ------------------
mb18 <- readOGR(paste0(file_folder, "./MB and SA/meshblock-2018-generalised.shp"))  # meshblock shape file
mb13 <- readOGR(paste0(file_folder, "./MB and SA/meshblock-boundaries-2013.shp")) 

nzdep13 <- read_delim(paste0(file_folder, "/2013_DEP_MESHBLOCK.txt"), delim = "\t") # deprivation & population file
nzdep18 <- read_delim(paste0(file_folder, "/2018_DEP_MESHBLOCK.txt"), delim = "\t")
nzdep18Pop <- read_excel(paste0(file_folder, "./otagoDep2018SA1Pop.xlsx"))

# 2013 Meshblock
proj4string(coordsDf) <- proj4string(mb13)
match_MB13 <- cbind(coordsDf, over(coordsDf, mb13))
match_MB13_df <- as.data.frame(match_MB13) %>%
  left_join(nzdep13, by = c("MB2013_V1_" = 'MB_2013'))


# 2018 Meshblock
proj4string(coordsDf) <- proj4string(mb18)
match_MB18 <- cbind(coordsDf, over(coordsDf, mb18))
match_MB18_df <- as.data.frame(match_MB18) %>%
  left_join(nzdep18 %>%
              mutate(MB2018_code = as.character(MB2018_code)), by = c("MB2018_V1_" = 'MB2018_code')) %>%
  left_join(nzdep18Pop %>% 
              mutate(SA12018_code = as.numeric(SA12018_code)) %>%
              dplyr::select(SA12018_code, URPopnSA1_2018), by= "SA12018_code")

# ------------------------ Combine All Tables -------------------
matchAll <- match_dhb_df %>% 
  dplyr::select(id, DHB2015_Co, DHB2015_Na) %>%  # DHB
  left_join(match_MB13_df %>%
              dplyr::select(id, MB2013_V1_, CAU_2013, NZDep2013, NZDep_score_2013, UR_pop_2013), by = "id") %>% # NZDep2013
  left_join(match_MB18_df %>%
              dplyr::select(id, MB2018_V1_, NZDep2018, NZDep2018_Score, SA12018_code, URPopnSA1_2018), by = "id") # NZDep2018

# ------------------------ Load to SQL -------------------
# generic function to write data to SQL database
# change the database name, table name, column names with the right types accordingly
con <- dbConnect(RSQLite::SQLite(), dbname = "xxxxxxxx") # YOUR OWN DATABASE NAME !!!
dbWriteTable(con, "xxxxxxx", matchAll, overwrite = TRUE) # YOUR OWN TABLE NAME !!!
dbDisconnect(con)

