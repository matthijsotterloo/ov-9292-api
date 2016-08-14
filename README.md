OV 9292 API Wrapper Swift
===================



This repository provides a Swift wrapper for the OV 9292 API (Dutch Public Transportation API).
The API is available at [api.9292.nl/1.0](http://api.9292.nl/1.0), we reverse engineered this API (from their official iOS App) and then created this API Wrapper in Swift.


Example Code
----------

```sh
let groningen = OV9292API.stationsForQuery(query: "Groningen").first!
let middelburg = OV9292API.stationsForQuery(query: "Middelburg").first!
OV9292API.journeysForTransportationTypes([.Bus, .Train, .Subway, .Tram, .Ferry], from: groningen, to: middelburg, departure: NSDate())
```


Contributors
----------
[http://erikvanderplas.com/](Erik van der Plas)
[https://matthijsotterloo.com](Matthijs Otterloo)


License
----------
This code is licenced under 'MIT License'.
