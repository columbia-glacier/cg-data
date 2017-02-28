# Optical Surveys (2005)

Preview this [Data Package](http://specs.frictionlessdata.io/data-packages/) using the [Data Package Viewer](http://data.okfn.org/tools/view?url=https://raw.githubusercontent.com/ezwelty/cg-data/master/optical-surveys-2005).

## Citation

> O’Neel, S. (2006). Understanding the mechanics of tidewater glacier retreats: Observations and analyses at Columbia Glacier, Alaska (Ph.D.). University of Colorado at Boulder. Retrieved from http://adsabs.harvard.edu/abs/2006PhDT........31O

Section A3.2.2: Optical Surveys

> Three survey targets were deployed during June, 2005 (Figure A3.1), within one km of the calving face using a helicopter. The maximum lifetime of the markers was limited to 15 days, before each succumbed to calving. Positions of the targets were obtained using a Leica total station robotic survey theodolite at nominal time separation of 20-30 minutes. At 1-2 km ranges observed, position accuracy is ~5 cm. Two targets were placed (fortuitously) on an identical flowline, such that along-flow strain rates are calculable over a 5 day period.

## TODO

- Times are given in decimal days. In what time zone?
- Coordinates are converted from local to world coordinates using gun (497126.859, 6775852.739) and reference target (497126.388, 6775984.429) coordinates. What datum are these coordinates in?
- Was the elevation of the gun ever surveyed (otherwise, I can use a reference DEM)?

> Since the speeds are compared to seismic stuff you should assume UTC. Dig around through all the scripts and see if you can find anything to the contrary.  you may be able to pry this out of the gun files, but im not sure. the gun is tied to the bolt, which was GPS surveyed in WGS84. (Shad O'Neel, email: 2017-02-14)
