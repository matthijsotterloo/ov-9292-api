import Foundation

public enum TransportationType {
    case bus, ferry, subway, tram, train
    
    func parameter()->String {
        
        switch self {
        case .bus: return "byBus"
        case .ferry: return "byFerry"
        case .subway: return "bySubway"
        case .tram: return "byTram"
        case .train: return "byTrain"
        }
    }
    
    public static func all() -> Array<TransportationType> {
        return [.bus, .ferry, .subway, .tram, .train]
    }
}

open class Station:NSObject {
    var locationID:String = ""
    var stationType:String = ""
    var name:String = ""
    var countryName:String = ""
    var cityName:String = ""
    var regionName:String = ""
    var coordinates:LatLong = LatLong()
}

open class Journey:NSObject {
    var ludMessages:Array<LudMessage> = []
    var departure:Date?
    var arrival:Date?
    var numberOfChanges:Int = 0
    var legs:Array<JourneyLeg> = []
    var fareInfo:FareInfo = FareInfo()
}

struct FareInfo {
    var complete:Bool = true
    var fullPriceCents:Int = 0
    var reducedPriceCents:Int = 0
}

open class JourneyLeg:NSObject {
    var destination:String = ""
    var operatorName:String = ""
    var type:String = ""
    var service:String = ""
    var stops:Array<Stop> = []
}

open class Stop:NSObject {
    
    var arrival:Date?
    var departure:Date?
    var platform:String = ""
    var station:Station?
}

struct LudMessage {
    var text:String = ""
    var urlString:String = ""
    var url:URL? {
        get {
            if let url = URL(string: urlString) {
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
    var formatter = DateFormatter()
    
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
    func stringFromDate(_ date: Date) -> String {
        return self.formatter.string(from: date as Date)
    }
    func dateFromString(_ date: String) -> Date? {
        return self.formatter.date(from: date)! as Date?
    }
}

extension Dictionary {
    mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

open class OV9292API:NSObject {
    
    open static let baseURL = "http://api.9292.nl/0.1/"
    
    open class func journeysForTransportationTypes(_ transportationTypes:Array<TransportationType>, from:Station, to: Station, departure:Date)  -> Array<Journey> {
        
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
    
    open class func getJourney(_ transportationTypes:Array<TransportationType>, from:Station, to: Station, departure:Date)  -> AnyObject? {
        
        let firstkeys = ["before":"1", "sequence":"1"]
        
        var keys = ["lang":"nl-NL", "from":from.locationID, "dateTime":DateformatterManager.dateFormatManager.stringFromDate(departure),"searchType":"departure", "interchangeTime":"standard", "after":"5", "to":to.locationID]
        let rkeys = transportationTypes.transportationDic()
        
        keys.update(rkeys)
        keys.update(firstkeys)
        
        
        let urlStr = OV9292API.baseURL.appendingFormat("journeys?\(OV9292API.paramterStringWithKeys(keys))")
        
        if let url = URL(string: urlStr) {
            
            return performRequest(url, POSTparameters: [:])
        }
        
        return [[String:AnyObject]]() as AnyObject?
    }
    
    open class func parseStation(_ stationjson:NSDictionary) -> Station {
        
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
    
    open class func stationsForQuery(query q:String) -> Array<Station> {
        
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
    
    open class func JSONStationsForQuery(query q:String) -> AnyObject? {
        
        let urlStr = OV9292API.baseURL + "locations?lang=nl-NL&q=\(q)"
        
        if let url = URL(string: urlStr) {
            
            return performRequest(url, POSTparameters: [:])
        }
        
        return [[String:AnyObject]]() as AnyObject?
    }
    
    open class func paramterStringWithKeys(_ keys:[String:String]) -> String {
        
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
    
    open class func performRequest(_ url:URL, POSTparameters params:[String:String])  -> AnyObject? {
        
        let request = NSMutableURLRequest(url: url as URL)
        
        if params.keys.count > 0 {
            request.httpMethod = "POST"
            request.httpBody = OV9292API.paramterStringWithKeys(params).data(using: String.Encoding.ascii, allowLossyConversion: true)
        } else {
            request.httpMethod = "GET"
        }
        
        let session = URLSession.shared
        
        var finished = false
        var obj:AnyObject?
        
        let task = session.dataTask(with: request as URLRequest) { data,response, error in
            
            if error == nil {

                do {
                    
                    
                    print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String)
                    
                    obj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    
                } catch {}
            }
            
            finished = true
        }
        
        task.resume()
        
        while finished == false { }
        
        return obj
    }
}
