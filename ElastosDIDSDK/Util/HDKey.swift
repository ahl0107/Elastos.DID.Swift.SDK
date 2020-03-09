import Foundation

class HDKey: NSObject {
    static let PUBLICKEY_BYTES : Int = CHDKey.PUBLICKEY_BYTES
    static let PRIVATEKEY_BYTES: Int = CHDKey.PRIVATEKEY_BYTES
    static let EXTENDED_PRIVATE_BYTES: Int = CHDKey.EXTENDEDKEY_BYTES
    static let SEED_BYTES: Int = 64
    static let PUBLICKEY_BASE58_BYTES: Int = 64
    
    private var chdKey: UnsafeMutablePointer<CHDKey>

    class DerivedKey {
        private var cderivedKey: UnsafeMutablePointer<CDerivedKey>

        init(_ chdkey: UnsafeMutablePointer<CHDKey>, _ index: Int) {
            let cderivedKey: UnsafeMutablePointer<CDerivedKey> = UnsafeMutablePointer<CDerivedKey>.allocate(capacity: 66)
            self.cderivedKey = HDKey_GetDerivedKey(chdkey, Int32(index), cderivedKey)
        }

        public class func getAddress(_ pk: [UInt8]) -> String  {
            var pkData: Data = Data(bytes: pk, count: pk.count)
            let cpks: UnsafeMutablePointer<UInt8> = pkData.withUnsafeMutableBytes { (bytes) -> UnsafeMutablePointer<UInt8> in
                return bytes
            }
            let address: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: 48)
            let cid = HDKey_PublicKey2Address(cpks, address, 48)
            
            return (String(cString: cid!))
        }

        func getAddress() -> String {
            let cid = DerivedKey_GetAddress(self.cderivedKey)
            return (String(cString: cid!))
        }
        
        public func getPublicKeyData() -> Data {
            let cpublicKeyPointer = DerivedKey_GetPublicKey(self.cderivedKey)
            let publicKeyPointerToArry: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: cpublicKeyPointer, count: PUBLICKEY_BYTES)
            let publicKeyData: Data = Data(buffer: publicKeyPointerToArry)
            return publicKeyData
        }
        
        public func getPublicKeyBytes() -> [UInt8] {
            let cpublicKeyPointer = DerivedKey_GetPublicKey(self.cderivedKey)
            let publicKeyPointerToArry: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: cpublicKeyPointer, count: PUBLICKEY_BYTES)
            let publicKeyData: Data = Data(buffer: publicKeyPointerToArry)
            return [UInt8](publicKeyData)
        }

        func getPublicKeyBase58() -> String {
            let publickeyPointer: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>.allocate(capacity: PUBLICKEY_BYTES)
            let cpublickeybase58 = DerivedKey_GetPublicKeyBase58(self.cderivedKey, publickeyPointer, Int32(PUBLICKEY_BASE58_BYTES))
            return String(cString: cpublickeybase58)
        }
        
        public func getPrivateKeyData() -> Data {
            let privatekeyPointer = DerivedKey_GetPrivateKey(self.cderivedKey)
            let privatekeyPointerToArry: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: privatekeyPointer, count: PRIVATEKEY_BYTES)
            let privatekeyData: Data = Data(buffer: privatekeyPointerToArry)
            return privatekeyData
        }
        
        public func getPrivateKeyBytes() -> [UInt8] {
            let privatekeyPointer = DerivedKey_GetPrivateKey(self.cderivedKey)
            let privatekeyPointerToArry: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: privatekeyPointer, count: PRIVATEKEY_BYTES)
            let privatekeyData: Data = Data(buffer: privatekeyPointerToArry)
            return [UInt8](privatekeyData)
        }
        
        func serialize() -> Data {
            return getPrivateKeyData()
        }
        
//        class func deserialize(_ data: Data) -> DerivedKey? {
//        }

        func wipe() {
            DerivedKey_Wipe(self.cderivedKey)
        }
    }

    init(_ chdKey: UnsafeMutablePointer<CHDKey>) {
        self.chdKey = chdKey
    }

    class func fromMnemonic(_ mnemonic: String, _ passPhrase: String, _ language: Int) -> HDKey {
        let cmnemonic = mnemonic.toUnsafePointerInt8()!
        let cpassphrase = passPhrase.toUnsafePointerInt8()!
        let chdKey: UnsafeMutablePointer<CHDKey> = UnsafeMutablePointer<CHDKey>.allocate(capacity: 66)
        let chdkey = HDKey_FromMnemonic(cmnemonic, cpassphrase, Int32(language), chdKey)
        return HDKey(chdkey)
    }

    class func fromSeed(_ seed: Data) -> HDKey {
        let cseed: UnsafePointer<UInt8> = seed.withUnsafeBytes { bytes -> UnsafePointer<UInt8> in
            return bytes
        }
        
        let chdKey: UnsafeMutablePointer<CHDKey> = UnsafeMutablePointer<CHDKey>.allocate(capacity: 66)
        let chdkey = HDKey_FromSeed(cseed, Int32(seed.count), chdKey)
        return HDKey(chdkey)
    }

    class func fromExtendedKey(_ extendedKey: Data) -> HDKey {
        var extendedkeyData = extendedKey
        let cextendedkey = extendedkeyData.withUnsafeMutableBytes { re -> UnsafeMutablePointer<UInt8> in
            return re
        }
        let chdKey: UnsafeMutablePointer<CHDKey> = UnsafeMutablePointer<CHDKey>.allocate(capacity: 66)
        let chdkey = HDKey_FromExtendedKey(cextendedkey, Int32(extendedKey.count), chdKey)
        return HDKey(chdkey)
    }
    
    func derivedKey(_ index: Int) -> HDKey.DerivedKey {
        return DerivedKey(self.chdKey, index)
    }

    func serialize() throws -> Data {
        let cextendedkey = UnsafeMutablePointer<UInt8>.allocate(capacity: HDKey.EXTENDED_PRIVATE_BYTES)
        let csize = HDKey_Serialize(self.chdKey, cextendedkey, Int32(HDKey.EXTENDED_PRIVATE_BYTES))
        if csize <= -1 {
            throw DIDError.didStoreError("HDKey_Serialize error.")
        }
        let extendedkeyPointerToArry: UnsafeBufferPointer<UInt8> = UnsafeBufferPointer(start: cextendedkey, count: HDKey.EXTENDED_PRIVATE_BYTES)
        return Data(buffer: extendedkeyPointerToArry)
    }

    func serialize() -> String {
        // TODO:
        return "TODO"
    }
    
    class func deserialize(_ keyData: Data) throws -> HDKey {
        if keyData.count == SEED_BYTES {
            return HDKey.fromSeed(keyData)
        }
        else if (keyData.count == EXTENDED_PRIVATE_BYTES) {
            return HDKey.fromExtendedKey(keyData)
        }
        else {
            // TODO:
            throw DIDError.unknownFailure("deserialize error.")
        }
    }
    
    class func deserialize(_ keyData: [UInt8]) throws -> HDKey {
        let keyData = Data(bytes: keyData, count: keyData.count)
        if keyData.count == SEED_BYTES {
            return HDKey.fromSeed(keyData)
        }
        else if (keyData.count == EXTENDED_PRIVATE_BYTES) {
            return HDKey.fromExtendedKey(keyData)
        }
        else {
            // TODO:
            throw DIDError.unknownFailure("deserialize error.")
        }
    }

    func wipe() {
        HDKey_Wipe(UnsafeMutablePointer<CHDKey>(mutating: chdKey))
    }
}
