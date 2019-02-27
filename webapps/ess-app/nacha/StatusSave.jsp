<%--
StatusSave.jsp - Records that an entry has been prenoted successfully
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
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Logfile"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>

<%
String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
   SysTable.setConnection(PersFile.getConnection());   //SystemInfo.jsp handled differently here
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
   }
   NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");

   if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
   }
   CCode = request.getParameter("ccode"); 


  session.putValue("loginAttempts", new java.lang.Integer(0));

  String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
  String database = request.getParameter("database");

  Reporter.setConnection(PersFile.getConnection());
  Reporter.setSQLTerminator(PersFile.getSQLTerminator()); 
  Reporter.setSQLStrings();

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());
  boolean errorCondition = false; 
 
  String msgdata = request.getParameter("msgdata");

%>
<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>The following user are ready for ACH payment:</em></strong><br>
<%  
   String SQLCommand;

   boolean xFlag;
   //String persname;
   //String persnum;
   String user2Prenote;

   String upSQL = SystemDOM.getDOMTableValueFor("achprenote","updatesqlstatus","");

   int SQLResult;

   String newAsOfDate = Dt.xBaseDate.format(Dt.date);
   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   if (SQLType.equals("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.simpleDate.format(Dt.date));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",newAsOfDate);
   } 

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("prenote"), ";"); 
   
   while (rp.hasMoreTokens()) {

     user2Prenote = rp.nextToken().trim() ;
     
     xFlag = Reporter.setPersNumInfo(user2Prenote); 
        
     if (xFlag ) {   

%>
     <br> User <%= user2Prenote %> sent for ACH payment.
<%          
        SQLCommand = upSQL;
   
        if (SQLCommand.equals("")) {
           SQLCommand = "UPDATE USER SET ";
           SQLCommand += "CASH='ACH' ";
           SQLCommand += "WHERE PERS_NUM = '$persnum$'" + PersFile.getSQLTerminator();
        }

        SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",user2Prenote);
        SQLResult = Reg.doSQLExecute(SQLCommand);

        if ( SQLResult > -1) { 
         Logfile.println("[202] StatusSave.jsp - processed: " + user2Prenote);
        } else { %>  
          -- processing failed due to database access problem
     <%  Logfile.println("[500] StatusSave.jsp - " + user2Prenote + " had a database access error");
        } 
     %>   
           
  <% } else { %>  
       <br> Cannot process <%=user2Prenote %>&nbsp;-- Reporter has not been found - (<%=user2Prenote %>)
         <% Logfile.println("[500] StatusSave.jsp - Cannot process: " + user2Prenote + " - reporter not found"); 
         %>
              
  <% }  //Done with the find reporter logic 
  %> 
     
     
  <% 
   } //While the tokens are still there
 %>    

<br><br><strong><em>End of processing</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWithDBase('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/StatusList.jsp?downlevel=','approvallevel','1')" tabindex="1"><em><strong>Return to reports requiring approval</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 
} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Logfile.println("[400] StatusSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% } 

}
%>





