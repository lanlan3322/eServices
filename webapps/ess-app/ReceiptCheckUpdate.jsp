<%--
ReceiptCheckUpdate.jsp - record if a receipt is present or not
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
public boolean ReceiptCheckUpdate(ess.AdisoftDbase dbx, ess.AdisoftDOM sys, String reportReference, java.util.StringTokenizer receipts, java.util.StringTokenizer checks, String SQLTerminator, ess.AuditTrail Logfile, ess.Report report) {
   
   boolean retVal = true;
   String receiptNumber;
   String checked;
   String xchecked;
   String SQLCommand;
   String SQLReceipted = sys.getDOMTableValueFor("auditreport", "receiptcheckupdate", "");;
   
   String logicalYes = sys.getDOMTableValueFor("sql", "yessql", "1");
   String logicalNo = sys.getDOMTableValueFor("sql", "nosql", "0");
   
   while (receipts.hasMoreTokens() && retVal) {  
     receiptNumber = receipts.nextToken().trim();
     xchecked = checks.nextToken().trim();
     
     if (xchecked.equalsIgnoreCase("YES"))
     {
        checked = logicalYes;
     } else {
        checked = logicalNo;
     }

     if (SQLReceipted.equals(""))
     { 
        SQLCommand = "UPDATE RECEIPT ";
        SQLCommand += "SET CHECK = " + checked + " ";
        SQLCommand += "WHERE RTRIM(VOUCHER) = '" + reportReference + "' AND RTRIM(RECEIPT) = '" + receiptNumber + "'" + SQLTerminator;
     } else
     {
        SQLCommand = ess.Utilities.replaceStr(SQLReceipted,"$checked$",checked);     
        SQLCommand = ess.Utilities.replaceStr(SQLCommand,"$voucher$",reportReference);     
        SQLCommand = ess.Utilities.replaceStr(SQLCommand,"$receipt$",receiptNumber);
     }

     try {
       if (dbx.doSQLExecute(SQLCommand) > -1) 
       {
          Logfile.println("[000] ReceiptCheckUpdate.jsp - OK: " + reportReference + ":" + receiptNumber);
          if (report.isSameReport(reportReference) && !report.setReceiptCheck(receiptNumber,xchecked)) {
               Logfile.println("[500] AuditSave.jsp - Receipt check update failed (Session)");
          }
       } else {
          Logfile.println("[500] ReceiptCheckUpdate.jsp - Update Failure: " + reportReference + ":" + receiptNumber);
          retVal = false;
       }
     } catch (java.lang.Exception ex) {
          Logfile.println("[500] ReceiptCheckUpdate.jsp - General Failure: " + reportReference + ":" + receiptNumber);
          Logfile.println("[500] ReceiptCheckUpdate.jsp - error: " + ex.toString());
          retVal = false;
     }
   }
   return retVal;
}
%>

