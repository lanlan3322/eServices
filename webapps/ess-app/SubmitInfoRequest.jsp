<%--
SubmitInfoRequest.jsp - Submits form for info to adisoft - change for your usage
Copyright (C) 2004 R. James Holton

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your option) 
any later version.  This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 
675 Mass Ave, Cambridge, MA 02139, USA. 
--%>

<%@ page contentType="text/html" %>
<jsp:useBean id = "SendForm"
     class="ess.SMTPSingle"
     scope="page" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<% 
   SysTable.setDB ("jdbc:mysql://localhost/adisoft", "root", "kenosha");
   SysTable.setSQLTerminator(";");
   String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
   java.io.File SystemFile = new java.io.File(system_file);
   SystemDOM.setDOM(SystemFile);
%>
<html>
<body onLoad="setTimeout('restart()',4000)">
<% 
//String SendMsgTo = request.getParameter("rcpt2");
String SendMsgTo = "service@adisoft-inc.com";

String smtp_address = SysTable.getSystemString("SMTP_ADDRESS","adisoft-inc.com"); 
SendForm.setIP_URL(smtp_address);
String smtp_port = SysTable.getSystemString("SMTP_PORT","25"); 
SendForm.setPort(smtp_port);

String MsgFrom = SysTable.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");
String MessageString = "<supportform>\n";
String ParamName = "";
String ParamValue = "";
java.util.Enumeration ParamList = request.getParameterNames();
try {
  while(true) {
    ParamName = (String) ParamList.nextElement();
    ParamValue = (String) request.getParameter(ParamName);
    MessageString += "<" + ParamName + ">" + ParamValue + "</" + ParamName + ">" + "\n"; 
  }
} catch (java.util.NoSuchElementException e) {
} 
MessageString += "</supportform>\n";
%>
<br><br>
<% if (SendForm.setSMTPMessage(MessageString,SendMsgTo,MsgFrom)) { %>
  <strong><em>Thank you. Your request has been sent to <bold>Adisoft, Inc.</bold></em></strong>
  <br>
  ....
  </body>
  <script Language="JavaScript">

  function restart() {
     window.location = "http://www.adisoft-inc.com";
  }

  </script>
  </html>

<% } else { %>
  <strong><em>Unable to deliver your message.  Please call <bold>Adisoft</bold> or try submitting your request later.  You may also e-mail <%=SendMsgTo %> with your request.</em></strong>
  <br>
  ....
  </body>
  <script Language="JavaScript">

  function restart() {
  }

  </script>
  </html>

<% }
%>

