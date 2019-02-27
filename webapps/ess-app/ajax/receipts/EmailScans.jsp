<%--
EmailScans.jsp - Display free standing scans that have been emailed in from this user 
Copyright (C) 2012 R. James Holton

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
<jsp:useBean id = "Scans"
     class="ess.Scan"
     scope="page" />     
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />      
<%@ include file="../../DBAccessInfo.jsp" %>

<%
Scans.setConnection(PersFile.getConnection());
Scans.setSQLTerminator(PersFile.getSQLTerminator()); 
String PVOUCHER = request.getParameter("pvoucher");
String PERS_NUM = PersFile.getPersNum();

%>
<%@ include file="../../SystemInfo.jsp" %>


<%

Scans.setSystemTable(SysTable);

	  int scanLinks = 0;
      java.util.Vector ReceiptScanRefs = new java.util.Vector();
      java.util.Vector ReceiptScanExts = new java.util.Vector();
      java.util.Vector ReceiptComments = new java.util.Vector();
      java.util.Vector ReceiptCrossRefs = new java.util.Vector();
	  String reference = null;
	  String[] scanInfo = null;

	  if (Scans.isScansAvailable(PERS_NUM))
	  {
		  Log.println("[000] ajax/receipts/EmailScans.jsp isScansAvailable returned true");
		  try
		  {   
			  scanInfo = Scans.getScan();
			  while (scanInfo != null) 
			  {
				  Log.println("[000] ajax/receipts/EmailScans.jsp scan #: " + Integer.toString(scanLinks));
				  reference = scanInfo[0];
				  ReceiptScanRefs.addElement(reference);
				  ReceiptScanExts.addElement(scanInfo[1]);
				  ReceiptComments.addElement(scanInfo[2]);
				  ReceiptCrossRefs.addElement(scanInfo[3]);
				  scanLinks += 1;
				  scanInfo = Scans.getNextScan();
				  PersFile.addImage(reference);
			  }
		  } catch (java.lang.Exception ex) 
		  {
			  Log.println("[500] ajax/receipts/EmailScans.jsp - setReceiptScanLinks - SQL Error");
			  Log.println("[500] ajax/receipts/EmailScans.jsp - " + ex.toString());
			  ex.printStackTrace();
			  %> An error occurred in the process!<br>
			  <%
		  } //try
	  } else {
		  Log.println("[000] ajax/receipts/EmailScans.jsp isScansAvailable returned false");
	  }

	Log.println("[000] ajax/receipts/EmailScans.jsp total scanLinks: " + Integer.toString(scanLinks));
	if (scanLinks > 0)
	{	
	   String[] receiptScans = new String[ReceiptScanRefs.size()];
	   String[] receiptRefs = new String[ReceiptScanRefs.size()];
	   String[] receiptCmnts = new String[ReceiptComments.size()];
	   String[] receiptXrefs = new String[ReceiptCrossRefs.size()];
	   
	   for (int i = 0; i < receiptScans.length; i++)
	   {
		  receiptRefs[i] = (String) ReceiptScanRefs.get(i); 
	      receiptScans[i] = (String) ReceiptScanRefs.get(i) + "." + (String) ReceiptScanExts.get(i);
	      receiptCmnts[i] = (String) ReceiptComments.get(i); 
	      receiptXrefs[i] = (String) ReceiptCrossRefs.get(i);
	   }

	   if (receiptScans.length > 0)
	   {
	      String ScanFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","htmlfolder","/receipts");
	      String HrefLink = SystemDOM.getDOMTableValueFor("receiptmanagement","hreflink","$link$");
	      String HrefString;
	      String DeleteLink = SystemDOM.getDOMTableValueFor("receiptmanagement","deleteemailscanajax","$link$");
	      String ApplyLink = SystemDOM.getDOMTableValueFor("receiptmanagement","applyemailscanajax","$link$");

	  	  DeleteLink = PersFile.SQLReplace(DeleteLink, "$persnum$", PERS_NUM); 
	  	  DeleteLink = PersFile.SQLReplace(DeleteLink, "$pvoucher$", PVOUCHER); 
	  	  ApplyLink = PersFile.SQLReplace(ApplyLink, "$persnum$", PERS_NUM); 
	  	  ApplyLink = PersFile.SQLReplace(ApplyLink, "$pvoucher$", PVOUCHER); 

		  for (int i = 0; i < receiptScans.length; i++)
    	  {
			  HrefString =  PersFile.SQLReplace(HrefLink, "$window$", "Scan_" + receiptRefs[i]);
		  %>
		  &nbsp;<%= receiptRefs[i] %>&nbsp;&nbsp; 
		  <a href="<%= PersFile.SQLReplace(HrefString, "$link$", "/ess-app/receipts/ReceiptView.jsp?image=" + receiptRefs[i])%>"><img SRC="/ess/images/ess-View.gif" title='<%= Lang.getString("view")%>' /></a>&nbsp;&nbsp;
		  <a href="JavaScript: void removeEmailScanAJAX('<%= PersFile.SQLReplace(DeleteLink, "$reference$", receiptRefs[i]) %>')"><img SRC="/ess/images/ess-Xout.gif" title='<%= Lang.getString("delete")%>' /></a>&nbsp;&nbsp;
          <% if (receiptXrefs[i] != null && receiptXrefs[i].length() > 0) { %>
		  <a href="JavaScript: void applyEmailScanAJAX('<%= PersFile.SQLReplace(ApplyLink, "$reference$", receiptRefs[i]) %>')"><img SRC="/ess/images/ess-Check.gif" title='<%= Lang.getString("attachAuto")%>' /></a>
          <% } else { %>
		  <a href="JavaScript: void applyEmailScanAJAX('<%= PersFile.SQLReplace(ApplyLink, "$reference$", receiptRefs[i]) %>')"><img SRC="/ess/images/ess-Plus.gif" title='<%= Lang.getString("attach")%>' /></a>
          <% } %>
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