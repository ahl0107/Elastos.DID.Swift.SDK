import Foundation

public class Proof {
    public var type: String!
    public var created: Date?
    public var creator: DIDURL?
    public var signature: String!
    public var verificationMethod: DIDURL!
    
    public var realm: String?
    public var nonce: String?

    // init for document
    init(_ type: String, _ created: Date, _ creator: DIDURL, _ signature: String) {
        self.type = type
        self.created = created
        self.creator = creator
        self.signature = signature
    }
    
    // init for document
    init(_ creator: DIDURL, _ signature: String) {
        self.type = Constants.DEFAULT_PUBLICKEY_TYPE
        self.created = DateFormater.currentDate()
        self.creator = creator
        self.signature = signature
    }
    
    // init for VerifiableCredential
    init(_ type: String, _ method: DIDURL, _ signature: String) {
        self.type = type
        self.verificationMethod = method
        self.signature = signature
    }

    init(_ type: String, _ method: DIDURL, _ realm: String, _ nonce: String, _ signature: String) {
        self.type = type
        self.verificationMethod = method
        self.realm = realm
        self.nonce = nonce
        self.signature = signature
    }
    
    init(_ method: DIDURL, _ realm: String, _ nonce: String, _ signature: String) {
        self.type = Constants.DEFAULT_PUBLICKEY_TYPE
        self.verificationMethod = method
        self.realm = realm
        self.nonce = nonce
        self.signature = signature
    }
    
    func toJson_vc(_ ref: DID, _ normalized: Bool) -> OrderedDictionary<String, Any> {
        var dic: OrderedDictionary<String, Any> = OrderedDictionary()
        var value: String
        //type:
        if normalized || type != Constants.DEFAULT_PUBLICKEY_TYPE {
            dic[Constants.TYPE] = type
        }
        
        // method:
        if normalized || verificationMethod.did != ref {
             value = verificationMethod.toExternalForm()
        }
        else {
            value = "#" + verificationMethod.fragment
        }
        dic[Constants.verificationMethod] = value
        
        // signature:
        dic[Constants.signature] = signature
        return dic
    }

    func toJson_dc(_ normalized: Bool) -> OrderedDictionary<String, Any> {
        var dic: OrderedDictionary<String, Any> = OrderedDictionary()
        //type:
        if normalized || (type != Constants.defaultPublicKeyType) {
            dic[Constants.TYPE] = type
        }
        
        // created
        if created != nil {
            dic[Constants.CREATED] = DateFormater.format(created!)
        }
        
        // creator
        if (normalized) {
            dic[Constants.CREATOR] = creator!.toExternalForm()
        }
        // signature:
        dic[Constants.SIGNATURE_VALUE] = signature
        
        return dic
    }

    func toJson_vp() -> OrderedDictionary<String, Any> {
        var dic: OrderedDictionary<String, Any> = OrderedDictionary()
        var value: String
        //type:
        dic[Constants.TYPE] = type
        
        // method:
        value = verificationMethod.toExternalForm()
        dic[Constants.verificationMethod] = value
        
        // realm
        dic[Constants.realm] = realm!
        
        // nonce
        dic[Constants.nonce] = nonce!
        
        // signature:
        dic[Constants.signature] = signature

        return dic
    }
    
    class func fromJson_dc(_ json: OrderedDictionary<String, Any>, _ refSignKey: DIDURL) throws -> Proof {
        let type: String = try JsonHelper.getString(json, Constants.TYPE, true, Constants.defaultPublicKeyType, "document proof type")
        
        let created: Date = try DateFormater.getDate(json, Constants.CREATED, true, nil, "")!
        
        let creator = try JsonHelper.getDidUrl(json, Constants.CREATOR, true, refSignKey.did, "document proof creator")
        var c = creator
        if creator == nil {
            c = refSignKey
        }
        let signature: String = try JsonHelper.getString(json, Constants.SIGNATURE_VALUE, false, nil, "document proof signature")
        return Proof(type, created, c!, signature)
    }

    // for VerifiableCredential
    class func fromJson_vc(_ json: OrderedDictionary<String, Any>, _ ref: DID?) throws -> Proof {
        let type: String = try JsonHelper.getString(json, Constants.TYPE, true, Constants.defaultPublicKeyType, "crendential proof type")
        let method: DIDURL = try JsonHelper.getDidUrl(json, Constants.verificationMethod, ref, "crendential proof verificationMethod")!
        let signature: String = try JsonHelper.getString(json, Constants.signature, false, nil, "crendential proof signature")
        return Proof(type, method, signature)
    }

    class func fromJson_vp(_ json: OrderedDictionary<String, Any>, _ ref: DID?) throws -> Proof {
        let type: String = try JsonHelper.getString(json, Constants.TYPE, true, Constants.defaultPublicKeyType, "crendential proof type")
        let method: DIDURL = try JsonHelper.getDidUrl(json, Constants.verificationMethod, ref, "presentation proof verificationMethod")!
         let realm: String = try JsonHelper.getString(json, Constants.realm, false, nil, "presentation proof realm")
         let nonce: String = try JsonHelper.getString(json, Constants.nonce, false, nil, "presentation proof nonce")
        let signature: String = try JsonHelper.getString(json, Constants.signature, false, nil, "presentation proof signature")
        return Proof(type, method, realm, nonce, signature)
    }
}
