<%--
DBAccessInfo.jsp - include for accessing parameters from the web.xml file
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

<% 
   ServletContext config2 = config.getServletContext(); 
   String DBDatabase = config2.getInitParameter("DBDatabase");
   String DBDriver = config2.getInitParameter("DBDriver");
   String DBUser = config2.getInitParameter("DBUser");  
   String DBPassword = config2.getInitParameter("DBPassword");
   String DBSQLTerminator = config2.getInitParameter("DBSQLTerminator");
   
   // DBDatabase cannot be null
   if (DBDriver == null) DBDriver = "";
   if (DBUser == null) DBUser = "";
   if (DBPassword == null) DBPassword = ""; 
   if (DBSQLTerminator == null) DBSQLTerminator = ";";
   
   String LDAPProvider = config2.getInitParameter("LDAPProvider");
   String LDAPSearchPrincipal = config2.getInitParameter("LDAPSearchPrincipal");
   String LDAPCredentials = config2.getInitParameter("LDAPCredentials");
   String LDAPFactory = config2.getInitParameter("LDAPFactory");
   String LDAPSearchString = config2.getInitParameter("LDAPSearchString");
   String LDAPEmailAttribute = config2.getInitParameter("LDAPEmailAttribute");
   String LDAPPrincipalAttribute = config2.getInitParameter("LDAPPrincipalAttribute");
   
   if (LDAPProvider == null) LDAPProvider = "";
   if (LDAPSearchPrincipal == null) LDAPSearchPrincipal = "";
   if (LDAPCredentials == null) LDAPCredentials = "";
   if (LDAPFactory == null) LDAPFactory = "";
   if (LDAPSearchString == null) LDAPSearchString = "";
   if (LDAPEmailAttribute == null) LDAPEmailAttribute = "";
   if (LDAPPrincipalAttribute == null) LDAPPrincipalAttribute = "";
   
%>