## ---------------------------
##
## Script name: make-shapes.R
##
## Purpose of script: This script generates shapefiles for use in Cortland Planning and Zoning Administration.
##
## Author: Jordan Duffin Wong
##
## Date Created: 2026-05-20
## Copyright (c) Jordan Duffin Wong, 2026
## Email: jordan@fiveruleplanning.com
##
## ---------------------------
##
## Notes: Made with R 4.5.1
##        Developed with Positron Version: 2026.05.1 (system setup) build 2
##                       Code - OSS Version: 1.109.2
##                       Commit: 80db96acd1bc6f7e7ff5ba4cbc509af8d40af1dd
##                       Date: 2026-05-05T18:05:10.234Z
##                       Electron: 39.3.0
##                       Chromium: 142.0.7444.265
##                       Node.js: 22.21.1
##                       V8: 14.2.231.22-electron.0
##                       OS: Windows_NT x64 10.0.26200
##
## ---------------------------
##### LIBRARIES #####
library(readxl)
library(spdep)
library(spatialreg)
library(sf)
library(tidyverse)

##### CUSTOM FUNCTIONS #####
# Creating a NOT IN operator
`%notin%` <- function(x, y) !(x %in% y)

##### Loading Raw Shapfiles #####
raw_municipal_boundary <- read_sf(
  dsn = "shapefiles/tl_2025_31_place/tl_2025_31_place.shp"
) %>%
  filter(NAME == "Cortland") %>%
  st_cast("POLYGON") %>%
  st_transform(crs = 26915) %>%
  select(GEOID, NAME, geometry)

raw_municipal_etj <- raw_municipal_boundary %>%
  st_buffer(x = ., dist = 1609.344)

raw_parcels <- read_sf(
  dsn = "shapefiles/StatewideParcels/StatewideParcels.shp"
) %>%
  st_transform(crs = 26915) %>%
  select(Parcel_ID, geometry) %>%
  rename("PID" = "Parcel_ID") %>% 
  filter(!is.na(PID))

##### Generating Parcel Municipality Tags #####
parcels_list <- st_join(x = raw_municipal_etj, y = raw_parcels, join = st_intersects) %>%
  as.data.frame() %>% 
  select(PID)

parcels <- raw_parcels %>% filter(PID %in% parcels_list$PID) %>% 
  st_zm()

##### Save and Output #####
### Municipal Boundary
write_sf(
  obj = raw_municipal_boundary,
  dsn = "shapefiles/shp-municipal-boundary/shp-municipal-boundary.shp"
)

### Municipal ETJ
write_sf(
  obj = raw_municipal_etj,
  dsn = "shapefiles/shp-municipal-etj/shp-municipal-etj.shp"
)

### Parcels
write_sf(
  obj = parcels,
  dsn = "shapefiles/shp-cortland-parcels/shp-cortland-parcels.shp"
)
