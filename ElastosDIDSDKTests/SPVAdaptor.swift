
import Foundation
import ElastosDIDSDK
import SPVWrapper

public typealias PasswordCallback = (_ walletDir: String, _ walletId: String) -> String?
public class SPVAdaptor: DIDAdapter {

    var walletDir: String!
    var walletId: String!
    var network: String!
    var handle: OpaquePointer!
    public var passwordCallback: PasswordCallback?
    
    public init(_ walletDir: String, _ walletId: String, _ network: String, _ resolver: String, _ passwordCallback: @escaping PasswordCallback) {
        
       handle = SPV.create(walletDir, walletId, network, resolver)
        print(handle)
        self.walletDir = walletDir
        self.walletId = walletId
        self.network = network
        self.passwordCallback = passwordCallback
    }
    
    public func destroy() {
        SPV.destroy(handle)
        handle = nil
    }
    
    public func isAvailable() throws -> Bool {
       return SPV.isAvailable(handle)
    }
    
    public func createIdTransaction(_ payload: String, _ memo: String?) throws -> String {
        let password = passwordCallback!(walletDir, walletId)
        guard password != nil else {
            throw DIDError.transactionError(_desc: "password is not nil.")
        }
        
        guard handle != nil else {
            throw DIDError.transactionError(_desc: "Unkonw error.")
        }
        let re = SPV.createIdTransaction(handle, password!, payload, memo)
        guard re != nil else {
            throw DIDError.transactionError(_desc: "Unkonw error.")
        }
        return re!
    }
    
    public func resolve(_ requestId: String, _ did: String, _ all: Bool) throws -> String {
        var resuleString: String?
        let url:URL! = URL(string: "http://api.elastos.io:21606")
        var request:URLRequest! = URLRequest.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let parameters: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "resolvedid",
            "params": ["did":did, "all": all],
            "id": requestId
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                    semaphore.signal()
                    return
            }
            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                semaphore.signal()
                return
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            resuleString = responseString
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        guard resuleString != nil else {
            throw DIDError.didResolveError(_desc: "Unkonw error.") 
        }
        return resuleString!
    }
}

