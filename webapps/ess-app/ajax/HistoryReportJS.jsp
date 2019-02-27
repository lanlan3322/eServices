<%--
HistoryReportJS.jsp - displays report along with approval option [js code]
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
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<% 
   //String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   //String status = request.getParameter("status");
   //String reply2 = request.getParameter("email");
   //String rcpt2 = request.getParameter("rcpt2");
   //String NeedPassword = request.getParameter("NeedPassword");
%> 
function screenLoad() {
      parent.DirectEdit = false;  
      parent.setDBPair(parent.PersDBase,"last_report", "<%= voucher %>");
// Need to check if report is in memory      
      if (ReportIsSaved) {  //Found in XShared1.js      
          parent.myESSMenu.setReceiptNewReport("<%= ESSDisplay.getPreviousNumber() %>");
      } else {
          parent.myESSMenu.setReceiptMenu("<%= ESSDisplay.getPreviousNumber() %>");
      }
      return true;
}

function screenUnload() {
      return true;
}
