<%--
RemoveFromDbaseCheck.jsp - list reports selected for removal for confirmation
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
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="session" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   

<%@ include file="DBAccessInfo.jsp" %>
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { %> 
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body onLoad="initForm()">
<%-- @ include file="parameters.jsp" --%>
<strong><em><%= Lang.getString("followingRepSelRem")%>:</em></strong><br>
<%
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   byte[] bArray;    //used for encrypted values
   String E;         //     ditto
   String SQLCommand;
   String owner;
   String status;
   String reference;
   String canRemove;
   String report2Remove;
   String report2RemStat;
   String create_date;
   String receipt_amount;
   int voucherNumber = 0;

   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor; 
   String errorcolor = "bgcolor=\"#FA8072\"";

   SQLCommand = "SELECT ";
   SQLCommand += "NAME, RP_STAT, VOUCHER, CRE_DATE, RE_AMT ";
   SQLCommand += "FROM REPORT ";
   SQLCommand += "WHERE RTRIM(VOUCHER) = '$voucher$' AND RTRIM(RP_STAT) = '$status$'" + PersFile.getSQLTerminator();
   String removeConfirm = SystemDOM.getDOMTableValueFor("removereport","confirm",SQLCommand);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("reference"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 
   
   Log.println("[000] RemoveFromDbaseCheck.jsp - references: " + request.getParameter("reference"));
   Log.println("[000] RemoveFromDbaseCheck.jsp - stati: " + request.getParameter("status"));
   
   String action = request.getParameter("xaction");
   boolean actionFlag;
   if (action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    
     <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   
     Log.println("[500] RemoveFromDbaseCheck.jsp - Invalid action by " + ownersName);
   }
%>
   <form>
   <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
   <tr>
   <td width="5%"></td> 
   <td width="10%"><u><%= Lang.getString("voucher")%></u></td>
   <td width="25%"><u><%= Lang.getString("owner")%></u></td>
   <td width="15%"><u><%= Lang.getString("created")%></u></td>
   <td width="20%"><u><%= Lang.getString("status")%></u></td>
   <td width="25%"><u><%= Lang.getString("action")%></u></td>
   </tr>
<%
   while (rp.hasMoreTokens() && actionFlag) {  
     report2Remove = rp.nextToken().trim() ;
     if (report2Remove.equals("X")) report2Remove = "";
     report2RemStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     SQLCommand = removeConfirm;
     SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Remove);
     SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",report2RemStat);
%> 
     <tr> 
<%
      if (Reg.setResultSet(SQLCommand)) {
           if (encrypt.equalsIgnoreCase("YES")) {
             bArray = Reg.myResult.getBytes(1);
             E = new String(bArray);
             owner = unScramble(E,encrypt,encryptKey);   
           } else {
             owner = PersFile.getTrim(Reg.myResult.getString(1));
           }
           status = PersFile.getTrim(Reg.myResult.getString(2));
           reference = PersFile.getTrim(Reg.myResult.getString(3));
           create_date = PersFile.getTrim(Reg.myResult.getString(4));
           receipt_amount = PersFile.getTrim(Reg.myResult.getString(5));
           canRemove = StatusDOM.getDOMTableValueWhere("default","translation",report2RemStat,"auditremoveallowed");

           if (canRemove.equalsIgnoreCase("Yes")) { 
%>              
                 <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" value="<%= status%>;<%= reference.trim() %>" checked=true></td> 
                 <td width="10%"  <%=backcolor%>><%= report2Remove %></td>
                 <td width="25%"  <%=backcolor%>><%= owner %></td>
                 <td width="15%"  <%=backcolor%>><%= create_date %></td>
                 <td width="20%"  <%=backcolor%>><%= StatXlation(status, "default",StatusDOM) %></td>
                 <td width="25%"  <%=backcolor%>><%= Lang.getString("willRem")%></td>
<%
           } else { 
%>
             <td width="5%"  <%=errorcolor%>></td>
             <td width="10%"  <%=errorcolor%>><%= report2Remove %></td>
             <td width="25%"  <%=errorcolor%>><%= owner %></td>
             <td width="15%"  <%=errorcolor%>><%= create_date %></td>
             <td width="20%"  <%=errorcolor%>><%= StatXlation(status, "default",StatusDOM) %></td>
             <td width="25%"  <%=errorcolor%>>Cannot remove report (check report status)</td>
<%   
             Log.println("[500] RemoveFromDbaseCheck.jsp - report status error " + report2RemStat);
           } 
      } else { 
%>
        <td width="5%"  <%=errorcolor%>></td>
        <td width="10%"  <%=errorcolor%>><%= report2Remove %></td>
        <td width="25%"  <%=errorcolor%>></td>
        <td width="15%"  <%=errorcolor%>></td>
        <td width="20%"  <%=errorcolor%>></td>
        <td width="25%"  <%=errorcolor%>>Database access problem, report not removed</td>
<%  
        Log.println("[500] RemoveFromDbaseCheck.jsp - report removal " + report2Remove + " has a database access error [2]");
      } 
%>
   </tr>
<%
   newbackcolor = backcolor;
   backcolor = oldbackcolor; 
   oldbackcolor = newbackcolor;

   } //while
%>
   </table>
   </form>

<br><br>

      <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/RemoveFromDbase.jsp">
        <input type="hidden" name="email" value>
        <input type="hidden" name="database" value>
        <input type="hidden" name="company" value>
        <input type="hidden" name="ccode" value>
        <input type="hidden" name="reference" value>
        <input type="hidden" name="status" value>
        <input type="hidden" name="xaction" value="remove">

      <p><input type="button" value="<%= Lang.getString("remove")%>" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag"><%= Lang.getString("clickRemComRem")%></span></p>
      </form>

      <script language="Javascript">

      function initForm() {
        if (parent.contents.getDBValue) {
          document.forms[1].name.value = parent.contents.getDBValue(parent.Header,"name");
          //reference was here
          document.forms[1].reference.value = "";
          document.forms[1].email.value = parent.contents.getDBValue(parent.Header,"email");
          document.forms[1].company.value = parent.company;
          document.forms[1].database.value = parent.database;
          document.forms[1].ccode.value = parent.CCode;
          document.forms[1].status.value = "";
          document.forms[1].xaction.value = "remove";
        } else {
          setTimeout("parent.main.initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        for (var i = 0; i < document.forms[0].length; i++) {
          if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
            if (document.forms[0].elements[i].reference == "") document.forms[0].elements[i].reference = "X"; 
            document.forms[1].status.value += delim + breakApart(document.forms[0].elements[i].value,1);
            document.forms[1].reference.value += delim + breakApart(document.forms[0].elements[i].value,2);
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm("Checked reports will now be permanently removed from the central database.  Is it 'OK' to proceed?")) {
            document.forms[1].submit();
          }
        } else {
          alert("Must check report(s) that you wish to remove");
        }
      }

      function breakApart(x,n) {
         var retVal = "";
         var semi = x.indexOf(";")
         var firstpart = x.substring(0,semi);
         var secondpart = x.substring(semi+1);
         if (n == 1) {
            retVal = firstpart;
         } else {
            retVal = secondpart;
         }
         return retVal
      }

      </script>
      
</body>
</html>

<% 
} else { 
     Log.println("[400] RemoveFromDbaseCheck.jsp timeout: " + ownersName); 
%>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>

<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>

