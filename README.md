# MailTools: A mailing list assistant for macOS Mail.app

MailTools (tentative name until I come up with something better) is a
[mail extension][mailext] for macOS that provides the following checks when
writing emails for a mailing list:

* Check if the email is plain text
  * Avoid sending HTML emails to lists
* Check if the reply is above the quote ("top posting")
  * Reminds you to quote below or inline
* Check if the email exceeds line limits
  * Avoid irritating VT100 users
* Check if the email was sent from the right address
  * Make sure you're sending it from the address you subscribed from

Mailing lists can require [specific rules][pedantry] to be followed; this
extenion helps you avoid making a mailing list faux pas.

You can also set what rules are applied for specific emails or domains.

## Requirements

This uses SwiftData and other new features, so it requires macOS 14.

Building is only tested on Xcode 16.

## Usage

Open MailTools.app to learn how to turn on the mail extension in Mail.app.

From MailTools.app you can add rules that will be automatically applied when
writing an email for that receipient. Or, you can manually override settings
per email by clicking the extension's toolbar icon in the compose window.

[mailext]: https://support.apple.com/en-ca/guide/mail/mlhla9a93cd5/mac
[pedantry]: https://useplaintext.email/#etiquette
