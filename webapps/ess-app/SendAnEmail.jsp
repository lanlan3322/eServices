<%--
SendAnEmail.jsp - sends a message via the SMTP server
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

<%!
private boolean SendAnEmail(String Rcpt2, String Reply2, String Subject, String MsgText, ess.ServerSystemTable SendInfo) {

  ess.SMTPSingle XM = new ess.SMTPSingle();
  boolean retVal = false;

  String smtp_address = SendInfo.getSystemString("smtp_address","expenseservices.com");
  String smtp_port = SendInfo.getSystemString("smtp_port","25");
  String smtp_delimiter = SendInfo.getSystemString("smtp_delimiter",".");
  String smtp_domain = SendInfo.getSystemString("smtp_domain","expenseservices.com");
  String messageBodyType = SendInfo.getSystemString("messages","messagebodytype","body=8BITMIME");
  String contentType = SendInfo.getSystemString("messages","contenttype","text/plain; charset=utf-8");
  String authType = SendInfo.getSystemString("smtp_authtype","none");
  String smtp_logon = SendInfo.getSystemString("smtp_logon","");
  String smtp_password = SendInfo.getSystemString("smtp_password","");	  
  
  XM.setIP_URL(smtp_address);
  XM.setPort(smtp_port);
  XM.setDelimiter(smtp_delimiter); 
  XM.setDomain(smtp_domain); 
  XM.setMessageBodyType(messageBodyType);
  XM.setContentType(contentType);
  XM.setAuthType(authType);
  XM.setAuthID(smtp_logon);
  XM.setAuthCode(smtp_password);
  
  XM.setSubject(Subject);

  if (XM.setSMTPMessage("\n" + MsgText, Rcpt2, Reply2)) retVal = true;
  return retVal;
}

private boolean SendAnEmail4(String Rcpt1, String Rcpt2,String Rcpt3,String Rcpt4,
							String Subject1, String Subject2,String Subject3,String Subject4,
							String MsgText1,String MsgText2,String MsgText3, String MsgText4, 
							String Reply2, 
							ess.ServerSystemTable SendInfo) {

  ess.SMTPSingle XM = new ess.SMTPSingle();
  boolean retVal = false;

  String smtp_address = SendInfo.getSystemString("smtp_address","services@elc.com.sg");
  String smtp_port = SendInfo.getSystemString("smtp_port","25");
  String smtp_delimiter = SendInfo.getSystemString("smtp_delimiter",".");
  String smtp_domain = SendInfo.getSystemString("smtp_domain","elc.com.sg");
  String messageBodyType = SendInfo.getSystemString("messages","messagebodytype","body=8BITMIME");
  String contentType = SendInfo.getSystemString("messages","contenttype","text/plain; charset=utf-8");
  String authType = SendInfo.getSystemString("smtp_authtype","none");
  String smtp_logon = SendInfo.getSystemString("smtp_logon","");
  String smtp_password = SendInfo.getSystemString("smtp_password","");	  
  
  XM.setIP_URL(smtp_address);
  XM.setPort(smtp_port);
  XM.setDelimiter(smtp_delimiter); 
  XM.setDomain(smtp_domain); 
  XM.setMessageBodyType(messageBodyType);
  XM.setContentType(contentType);
  XM.setAuthType(authType);
  XM.setAuthID(smtp_logon);
  XM.setAuthCode(smtp_password);
  
  if(Rcpt1.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject1);
	  if (XM.setSMTPMessage("\n" + MsgText1, Rcpt1, Reply2)) retVal = true;
  }
  if(Rcpt2.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject2);
	  if (XM.setSMTPMessage("\n" + MsgText2, Rcpt2, Reply2)) retVal = true;
  }
  if(Rcpt3.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject3);
	  if (XM.setSMTPMessage("\n" + MsgText3, Rcpt3, Reply2)) retVal = true;
  }
  if(Rcpt4.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject4);
	  if (XM.setSMTPMessage("\n" + MsgText4, Rcpt4, Reply2)) retVal = true;
  }
  return retVal;
}
private boolean SendAnEmailLocal(String Rcpt1, String Rcpt2,String Rcpt3,String Rcpt4,
							String Subject1, String Subject2,String Subject3,String Subject4,
							String MsgText1,String MsgText2,String MsgText3, String MsgText4, 
							String Reply2, ess.SMTPSingle XM,
							ess.ServerSystemTable SendInfo) {

  //ess.SMTPSingle XM = new ess.SMTPSingle();
  boolean retVal = false;
  
  if(Rcpt1.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject1);
	  if (XM.setSMTPMessage("\n" + MsgText1, Rcpt1, Reply2)) retVal = true;
  }
  if(Rcpt2.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject2);
	  if (XM.setSMTPMessage("\n" + MsgText2, Rcpt2, Reply2)) retVal = true;
  }
  if(Rcpt3.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject3);
	  if (XM.setSMTPMessage("\n" + MsgText3, Rcpt3, Reply2)) retVal = true;
  }
  if(Rcpt4.indexOf("@elc.com.sg") > -1){
	  XM.setSubject(Subject4);
	  if (XM.setSMTPMessage("\n" + MsgText4, Rcpt4, Reply2)) retVal = true;
  }
  return retVal;
}
%>

