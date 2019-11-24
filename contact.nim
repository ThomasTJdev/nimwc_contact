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
  datetime2human,
  json,
  logging,
  os,
  parsecfg,
  strutils,
  uri

when defined(postgres): import db_postgres
else:                   import db_sqlite

from times import epochTime
import jester
import ../../nimwcpkg/emails/emails
import ../../nimwcpkg/plugins/plugins
import ../../nimwcpkg/sessions/sessions
import ../../nimwcpkg/utils/loggers
import ../../nimwcpkg/webs/html_utils

proc pluginInfo() =
  let (n, v, d, u) = pluginGetDetails("contact")
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
