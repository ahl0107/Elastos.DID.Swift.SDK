
import XCTest
import ElastosDIDSDK

class DIDStoreTests: XCTestCase {
    
    var store: DIDStore!
    static var ids: Dictionary<DID, String> = [: ]
    static var primaryDid: DID!
    var adapter: SPVAdaptor!
    
    func testCreateEmptyStore() {
        do {
            let testData: TestData = TestData()
            try _ = testData.setupStore(true)
            _ = testData.exists(storeRoot)
            
            let path = storeRoot + "/" + ".meta"
            _ = testData.existsFile(path)
        } catch {
            print("testCreateEmptyStore error: \(error)")
            XCTFail()
        }
    }
    
    func testCreateDidInEmptyStore()  {
        do {
            let testData: TestData = TestData()
            let store = try testData.setupStore(true)
            _ = try testData.initIdentity()
            _  = try store.newDid("this will be fail", storePass)
        } catch {
            print(error)
            XCTAssertTrue(true)
        }
    }

    func testInitPrivateIdentity0() {
        do {
            let testData: TestData = TestData()
            var store: DIDStore = try testData.setupStore(true)
            
            XCTAssertFalse(try store.containsPrivateIdentity())
            
            _ = try testData.initIdentity()
            XCTAssertTrue(try store.containsPrivateIdentity())
                        
            var path = storeRoot + "/" + "private" + "/" + "key"
            XCTAssertTrue(testData.existsFile(path))
            path = storeRoot + "/" + "private" + "/" + "index"
            XCTAssertTrue(testData.existsFile(path))
            
           store = try DIDStore.open("filesystem", storeRoot)
            
            XCTAssertTrue(try store.containsPrivateIdentity())
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testCreateDIDWithAlias() throws {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let alias: String = "my first did"
            
            let doc: DIDDocument = try store.newDid(alias, storePass)
            XCTAssertTrue(try doc.isValid())
            
            var resolved = try doc.subject?.resolve()
            XCTAssertNil(resolved)
            
            _ = try store.publishDid(doc.subject!, storePass)
            var path = storeRoot
            
            path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/document"
            XCTAssertTrue(testData.existsFile(path))
            path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/.meta"
            XCTAssertTrue(testData.existsFile(path))
            
            resolved = try store.resolveDid(doc.subject!, true)!
            
            XCTAssertNotNil(resolved)
            XCTAssertEqual(alias, try resolved!.getAlias())
            XCTAssertEqual(doc.subject, resolved!.subject)
            XCTAssertEqual(doc.proof.signature, resolved!.proof.signature)
            
            XCTAssertTrue(try resolved!.isValid())
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testCreateDIDWithoutAlias() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let doc: DIDDocument = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            
            var resolved = try doc.subject?.resolve(true)
            XCTAssertNil(resolved)
            
            _ = try store.publishDid(doc.subject!, storePass)
            var path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/document"
            XCTAssertTrue(testData.existsFile(path))
            // todo isFile

            path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/.meta"
            XCTAssertFalse(testData.existsFile(path))

            resolved = try doc.subject?.resolve(true)
            XCTAssertNotNil(resolved)
            XCTAssertEqual(doc.subject, resolved!.subject)
            XCTAssertEqual(doc.proof.signature, resolved!.proof.signature)
            XCTAssertTrue(try resolved!.isValid())
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testUpdateDid() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let doc: DIDDocument = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            _ = try store.publishDid(doc.subject!, storePass)
            
            var resolved = try doc.subject?.resolve(true)
            XCTAssertNotNil(resolved)
            try store.storeDid(resolved!)
            
            // Update
            var db: DIDDocumentBuilder = resolved!.edit()
            var key = try TestData.generateKeypair()
            _ = try db.addAuthenticationKey("key1", key.getPublicKeyBase58())
            var newDoc = try db.seal(storepass: storePass)
            XCTAssertEqual(2, newDoc.getPublicKeyCount())
            XCTAssertEqual(2, newDoc.getAuthenticationKeyCount())
            try store.storeDid(newDoc)
            
            _ = try store.publishDid(newDoc.subject!, storePass)
            
            resolved = try doc.subject!.resolve(true)!

            XCTAssertNotNil(resolved)
            XCTAssertEqual(newDoc.description, resolved?.description)
            try store.storeDid(resolved!)

            // Update again
            db = resolved!.edit()
            key = try TestData.generateKeypair()
            _ = try db.addAuthenticationKey("key2", key.getPublicKeyBase58())
            newDoc = try! db.seal(storepass: storePass)
            XCTAssertEqual(3, newDoc.getPublicKeyCount())
            XCTAssertEqual(3, newDoc.getAuthenticationKeyCount())
            try store.storeDid(newDoc)
            _ = try store.publishDid(newDoc.subject!, storePass)
            
            resolved = try! doc.subject?.resolve(true)
            key.derivedKeyWipe()
            XCTAssertNotNil(resolved)
            XCTAssertEqual(newDoc.description, resolved?.description)
        } catch {
            XCTFail()
        }
    }
    
    func testUpdateNonExistedDid() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            

            let doc = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            // fake a txid
            let meta = DIDMeta()
            meta.store = store
            meta.transactionId = "12345678"
            try store.storeDidMeta(doc.subject!, meta)

            // Update will fail
            _ = try store.publishDid(doc.subject!, storePass)
        } catch  {
            // todo:  Create ID transaction error.
            XCTAssertTrue(true)
        }
    }
    
    func testDeactivateSelfAfterCreate() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try! testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let doc = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            
            _ = try store.publishDid(doc.subject!, storePass)
            let resolved: DIDDocument = try doc.subject!.resolve(true)!
            XCTAssertNotNil(resolved)
            
            _ = try store.deactivateDid(doc.subject!, storePass)
            
            let resolvedNil = try doc.subject!.resolve(true)
            
            XCTAssertNil(resolvedNil)
        } catch  {
            switch error as! DIDError{
            case .didDeactivatedError(_desc: ""):
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testDeactivateSelfAfterUpdate() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let doc = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            
            _ = try store.publishDid(doc.subject!, storePass)
            
            var resolved: DIDDocument! = try doc.subject!.resolve(true)
            XCTAssertNotNil(resolved)
            try store.storeDid(resolved!)
            
            // update
            let db: DIDDocumentBuilder = resolved.edit()
            let key = try TestData.generateKeypair()
            _ = try db.addAuthenticationKey("key2", key.getPublicKeyBase58())
            let newDoc = try db.seal(storepass: storePass)
            key.derivedKeyWipe()
            XCTAssertEqual(2, newDoc.getPublicKeyCount())
            XCTAssertEqual(2, newDoc.getAuthenticationKeyCount())
            try store.storeDid(newDoc)
            
            _ = try store.publishDid(newDoc.subject!, storePass)
            
            resolved = try doc.subject!.resolve(true)
            XCTAssertNotNil(resolved)
            XCTAssertEqual(newDoc.toJson(true, forSign: true), resolved?.toJson(true, forSign: true))
            try store.storeDid(resolved!)
            
            _ = try store.deactivateDid(newDoc.subject!, storePass)
            
            resolved = try doc.subject!.resolve(true)
            
            let resolvedNil: DIDDocument? = try doc.subject!.resolve(true)
            
            XCTAssertNil(resolvedNil)
        } catch  {
            switch error as! DIDError {
            case .didDeactivatedError(_desc: ""):
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testDeactivateWithAuthorization1() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            let doc = try store.newDid(storePass)
            XCTAssertTrue(try doc.isValid())
            
            _ = try store.publishDid(doc.subject!, storePass)
            
            var resolved: DIDDocument! = try doc.subject!.resolve(true)
            XCTAssertNotNil(resolved)
            XCTAssertEqual(doc.toJson(true, forSign: true), resolved?.toJson(true, forSign: true))
            
            var target = try store.newDid(storePass)
            let db: DIDDocumentBuilder = target.edit()
            _ = try db.authorizationDid("recovery", doc.subject!.description)
            target = try db.seal(storepass: storePass)
            XCTAssertNotNil(target)
            XCTAssertEqual(1, target.getAuthorizationKeyCount())
            let controller = target.getAuthorizationKeys()[0].controller
            XCTAssertEqual(doc.subject, controller)
            try store.storeDid(target)
                        
            _ = try store.publishDid(target.subject!, storePass)
            resolved = try target.subject!.resolve()
            XCTAssertNotNil(resolved)
            XCTAssertEqual(target.toJson(true, forSign: true), resolved.toJson(true, forSign: true))
            
            _ = try store.deactivateDid(target.subject!, doc.subject!, storePass)
            
            let resolvedNil: DIDDocument? = try target.subject!.resolve(true)
            XCTAssertNil(resolvedNil)
        } catch  {
            switch error as! DIDError {
            case .didDeactivatedError(_desc: ""):
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testDeactivateWithAuthorization2() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            var doc = try store.newDid(storePass)
            let key = try TestData.generateKeypair()
            var db: DIDDocumentBuilder = doc.edit()
            let id = try DIDURL(doc.subject!, "key-2")
            _ = try db.addAuthenticationKey(id, key.getPublicKeyBase58())
            try store.storePrivateKey(doc.subject!, id, key.getPrivateKeyData(), storePass)
            doc = try db.seal(storepass: storePass)
            XCTAssertTrue(try doc.isValid())
            XCTAssertEqual(2, doc.getAuthenticationKeyCount())
            try store.storeDid(doc)
            
            _ = try store.publishDid(doc.subject!, storePass)
            
            var resolved: DIDDocument = try doc.subject!.resolve(true)!
            XCTAssertNotNil(resolved)
            XCTAssertEqual(doc.toJson(true, forSign: true), resolved.toJson(true, forSign: true))
            
            var target: DIDDocument = try store.newDid(storePass)
            db = target.edit()
            _ = try db.addAuthorizationKey("recovery", doc.subject!.description, key.getPublicKeyBase58())
            target = try db.seal(storepass: storePass)
            XCTAssertNotNil(target)
            XCTAssertEqual(1, target.getAuthorizationKeyCount())
            let controller = target.getAuthorizationKeys()[0].controller
            XCTAssertEqual(doc.subject, controller)
            try store.storeDid(target)
            
            _ = try store.publishDid(target.subject!, storePass)
            
            resolved = try target.subject!.resolve()!
            XCTAssertNotNil(resolved)
            XCTAssertEqual(target.toJson(true, forSign: true), resolved.toJson(true, forSign: true))
            
            _ = try store.deactivateDid(target.subject!, doc.subject!, signKey: id, storePass)
            
            let resolvedNil: DIDDocument? = try target.subject!.resolve(true)
            key.derivedKeyWipe()
            XCTAssertNil(resolvedNil)
        } catch  {
            switch error as! DIDError {
            case .didDeactivatedError(_desc: ""):
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testDeactivateWithAuthorization3() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            var doc = try store.newDid(storePass)
            var db: DIDDocumentBuilder = doc.edit()
            
            let key = try TestData.generateKeypair()
            let id: DIDURL = try DIDURL(doc.subject!, "key-2")
            _ = try db.addAuthenticationKey(id, key.getPublicKeyBase58())
            
            try store.storePrivateKey(doc.subject!, id, key.getPrivateKeyData(), storePass)
            doc = try db.seal(storepass: storePass)
            XCTAssertTrue(try doc.isValid())
            XCTAssertEqual(2, doc.getAuthenticationKeyCount())
            try store.storeDid(doc)
            
            _ = try store.publishDid(doc.subject!, storePass)
            
            var resolved: DIDDocument = try doc.subject!.resolve(true)!
            XCTAssertNotNil(resolved)
            XCTAssertEqual(doc.toJson(true, forSign: true), resolved.toJson(true, forSign: true))
            
            var target = try store.newDid(storePass)
            db = target.edit()
            _ = try db.addAuthorizationKey("recovery", doc.subject!.description, key.getPublicKeyBase58())
            target = try db.seal(storepass: storePass)
            XCTAssertNotNil(target)
            XCTAssertEqual(1, target.getAuthorizationKeyCount())
            let controller = target.getAuthorizationKeys()[0].controller
            XCTAssertEqual(doc.subject, controller)
            try store.storeDid(target)
            
            _ = try store.publishDid(target.subject!, storePass)
            
            resolved = try target.subject!.resolve()!
            XCTAssertNotNil(resolved)
            XCTAssertEqual(target.toJson(true, forSign: true), resolved.toJson(true, forSign: true))
            
            _ = try store.deactivateDid(target.subject!, doc.subject!, storePass)
            
            resolved = try target.subject!.resolve(true)!
            key.derivedKeyWipe()
            XCTAssertNil(resolved)
        } catch  {
            switch error as! DIDError{
            case .didDeactivatedError(_desc: ""):
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }

    func testBulkCreate() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            for i in 0..<100 {
                let alias: String = "my did \(i)"
                let doc: DIDDocument = try store.newDid(alias, storePass)
                XCTAssertTrue(try doc.isValid())
                
                var resolved = try store.resolveDid(doc.subject!, true)
                XCTAssertNil(resolved)
                
                _ = try store.publishDid(doc.subject!, storePass)
                
                var path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/document"
                XCTAssertTrue(testData.existsFile(path))
                
                path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/.meta"
                XCTAssertTrue(testData.existsFile(path))
                
                resolved = try doc.subject?.resolve(true)
                try store.storeDid(resolved!)
                XCTAssertNotNil(resolved)
                XCTAssertEqual(alias, try resolved!.getAlias())
                XCTAssertEqual(doc.subject, resolved!.subject)
                XCTAssertEqual(doc.proof.signature, resolved!.proof.signature)
                XCTAssertTrue(try resolved!.isValid())
            }
            var dids: Array<DID> = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(100, dids.count)
            
            dids = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY)
            XCTAssertEqual(100, dids.count)
            
            dids = try store.listDids(DIDStore.DID_NO_PRIVATEKEY)
            XCTAssertEqual(0, dids.count)
        } catch {
            XCTFail()
        }
    }
    
    func testDeleteDID() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            // Create test DIDs
            var dids: Array<DID> = []
            for i in 0..<100 {
                let alias: String = "my did \(i)"
                let doc: DIDDocument = try store.newDid(alias, storePass)
               _ =  try store.publishDid(doc.subject!, storePass)
                dids.append(doc.subject!)
            }
            
            for i in 0..<100 {
                if (i % 5 != 0){
                    continue
                }
                
                let did: DID = dids[i]
                
                var deleted: Bool = try store.deleteDid(did)
                XCTAssertTrue(deleted)
                
                let path = storeRoot + "/ids/" + did.methodSpecificId
                XCTAssertFalse(testData.exists(path))
                
                deleted = try store.deleteDid(did)
                XCTAssertFalse(deleted)
            }
            var remains: Array<DID> = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(80, remains.count)
            
            remains = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY)
            XCTAssertEqual(80, remains.count)
            
            remains = try store.listDids(DIDStore.DID_NO_PRIVATEKEY)
            XCTAssertEqual(0, remains.count)
        } catch  {
            XCTFail()
        }
    }
    
    func testStoreAndLoadDID() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            // Store test data into current store
            let issuer: DIDDocument = try testData.loadTestIssuer()
            let test: DIDDocument = try testData.loadTestDocument()
                        
            var doc: DIDDocument = try  store.loadDid(issuer.subject!)!
            XCTAssertEqual(issuer.subject, doc.subject)
            XCTAssertEqual(issuer.proof.signature, doc.proof.signature)
            XCTAssertTrue(try doc.isValid())
            
            doc = try store.loadDid(test.subject!.description)!
            XCTAssertEqual(test.subject, doc.subject)
            XCTAssertEqual(test.proof.signature, doc.proof.signature)
            XCTAssertTrue(try doc.isValid())
            
            var dids: Array<DID> = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(2, dids.count)
            
            dids = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY)
            XCTAssertEqual(2, dids.count)
            
            dids = try store.listDids(DIDStore.DID_NO_PRIVATEKEY)
            XCTAssertEqual(0, dids.count)
        }
        catch {
            XCTFail()
        }
    }
    
    func testLoadCredentials() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            // Store test data into current store
            _ = try testData.loadTestIssuer()
            let test: DIDDocument = try testData.loadTestDocument()
            var vc = try testData.loadProfileCredential()
            try vc!.setAlias("MyProfile")
            vc = try testData.loadEmailCredential()
            try vc!.setAlias("Email")
            vc = try testData.loadTwitterCredential()
            try vc!.setAlias("Twitter")
            vc = try testData.loadPassportCredential()
            try vc!.setAlias("Passport")
                        
            var id: DIDURL = try DIDURL(test.subject!, "profile")
            vc = try store.loadCredential(test.subject!, id)
            XCTAssertNotNil(vc)
            XCTAssertEqual("MyProfile", vc!.getAlias())
            XCTAssertEqual(test.subject, vc!.subject.id)
            XCTAssertEqual(id, vc!.id)
            XCTAssertTrue(try vc!.isValid())
            
            // try with full id string
            vc = try store.loadCredential(test.subject!.description, id.description)
            XCTAssertNotNil(vc)
            XCTAssertEqual("MyProfile", vc!.getAlias())
            XCTAssertEqual(test.subject, vc!.subject.id)
            XCTAssertEqual(id, vc!.id)
            XCTAssertTrue(try vc!.isValid())
            
            id = try DIDURL(test.subject!, "twitter")
            vc = try store.loadCredential(test.subject!.description, "twitter")
            XCTAssertNotNil(vc)
            XCTAssertEqual("Twitter", vc!.getAlias())
            XCTAssertEqual(test.subject, vc!.subject.id)
            XCTAssertEqual(id, vc!.id)
            XCTAssertTrue(try vc!.isValid())
            
            vc = try  store.loadCredential(test.subject!.description, "notExist")
            XCTAssertNil(vc)

            id = try DIDURL(test.subject!, "twitter")
            XCTAssertTrue(try store.containsCredential(test.subject!, id))
            XCTAssertTrue(try store.containsCredential(test.subject!.description, "twitter"))
            XCTAssertFalse(try store.containsCredential(test.subject!.description, "notExist"))
        }
        catch {
            XCTFail()
        }
    }
    
    func testListCredentials() {
        do {
            let testData: TestData = TestData()
            let store: DIDStore = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            // Store test data into current store
            _ = try testData.loadTestIssuer()
            let test: DIDDocument = try testData.loadTestDocument()
            var vc = try testData.loadProfileCredential()
            try vc!.setAlias("MyProfile")
            vc = try testData.loadEmailCredential()
            try vc!.setAlias("Email")
            vc = try testData.loadTwitterCredential()
            try vc!.setAlias("Twitter")
            vc = try testData.loadPassportCredential()
            try vc!.setAlias("Passport")
            
            let vcs: Array<DIDURL> = try store.listCredentials(test.subject!)
            XCTAssertEqual(4, vcs.count)
            for id in vcs {
                var re = id.fragment == "profile" || id.fragment == "email" || id.fragment == "twitter" || id.fragment == "passport"
                XCTAssertTrue(re)
                
                re = id.aliasName == "MyProfile" || id.aliasName == "Email" || id.aliasName == "Twitter" || id.aliasName == "Passport"
                XCTAssertTrue(re)
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testDeleteCredential() {
        do {
            let testData: TestData = TestData()
            let store = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            // Store test data into current store
            _ = try testData.loadTestIssuer()
            let test: DIDDocument = try testData.loadTestDocument()
            var vc = try testData.loadProfileCredential()
            try vc!.setAlias("MyProfile")
            vc = try testData.loadEmailCredential()
            try vc!.setAlias("Email")
            vc = try testData.loadTwitterCredential()
            try vc!.setAlias("Twitter")
            vc = try testData.loadPassportCredential()
            try vc!.setAlias("Passport")
            
            var path = storeRoot + "/ids/" + test.subject!.methodSpecificId + "/credentials/twitter/credential"
            XCTAssertTrue(testData.existsFile(path))
            
            path = storeRoot + "/" + "ids" + "/" + test.subject!.methodSpecificId + "/" + "credentials" + "/" + "twitter" + "/" + ".meta"
            XCTAssertTrue(testData.existsFile(path))
            
            path = storeRoot + "/" + "ids" + "/" + test.subject!.methodSpecificId + "/" + "credentials" + "/" + "passport" + "/" + "credential"
            XCTAssertTrue(testData.existsFile(path))
            
            path = storeRoot + "/" + "ids" + "/" + test.subject!.methodSpecificId
                + "/" + "credentials" + "/" + "passport" + "/" + ".meta"
            XCTAssertTrue(testData.existsFile(path))
            
            var deleted: Bool = try store.deleteCredential(test.subject!, DIDURL(test.subject!, "twitter"))
            XCTAssertTrue(deleted)
            
            deleted = try store.deleteCredential(test.subject!.description, "passport")
            XCTAssertTrue(deleted)
            
            deleted = try store.deleteCredential(test.subject!.description, "notExist")
            XCTAssertFalse(deleted)
            
            path = storeRoot + "/" + "ids"
                + "/" + test.subject!.methodSpecificId
                + "/" + "credentials" + "/" + "twitter"
            XCTAssertFalse(testData.existsFile(path))
            
            path = storeRoot + "/" + "ids"
                + "/" + test.subject!.methodSpecificId
                + "/" + "credentials" + "/" + "passport"
            XCTAssertFalse(testData.existsFile(path))
            
            XCTAssertTrue(try store.containsCredential(test.subject!.description, "email"))
            XCTAssertTrue(try store.containsCredential(test.subject!.description, "profile"))
            
            XCTAssertFalse(try store.containsCredential(test.subject!.description, "twitter"))
            XCTAssertFalse(try store.containsCredential(test.subject!.description, "passport"))
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testCompatibility() throws {
        let bundle = Bundle(for: type(of: self))
        let jsonPath: String = bundle.path(forResource: "teststore", ofType: "")!
        print(jsonPath)
        
        try DIDBackend.createInstance(DummyAdapter(), TestData.getResolverCacheDir())
        let store = try! DIDStore.open("filesystem", jsonPath)
        
        let dids = try! store.listDids(DIDStore.DID_ALL)
        XCTAssertEqual(2, dids.count)
        
        for did in dids {
            if did.alias == "Issuer" {
                let vcs: [DIDURL] = try! store.listCredentials(did)
                XCTAssertEqual(1, vcs.count)
                
                let id: DIDURL = vcs[0]
                XCTAssertEqual("Profile", id.aliasName)
                
                XCTAssertNotNil(try! store.loadCredential(did, id))
            } else if did.alias == "Test" {
                let vcs: [DIDURL] = try! store.listCredentials(did)
                XCTAssertEqual(4, vcs.count)
                
                for id: DIDURL in vcs {
                    XCTAssertTrue(id.aliasName == "Profile"
                    || id.aliasName == "Email"
                    || id.aliasName == "Passport"
                    || id.aliasName == "Twitter")
                    
                    XCTAssertNotNil(try! store.loadCredential(did, id))
                }
            }
        }
    }
    
    func testCompatibilityNewDIDWithWrongPass() {
        do {
            try DIDBackend.createInstance(DummyAdapter(), TestData.getResolverCacheDir())
            let bundle = Bundle(for: type(of: self))
            let jsonPath = bundle.path(forResource: "teststore", ofType: "")
            let store = try! DIDStore.open("filesystem", jsonPath!)

            _ = try store.newDid("wrongpass");
        } catch {
            if error is DIDError {
                let err = error as! DIDError
                switch err {
                case .didStoreError(_desc: "decryptFromBase64 error."):
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }
    
    func testCompatibilityNewDID() throws {
        
        try DIDBackend.createInstance(DummyAdapter(), TestData.getResolverCacheDir())
        let bundle = Bundle(for: type(of: self))
        let jsonPath = bundle.path(forResource: "teststore", ofType: "")
        let store = try! DIDStore.open("filesystem", jsonPath!)
        
        let doc: DIDDocument = try! store.newDid(storePass)
        XCTAssertNotNil(doc)
                
        _ = try! store.deleteDid(doc.subject!)
    }

    func createDataForPerformanceTest(_ store: DIDStore) {
        do {
            var props: Dictionary<String, String> = [: ]
            props["name"] = "John"
            props["gender"] = "Male"
            props["nation"] = "Singapore"
            props["language"] = "English"
            props["email"] = "john@example.com"
            props["twitter"] = "@john"
            
            for i in 0..<10 {
                let alias: String = "my did \(i)"
                let doc: DIDDocument = try store.newDid(alias, storePass)
                
                let issuer: Issuer = try Issuer(doc)
                let cb: CredentialBuilder = issuer.issueFor(did: doc.subject!)
                let vc: VerifiableCredential = try cb.idString("cred-1")
                    .types(["BasicProfileCredential", "InternetAccountCredential"])
                    .properties(props)
                    .seal(storepass: storePass)
                try store.storeCredential(vc)
            }
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testStorePerformance(_ cached: Bool) {
        do {
            _ = DummyAdapter()
            _ = TestData()
            TestData.deleteFile(storeRoot)
            var store: DIDStore
            if (cached){
               store = try DIDStore.open("filesystem", storeRoot)
            }
            else {
               store = try DIDStore.open("filesystem", storeRoot, 0, 0)
            }
                        
            let mnemonic: String = try Mnemonic.generate(0)
            try store.initPrivateIdentity(0, mnemonic, passphrase, storePass, true)
            
            createDataForPerformanceTest(store)
            let dids: Array<DID> = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(10, dids.count)
            // TODO: TimeMillis
            /*
             long start = System.currentTimeMillis()
             private void testStorePerformance(boolean cached) throws DIDException {
             
             for (int i = 0; i < 1000; i++) {
             for (DID did : dids) {
             DIDDocument doc = store.loadDid(did);
             assertEquals(did, doc.getSubject());
             
             DIDURL id = new DIDURL(did, "cred-1");
             VerifiableCredential vc = store.loadCredential(did, id);
             assertEquals(id, vc.getId());
             }
             }
             
             long end = System.currentTimeMillis();
             
             System.out.println("Store " + (cached ? "with " : "without ") +
             "cache took " + (end - start) + " milliseconds.");
             }
             */
            
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testStoreWithCache() {
        testStorePerformance(true)
    }
    
    func testStoreWithoutCache() {
        testStorePerformance(false)
    }
    
    func testMultipleStore() {
        do {
            var stores: Array = Array<DIDStore>()
            var docs: Array = Array<DIDDocument>()
            
            for i in 0..<10 {
                let path = storeRoot + String(i)
                TestData.deleteFile(path)
                let store: DIDStore = try DIDStore.open("filesystem", storeRoot + String(i))
                stores.append(store)
                let mnemonic: String = try Mnemonic.generate(0)
                try store.initPrivateIdentity(0, mnemonic, passphrase, storePass, true)
            }
            
            for i in 0..<10 {
                let doc: DIDDocument = try stores[i].newDid(storePass)
                XCTAssertNotNil(doc)
                docs.append(doc)
            }
            
            for i in 0..<10 {
                let doc = try stores[i].loadDid(docs[i].subject!)
                XCTAssertNotNil(doc)
                XCTAssertEqual(docs[i].toJson(true, forSign: true), doc!.toJson(true, forSign: true))
            }
            
        } catch {
            print(error)
            XCTFail()
        }

    }
    
    func testChangePassword() {
        do {
            let testData: TestData = TestData()
            let store = try testData.setupStore(true)
            _ = try testData.initIdentity()
            
            for i in 0..<10 {
                let alias: String = "my did \(i)"
                let doc = try store.newDid(alias, storePass)
                XCTAssertTrue(try doc.isValid())
                var resolved = try doc.subject!.resolve(true)
                XCTAssertNil(resolved)
                _ = try store.publishDid(doc.subject!, storePass)
                var path: String = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/document"
                XCTAssertTrue(testData.existsFile(path))
                
                path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/.meta"
                XCTAssertTrue(testData.existsFile(path))
                resolved = try doc.subject!.resolve(true)
                XCTAssertNotNil(resolved)
                try store.storeDid(resolved!)
                XCTAssertEqual(alias, try resolved!.getAlias())
                XCTAssertEqual(doc.subject, resolved?.subject)
                XCTAssertEqual(doc.proof.signature, resolved?.proof.signature)
                XCTAssertTrue(try resolved!.isValid())
            }
            var dids = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY);
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_NO_PRIVATEKEY);
            XCTAssertEqual(0, dids.count)

            try store.changePassword(storePass, "newpasswd")

            dids = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY)
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_NO_PRIVATEKEY)
            XCTAssertEqual(0, dids.count)

            let doc = try store.newDid("newpasswd")
            XCTAssertNotNil(doc)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testChangePasswordWithWrongPassword() {
        do {
            let testData: TestData = TestData()
            let store = try testData.setupStore(true)
            _ = try testData.initIdentity()
            for i in 0..<10 {
                let alias = "my did \(i)"
                let doc = try store.newDid(alias, storePass)
                XCTAssertTrue(try doc.isValid())
                var resolved = try doc.subject!.resolve(true)
                XCTAssertNil(resolved)
                _ = try store.publishDid(doc.subject!, storePass)
                var path: String = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/document"
                XCTAssertTrue(testData.existsFile(path))
                
                path = storeRoot + "/ids/" + doc.subject!.methodSpecificId + "/.meta"
                XCTAssertTrue(testData.existsFile(path))
                resolved = try doc.subject!.resolve(true)
                XCTAssertNotNil(resolved)
                try store.storeDid(resolved!)
                XCTAssertEqual(alias, try resolved?.getAlias())
                XCTAssertEqual(doc.subject, resolved?.subject)
                XCTAssertEqual(doc.proof.signature, resolved?.proof.signature)
                XCTAssertTrue(try resolved!.isValid())
            }
            var dids = try store.listDids(DIDStore.DID_ALL)
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_HAS_PRIVATEKEY)
            XCTAssertEqual(10, dids.count)

            dids = try store.listDids(DIDStore.DID_NO_PRIVATEKEY)
            XCTAssertEqual(0, dids.count)

            try store.changePassword("wrongpasswd", "newpasswd")

            // Dead code
            let doc = try store.newDid("newpasswd")
            XCTAssertNotNil(doc)
        } catch {
            if error is DIDError {
                let err = error as! DIDError
                switch err {
                case .didStoreError(_desc: "Change store password failed."):
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            }
        }
    }
    
}

