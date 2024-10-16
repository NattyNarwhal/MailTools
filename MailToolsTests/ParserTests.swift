//
//  ParserTests.swift
//  MailToolsTests
//
//  Created by Calvin Buckley on 2024-09-30.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

@testable import MailToolsCommon
import Testing

struct ParserTests {
    
    @Test func isPlainText() async throws {
        let html = """
        <html>
         <head></head>
         <body style="overflow-wrap: break-word; -webkit-nbsp-mode: space; line-break: after-white-space;">
          text/html
         </body>
        </html>
        """
        let parser = try MailParser(html: html)
        #expect(!parser.isPlainText())
    }
    
    @Test func exceedsColumnLimit() async throws {
        let html = """
        <html>
         <head></head>
         <body style="overflow-wrap: break-word; -webkit-nbsp-mode: space; line-break: after-white-space;" class="ApplePlainTextBody">
          <div>
           text/html
          </div>
          <div>
           Test...
          </div>
          <div>
           <br />
          </div>
          <div>
           abcefghijklmnopqrstuvqxyzabcefghijklmnopqrstuvqxyzabcefghijklmnopqrstuvqxyz
          </div>
         </body>
        </html>
        """
        let parser = try MailParser(html: html)
        #expect(!parser.linesThatExceed(columns: 72).isEmpty)
    }

    @Test func topPosting() async throws {
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
