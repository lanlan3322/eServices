<%--
ApplyEmailScans.jsp - Apply a scan file that has been previously uploaded.
Copyright (C) 2004,2012 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "db"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
          
<%@ include file="../../DBAccessInfo.jsp" %><%
// need to put the active session check here.
String persnum = PersFile.getPersNum();
String uploadMsg = "";
db.setConnection(PersFile.getConnection());
db.setSQLTerminator(PersFile.getSQLTerminator());
%>
<%@ include file="../../SystemInfo.jsp" %>
<% 
String parentFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","parentfolder");
String validFileTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","filetypes");
validFileTypes = validFileTypes.toLowerCase();
String limitSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","limitchecksql");
String applySQL = SystemDOM.getDOMTableValueFor("receiptmanagement","applyemailscanupdate");


String CurDate = Dt.simpleDate.format(Dt.date);

String pvoucher = "00000000";
boolean fileOK = true;

pvoucher = request.getParameter("pvoucher");
limitSQL = db.SQLReplace(limitSQL,"$persnum$",persnum);
limitSQL = db.SQLReplace(limitSQL,"$pvoucher$",pvoucher);
if (db.setResultSet(limitSQL))
{
   	try 
   	{
   	    int itemCount = db.myResult.getInt(1);
   	    if (itemCount > 30)
   	    {
   	   	    uploadMsg = "You have exceeded the number of receipt files that can be attached to this report!";
   	        Log.println("[249] Upload.jsp - Exceeded number of scan files for one report: " + itemCount);        
   	  	    fileOK = false;
   	    }
   	} catch (java.lang.Exception ex)
   	{
   		uploadMsg = "REC_UPL_ERR501";
   		Log.println("[500] ApplyEmailScan.jsp - error - see logs: " + ex.toString());
   		ex.printStackTrace();
   	    fileOK = false;
    }
}
      
if (fileOK)
{
	String[] tags = {"SCAN_REF","PVOUCHER","STATUS"};
	String[] values = new String[3];
	String reference = request.getParameter("reference");
	applySQL = db.SQLReplace(applySQL,"$reference$",reference);
	applySQL = db.SQLReplace(applySQL,"$pvoucher$",pvoucher);
	applySQL = db.SQLReplace(applySQL,"$status$","Applied");
	if (db.doSQLExecute(applySQL) == 1)
	{
		uploadMsg = "REC_UPL_OK";	
		Log.println("[000] ApplyEmailScan.jsp - File upload OK");        
    	    // db.setCommit();
	} else 
	{
		Log.println("[500] ApplyEmailScan.jsp - database update failure - investigate SCAN_REF: " + reference);
		uploadMsg = "REC_UPL_ERR501";
	}
} else
{
    uploadMsg = "REC_UPL_ERR505";
	Log.println("[500] ApplyEmailScan.jsp - Upload error 505");
}
%>
<%= Lang.getString(uploadMsg) %>
