# ACE CWMS Columbia Glacier Data

Preview this [Data Package](http://specs.frictionlessdata.io/data-packages/) using the [Data Package Viewer](http://data.okfn.org/tools/view?url=https://raw.githubusercontent.com/ezwelty/cg-data/master/ace-cwms-col).

## Data

### Description

The data includes meteorological observations from the active US Army Corps of Engineers (USACE) Corps Water Management System (CWMS) [Columbia Glacier](http://glacierresearch.com/locations/columbia/) (COL) station:

- Air temperature
- Relative humidity
- Wind speed & direction
- Pressure
- Voltage

### Sources

- Glacier Research: Columbia Glacier ([glacierresearch.org](http://glacierresearch.org/))
- Pete Gadomski's [cwms-jsonapi](https://github.com/gadomski/cwms-jsonapi) (live at https://reservoircontrol.usace.army.mil/NE/pls/cwmsweb/cwms_web.jsonapi)

## To Do

- Meaning of `quality_code` (a bitmask) returned by the CWMS API `timeseriesdata` endpoint.
- Reference and direction of `wind_direction` values.
- Datum of location `elevation`.
- Physical description of the `Pressure` and `Voltage` timeseries.
- Convert values to SI (derived) units (kph -> m/s, deg -> rad, kPa -> Pa).
- Locate pre-August 2012 data (although the station was installed in May 2009, the API only returns data since August 2012).
