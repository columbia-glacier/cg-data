Columbia Glacier Data
=====================

This repository serves as a guide to the [columbia-glacier](https://github.com/columbia-glacier/) datasets. Each data repository is formatted as an Open Knowledge International [Data Package](http://specs.frictionlessdata.io/data-packages/) following a standard structure:

- `README.md` – Introductory documentation.
- `datapackage.json` – Structured metadata.
- `data/` - Data files (e.g. `*.csv`).
- `scripts/` - Scripts for generating, processing, and analyzing the data (e.g. `*.R`).
- `sources/` - Raw data and documentation used to generate the final data and documentation.

Tools for working with Data Packages are available [here](https://frictionlessdata.io/tools/).

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

| Variable | Field | Unit  / Format | Datum |
| --- | --- | --- | --- |
| Time | `t` | `YYYY-MM-DDThh:mm:ssZ` | [Coordinated Universal Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (UTC) |
| Time | `t` | `YYYY-MM-DDThh:mm:ss` | *unknown* |
| Easting | `x` | meters (m) | [WGS 84 UTM Zone 6N](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:32606) |
| Northing | `y` | meters (m) | [WGS 84 UTM Zone 6N](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:32606) |
| Longitude | `longitude` | decimal degrees (°) | [WGS 84](http://spatialreference.org/ref/epsg/wgs-84-utm-zone-6n/) (EPSG:4326) |
| Latitude | `latitude` | decimal degrees (°) | [WGS 84](http://spatialreference.org/ref/epsg/4326/) (EPSG:4326) |
| Elevation | `elevation` | meters (m) | [WGS 84 Ellipsoid](https://en.wikipedia.org/wiki/World_Geodetic_System#A_new_World_Geodetic_System:_WGS_84) |
| Water level | `water_level` | meters (m) | [Mean Lower Low Water](https://en.wikipedia.org/wiki/Chart_datum#Mean_lower_low_water) (MLLW) |
| Relative humidity | `relative_humidity` | percent (%) | --- |
| Direction | `*_direction` | radians (rad) | counterclockwise from east |
| Speed | `*_speed` | meters per day (m/day) | --- |
| Speed (glacier) | `*_speed` | meters per second (m/s) | --- |
| Discharge | `*_discharge` | cubic meters per second (m<sup>3</sup>/s) | --- |
| Temperature | `*_temperature` | degrees Celsius (°C) | --- |
| Conductivity | `*_conductivity` | siemens per meter (S/m) | --- |
| Pressure | `*_pressure` | pascals (Pa) | --- |
| Voltage | `*_voltage` | volts (V) | --- |
| *... range* | `*_begin`, `*_end` | --- | --- |
| *... component* | `*_x`, `*_y`, ... | --- | --- |
