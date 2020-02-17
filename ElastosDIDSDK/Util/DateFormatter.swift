import Foundation

extension DateFormatter {
    class func convertToUTCDateFromString(_ dateToConvert: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: dateToConvert)
    }

    class func convertToUTCStringFromDate(_ dateToConvert: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: dateToConvert)
    }
}

/*
public class DateFormatterHelper {
    class func getDate(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, _ ref: Date?, _ hint: String) throws -> Date? {
        let vn = dic[name]
        if vn == nil {
            if optional {
                return ref
            }
            else {
                throw DIDError.illegalArgument("Missing \(hint).")
            }
        }
        if !(vn is String) {
            throw DIDError.illegalArgument("Invalid \(hint) value.")
        }
        let value: String = String("\(vn as! String)")
        
        if value == "" {
            throw DIDError.illegalArgument("Invalid \(hint) value.")
        }
        
        let formatter = Foundation.DateFormatter()
        // formatter.dateFormat = DATE_FORMAT
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let date: Date  = formatter.date(from: value) ?? Date()
        
        return date
    }
    
    public class func currentDateToWantDate(_ year: Int)-> Date {
        let current = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        var comps:DateComponents?
        
        comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: current)
        // comps?.year = MAX_VALID_YEARS
        comps?.month = 0
        comps?.day = 0
        comps?.hour = 0
        comps?.minute = 0
        comps?.second = 0
        comps?.nanosecond = 0
        let realDate = calendar.date(byAdding: comps!, to: current) ?? Date()
        let hour = calendar.component(.hour, from: realDate)
        let useDate = calendar.date(bySettingHour: hour, minute: 00, second: 00, of: realDate) ?? Date()
        
        return useDate
    }
    
    public class func dateToWantDate(_ date: Date, _ year: Int)-> Date {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        var comps:DateComponents?
        
        comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        // comps?.year = MAX_VALID_YEARS
        comps?.month = 0
        comps?.day = 0
        comps?.hour = 0
        comps?.minute = 0
        comps?.second = 0
        comps?.nanosecond = 0
        let realDate = calendar.date(byAdding: comps!, to: date) ?? Date()
        let hour = calendar.component(.hour, from: realDate)
        let useDate = calendar.date(bySettingHour: hour, minute: 00, second: 00, of: realDate) ?? Date()
        
        return useDate
    }
    
   
    
  public class func setExpires(_ expire: Date) -> Date {
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        let hour = calendar.component(.hour, from: expire)
        let date = calendar.date(bySettingHour: hour, minute: 00, second: 00, of: expire) ?? Date()
        
        return date
    }
    
   public class func comporsDate(_ expireDate: Date, _ defaultDate: Date) -> Bool {
        return  defaultDate > expireDate
    }
}
*/