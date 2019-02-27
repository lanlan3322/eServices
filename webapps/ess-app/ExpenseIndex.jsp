<%--
ExpenseIndex.jsp - Working - creates an index - must be modified to run
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

<%@ include file="DBAccessInfo.jsp" %>
<% //String database = request.getParameter("database");
   //String email = request.getParameter("email"); 
   //String password = request.getParameter("password");
   //String company = request.getParameter("company");
   //String folder = request.getParameter("folder");
   //PersFile.setDB(database,DBUser,DBPassword);
   
   String database = "jdbc:odbc:adisoft";
   String email = "jim@adisoft-inc.com"; 
   String password = "xxxxxx";
   String company = "ess";
   PersFile.setDB(database,DBUser,DBPassword);
      
   if (password == null) password = "";
   PersFile.setSQLStrings();
 
   // put in a level check later
   if (PersFile.setPersInfo(email) && PersFile.password.toUpperCase().equals(password.toUpperCase())) { 

       int x = PersFile.doSQLExecute("CREATE UNIQUE INDEX REFERENCE ON REGISTER (REFERENCE);");
       x = PersFile.doSQLExecute("CREATE INDEX OWNER ON REGISTER (OWNER);");

       //x = PersFile.doSQLExecute("CREATE INDEX REVDATE ON REGISTER (CRE_DATE DESC, VOUCHER DESC);");

%>
       <HTML><BODY>
       Index has been completed.
       </BODY><HTML>
<% } else { %>
       <HTML><BODY>
       Can't verify password - Please note that unauthorized usage of this utility could cause problems.
       </BODY><HTML>
<% } 
   PersFile.close();
%>