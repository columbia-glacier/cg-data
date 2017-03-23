# Optical Surveys (1986)

Preview this [Data Package](http://specs.frictionlessdata.io/data-packages/) using the [Data Package Viewer](http://data.okfn.org/tools/view?url=https://raw.githubusercontent.com/ezwelty/cg-data/master/optical-surveys-1986).

## Citation

> Robert M. Krimmel and Bruce H. Vaughn (1987). Columbia Glacier, Alaska: Changes in Velocity 1977–1986. Journal of Geophysical Research: Solid Earth 92 (B9): 8961–8968. doi:[10.1029/JB092iB09p08961](https://doi.org/10.1029/JB092iB09p08961).

Velocity of the Lower Glacier

> Measurements as frequent as every 10 or 15 min were made using an automated laser EDM (electronic distance measurement) system and are limited to a small number of markers for less than 30 days in each year 1984-1986 [...] In March and April 1986, during a period of mostly below freezing temperatures, one reflector was placed near the position of the 1984 and 1985-A reflectors. Velocity variations were nearly synchronous with the Valdez, Alaska, predicted tide.

Figure 8

> The 1986 short-term velocity measurements. A single reflector was located 1.8 km above the terminus. Air temperature, air pressure, and precipitation were measured at site H (Figure 1). High and low tide are plotted from Valdez, Alaska, predicted tides, plotted low tide down.

## Analog-Digital Conversion

The scanned copy of the report ([krimmel-vaughn-1987.pdf](sources/krimmel-vaughn-1987.pdf)) was downloaded from the [Wiley Online Library](http://onlinelibrary.wiley.com/doi/10.1029/JB092iB09p08961/). The data in Figure 8 were traced in Adobe Illustrator and saved as an SVG file ([krimmel-vaughn-1987-figure-8.svg](sources/krimmel-vaughn-1987-figure-8.pdf)) following the convention:

  - `<series>`
    - `axes`
      - Point paths marking axes corners, with names `x<x_value>y<y_value>`.
    - `data`
      - Point paths marking isolated points.
      - Polyline paths tracing continuous line segments.

For each `series`, the `axes` control points are used to compute a 2-dimensional transformation for transforming the image coordinates of `data` paths into figure coordinates.

The position of the weather station was estimated from point "H" in Figure 1.

## To Do

- Locate original data.
- Convert pressure to SI derived unit (mbar to Pa).
- Use position of Heather Island EDM as weather station position. See Figure 1:

> H is location of the instrument station used for velocity experiments 1984-1986.
