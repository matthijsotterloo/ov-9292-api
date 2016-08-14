import Foundation

public enum TransportationType {
    case Bus, Ferry, Subway, Tram, Train
    
    func parameter()->String {
        
        switch self {
        case .Bus: return "byBus"
        case .Ferry: return "byFerry"
        case .Subway: return "bySubway"
        case .Tram: return "byTram"
        case .Train: return "byTrain"
        }
    }
    
    public static func all() -> Array<TransportationType> {
        return [.Bus, .Ferry, .Subway, .Tram, .Train]
    }
}

public class Station:NSObject {
    var locationID:String = ""
    var stationType:String = ""
    var name:String = ""
    var countryName:String = ""
    var cityName:String = ""
    var regionName:String = ""
    var coordinates:LatLong = LatLong()
}

public class Journey:NSObject {
    var ludMessages:Array<LudMessage> = []
    var departure:NSDate?
    var arrival:NSDate?
    var numberOfChanges:Int = 0
    var legs:Array<JourneyLeg> = []
    var fareInfo:FareInfo = FareInfo()
}

struct FareInfo {
    var complete:Bool = true
    var fullPriceCents:Int = 0
    var reducedPriceCents:Int = 0
}

public class JourneyLeg:NSObject {
    var destination:String = ""
    var operatorName:String = ""
    var type:String = ""
    var service:String = ""
    var stops:Array<Stop> = []
}

public class Stop:NSObject {
    
    var arrival:NSDate?
    var departure:NSDate?
    var platform:String = ""
    var station:Station?
}

struct LudMessage {
    var text:String = ""
    var urlString:String = ""
    var url:NSURL? {
        get {
            if let url = NSURL(string: urlString) {
                return url
            }
            
            return nil
        }
    }
}

struct LatLong {
    var lat:Float = 0.0
    var long:Float = 0.0
}

extension Array {
    
    func transportationDic() -> Dictionary<String, String> {
        
        var dic:Dictionary<String, String> = [:]
        
        
        for type in TransportationType.all() {
            for obj  in self {
                if let ctype = obj as? TransportationType {
                    if type == ctype {
                        dic[type.parameter()] = "true"
                    }
                }
            }
        }
        
        for type in TransportationType.all() {
            if dic[type.parameter()] == nil {
                dic[type.parameter()] = "false"
            }
        }
        
        return dic
    }
}

class DateformatterManager {
    var formatter = NSDateFormatter()
    
    class var dateFormatManager : DateformatterManager {
        struct Static {
            static let instance : DateformatterManager = DateformatterManager()
        }
        // date shown as date in some tableviews
        Static.instance.formatter.dateFormat = "yyyy-MM-dd'T'HHmm"
        return Static.instance
    }
    
    class var dateFormatManager2 : DateformatterManager {
        struct Static {
            static let instance : DateformatterManager = DateformatterManager()
        }
        // date shown as date in some tableviews
        Static.instance.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return Static.instance
    }
    
    // MARK: - Helpers
    func stringFromDate(date: NSDate) -> String {
        return self.formatter.stringFromDate(date)
    }
    func dateFromString(date: String) -> NSDate? {
        return self.formatter.dateFromString(date)!
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

public class OV9292API:NSObject {
    
    public static let baseURL = "http://api.9292.nl/0.1/"
    
    public class func journeysForTransportationTypes(transportationTypes:Array<TransportationType>, from:Station, to: Station, departure:NSDate)  -> Array<Journey> {
        
        let obj = OV9292API.getJourney(transportationTypes, from: from, to: to, departure: departure)
        
        var journeys:Array<Journey> = []
        
        if let firstdic = obj as? NSDictionary {
            if let journeyobjs = firstdic["journeys"] as? NSArray {
                for journey in journeyobjs {
                    
                    let journeyObject = Journey()
                    
                    if let rjourney = journey as? NSDictionary {
                        
                        if let ludmessages = rjourney["ludMessages"] as? NSArray {
                            for ludmessage in ludmessages {
                                
                                var ludMessage = LudMessage()
                                
                                if let rludmessage = ludmessage as? NSDictionary {
                                    if let text = rludmessage["text"] as? NSString {
                                        ludMessage.text = text as String
                                    }
                                    if let url = rludmessage["url"] as? NSString {
                                        ludMessage.urlString = url as String
                                    }
                                }
                                
                                journeyObject.ludMessages.append(ludMessage)
                            }
                        }
                    
                        if let departure = rjourney["departure"] as? NSString {
                            journeyObject.departure = DateformatterManager.dateFormatManager2.dateFromString(departure as String)
                        }
                        
                        if let arrival = rjourney["arrival"] as? NSString {
                            journeyObject.arrival = DateformatterManager.dateFormatManager2.dateFromString(arrival as String)
                        }
                        if let noc = rjourney["numberOfChanges"] as? Int {
                            journeyObject.numberOfChanges = noc
                        }
                        
                        if let arrlegs = rjourney["legs"] as? NSArray {
                            
                            var legs:Array<JourneyLeg> = []
                            
                            for rleg in arrlegs {
                                let leg = JourneyLeg()
                                
                                if let legdic = rleg as? NSDictionary {
                                    if let destination = legdic["destination"] as? NSString {
                                        leg.destination = destination as String
                                    }
                                    if let operatorDic = legdic["operator"] as? NSDictionary {
                                        if let operatorName = operatorDic["name"] as? NSString {
                                            leg.operatorName = operatorName as String
                                        }
                                    }
                                    if let mode = legdic["mode"] as? NSDictionary {
                                        if let type = mode["type"] as? NSString {
                                            leg.type = type as String
                                        }
                                    }
                                    if let service = legdic["service"] as? NSString {
                                        leg.service = service as String
                                    }
                                    
                                    if let stops = legdic["stops"] as? NSArray {
                                        
                                        var stopArr:Array<Stop> = []
                                        
                                        print(stops)
                                        
                                        for stop in stops {
                                            
                                            let rstop = Stop()
                                            
                                            if let jsonstop = stop as? NSDictionary {
                                                if let arrival = jsonstop["arrival"] as? NSString {
                                                    rstop.arrival = DateformatterManager.dateFormatManager2.dateFromString(arrival as String)
                                                }
                                                if let departure = jsonstop["departure"] as? NSString {
                                                    rstop.departure = DateformatterManager.dateFormatManager2.dateFromString(departure as String)
                                                }
                                                if let platform = jsonstop["platform"] as? NSString {
                                                    rstop.platform = platform as String
                                                }
                                                if let location = jsonstop["location"] as? NSDictionary {
                                                    rstop.station = OV9292API.parseStation(location)
                                                }
                                            }
                                            
                                            stopArr.append(rstop)
                                        }
                                        
                                        leg.stops = stopArr
                                    }
                                    
                                    legs.append(leg)
                                }
                            }
                            
                            journeyObject.legs = legs
                        }
                    }

                    journeys.append(journeyObject)
                }
            }
        }
    
        
        return journeys
    }
    
    public class func getJourney(transportationTypes:Array<TransportationType>, from:Station, to: Station, departure:NSDate)  -> AnyObject? {
        
        let firstkeys = ["before":"1", "sequence":"1"]
        
        var keys = ["lang":"nl-NL", "from":from.locationID, "dateTime":DateformatterManager.dateFormatManager.stringFromDate(departure),"searchType":"departure", "interchangeTime":"standard", "after":"5", "to":to.locationID]
        let rkeys = transportationTypes.transportationDic()
        
        keys.update(rkeys)
        keys.update(firstkeys)
        
        
        let urlStr = OV9292API.baseURL.stringByAppendingString("journeys?\(OV9292API.paramterStringWithKeys(keys))")
        
        if let url = NSURL(string: urlStr) {
            
            return performRequest(url, POSTparameters: [:])
        }
        
        return [:]
    }
    
    public class func parseStation(stationjson:NSDictionary) -> Station {
        
        let station = Station()
        
        if let id = stationjson["id"] as? NSString {
            station.locationID = id as String
        }
        if let name = stationjson["name"] as? NSString {
            station.name = name as String
        }
        if let stationType = stationjson["stationType"] as? NSString {
            station.stationType = stationType as String
        }
        if let place = stationjson["place"] as? NSDictionary {
            if let country = place["countryName"] as? NSString {
                station.countryName = country as String
            }
            if let city = place["name"] as? NSString {
                station.cityName = city as String
            }
            if let region = place["regionName"] as? NSString {
                station.regionName = region as String
            }
        }
        if let latlong = stationjson["latLong"] as? NSDictionary {
            
            var coordinates = LatLong()
            
            if let lat = latlong["lat"] as? Float {
                coordinates.lat = lat
            }
            if let long = latlong["long"] as? Float {
                coordinates.long = long
            }
            
            station.coordinates = coordinates
        }
        
        return station
    }
    
    public class func stationsForQuery(query q:String) -> Array<Station> {
        
        let obj = OV9292API.JSONStationsForQuery(query: q)
        
        var stations:Array<Station> = []
        
        if let dic = obj as? NSDictionary {
            if let array = dic["locations"] as? NSArray {
                for obj in array {
                    if let stationjson = obj as? NSDictionary {
                        
                        stations.append(OV9292API.parseStation(stationjson))
                    }
                }
            }
        }
        
        return stations
    }
    
    public class func JSONStationsForQuery(query q:String) -> AnyObject? {
        
        let urlStr = OV9292API.baseURL.stringByAppendingString("locations?lang=nl-NL&q=\(q)")
        
        if let url = NSURL(string: urlStr) {
            
            return performRequest(url, POSTparameters: [:])
        }
        
        return [:]
    }
    
    public class func paramterStringWithKeys(keys:[String:String]) -> String {
        
        var isFirst = true
        
        var string = ""
        
        for (key, value) in keys {
            
            if !isFirst {
                string = "\(string)&"
            } else {
                isFirst = false
            }
            
            string = "\(string)\(key)=\(value)"
        }
        
        return string
    }
    
    public class func performRequest(url:NSURL, POSTparameters params:[String:String])  -> AnyObject? {
        
        let request = NSMutableURLRequest(URL: url)
        
        if params.keys.count > 0 {
            request.HTTPMethod = "POST"
            request.HTTPBody = OV9292API.paramterStringWithKeys(params).dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        } else {
            request.HTTPMethod = "GET"
        }
        
        let session = NSURLSession.sharedSession()
        
        var finished = false
        var obj:AnyObject?
        
        let task = session.dataTaskWithRequest(request) { data,response, error in
            
            if error == nil {
                
                do {
                
                    
                    print(NSString(data: data!, encoding: NSUTF8StringEncoding) as! String)
                    
                    obj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    
                } catch {}
            }
            
            finished = true
        }
        
        task.resume()
        
        while finished == false { }
        
        return obj
    }
}
