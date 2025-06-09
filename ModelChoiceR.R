############################################################
#  SDM_PATHWAY_final.R
#  --------------------------------------------------------
#  • NO2 flächenhafte (2013) only
#  • Symmetric k = 15 NN weights on sales points
#  • Fits SDM, SAR, SEM
#  • Manual LR tests  (so no LR.sarlm() dependency)
############################################################

# ---- 0 · packages ---------------------------------------------------------
pkgs <- c("sf", "dplyr", "readr", "purrr", "spdep", "spatialreg")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))

# ---- 1 · paths ------------------------------------------------------------
root     <- "G:/TU Dresden/4. Semester/Empirical Research in Spatial and Environmental Economics/Data"
poll_dir <- file.path(root, "Data_Pollution")
hp_dir   <- file.path(root, "Housing prices shp")

# ---- 2 · read data --------------------------------------------------------
cat("Reading house-sale shapefiles …\n")
sales <- list.files(hp_dir, "\\.shp$", full.names = TRUE, ignore.case = TRUE) |>
  purrr::map_dfr(st_read)

cat("Reading NO2 flächenhafte CSV …\n")
no2_csv <- list.files(poll_dir,
                      "NO2.*flächenhafte.*2013.*csv$",
                      full.names = TRUE, ignore.case = TRUE)[1]
stopifnot(!is.na(no2_csv))

no2_raw <- read_delim(no2_csv, delim = ";",
                      locale = locale(encoding = "UTF-8"))
wkt <- grep("shape|wkt|geometry", names(no2_raw), value = TRUE, ignore.case = TRUE)[1]
no2_sf <- st_as_sf(no2_raw, wkt = wkt, crs = 4326) |> rename(NO2 = deskn1)

# ---- 3 · clean nums & join -----------------------------------------------
sales <- st_transform(sales, st_crs(no2_sf)) |>
  mutate(
    Kaufpreis  = parse_number(Kaufpreis,  locale = locale(decimal_mark = ",")),
    Wohnflaech = parse_number(Wohnflaech, locale = locale(decimal_mark = ",")),
    Zimmer     = parse_number(Zimmer,     locale = locale(decimal_mark = ","))
  )

dat <- st_join(sales, no2_sf |> select(NO2)) |>
  filter(Kaufpreis  > 0,
         Wohnflaech > 0,
         Zimmer     > 0,
         !is.na(NO2)) |>
  mutate(
    log_price   = log(Kaufpreis),
    living_area = Wohnflaech,
    rooms       = Zimmer
  ) |>
  select(log_price, living_area, rooms, NO2, geometry)

stopifnot(nrow(dat) > 30)
cat("Final sample:", nrow(dat), "\n")

# ---- 4 · symmetric k = 15 NN weights -------------------------------------
coords <- st_coordinates(dat)
nb_dir <- knn2nb(knearneigh(coords, k = 15))
nb_sym <- make.sym.nb(nb_dir)                    # add missing reverse links
W      <- nb2listw(nb_sym, style = "W", zero.policy = TRUE)
cat("Weight matrix: symmetric 15-NN\n")

# ---- 5 · fit SDM, SAR, SEM -----------------------------------------------
cat("\nFitting SDM …\n")
sdm <- lagsarlm(log_price ~ NO2 + living_area + rooms,
                data = dat, listw = W, type = "mixed",
                zero.policy = TRUE, method = "Matrix")

cat("Fitting SAR …\n")
sar <- lagsarlm(log_price ~ NO2 + living_area + rooms,
                data = dat, listw = W,
                zero.policy = TRUE, method = "Matrix")

cat("Fitting SEM …\n")
sem <- errorsarlm(log_price ~ NO2 + living_area + rooms,
                  data = dat, listw = W,
                  zero.policy = TRUE, method = "Matrix")

# ---- 6 · manual LR tests --------------------------------------------------
lr_stat  <- function(big, small) 2 * (logLik(big) - logLik(small))
lr_pval  <- function(stat, df)    pchisq(stat, df = df, lower.tail = FALSE)

LR_SAR <- lr_stat(sdm, sar);  p_SAR <- lr_pval(LR_SAR, df = 2)
LR_SEM <- lr_stat(sdm, sem);  p_SEM <- lr_pval(LR_SEM, df = 1)

cat("\nLikelihood-ratio tests (SDM vs. restricted models)\n")
cat(sprintf("  SDM → SAR   :  LR = %.3f   p = %.4f\n", LR_SAR, p_SAR))
cat(sprintf("  SDM → SEM   :  LR = %.3f   p = %.4f\n", LR_SEM, p_SEM))

# ---- 7 · choose final model ----------------------------------------------
if (p_SAR > .05 && p_SEM > .05) {
  final <- list(name = "SDM", fit = sdm)
  msg   <- "Neither restriction holds → keep **SDM**."
} else if (p_SAR > .05) {
  final <- list(name = "SAR", fit = sar)
  msg   <- "LR-SAR not significant → choose **SAR**."
} else if (p_SEM > .05) {
  final <- list(name = "SEM", fit = sem)
  msg   <- "LR-SEM not significant → choose **SEM**."
} else {
  final <- list(name = "SAR", fit = sar)
  msg   <- "Both LR significant; pick simpler **SAR**."
}

cat("\n→", msg, "\n")

# ---- 8 · print summary & impacts -----------------------------------------
cat("\n============  Final model:", final$name, "============\n")
print(summary(final$fit))

if (inherits(final$fit, "sarlm") && final$name != "SEM") {
  cat("\nSpatial impacts (direct | spillover | total):\n")
  imp <- impacts(final$fit, listw = W, R = 500, zero.policy = TRUE)
  print(summary(imp, short = TRUE))
}

cat("\nDone – use LR table + summary in your slides.\n")
