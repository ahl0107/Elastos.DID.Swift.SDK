import Foundation

public class JwtBuilder {

    var publicKeyClosure: ((_ id: String?) throws -> KeyValuePairs<Any, Any>?)
    var privateKeyClosure: ((_ id: String?, _ storepass: String) throws -> KeyValuePairs<Any, Any>?)

    init(publicKey: @escaping (_ id: String?) throws -> KeyValuePairs<Any, Any>?, privateKey: @escaping (_ id: String?, _ storepass: String) throws -> KeyValuePairs<Any, Any>?) {
        publicKeyClosure = publicKey
        privateKeyClosure = privateKey
    }
}
