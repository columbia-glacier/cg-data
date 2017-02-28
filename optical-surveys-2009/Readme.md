# Optical Surveys (2009)

Preview this [Data Package](http://specs.frictionlessdata.io/data-packages/) using the [Data Package Viewer](http://data.okfn.org/tools/view?url=https://raw.githubusercontent.com/ezwelty/cg-data/master/optical-surveys-2009).

## TODO

> Status as of 26 May 2009:
Preliminary  trajectory of GPS receiver on Main Branch tracked by optical survey.
Coordinates are local and arbitrary - conversion to real (UTM) coords pending receipt of absolute coords of survey references.
Time zone unknown pending receipt of survey gun's time setting.

- "Time zone unknown pending receipt of survey gun's time setting." – Was the time zone ever determined? Any guesses?
- "Conversion to real (UTM) coords pending receipt of absolute coords of survey references" – Were these every surveyed?
- Does the GPS data from the GPS rover exist somewhere?

> Time is either UTC or AK.  In  my field book there is a note from may 9 2009 that says the gun was restarted at 8:58 local or 16:57 UTC.  THis should help determine which time zone the gun is in by looking at the output. Looking at the files, the plots are made by you! As I recall you were on this trip, it was early in your thesis work, so I think im off the hook! Did you dig into the field notes and or the GPS baseline solution reports? (Shad O'Neel, email: 2017-02-14)

> At least in my 2009 field book there are several survey notes about changes in the theodolite survey and the time of day that these happened.  I can scan these and send your way if the time zone thing remains nebulous.  You can also look in the m scripts that compare motion to seismicity and see if there any time shift or not, or if there is a time shift in the visual observations, which were originally recorded in AK time. My intuition would be that seismic, GPS, optical are in UTC and calving obs in AK time. (Shad O'Neel, email: 2017-02-15)

## Fields

- `t`: Decimal day of 2009 – What time zone?
- `x`: Local x coordinate, relative to gun
- `y`: Local y coordinate, relative to gun
- `z`: Elevation, relative to gun

## Plot in MATLAB

```matlab
data = readtable('data/marker.local.csv');
figure
plot(data.x, -data.y, '.') % simple transform: reverse y
```
