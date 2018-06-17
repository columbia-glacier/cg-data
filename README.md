Columbia Glacier Data
=====================

This repository serves as a guide to the [columbia-glacier](https://github.com/columbia-glacier/) datasets. Each data repository is formatted as an Open Knowledge International [Data Package](http://specs.frictionlessdata.io/data-packages/) following a standard structure:

- `README.md` – Introductory documentation.
- `datapackage.json` – Structured metadata.
- `data/` - Data files (e.g. `*.csv`).
- `scripts/` - Scripts for generating, processing, and analyzing the data (e.g. `*.R`).
- `sources/` - Raw data and documentation used to generate the final data and documentation.

Tools for working with Data Packages are available [here](https://frictionlessdata.io/tools/).

## Installation

To clone all the [columbia-glacier](https://github.com/columbia-glacier/) repositories, you can use the following `bash` command:

```
curl "https://api.github.com/users/columbia-glacier/repos?page=1&per_page=100" |
  grep -e 'git_url*' |
  cut -d \" -f 4 |
  xargs -L1 git clone
```
(source: http://stackoverflow.com/a/32833411)

## Datasets

| Name |
| --- |
| [gak1](https://github.com/columbia-glacier/gak1) |
| [gps-rovers-2004](https://github.com/columbia-glacier/gps-rovers-2004) |
| [gps-rovers-2010](https://github.com/columbia-glacier/gps-rovers-2010) |
| [noaa-coops](https://github.com/columbia-glacier/noaa-coops) |
| [noaa-ncdc](https://github.com/columbia-glacier/noaa-ncdc) |
| [optical-surveys-1984](https://github.com/columbia-glacier/optical-surveys-1984) |
| [optical-surveys-1985](https://github.com/columbia-glacier/optical-surveys-1985) |
| [optical-surveys-1986](https://github.com/columbia-glacier/optical-surveys-1986) |
| [optical-surveys-1987](https://github.com/columbia-glacier/optical-surveys-1987) |
| [optical-surveys-2005](https://github.com/columbia-glacier/optical-surveys-2005) |
| [optical-surveys-2008](https://github.com/columbia-glacier/optical-surveys-2008) |
| [optical-surveys-2009](https://github.com/columbia-glacier/optical-surveys-2009) |
| [usace-cwms-col](https://github.com/columbia-glacier/usace-cwms-col) |
| [usgs-nwis](https://github.com/columbia-glacier/usgs-nwis) |

## Conventions

Although datasets are assembled from many disparate sources, the following conventions are followed whenever possible. Note that these conventions are not followed throughout, so always check the `datapackage.json` for the current field definitions.

### Time

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Date and time | `t` | `YYYY-MM-DDThh:mm:ssZ` | [Coordinated Universal Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (UTC) |
| Date and time | `t` | `YYYY-MM-DDThh:mm:ss` | *Unknown* |
| Observation period | `*_period` | seconds (s) | Ending at the listed date and time |
| *... endpoints* | `*_begin`, `*_end` | --- | --- |

### Space

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Easting | `x` | meters (m) | [WGS 84 UTM Zone 6N](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:32606) |
| Northing | `y` | meters (m) | [WGS 84 UTM Zone 6N](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:32606) |
| Elevation | `z` | meters (m) | [WGS 84 Ellipsoid](https://en.wikipedia.org/wiki/World_Geodetic_System#A_new_World_Geodetic_System:_WGS_84) |
| Longitude | `lng` | decimal degrees (°) | [WGS 84](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:4326) |
| Latitude | `lat` | decimal degrees (°) | [WGS 84](http://spatialreference.org/ref/epsg/4326/) (EPSG:4326) |
| *... component* | `*_x`, `*_y`, ... | --- | --- |

### Meteorology

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Air temperature | `air_temperature` | degrees Celsius (°C) | --- |
| Air pressure (station) | `air_pressure` | pascals (Pa) | Station elevation |
| Air pressure (sea level) | `air_pressure_at_sea_level` | pascals (Pa) | Mean Sea Level (MSL) |
| Dew point | `dew_point` | degrees Celsius (°C) | --- |
| Precipitation (liquid equivalent) | `precipitation_lwe` | meters (m) | --- |
| Precipitation (liquid) | `rainfall` | meters (m) | --- |
| Precipitation (solid) | `snowfall` | meters (m) | --- |
| Precipitation (solid, liquid equivalent) | `snowfall_lwe` | meters (m) | --- |
| Relative humidity | `relative_humidity` | percent (%) | --- |
| Solar irradiance | `solar_irradiance` | Watts per square meter (W/m<sup>2</sup>) | Total amount of direct and diffuse solar radiation received on a horizontal surface |
| Snow depth | `snow_thickness` | meters (m) | --- |
| Snow depth (liquid equivalent) | `snow_thickness_lwe` | meters (m) | --- |
| Wind direction | `wind_temperature` | radians (rad) | Direction of travel counterclockwise from east |
| Wind speed | `wind_speed` | meters per second (m/s) | --- |

### Oceanography

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Sea level | `sea_level` | meters (m) | [Mean Lower Low Water](https://en.wikipedia.org/wiki/Chart_datum#Mean_lower_low_water) (MLLW) |
| Sea surface temperature | `sea_surface_temperature` | degrees Celsius (°C) | --- |
| Water temperature | `water_temperature` | degrees Celsius (°C) | --- |

### Modifiers

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Speed | `*_speed` | meters per second (m/s) | --- |
| Speed (glacier) | `*_speed` | meters per day (m/d) | --- |
| Direction | `*_direction` | radians (rad) | Direction of travel counterclockwise from east |
| Discharge | `*_discharge` | cubic meters per second (m<sup>3</sup>/s) | --- |
| Temperature | `*_temperature` | degrees Celsius (°C) | --- |
| Conductivity | `*_conductivity` | siemens per meter (S/m) | --- |
| Pressure | `*_pressure` | pascals (Pa) | --- |
| Voltage | `*_voltage` | volts (V) | --- |
| Observation quality | `*_quality` | --- | --- |
| *... counter* | `*_1`, `*_2`, ... | --- | --- |

## Development

All the scripts (`scripts/*`) that generate the data files (`data/*`) are written in [R](https://www.r-project.org/). Many of these require the R package [cgr](https::/github.com/columbia-glacier/cgr).
