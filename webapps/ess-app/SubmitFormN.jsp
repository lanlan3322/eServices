<%--
SubmitFormN.jsp - same as SubmitForm but does not generate XML
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
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<%@ include file="SystemInfo.jsp" %>
<html>
<body>
<% 
String SendMsgTo = request.getParameter("rcpt2");
String smtp_address = SysTable.getSystemString("SMTP_ADDRESS","adisoft-inc.com"); 
SendForm.setIP_URL(smtp_address);
String smtp_port = SysTable.getSystemString("SMTP_PORT","25"); 
SendForm.setPort(smtp_port);


String MsgFrom = SysTable.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");
String MessageString = "Support Form\n";
String ParamName = "";
String ParamValue = "";
if (SendMsgTo == null || SendMsgTo.equalsIgnoreCase("")) SendMsgTo = MsgFrom;
java.util.Enumeration ParamList = request.getParameterNames();
try {
  while(true) {
    ParamName = (String) ParamList.nextElement();
    ParamValue = (String) request.getParameter(ParamName);
    MessageString += ParamName + ": " + ParamValue  + "\n"; 
  }
} catch (java.util.NoSuchElementException e) {
} 
MessageString += "End\n";
%>
<br><br>
<% if (SendForm.setSMTPMessage(MessageString,SendMsgTo,MsgFrom)) { %>
  <strong><em>Thank you. Your request has been forwarded and we will respond soon.</em></strong>
  <br><br>
  <a href="javascript: void history.go(-2)"><em>Return to www.expenseservices.net</em></a>


<% } else { %>
  <strong><em>Unable to deliver your message.  Please call support if you have an urgent problem or else try to send your message later.  You may also e-mail <%=SendMsgTo %> with your request.</em></strong>
<% }
%>

<br>
</body>
</html>
