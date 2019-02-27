<%--
CompanyCode.jsp - Writes out JS profile (ESS or Audit) to folder
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
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="page" />
<jsp:useBean id = "Output"
     class="ess.OutputTextFile"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="DBAccessInfo.jsp" %>


<% String securityContext = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
   if (securityContext == null) securityContext = "APPLICATION";
   String database = request.getParameter("database");
   String email = request.getParameter("email"); 
   String password = request.getParameter("password");
   String company = request.getParameter("company");
   String folder = request.getParameter("folder");
   String jsfile = request.getParameter("jsfile");
   if (DBDatabase != null) {
       database = DBDatabase;
   } else {
       database = request.getParameter("database");
   }

   if (DBDriver != null && !DBDriver.equals("")) {
       PersFile.setDBDriver(DBDriver);
   }
   PersFile.setDB(database,DBUser,DBPassword);
   PersFile.setSQLTerminator(DBSQLTerminator);
   if (password == null) password = "";
   PersFile.setSQLStrings();
   Log.println("[200] CompanyCode.jsp Remote IP: " + request.getRemoteAddr()); 
   Log.println("[200] CompanyCode.jsp email entered: " + email);
   boolean ok2Run = false;
%>
<%@ include file="SystemAndSecurityInfo.jsp" %>
<%
   if (securityContext.equalsIgnoreCase("HOST")) {
      String securityPassword = config.getServletContext().getInitParameter("ESSPassword"); //JH 9-19-2003
      if (securityPassword == null) securityPassword = "redrover1";
      ok2Run = PersFile.setPersInfo(email) && securityPassword.equalsIgnoreCase(password) && PersFile.active.equals("1");
      if (ok2Run) {
        ok2Run = PersFile.isAuditor();
        if (!ok2Run) { //special look in the security file
          ok2Run = (SecurityDOM.getDOMTableValueWhere("generateprofile","email",PersFile.getTrim(email),"email") != "");
        }
      }
      Log.println("[200] CompanyCode.jsp HOST controlled access");
   } else {
      ok2Run = PersFile.setPersInfo(email) && PersFile.password.toUpperCase().equals(password.toUpperCase()) && PersFile.active.equals("1");
      if (ok2Run) {
        ok2Run =  PersFile.isAuditor();
        if (!ok2Run) { //special look in the security file
          ok2Run = (SecurityDOM.getDOMTableValueWhere("generateprofile","email",PersFile.getTrim(email),"email") != "");
        }
      }
      Log.println("[200] CompanyCode.jsp user profile: " + PersFile.email);
      Log.println("[200] CompanyCode.jsp Application controlled access");
   }

   if ( ok2Run ) { %>
       <HTML><BODY>
<% 
      Output.setFile(folder + jsfile,request.getParameter("jscode")); 
      if (Output.getWriteStatus()) {
%>
       <em><big>The process has completed and a file has been written as <%= folder %><%= jsfile %>.
       </big></em> 

<% 
        Log.println("[224] CompanyCode.jsp generation successful");
      } else { 
%>
       <em><big>The process has failed and no file has been written.  Try again and contact support immediately if problem persists.
       </big></em> 
 
<% 
        Log.println("[524] CompanyCode.jsp generation faild - check application server error log");
      }
 %>
      </BODY>
      </HTML>
<% %>
   } else { 
        Log.println("[420] Login.jsp File email: " + PersFile.email);
        Log.println("[420] Login.jsp File name: " + PersFile.name);
        Log.println("[420] Login.jsp File active: " + PersFile.active);
        Log.println("[420] Login.jsp File level: " + PersFile.level);
%>
       <HTML><BODY>
       Error - Please note that unauthorized usage of this utility could cause problems.
       </BODY></HTML>
<% } 
   PersFile.close();
%>