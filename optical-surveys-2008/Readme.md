# Optical Surveys (2008)

Preview this [Data Package](http://specs.frictionlessdata.io/data-packages/) using the [Data Package Viewer](http://data.okfn.org/tools/view?url=https://raw.githubusercontent.com/ezwelty/cg-data/master/optical-surveys-2008).

## TODO

Only raw files `*160608*` and `*190608*` include times. Only the coordinates from these files are included, as reduced local coordinates.
Were the absolute positions of the gun and reference target ever surveyed?

- Times are given in decimal days. In what time zone?
- Were the absolute positions of the gun and reference target ever surveyed? There is no evidence of these having been transformed to world coordinates

> Not sure. I dont think the gun was ever set up anywhere other than the GPS benchmark (bolt). (Shad O'Neel, email: 2017-02-14)

## Fields

- `id`: Original marker identifier
- `t`: Decimal day of 2008 – What time zone?
- `x`: Local x coordinate, relative to gun
- `y`: Local y coordinate, relative to gun
- `z`: Elevation, relative to gun

## Plot in MATLAB

```matlab
data = readtable('data/markers.local.csv');
figure, hold on
for i = unique(data.id)'
  ind = data.id == i;
  plot(data.x(ind), data.y(ind), '.')
end
```
