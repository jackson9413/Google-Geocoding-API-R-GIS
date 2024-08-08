# load the packages
# install.packages("pacman")
# pacman::p_load(tidyverse, DBI, odbc)
# Package names
packages <- c("MASS",
              "janitor",
              "reshape2",
              "data.table",
              "httr",
              "jsonlite",
              "foreach",
              "doParallel",
              "rgeos",
              "sp",
              "rgdal",
              "PROJ",
              "stringi",
              "glue",
              "tidyverse",
              "readxl",
              "parallel",
              "tidyr",
              "janitor")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))
setwd("xxxxxx")  # YOUR OWN WORK DIRECTORY !!!

# Define a function to use parallel process with Google API
address_lookup <- function(df, locationCols, googleKey) {
  df$ID <- 1:nrow(df) # create an ID column
  pkgs <- c("httr","jsonlite","stringr", "stringi","glue")
  cores <- detectCores()-1     
  cl <- makeCluster(cores)      # multiple core process setting
  registerDoParallel(cl)
  
  # multiple core process
  ResDF <- foreach(i=1:nrow(df), .packages=pkgs) %dopar% {
    address <- paste(paste(df[i, locationCols][df[i, locationCols] != ""], collapse =", "))
    this <- GET("https://maps.googleapis.com/maps/api/geocode/json",
                query = list(address=address,
                             key=googleKey))
    data = fromJSON(rawToChar(this$content))
    
    # Google geocoding results
    list(id=i,
         lat=data$results$geometry$location$lat[1],
         lng=data$results$geometry$location$lng[1],
         formatted_address=data$results$formatted_address[1],
         full_address = address,
         partial_match=as.numeric(data$results$partial_match),
         location_type=data$results$geometry$location_type,
         api_hit_count=length(data$results$geometry$location$lat))
  }
  
  stopCluster(cl)
  
  t <- suppressWarnings(rbindlist(ResDF)) # save all the result list as data frame
  df <- df %>%
    left_join(t, by = c("ID" = "id")) %>%
    dplyr::select(-c(locationCols, ID)) # join the Google API result with the original data frame
  return(df)
}

Df <- read.csv("xxxxxxxx", na.strings = NULL) # YOUR OWN CSV FILES OR OTHER FORMATS ACCORDINGLY WHICH CONTAINS THE ADDRESS INFORMATION NEED TO BE VALIDATED
Cp <- Df

# change the "NULL", "RD", OR "R D" in the address columns to blank
colNames <- c("address_street_1", "address_suburb_1", "address_city_1", "address_country_1") # create new columns
Cp[,colNames] <- mapply(function(x) gsub(c("NULL|R D|RD|NA"), "", x), Cp[,
                                                                              c("address_street", 
                                                                                "address_suburb", 
                                                                                "address_city", 
                                                                                "address_country")]) 

# drop the unknown and overseas address
Cp <- Cp %>%
  mutate(address_country_1 = ifelse(((address_country_1 == "New Zealand") | (address_country_1 == "") | (address_country_1 == "Unavailable")), 
                                    "New Zealand", 
                                    address_country_1))

googleKey <- "xxxxxxx" # YOUR OWN GOOGLE API KEY
locationCols <- c("address_street_1", "address_suburb_1", "address_city_1")
Full <- address_lookup(Cp, locationCols, googleKey)
colnames(Full)[1] <- "id"
write.csv(Full, "xxxxxxx", row.names = FALSE) # NAME YOUR OWN OUTPUT CSV FILE



