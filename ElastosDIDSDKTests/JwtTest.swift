
import XCTest
@testable import ElastosDIDSDK

class JwtTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJwt() {
        do {
            let testData = TestData()
            _ = testData.setupStore(true)
            testData.initIdentity()

            let doc = testData.loadTestDocument()
            XCTAssertNotNil(doc)
            XCTAssertTrue(doc.isValid)

            let h = Header()
            h["library"] = "Elastos DID"
            h["version"] = "1.0"

        } catch {
            XCTFail()
        }
    }

    /*
     @Test
     public void jwtTest()
             throws DIDException, IOException, JwtException {
         Header h = JwtBuilder.createHeader();
         h.setType(Header.JWT_TYPE)
             .setContentType("json");
         h.put("library", "Elastos DID");
         h.put("version", "1.0");

         Calendar cal = Calendar.getInstance();
         cal.set(Calendar.MILLISECOND, 0);
         Date iat = cal.getTime();
         cal.add(Calendar.MONTH, -1);
         Date nbf = cal.getTime();
         cal.add(Calendar.MONTH, 4);
         Date exp = cal.getTime();

         Claims b = JwtBuilder.createClaims();
         b.setSubject("JwtTest")
             .setId("0")
             .setIssuer(doc.getSubject().toString())
             .setAudience("Test cases")
             .setIssuedAt(iat)
             .setExpiration(exp)
             .setNotBefore(nbf)
             .put("foo", "bar");

         String token = doc.jwtBuilder()
                 .setHeader(h)
                 .setClaims(b)
                 .compact();

         assertNotNull(token);
         printJwt(token);

         JwtParser jp = doc.jwtParserBuilder().build();
         Jwt<Claims> jwt = jp.parseClaimsJwt(token);
         assertNotNull(jwt);

         h = jwt.getHeader();
         assertNotNull(h);
         assertEquals("json", h.getContentType());
         assertEquals(Header.JWT_TYPE, h.getType());
         assertEquals("Elastos DID", h.get("library"));
         assertEquals("1.0", h.get("version"));

         Claims c = jwt.getBody();
         assertNotNull(c);
         assertEquals("JwtTest", c.getSubject());
         assertEquals("0", c.getId());
         assertEquals(doc.getSubject().toString(), c.getIssuer());
         assertEquals("Test cases", c.getAudience());
         assertEquals(iat, c.getIssuedAt());
         assertEquals(exp, c.getExpiration());
         assertEquals(nbf, c.getNotBefore());
         assertEquals("bar", c.get("foo", String.class));
     }

     */

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
