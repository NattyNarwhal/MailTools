//
//  ParserTests.swift
//  MailToolsTests
//
//  Created by Calvin Buckley on 2024-09-30.
//

@testable import MailToolsCommon
import Testing

struct ParserTests {

    @Test func checkTopPost() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let html = """
        <html>
         <head></head>
         <body style="overflow-wrap: break-word; -webkit-nbsp-mode: space; line-break: after-white-space;" class="ApplePlainTextBody">
          top post
          <br id="lineBreakAtBeginningOfMessage" />
          <div class="AppleOriginalContents">
           <br />
           <blockquote type="cite">
            <div>
             On Sep 27, 2024, at 10:15 PM, Calvin Buckley &lt;calvin@cmpct.info&gt; wrote:
            </div>
            <br class="Apple-interchange-newline" />
            <div>
             <div>
              text/html?
              <br />
             </div>
            </div>
           </blockquote>
          </div>
          <br />
         </body>
        </html>
        """
        let parser = try MailParser(html: html)
        #expect(parser.isTopPosting())
    }

}
