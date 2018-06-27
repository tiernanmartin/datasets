
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Hospitals in Washington State
-----------------------------

A list of hospitals in Washington State.

### Data Dictionary

| VARIABLE       | DESCRIPTION                                         | SOURCE            | NOTE                                                                                |
|:---------------|:----------------------------------------------------|:------------------|:------------------------------------------------------------------------------------|
| Name           | Name of the hospital                                | data.medicare.gov |                                                                                     |
| Hospital Type  | The type of services provided                       | data.medicare.gov | Includes: Acute Care, Critical Access, Childrens                                    |
| Ownership Type | The type of ownership                               | data.medicare.gov | For instance: Government - Local, Voluntary non-profit - Private, Proprietary, etc. |
| Address        | The hospital's street address                       | Google Maps API   |                                                                                     |
| City           | The city where the hospital is located              | Google Maps API   |                                                                                     |
| County         | The county where the hospital is located            | Google Maps API   |                                                                                     |
| State          | The state where the hospital is located             | Google Maps API   |                                                                                     |
| Zip Code       | The hospital's address zip code                     | Google Maps API   |                                                                                     |
| Lng            | The longitude of the hospital's geographic location | Google Maps API   |                                                                                     |
| Lat            | The latitude of the hospital's geographic location  | Google Maps API   |                                                                                     |
| geom           | The geometry of the libraries location              | Google Maps API   |                                                                                     |

Download
--------

To download the data, right-click the following link and choose 'Save link as...': [`wa-hospitals.gpkg`](https://github.com/tiernanmartin/datasets/raw/master/wa-hospitals/data/wa-hospitals.gpkg).

License <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Data license: [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/) · Data source: [Data.Medicare.gov](https://data.medicare.gov/Hospital-Compare/Hospital-General-Information/xubh-q36u/data)
