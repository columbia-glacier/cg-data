GPS Rovers
==========

> O’Neel, S. (2006). Understanding the mechanics of tidewater glacier retreats: Observations and analyses at Columbia Glacier, Alaska (Ph.D.). University of Colorado at Boulder. Retrieved from http://adsabs.harvard.edu/abs/2006PhDT........31O

A3.2.1 GPS
> A semi-permanent GPS station was installed on the surface of Columbia Glacier during June 2004 and operated for 60 days until mid-August 2004. A stable platform for this station was found ~7 km upstream from the terminus. The antenna was coupled to the surface using three ~10 m poles drilled into the ice in the shape of a triangle with a wooden platform near the top to stabilize the mount. The Trimble 4000 receiver, battery and charging system were tethered to a separate nearby pole. Position solutions were made 8 times daily and post-processed against a base station located near the terminus, providing ~2 cm positional precision.

# Fields:

- `date`: Local time?
- `x`: UTM (NAD27?)
- `y`: UTM (NAD27?)
- `z`: ?
- `x`: Longitude (WGS84?)
- `y`: Latitude (WGS84?)
- `z`: WGS84 HAE?

# Plot in MATLAB

```matlab
d1 = table2struct(readtable('data/positions-short.csv'), 'ToScalar', true);
[x, y, zone] = wgs2utm(d1.lat_WGS84, d1.lng_WGS84);
d1.x = x; d1.y = y;
d2 = table2struct(readtable('data/positions-long.csv'), 'ToScalar', true);
[x, y, zone] = wgs2utm(d2.lat_WGS84, d2.lng_WGS84);
d2.x = x; d2.y = y;

figure
[Z, ~, bbox] = geotiffread('/Volumes/Science/data/columbia/_new/ArcticDEM/tiles/merged_projected_clipped.tif');
dem = DEM(Z, bbox(:, 1), flip(bbox(:, 2)));
dem.plot(2); hold on
plot(d1.x, d1.y, 'r.', d2.x, d2.y, 'y.')
```
