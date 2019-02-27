<%--
DepartmentSelect.jsp - list users for selection by admin, audit, etc (see UserSelect.jsp)
Copyright (C) 2008 R. James Holton

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
String CCode = "";

String ownersName = request.getParameter("email");
Log.println("[000] DepartmentSelect.jsp accessed by :" + ownersName);
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
%>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String SQLCommand;
   String SQLType; 
   if (PersFile.isAuditor())
   {
	   SQLType = "departlistsql";
   } else {
       SQLType = "departadminsql";
   }

   String departname = request.getParameter("departname");
   if (departname != null) {
      SQLCommand = SystemDOM.getDOMTableValueFor("departtable",SQLType);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",Reg.repStr(departname.toUpperCase()) + "%");
      SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",PersFile.getCompany());
      Log.println("[000] DepartmentSelect.jsp SQL:" + SQLCommand);
   } else {
      SQLCommand = null;
   }   

   if (SQLCommand != null && Reg.setResultSet(SQLCommand)) { %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Personnel Number Selection</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <h1><%= Lang.getString("departementSel")%></h1><h2>
<%   
     String depart = ""; 
     String describ = "";
     String company = "";
     String gl_term = "";

     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     int adjustment = 0; //see status.xml
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">



<% try {
%>        <tr>
        <td width="20%" align="left"><u><%= Lang.getString("departement")%></u></td>
        <td width="20%" align="left"><u><%= Lang.getString("description")%></u></td>
        <td width="20%" ><u><%= Lang.getString("company")%></u></td>
        <td width="20%" ><u><%= Lang.getString("glMap")%></u></td>
        <td width="20%" ></td>
        </tr>
<%     
     do { 

        depart = PersFile.getTrim(Reg.myResult.getString(1)); 
        describ = PersFile.getTrim(Reg.myResult.getString(2));
        company = PersFile.getTrim(Reg.myResult.getString(3));
        gl_term = PersFile.getTrim(Reg.myResult.getString(4));
     
     %>          
            <tr>
            <td width="20%" <%=backcolor%> align="left"><%= depart%></td>
            <td width="20%" <%=backcolor%> align="left"><%= describ%></td>
            <td width="20%" <%=backcolor%>><%= company%></td>
            <td width="20%" <%=backcolor%>><%= gl_term%></td>
            <td width="20%" <%=backcolor%>><a href="javascript: void selectDepart('<%= depart%>','<%= describ%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select")%></span></a></td>
            </tr>

     <%     newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;

     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] DepartmentSelect.jsp java.lang exception");
%>
    <h2>Error in the SQL logic - contact support.</h2>
<%  
  } //try
  Reg.close();
%>
  </table>

<p><h2><%= Lang.getString("useSelLinUpdScr")%></h2></p>

<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addmerchant.js"></script>
<script>

function selectDepart(x,y){
  //window.opener.parent.main.LocalFldObj.value = x;
  window.opener.parent.main.returnDepart(x,y);
  window.opener.parent.main.LocalFldObj.focus();
  window.close();
}

function FormInit(){
  window.focus();
  window.onresize = hdleResize;
  document.forms[0].merchant.focus();  
}

function hdleResize() {
//  note that ns6 also supports : body.clientWidth/Height 
  var x = 0;
  var y = 0;
  if (document.documentElement.clientWidth && document.documentElement.clientWidth != 0) {
    x = document.documentElement.clientWidth;  //IE 6 standard
    y = document.documentElement.clientHeight;
  } else if (document.body.clientWidth && document.body.clientWidth != 0) {
    x = document.body.clientWidth;  // IE quirkie mode
    y = document.body.clientHeight;
  } else if (window.innerWidth && window.innerWidth != 0) {
    x = window.innerWidth;  // NS
    y = window.innerHeight;
  }
  
  if(opener.parent.main.MerWinSize && opener.parent.main.MerWinSize != null) { 
    opener.parent.main.MerWinSize(x,y);
  }
}

</script>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title><%= Lang.getString("departmentSea")%></title>
    <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
    </head>
    <body>
    <h1><%= Lang.getString("departmentSea")%></h1>
    <% Log.println("[400] DepartmentSelect.jsp Selection only.");
    } //if (Reg.setResultSet(SQLCommand)) 
%>
  <form method="POST" action="DepartmentSelect.jsp" onSubmit="return SubmitSearch()">
    <h2><br><%= Lang.getString("selectDepSta")%>
    <input type="text" name="departname" size="16" value="%"> 
    <input type="submit" value= "<%= Lang.getString("butSea")%>" name="Search"></h2>
    <br><em><%= Lang.getString("useCauAllUse")%></em>
    <input type="hidden" name="email" value>
    <input type="hidden" name="ccode" value>
    <input type="hidden" name="database" value>
  </form>
  <script language=JavaScript>
  function SubmitSearch() {
   with(document.forms[0]) {
    var xyz = window.opener.parent.contents.alltrim(departname.value);
    if (xyz.length >= 1) {
       email.value = "<%= ownersName %>";
       return true;  
    } else {
      alert("<%= Lang.getString("youLimSeaOneAlp")%>");
      return false;
    }
   }
  }
  </script>
</body>
</html>
<%
} else { %>
  <script>
    alert("Function not available.  Retry and/or relogin.  If problem persists, contact support.");
    window.opener.focus();
    window.close();
  </script>
  </body>
  </html>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
%>



