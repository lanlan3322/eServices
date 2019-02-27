<%--
AuditList.jsp - List out reports to be audited - allows batch auditing
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
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />     

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
%>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="DepartInfo.jsp" %>
<%
   Log.println("[000] AuditList.jsp - start: " + ownersName); 

   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   Reporter.setConnection(PersFile.getConnection());
   Reporter.setSQLTerminator(PersFile.getSQLTerminator());
   Reporter.setSQLStrings();


   String PData =  request.getParameter("persdbase");
   if (PData != null) {
      Log.println("[000] AuditList.jsp - Audit access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] AuditList.jsp - Audit access by " + ownersName);
   }

   String NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_audit","yes");
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String downlevel = request.getParameter("downlevel");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);

   String SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectaudit",""); 
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RC_AMT, RP_STAT, ";
     SQLCommand += "CUR_DATE, SIGN1, VOUCHER, PVOUCHER, SIGN2, DEPART, RE_AMT, CURRENCY ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RP_STAT = 'E2' ";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());
   SQLCommand = Reg.SQLReplace(SQLCommand,"$level$", PersFile.getSecurityLevel());

   if (Reg.setResultSet(SQLCommand)) {
      Log.println("[000] AuditList.jsp - SQL: " + SQLCommand);
  %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Report Selection:</title>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1>Reports ready for audit:</h1><br>
<%   String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher;
     String reference;
     String curdate;
     String repamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     String approvalType; 
     String limitRequired; 
     String firstSigner;
     String signerColumn;
     String dupAllowed; 
     String adjustment; 
     String subTable;
     String depart;
     String prefer;
     String dueamt;
     String currency;
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
     <td width="10%" <%=backcolor%> align='center'><u>Central #</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>User's #</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Cur Date</u></td>
     <td width="16%" <%=backcolor%> align='center'><u>Name</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Total</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Due</u></td>
     <td width="25%" <%=backcolor%> align='left'><u>Payment Status</u></td>
     <td width="8%" <%=backcolor%>></td>
     </tr>
     <form>
<% 
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
    try {
     do { 
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(1);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(1));
        }
        reference = PersFile.getTrim(Reg.myResult.getString(2));
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        curdate = PersFile.getTrim(Reg.myResult.getString(5));
        firstSigner = PersFile.getTrim(Reg.myResult.getString(6));  //need variable name for column later to check for dup sign
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        prefer = PersFile.getTrim(Reg.myResult.getString(8));
        depart = PersFile.getTrim(Reg.myResult.getString(10));
        dueamt = PersFile.getTrim(Reg.myResult.getString(11));
        currency = PersFile.getTrim(Reg.myResult.getString(12));

        //subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        //approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        //if (approvalType.equals("")) 
        //{
        //  Log.println("[400] ApprovalList.jsp rule " + subTable + " not found - using default");  //jh - remove
        //  subTable = "default";
        //  approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        //}

        //limitRequired = "No";
        //dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"duplicatesignerallowed");
        //signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"updatesqlsigner");
        //adjustment = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"leveladjustment");
 
        //xFlag = Reporter.setPersNumInfo(reference); 
        if (!reference.equals(PersFile.getPersNum())) {
%>          
        <tr>
        <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
        <td width="10%" <%=backcolor%> align="center"><%= prefer%></td>
        <td width="10%" <%=backcolor%>><%= Dt.getSimpleDate(Dt.getDateFromXBase(curdate))%></td>
        <td width="16%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="10%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
        <td width="10%" <%=backcolor%> align="center"><%= money.format(money.parse(dueamt))%></td>
        <td width="25%" <%=backcolor%>><%= repDBStat%></td>
        <td width="8%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink">Select</span></a></td>
        </tr>
<%      }
        xfound = true;
        newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] AuditList.jsp Language Error");
    Log.println("[500] AuditList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
%>
  </form>
  </table>
<% if (!xfound) { %>
<strong><em>
No reports pending your signoff at this level.<br>
</em></strong>
<% } %>
<br><h1>End of list</h1><br>
<script language="Javascript">

function initForm() {
    parent.contents.initStacks();
    parent.contents.setLastSQL("<%=SQLCommand %>"); 
    parent.contents.setLastDisplay("AuditListSingle.jsp");
}
</script>
  </body>
     <head>
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">
     </head>
  </html>
<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder()%>/expense.css" type="text/css">
    </head>
    <body>
    <p><%=PersFile.name%>, No expense reports have been found.
    <% Log.println("[400] AuditList.jsp No expense reports where found."); %>
     </p>
    </body>
     <head>
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">
     </head>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reporter.close();
Log.println("[000] AuditList.jsp - Done: " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>



