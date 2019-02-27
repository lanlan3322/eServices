<%--
getDBase.jsp - personal DOM from XMLU is created
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

<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Rep2"
     class="ess.Report2Client"
     scope="page" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<% 
   // Need to have PersFile defined in calling routine ------

   DOM.setConnection(PersFile.getConnection()); 
   Sys.setConnection(PersFile.getConnection());
   Sys.setSQLTerminator(PersFile.getSQLTerminator());
   
   String reg_dbase = Sys.getSystemString("PERSONAL_FOLDER","C:\\WORK\\");
   java.io.File PersDBaseDOM = new java.io.File(reg_dbase + PersFile.getEmailAddress());  //need to be defined in parent
   DOM.setDOM(PersDBaseDOM); 
   Rep2.setDBString(DOM.getDOM());
   // Sys.close(); need to do this in the calling program
%>

