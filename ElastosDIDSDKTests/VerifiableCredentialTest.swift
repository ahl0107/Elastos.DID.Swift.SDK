
import XCTest
import ElastosDIDSDK

class VerifiableCredentialTest: XCTestCase {
    
    func TestKycCredential() {
        do {
            let testData = TestData()
            
            // for integrity check
            _ = try testData.setupStore(true)
            let issuer:DIDDocument = try testData.loadTestIssuer()
            let test: DIDDocument = try testData.loadTestDocument()
            let vc: VerifiableCredential = try testData.loadEmailCredential()
            
            XCTAssertEqual(try DIDURL(test.subject!, "email"), vc.id)
            
            XCTAssertTrue((vc.types).contains("BasicProfileCredential"))
            XCTAssertTrue((vc.types).contains("InternetAccountCredential"))
            XCTAssertTrue((vc.types).contains("EmailCredential"))
            
            XCTAssertEqual(issuer.subject, vc.issuer)
            XCTAssertEqual(test.subject, vc.subject.id)
            XCTAssertEqual("john@example.com", vc.subject.getProperty("email") as! String)
            
            XCTAssertNotNil(vc.issuanceDate)
            XCTAssertNotNil(vc.expirationDate)
            
            XCTAssertFalse(try vc.isExpired())
            XCTAssertTrue(try vc.isGenuine())
            XCTAssertTrue(try vc.isValid())
        }
        catch {
            XCTFail()
        }
    }
    
    func TestSelfProclaimedCredential() {
        do{
            let testData: TestData = TestData()
            
            // for integrity check
            _ = try testData.setupStore(true)
            let test: DIDDocument = try testData.loadTestDocument()
            
            let vc = try testData.loadProfileCredential()
            
            XCTAssertEqual(try DIDURL(test.subject!, "profile"), vc!.id)
            XCTAssertTrue((vc!.types).contains("BasicProfileCredential"))
            XCTAssertTrue((vc!.types).contains("SelfProclaimedCredential"))
            
            XCTAssertEqual(test.subject, vc!.issuer)
            XCTAssertEqual(test.subject, vc!.subject.id)
            
            XCTAssertEqual("John", vc!.subject.getProperty("name") as! String)
            XCTAssertEqual("Male", vc!.subject.getProperty("gender") as! String)
            XCTAssertEqual("Singapore", vc!.subject.getProperty("nation") as! String)
            XCTAssertEqual("English", vc!.subject.getProperty("language") as! String)
            XCTAssertEqual("john@example.com", vc!.subject.getProperty("email") as! String)
            XCTAssertEqual("@john", vc!.subject.getProperty("twitter") as! String)
            XCTAssertNotNil(vc!.issuanceDate)
            XCTAssertNotNil(vc!.expirationDate)
            
            XCTAssertFalse(try vc!.isExpired())
            XCTAssertTrue(try vc!.isGenuine())
            XCTAssertTrue(try vc!.isValid())
        }
        catch {
            XCTFail()
        }
    }
    
    func testParseAndSerializeKycCredential() {
        do{
            let testData: TestData = TestData()
            
            var json: String = try testData.loadTwitterVcNormalizedJson()
            let normalized: VerifiableCredential = try VerifiableCredential.fromJson(json)
            
            json = try testData.loadTwitterVcCompactJson()
            let compact: VerifiableCredential = try VerifiableCredential.fromJson(json)
            
            let vc: VerifiableCredential = try testData.loadTwitterCredential()
            
            XCTAssertEqual(try testData.loadTwitterVcNormalizedJson(), normalized.description(true))
            XCTAssertEqual(try testData.loadTwitterVcNormalizedJson(), compact.description(true))
            XCTAssertEqual(try testData.loadTwitterVcNormalizedJson(), vc.description(true))
            
            XCTAssertEqual(try testData.loadTwitterVcCompactJson(), normalized.description(false))
            XCTAssertEqual(try testData.loadTwitterVcCompactJson(), compact.description(false))
            XCTAssertEqual(try testData.loadTwitterVcCompactJson(), vc.description(false))
        }
        catch {
         print(error)
            XCTFail()
        }
    }
    
    func testParseAndSerializeSelfProclaimedCredential() {
        do {
            let testData: TestData = TestData()
            
            var json: String = try testData.loadProfileVcNormalizedJson()
            let normalized: VerifiableCredential = try VerifiableCredential.fromJson(json)
            
            json = try testData.loadProfileVcCompactJson()
            let compact: VerifiableCredential = try VerifiableCredential.fromJson(json)
            
            let vc = try testData.loadProfileCredential()
            
            XCTAssertEqual(try testData.loadProfileVcNormalizedJson(), normalized.description(true))
            XCTAssertEqual(try testData.loadProfileVcNormalizedJson(), compact.description(true))
            XCTAssertEqual(try testData.loadProfileVcNormalizedJson(), vc!.description(true))
            
            XCTAssertEqual(try testData.loadProfileVcCompactJson(), normalized.description(false))
            XCTAssertEqual(try testData.loadProfileVcCompactJson(), compact.description(false))
            XCTAssertEqual(try testData.loadProfileVcCompactJson(), vc!.description(false))
        }
        catch {
            XCTFail()
        }
    }
    
    func testParseAndSerializeJsonCredential() {
        do {
            let testData = TestData()
            var json = try testData.loadJsonVcNormalizedJson()
            let normalized = try VerifiableCredential.fromJson(json)
            json = try testData.loadJsonVcCompactJson()
            let compact = try VerifiableCredential.fromJson(json)
            let vc = try testData.loadJsonCredential()
            XCTAssertEqual(try testData.loadJsonVcNormalizedJson(), normalized.description(true))
            XCTAssertEqual(try testData.loadJsonVcNormalizedJson(), compact.description(true))
            XCTAssertEqual(try testData.loadJsonVcNormalizedJson(), vc.description(true))

            XCTAssertEqual(try testData.loadJsonVcCompactJson(), normalized.description(false))
            XCTAssertEqual(try testData.loadJsonVcCompactJson(), compact.description(false))
            XCTAssertEqual(try testData.loadJsonVcCompactJson(), vc.description(false))
        } catch {
            XCTFail()
        }
    }
}
