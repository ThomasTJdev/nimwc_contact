#
#
#        TTJ
#        (c) Copyright 2018 Thomas Toftgaard Jarløv
#        Plugin for Nim Website Creator: Contact
#        License: MIT
#
#

import
  asyncdispatch,
  asyncnet,
  db_sqlite,
  json,
  logging
  os,
  parsecfg,
  strutils,
  uri,


from times import epochTime
import jester
import ../../nimwcpkg/resources/email/email_connection
import ../../nimwcpkg/resources/session/user_data
import ../../nimwcpkg/resources/utils/dates
import ../../nimwcpkg/resources/utils/logging_nimwc
import ../../nimwcpkg/resources/utils/plugins
import ../../nimwcpkg/resources/web/google_recaptcha

proc pluginInfo() =
  let (n, v, d, u) = pluginExtractDetails("contact")
  echo " "
  echo "--------------------------------------------"
  echo "  Package:      " & n
  echo "  Version:      " & v
  echo "  Description:  " & d
  echo "  URL:          " & u
  echo "--------------------------------------------"
  echo " "
pluginInfo()

let dict = loadConfig(replace(getAppDir(), "/nimwcpkg", "") & "/config/config.cfg")
let emailSupport = dict.getSectionValue("SMTP","SMTPEmailSupport")
let title = dict.getSectionValue("Server","title")

include "html.tmpl"


proc contactSendMail*(c: var TData, db: DbConn, content, senderEmail, senderName: string): string =
  ## Send the mail

  let emailContent = """
A new message from $1
<br><br>
Senders name: $2
<br>
Senders email: $3
<br>
Email content:
$4
""" % [title, senderName, senderEmail, content]

  debug("Plugin Mailer: Sending contact mail")

  when not defined(demo):
    asyncCheck sendMailNow("Contact email from: " & senderName, emailContent, emailSupport)

  return "Thank you. The email was sent."



proc contactStart*(db: DbConn) =
  ## Required proc. Will run on each program start
  ##
  ## If there's no need for this proc, just
  ## discard it. The proc may not be removed.

  discard