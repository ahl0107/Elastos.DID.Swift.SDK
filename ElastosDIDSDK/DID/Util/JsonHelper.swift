import Foundation

public class JsonHelper {
    class func getDid(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, ref: DID? = nil, _ hint: String) throws -> DID? {

        let vn = dic[name]
        if vn == nil {
            if (optional) { return ref }
            else {
                throw DIDError.failue("Missing " + hint + ".")
            }
        }
        let value: String = vn as? String ?? ""
        guard value != "" else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }

        return try DID(value)
    }
    
    class func getDid(_ dic: Dictionary<String, Any>, _ name: String, _ optional: Bool, ref: DID? = nil, _ hint: String) throws -> DID? {

        let vn = dic[name]
        if vn == nil {
            if (optional) { return ref }
            else {
                throw DIDError.failue("Missing " + hint + ".")
            }
        }
        let value: String = vn as? String ?? ""
        guard value != "" else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        
        return try DID(value)
    }
    
    class func getDate(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, ref: Date? = nil, _ hint: String) throws -> Date? {
        let vn = dic[name]
        if vn == nil {
            if optional {
                return ref
            }
            else {
                throw DIDError.failue("Missing \(hint).")
            }
        }
        if !(vn is String) {
            throw DIDError.failue("Invalid \(hint) value.")
        }
        let value: String = String("\(vn as! String)")

        if value == "" {
            throw DIDError.failue("Invalid \(hint) value.")
        }

        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = DATE_FORMAT
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let date: Date  = formatter.date(from: value) ?? Date()

        return date
    }
    
    class func getDate(_ dic: Dictionary<String, Any>, _ name: String, _ optional: Bool, ref: Date? = nil, _ hint: String) throws -> Date? {
        let vn = dic[name]
        if vn == nil {
            if optional {
                return ref
            }
            else {
                throw DIDError.failue("Missing \(hint).")
            }
        }
        if !(vn is String) {
            throw DIDError.failue("Invalid \(hint) value.")
        }
        let value: String = String("\(vn as! String)")
        
        if value == "" {
            throw DIDError.failue("Invalid \(hint) value.")
        }
        
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = DATE_FORMAT
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let date: Date  = formatter.date(from: value) ?? Date()
        
        return date
    }
    
    class func getDidUrl(_ dic: OrderedDictionary<String, Any>, _ name: String, ref: DID? = nil, _ hint: String) throws -> DIDURL? {
        return try getDidUrl(dic, name, false, ref, hint)
    }
    
    class func getDidUrl(_ dic: Dictionary<String, Any>, _ name: String, ref: DID? = nil, _ hint: String) throws -> DIDURL? {
        return try getDidUrl(dic, name, false, ref: ref, hint)
    }
    
    class func getDidUrl(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, _ ref: DID?, _ hint: String) throws -> DIDURL? {
        let vn = dic[name]
        if vn == nil {
            if optional {
                return nil
            }
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        var value: String = vn as? String ?? ""

        guard !value.isEmpty else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        let fragment: String = String(value.prefix(1))
        if ref != nil && fragment == "#" {
            value = String(value.suffix(value.count - 1))
            return try DIDURL(ref!, value)
        }
        return try DIDURL(value)
    }

    class func getDidUrl(_ dic: Dictionary<String, Any>, _ name: String, _ optional: Bool, ref: DID? = nil, _ hint: String) throws -> DIDURL? {
        let vn = dic[name]
        if vn == nil {
            if optional {
                return nil
            }
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        var value: String = vn as? String ?? ""
        
        guard !value.isEmpty else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        let fragment: String = String(value.prefix(1))
        if ref != nil && fragment == "#" {
            value = String(value.suffix(value.count - 1))
            return try DIDURL(ref!, value)
        }
        return try DIDURL(value)
    }
    
    class func getDidUrl(_ str: String, _ ref: DID?, _ hint: String) throws -> DIDURL {
        var value: String = str
        let fragment: String = String(str.prefix(1))
        if ref != nil && fragment == "#" {
            value = String(value.suffix(value.count - 1))
            return try DIDURL(ref!, value)
        }
        return try DIDURL(value)
    }
    
    class func getString(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, ref: String? = nil, _ hint: String) throws -> String {
        let vn = dic[name]
        if vn == nil {
            if (optional) { return ref! }
        }

        let value: String = vn as? String ?? ""

        guard value != "" else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        return value
    }

    class func getString(_ dic: Dictionary<String, Any>, _ name: String, _ optional: Bool, ref: String? = nil, _ hint: String) throws -> String {
        let vn = dic[name]
        if vn == nil {
            if (optional) { return ref! }
        }
        
        let value: String = vn as? String ?? ""
        
        guard value != "" else {
            throw DIDError.failue("Invalid " + hint + " value.")
        }
        return value
    }
    
    class func getInteger(_ dic: OrderedDictionary<String, Any>, _ name: String, _ optional: Bool, _ ref: Int, _ hint: String) throws -> Int {
        let vn = dic[name]
        var v: Int = 0
        if vn == nil {
            if optional {
                return ref
            }
            else {
                throw DIDError.failue("Invalid " + hint + " value.")
            }
        }
        if vn is String {
            let velue: String = vn as! String
            v = Int(velue)!
        }
        else {
            v = vn as! Int
        }
        return v
    }
    
    class func getInteger(_ dic: Dictionary<String, Any>, _ name: String, _ optional: Bool, _ ref: Int, _ hint: String) throws -> Int {
        let vn = dic[name]
        var v: Int = 0
        if vn == nil {
            if optional {
                return ref
            }
            else {
                throw DIDError.failue("Invalid " + hint + " value.")
            }
        }
        if vn is String {
            let velue: String = vn as! String
            v = Int(velue)!
        }
        else {
            v = vn as! Int
        }
        return v
    }
    
    class public func creatJsonString(dic: OrderedDictionary<String, Any>) -> String {
        
        var namedPaird = [String]()
        dic.forEach { (key, value) in
            if value is OrderedDictionary<String, Any> {
                namedPaird.append("\"\(key)\":\(self.creatJsonString(dic: value as! OrderedDictionary<String, Any>))")
            } else if value is [Any] {
                let v = value as! [Any]
                var subName = [String]()
                v.forEach { ve in
                    if ve is String {
                        subName.append("\"\(ve)\"")
                    } else {
                        subName.append("\(self.creatJsonString(dic: ve as! OrderedDictionary<String, Any>))")
                    }
                }
                let st = subName.joined(separator: ",")
                namedPaird.append("\"\(key)\":[\(st)]")
            } else {
                if value is Bool {
                    let v = value as! Bool
                    if v {
                        namedPaird.append("\"\(key)\":true")
                    } else {
                        namedPaird.append("\"\(key)\":false")
                    }
                } else if !(value is String) {
                    namedPaird.append("\"\(key)\":\(value)")
                } else {
                    namedPaird.append("\"\(key)\":\"\(value)\"")
                }
            }
        }
        let returnString = namedPaird.joined(separator:",")
        return "{\(returnString)}"
    }
    
    //    MARK: json
    class public func isArrayJsonString(_ jsonString: String) -> Bool {
        return jsonString.first == "[" && jsonString.last == "]"
    }
    
    class public func isDictionaryJsonString(_ jsonString: String) -> Bool {
        return jsonString.first == "{" && jsonString.last == "}"
    }
    
    class public func checkAndRemoveFirstAndLastDoubleQuotes(_ string: String) -> Any {
        
        if string == "\"\"" {
            return ""
        }
        
        if !string.contains("\"") {
            if string == "true"  {
                return true
            }
            if string == "false"  {
                return false
            }
            
            if string.contains(".") {
                if let value = string.float {
                    return value
                }
            } else {
                if let value = string.integer {
                    return value
                }
            }
        }
        
        var startIndex: String.Index
        var endIndex: String.Index
        if string.first == "\"" {
            startIndex = string.index(string.startIndex, offsetBy: 1)
        } else {
            startIndex = string.startIndex
        }
        if string.last == "\"" {
            endIndex = string.index(string.endIndex, offsetBy: -2)
        } else {
            endIndex = string.index(string.endIndex, offsetBy: -1)
        }
        
        return String(string[startIndex...endIndex])
    }
    
    class public func checkAndRemoveFirstAndLastBrackets(_ string: String) -> String {
        if ((string.first == "{" && string.last == "}")
            || (string.first == "[" && string.last == "]"))
            && string.count > 2 {
            
            let startIndex = string.index(string.startIndex, offsetBy: 1)
            let endIndex = string.index(string.endIndex, offsetBy: -2)
            return String(string[startIndex...endIndex])
        }
        return string
    }
    
    class public func getKeyAndValueFromString(_ string: String) -> (String, Any) {
        if string == "{}" {
            return ("", "")
        }
        let colonStringIndex = string.index(string.firstIndex(of: ":")!, offsetBy:0)
        let keyStartIndex = string.index(string.startIndex, offsetBy:0)
        let keyEndIndex = string.index(colonStringIndex, offsetBy:-1)
        let valueStartIndex = string.index(colonStringIndex, offsetBy:1)
        let valueEndIndex = string.index(string.endIndex, offsetBy:-1)
        
        let key: String = checkAndRemoveFirstAndLastDoubleQuotes(String(string[keyStartIndex...keyEndIndex])) as! String
        let value: Any = checkAndRemoveFirstAndLastDoubleQuotes(String(string[valueStartIndex...valueEndIndex]))
        
        return (key, value)
    }
    
    class public func preHandleString(_ jsongString: String) -> String {
        let str = jsongString.replacingOccurrences(of: "\n", with: "")
        var token: Bool = false
        var string: String = ""

        for (_, c) in str.enumerated() {
            
            if token {
                string.append(c)
            } else {
                if c != " " && c != "\n"{
                    string.append(c)
                }
            }
            
            if c == "\"" {
                token = !token
            }
        }
        return string
    }
    
    class public func handleString(_ jsonString: String) -> Any? {

        if isDictionaryJsonString(jsonString) {
            
            var orderDictionary: OrderedDictionary<String, Any>
            var keys: Array = [String]()
            var tempStr: String?
            var level: Int = 0
            
            let content = checkAndRemoveFirstAndLastBrackets(jsonString)
            
            orderDictionary = OrderedDictionary<String, Any>()
            
            for (index, char) in content.enumerated() {
                
                if char == "{" || char == "["{
                    level = level + 1
                }
                if char == "}" || char == "]"{
                    level = level - 1
                }
                
                if (level == 0 && char == ",") || (level == 0 && index == String(content).count - 1) {
                    
                    if (level == 0 && index == String(content).count - 1) {
                        tempStr = (tempStr ?? "") + String(char)
                    }
                    
                    if tempStr?.count ?? 0 >= 0 {
                        keys.append(String(tempStr!))
                        tempStr = nil
                    }
                } else {
                    tempStr = (tempStr ?? "") + String(char)
                }
            }
            
            for content: String in keys {
                
                let keyAndValue: (String, Any) = getKeyAndValueFromString(content)
                let key: String = keyAndValue.0
                let value: Any = keyAndValue.1
                
                if value is String {
                    if isDictionaryJsonString(value as! String) {
                        orderDictionary[key] = self.handleString(String(value as! String))
                    } else if isArrayJsonString(value as! String) {
                        orderDictionary[key] = self.handleString(String(value as! String))
                    } else {
                        orderDictionary[key] = value
                    }
                } else {
                    orderDictionary[key] = value
                }

            }
            
            return orderDictionary;
        }
        
        if isArrayJsonString(jsonString) {
            
            var resultArray: Array = Array<Any>()
            var tempStr: String?
            var level: Int = 0
            
            let content = checkAndRemoveFirstAndLastBrackets(jsonString)
            
            for (index, char) in content.enumerated() {
                
                if char == "{" || char == "["{
                    level = level + 1
                }
                if char == "}" || char == "]"{
                    level = level - 1
                }
                
                if (level == 0 && char == ",") || (level == 0 && index == String(content).count - 1) {
                    if (level == 0 && index == String(content).count - 1) {
                        tempStr = (tempStr ?? "") + String(char)
                    }
                    if tempStr == "[]" {
                        return resultArray
                    } else if isDictionaryJsonString(tempStr ?? "") {
                        resultArray.append(self.handleString(tempStr!) as Any)
                    } else if isArrayJsonString(tempStr ?? "") {
                        resultArray.append(self.handleString(tempStr!) as Any)
                    } else {
                        resultArray.append(checkAndRemoveFirstAndLastDoubleQuotes(String(tempStr ?? "")))
                    }
                    tempStr = nil
                } else {
                    tempStr = (tempStr ?? "") + String(char)
                }
            }
            return resultArray
        }
        return nil
    }
    
    class public func handleString(jsonString: String) -> Any? {

        if isDictionaryJsonString(jsonString) {
            
            var orderDictionary: Dictionary<String, Any>
            var keys: Array = [String]()
            var tempStr: String?
            var level: Int = 0
            
            let content = checkAndRemoveFirstAndLastBrackets(jsonString)
            
            orderDictionary = Dictionary<String, Any>()
            
            for (index, char) in content.enumerated() {
                
                if char == "{" || char == "["{
                    level = level + 1
                }
                if char == "}" || char == "]"{
                    level = level - 1
                }
                
                if (level == 0 && char == ",") || (level == 0 && index == String(content).count - 1) {
                    
                    if (level == 0 && index == String(content).count - 1) {
                        tempStr = (tempStr ?? "") + String(char)
                    }
                    
                    if tempStr?.count ?? 0 >= 0 {
                        keys.append(String(tempStr!))
                        tempStr = nil
                    }
                } else {
                    tempStr = (tempStr ?? "") + String(char)
                }
            }
            
            for content: String in keys {
                
                let keyAndValue: (String, Any) = getKeyAndValueFromString(content)
                let key: String = keyAndValue.0
                let value: Any = keyAndValue.1
                
                if value is String {
                    if isDictionaryJsonString(value as! String) {
                        orderDictionary[key] = self.handleString(jsonString: String(value as! String))
                    } else if isArrayJsonString(value as! String) {
                        orderDictionary[key] = self.handleString(jsonString: String(value as! String))
                    } else {
                        orderDictionary[key] = value
                    }
                } else {
                    orderDictionary[key] = value
                }

            }
            
            return orderDictionary;
        }
        
        if isArrayJsonString(jsonString) {
            
            var resultArray: Array = Array<Any>()
            var tempStr: String?
            var level: Int = 0
            
            let content = checkAndRemoveFirstAndLastBrackets(jsonString)
            
            for (index, char) in content.enumerated() {
                
                if char == "{" || char == "["{
                    level = level + 1
                }
                if char == "}" || char == "]"{
                    level = level - 1
                }
                
                if (level == 0 && char == ",") || (level == 0 && index == String(content).count - 1) {
                    if (level == 0 && index == String(content).count - 1) {
                        tempStr = (tempStr ?? "") + String(char)
                    }
                    if tempStr == "[]" {
                        return resultArray
                    } else if isDictionaryJsonString(tempStr ?? "") {
                        resultArray.append(self.handleString(jsonString: tempStr!) as Any)
                    } else if isArrayJsonString(tempStr ?? "") {
                        resultArray.append(self.handleString(jsonString: tempStr!) as Any)
                    } else {
                        resultArray.append(checkAndRemoveFirstAndLastDoubleQuotes(String(tempStr ?? "")))
                    }
                    tempStr = nil
                } else {
                    tempStr = (tempStr ?? "") + String(char)
                }
            }
            return resultArray
        }
        return nil
    }
}

extension StringProtocol {
    var double: Double? { Double(self) }
    var float: Float? { Float(self) }
    var integer: Int? { Int(self) }
}
