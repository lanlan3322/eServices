<%--
ReportList.jsp - List reports in the central database for editing, viewing or removal
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
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="org.json.JSONObject" %>
<%@page import="java.text.SimpleDateFormat"%>
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Reg2"
     class="ess.AdisoftDbase"
     scope="page" />
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
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
		String backcolor = "class=\"offsetColor\"";
		String oldbackcolor = "";
		String newbackcolor;
	   String begDateStr = request.getParameter("target");
	   String cat = request.getParameter("cat");

boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
Reg.setConnection(PersFile.getConnection()); 
   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
	 (function() {
		for(var n=8, r=document.querySelector("tbody>tr"), p=r.parentNode; n--; p.appendChild(r.cloneNode(true)));
		})();
     </script>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/tables.css" type="text/css">
	  </head>
     <body>
	 <br/>
	 <br/>
     <h1>Inventory balance for the year : <%=begDateStr%>  - Category: <%=cat%></h1>
<%
		String SQLCommand3 = "SELECT * FROM DB_BALANCE WHERE ITEM_YEAR = '" + begDateStr + "' AND ITEM_CATEGORY = '" + cat + "'";
		if(cat.equals("All")){
			SQLCommand3 = "SELECT * FROM DB_BALANCE WHERE ITEM_YEAR = '" + begDateStr + "' ORDER BY ITEM_CATEGORY";
		}
		SQLCommand3 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand3)) {
			try {%>
	<div class="scrollingtable">
		<div>
			<div>
				<table>
					<thead>
         <tr>
             <th><div label="Name"></div></th>
             <th><div label="Category"></div></th>
             <th><div label="Description"></div></th>
             <th><div label="Balance"></div></th>
             <th><div label="Storage"></div></th>
         </tr>
     </thead>
    <!-- Table Body -->
    <tbody>
<%			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			do {
%>
            <tr>
            <td width="30%" <%=backcolor%> align="left"><%= PersFile.getTrim(Reg2.myResult.getString(2))%></td>
            <td width="10%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(3))%></td>
            <td width="30%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(4))%></td>
            <td width="10%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(5))%></td>
            <td width="20%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(7))%></td>
           </tr>
<%
			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			} while (Reg2.myResult.next());
		  } catch (java.lang.Exception ex) {
			ex.printStackTrace();
		  } //try
		}else { %>
<br><br><strong><em>No record found!</em></strong>
<%
}
%>
				</tbody>
				</table>
			</div>
		</div>
	</div>
	</body>
	  </html>
<%	} else { %>
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reg2.close();      //cleaning up open connections 
%>




