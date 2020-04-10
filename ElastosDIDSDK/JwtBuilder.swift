import Foundation
import SwiftJWT

public class JwtBuilder<T: Claims> {

    var h: Header?
    var c: T?
    var publicKeyClosure: ((_ id: String?) throws -> String?)?
    var privateKeyClosure: ((_ id: String?, _ storepass: String) throws -> String?)?

    init(publicKey: @escaping (_ id: String?) throws -> String?, privateKey: @escaping (_ id: String?, _ storepass: String) throws -> String?) {
        publicKeyClosure = publicKey
        privateKeyClosure = privateKey
    }

    func header(header: Header = Header()) -> JwtBuilder {
        self.h = header
        return self
    }

    func claims(claims: T) -> JwtBuilder {
        self.c = claims
        return self
    }

    func sign(using password: String) throws -> String {
        let jwt = JWT(header: self.h!, claims: self.c!)
        let privateKey = try self.privateKeyClosure!(nil, password)
        let jwtSigner = JWTSigner.rs256(privateKey: (privateKey?.data(using: .utf8))!)
        let signedJWT = try jwt.sign(using: jwtSigner)

        return signedJWT
    }
}
