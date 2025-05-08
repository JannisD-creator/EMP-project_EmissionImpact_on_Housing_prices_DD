library(dplyr)
library(readr)
library(sf)

pm10_2013 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/PM10 - flächenhafte Belastung (2013).csv", stringsAsFactors = FALSE)
str(pm10_2013)
head(pm10_flächenhaft)
names(pm10_flächenhaft)
summary(pm10_flächenhaft)
View(pm10_2013)

pm10_2015 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/PM10 - flächenhafte Belastung (2015).csv", stringsAsFactors = FALSE)

no2_fl_2013 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/NO2 - flächenhafte Belastung (2013).csv")

no2_fl_2015 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/NO2 - flächenhafte Belastung (2015).csv")

DD_houses <- read_sf("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/Housing prices shp/DDEH_STVSCHdaynight_25833.shp", stringsAsFactors = FALSE)
str(DD_housing)


DD_apartments <- read_sf("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/Housing prices shp/DDEW_STVSCHdaynight_25833_korr.shp", stringsAsFactors = FALSE)
str(DD_housing_corr)
head(DD_housing)
View(DD_housing)
View(DD_housing_corr)

DD_houses_rentals <- read_sf("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/Housing prices shp/DDMH_STVSCHdaynight_25833.shp", stringsAsFactors = FALSE)
View(DD_housing_data)

DD_apartments_rentals <- read_sf("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/Housing prices shp/DDMW_STVSCHdaynight_25833_korr.shp", stringsAsFactors = FALSE)
View(DD_apartments_rentals)
