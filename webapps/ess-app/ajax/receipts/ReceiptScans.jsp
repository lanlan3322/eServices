<%--
ReceiptScans.jsp - Specifies which file to import 
Copyright (C) 2008 R. James Holton

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

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "db"
     class="ess.AdisoftDbase"
     scope="page" />     
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />      
<%@ include file="../../DBAccessInfo.jsp" %>

<%
db.setConnection(PersFile.getConnection());
db.setSQLTerminator(PersFile.getSQLTerminator()); 
String PVOUCHER = request.getParameter("pvoucher");
String PERS_NUM = PersFile.getPersNum();

%>
<%@ include file="../../SystemInfo.jsp" %>


<% 
	  int scanLinks = 0;
      java.util.Vector ReceiptScanRefs = new java.util.Vector();
      java.util.Vector ReceiptScanCmnts = new java.util.Vector();
      String scanSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","receiptreporterSQL","/receipts");
      String SQLCommand = db.SQLReplace(scanSQL, "$pvoucher$", PVOUCHER);
	  SQLCommand = db.SQLReplace(SQLCommand, "$persnum$", PERS_NUM);
	  String reference;
	  Log.println("[000] ajax/receipts/ReceiptScans.java - SQL: " + SQLCommand);
	  if (db.setResultSet(SQLCommand))
	  {
		  try
		  {
			  do 
			  {
				  reference = db.myResult.getString(1);
				  ReceiptScanRefs.addElement(reference);
				  ReceiptScanCmnts.addElement(db.myResult.getString(3));
				  scanLinks += 1;
			  } while (db.myResult.next());
		  } catch (java.lang.Exception ex) 
		  {
			  Log.println("[500] ajax/receipts/ReceiptScans.java - setReceiptScanLinks - SQL Error");
			  Log.println("[500] ajax/receipts/ReceiptScans.java - " + ex.toString());
			  ex.printStackTrace();
			  %> An error occurred in the process!<br>
			  <%
		  } //try
	  }

 
	if (scanLinks > 0)
	{	
	   String[] receiptRefs = new String[ReceiptScanRefs.size()];
	   String[] receiptCmnts = new String[ReceiptScanCmnts.size()];
	   
	   for (int i = 0; i < receiptRefs.length; i++)
	   {
		  receiptRefs[i] = (String) ReceiptScanRefs.get(i); 
	      receiptCmnts[i] = (String) ReceiptScanCmnts.get(i);
	   }

	   if (receiptRefs.length > 0)
	   {
	      // String ScanFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","htmlfolder","/receipts");
	      String HrefLink = SystemDOM.getDOMTableValueFor("receiptmanagement","hreflink","$link$");
	      String HrefString;
	      String DeleteLink = SystemDOM.getDOMTableValueFor("receiptmanagement","deletelinkajax","$link$");
	  	  DeleteLink = PersFile.SQLReplace(DeleteLink, "$persnum$", PERS_NUM); 
	  	  DeleteLink = PersFile.SQLReplace(DeleteLink, "$pvoucher$", PVOUCHER); 
		  for (int i = 0; i < receiptRefs.length; i++)
    	  {
			  HrefString =  PersFile.SQLReplace(HrefLink, "$window$", "Receipt_" + receiptRefs[i]);
		  %> 
		  &nbsp;<%= receiptRefs[i] %>
          <a href="<%= PersFile.SQLReplace(HrefString, "$link$", "/ess-app/receipts/ReceiptView.jsp?image=" + receiptRefs[i])%>"><img SRC="/ess/images/ess-View.gif" title='<%= Lang.getString("view")%>' /></a>&nbsp;&nbsp;
		  <a href="JavaScript: void removeScanAJAX('<%= PersFile.SQLReplace(DeleteLink, "$reference$", receiptRefs[i]) %>')"><img SRC="/ess/images/ess-Xout.gif" title='<%= Lang.getString("delete")%>' /></a>
		  &nbsp;&nbsp;<%= receiptCmnts[i] %><br>
		  <% 
    	  }
	   } else {
		  %><%= Lang.getString("REC_MISSING_FILES") %>
		  <%
	   }
	} else 
	{
		%><%= Lang.getString("REC_NO_SCANS") %>
		<%

	}
%>