OV 9292 API Wrapper Swift
===================



Provides a Swift wrapper for the OV 9292 API (Dutch public transportation API).



Example Code
----------
	let groningen = OV9292API.stationsForQuery(query: "Groningen").first!
	
	let middelburg = OV9292API.stationsForQuery(query: "Middelburg").first!
	
	OV9292API.journeysForTransportationTypes([.Bus, .Train, .Subway, .Tram, .Ferry], from: groningen, to: middelburg, departure: NSDate())


License
----------
This code is licenced under 'MIT License'.
