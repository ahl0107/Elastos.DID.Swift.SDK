
public class CredentialBuilder {
    
    private var target: DID
    private var credential: VerifiableCredential
    private var signKey: DIDURL
    private var document: DIDDocument
    
    public init(did: DID, doc: DIDDocument, signKey:DIDURL) {
        self.target = did
        self.document = doc
        self.signKey = signKey
        self.credential = VerifiableCredential()
        self.credential.issuer = doc.subject
    }
    
    public func id(_ id: DIDURL) throws -> CredentialBuilder {
        self.credential.id = id
        return self
    }
    
    public func idString(_ idString: String) throws -> CredentialBuilder {
        return try self.id(DIDURL(target, idString))
    }
    
    public func types(_ types: Array<String>) throws -> CredentialBuilder {
        guard types.count != 0 else {
            throw DIDError.illegalArgument("type is nil.")
        }
        
        self.credential.types = types
        return self
    }
    
    private func getMaxExpires() -> Date {
        var date: Date = Date()
        if credential.issuanceDate != nil {
            date = self.credential.issuanceDate!
        }
        return DateFormater.dateToWantDate(date, MAX_VALID_YEARS)
    }
    
    public func defaultExpirationDate() {
        credential.expirationDate = getMaxExpires()
    }

    public func expirationDate(_ expirationDate: Date) -> CredentialBuilder {
        let maxExpires = getMaxExpires()
        var date: Date = expirationDate
        if DateFormater.comporsDate(expirationDate, maxExpires) {
            date = maxExpires
        }
        credential.expirationDate = date
        
        return self
    }
    
    public func properties(_ properties: Dictionary<String, Any>) throws -> CredentialBuilder {
        guard properties.keys.count != 0 else {
            throw DIDError.illegalArgument("properties count is 0.")
        }
        self.credential.subject = CredentialSubject(self.target)
        self.credential.subject.addProperties(properties)
        return self
    }
    
    public func properties(properties: String) throws -> CredentialBuilder {
        
        if let data = properties.data(using: String.Encoding.utf8) {
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? Dictionary<String, Any>
                if dic != nil {
                    var dict: Dictionary<String, Any> = [: ]
                    dic?.forEach{ (key, va) in
                        dict[key] = va
                    }
                    return try self.properties(dict)
                }
                else {
                  throw DIDError.didExpiredError(_desc: "Credential properties is invalid.")
                }
            } catch {
               throw DIDError.didExpiredError(_desc: "Credential properties is invalid.")
            }
        }
        else {
            throw DIDError.didExpiredError(_desc: "Credential properties is invalid.")
        }
    }
    
    public func seal(storepass: String) throws -> VerifiableCredential {
        guard !storepass.isEmpty else {
            throw DIDError.illegalArgument("storepass is empty.")
        }
        
        guard self.credential.id != nil else {
            throw DIDError.illegalArgument("Missing id.")
        }
        
        guard self.credential.subject != nil else {
            throw DIDError.illegalArgument("Missing subject.")
        }
        
        let date = DateFormater.currentDate()
        self.credential.issuanceDate = date
        
        if credential.expirationDate == nil {
            defaultExpirationDate()
        }
        
        let dic = self.credential.toJson(true, true)
        let json = JsonHelper.creatJsonString(dic: dic)
        let sig: String = try (self.document.sign(signKey, storepass, json))
        
        let proof = CredentialProof(DEFAULT_PUBLICKEY_TYPE, signKey, sig)
        self.credential.proof = proof
        
        return self.credential
    }
}
