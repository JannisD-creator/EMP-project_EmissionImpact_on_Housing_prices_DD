library(dplyr)
library(readr)

pm10_2013 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/PM10 - flächenhafte Belastung (2013).csv", stringsAsFactors = FALSE)
str(pm10_2013)
head(pm10_flächenhaft)
names(pm10_flächenhaft)
summary(pm10_flächenhaft)
View(pm10_2013)

pm10_2015 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/PM10 - flächenhafte Belastung (2015).csv", stringsAsFactors = FALSE)

no2_fl_2013 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/NO2 - flächenhafte Belastung (2013).csv")

no2_fl_2015 <- read.csv("~/spatial and environmental economic research/Project/EMP-project_EmissionImpact_on_Housing_prices_DD/data/NO2 - flächenhafte Belastung (2015).csv")




