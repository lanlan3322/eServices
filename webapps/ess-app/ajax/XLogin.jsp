<%--
XLogin.jsp - Entrance to the ESS system
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CD"
     class="ess.CustomDate"
     scope="request" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
<jsp:useBean id = "Hash"
     class="ess.AdisoftHash"
     scope="session" />        

<%@ include file="../DBAccessInfo.jsp" %>
<%@  include file="../Headers.jsp" %>
<%
   String email = request.getParameter("email"); 
   String email2 = request.getParameter("email2"); 
   String password = request.getParameter("password");
   String database;

   Log.println("[000] XLogin.jsp Access from: " + request.getRemoteAddr());

   if (DBDatabase != null) {
       database = DBDatabase;
   } else {
       database = request.getParameter("database");
   }

   if (DBDriver != null && !DBDriver.equals("")) {
       PersFile.setDBDriver(DBDriver);
       Log.println("[308] XLogin.jsp DBDriver: " + DBDriver);
   }

   
   PersFile.setDB(database,DBUser,DBPassword); 
   PersFile.setSQLTerminator(DBSQLTerminator);
   if (password == null) password = "";
   PersFile.setSQLStrings();
   PersFile.setLDAP(LDAPProvider,LDAPSearchPrincipal,LDAPCredentials,LDAPFactory,LDAPSearchString,LDAPEmailAttribute,LDAPPrincipalAttribute);
   
   String CurDateString = CD.xBaseDate.format(CD.date);

   boolean foundUser = false;
   if (PersFile.setPersInfo(email)) {
     Log.println("[000] XLogin.jsp primary login: " + email);
     foundUser = true;
   //} else {
   //  Log.println("[000] XLogin.jsp secondary login attempt: " + email2);
   //  if (email2 != null) foundUser = PersFile.setPersInfo(email2);
   //  email = email2; 
   }
   Log.println("[000] XLogin.jsp password hash: " + Hash.Hash(password));
   if (foundUser && PersFile.validPassword(password) && PersFile.active.equals("1")) { 
     if (PersFile.getChallengeCode().equals("")) {
        PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
     }
     Log.println("[220] XLogin.jsp " + PersFile.email + " is logged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     email = PersFile.email; //normalizing the email address for pers data retrieval.
     Log.setAddUser(email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12

     Lang.resetLanguage(PersFile.getLanguage());
     //CD.setDateFormat(PersFile.getDateFormat());
     //Lang.setDecimal(PersFile.getDecimal());
     //Lang.setSeparator(PersFile.getSeparator());
%>
<%@  include file="../getDBase.jsp" %>
<%@  include file="../SystemInfo.jsp" %>
<%   
     String company = Sys.getSystemString("customfolder","ess"); //replaces the parameter coming in.
     int days2Expire = Sys.getSystemInt("PWD_EXPIRES_DAYS");
     if (days2Expire == -1) days2Expire = 1000;

     String NewExpireDate; 
     if (PersFile.asofdate == null || PersFile.asofdate.equals("")) {
       NewExpireDate = "1980-01-01";
     } else {
       Log.println("[000] XLogin.jsp asofdate: " + PersFile.asofdate);
       NewExpireDate = CD.xBaseDate.format(CD.addDays(CD.getDateFromXBase(PersFile.asofdate), days2Expire));
     }
     if (CurDateString.compareTo(NewExpireDate) < 0 || days2Expire == 0) {
       session.putValue("loginAttempts", new java.lang.Integer(0));    

       String persnumber = PersFile.persnum.toUpperCase(); 
       String SQLCommand = "SELECT ";
       SQLCommand += "REGISTER.STATUS, REGISTER.REFERENCE, REGISTER.MESSAGE, REPORT.RP_STAT, ";
       SQLCommand += "REPORT.ACT_DATE, REPORT.ACT_TIME, REGISTER.REPDATE, REPORT.PERS_NUM, REPORT.RC_AMT ";
       SQLCommand += "FROM REGISTER LEFT JOIN REPORT ON RTRIM(REGISTER.THEIR_REF) = RTRIM(REPORT.VOUCHER) ";
       SQLCommand += "AND RTRIM(REPORT.VOUCHER) <> '' ";
       SQLCommand += "WHERE RTRIM(REGISTER.OWNER) = '" + SysTable.repStr(email.toUpperCase()) + "' "; 
       SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Copy' AND RTRIM(REGISTER.STATUS) <> 'Remove' ";
       SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Delete' AND RTRIM(REGISTER.STATUS) <> 'Problem' ";
       SQLCommand += "ORDER BY REGISTER.THEIR_REF DESC, REGISTER.XREF DESC" + PersFile.getSQLTerminator();
 
       SQLCommand = SystemDOM.getDOMTableValueFor("registertable","listreports",SQLCommand);
       if (SQLCommand != null && !SQLCommand.equals("")) {
          SQLCommand = SysTable.SQLReplace(SQLCommand,"$owner$",SysTable.repStr(email.toUpperCase()));
       } 
  
       Log.println("[000] XLogin.jsp SQL/XMLR Check Start");
       if (!SysTable.setResultSet(SQLCommand)) { 
       	  CreateRegister(PersFile,Log);
       }
       
       %>

      <%@ include file="XReport.jsp" %>
<%   } else { %>
         <HTML><BODY>
         <strong><em><%= Lang.getString("CHANGE_PASSWORD") %></em></strong><br><br>
         <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getAppFolder() %>/ChangePasswordScreen.jsp"><%= Lang.getDataString("CHANGE_PASSWORD_LINK","Click here to change your password")%></a>
         </BODY>
         <script type="text/javascript">
         function init() {
           window.location = "<%= PersFile.getWebServer() %>/<%= PersFile.getAppFolder() %>/ChangePasswordScreen.jsp";
         }
         setTimeout("init()",1000);
         </script>
         </HTML>
<%   }

     Sys.closeMyState();

   } else { %>
       <HTML><BODY><strong><em><br/>
       <%= Lang.getString("ERROR_INVALID_LOGIN") %>
       </em></strong>
       </BODY></HTML>
<%   Log.println("[420] XLogin.jsp invalid login email: " + email);
     Log.println("[420] XLogin.jsp File email: " + PersFile.email);
     Log.println("[420] XLogin.jsp File name: " + PersFile.name);
     Log.println("[420] XLogin.jsp File active: " + PersFile.active);
     java.lang.Boolean passwordTest = new java.lang.Boolean(password.equalsIgnoreCase(PersFile.password));
     Log.println("[420] XLogin.jsp Password ok: " + passwordTest.toString());
     Log.println("[420] XLogin.jsp Remote IP: " + request.getRemoteAddr());
     PersFile.close();
   } %>

  
   <%@ include file="../CreateRegister.jsp" %>

