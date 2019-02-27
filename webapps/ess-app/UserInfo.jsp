<%--
UserList.jsp - list users for selection by admin, audit, etc (see UserSelect.jsp)
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
Log.println("[000] UserManager.jsp accessed by :" + ownersName);
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
	   SQLType = "userlistsql";
   } else {
       SQLType = "useradminsql";
   }
  
   String lastName = request.getParameter("lastname");
   if (lastName != null) {
      SQLCommand = SystemDOM.getDOMTableValueFor("personneltable",SQLType);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$lname$",Reg.repStr(lastName.toUpperCase()) + "%");
      SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",PersFile.getCompany());   
      Log.println("[000] UserInfo.jsp SQL:" + SQLCommand);
   } else {
      SQLCommand = null;
   }   

   if (SQLCommand != null && Reg.setResultSet(SQLCommand)) { %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Report Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <h1><%= Lang.getString("userLis")%></h1><h2>
<%   
     String Pers_num = ""; 
     String Lname = "";
     String Fname = "";
     String Name = "";
     String Phone = "";
     String Location = "";
     String Depart = "";
     String Vehicle = "";
     String ServDate = "";

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
        <td width="20%" align="left"><u><%= Lang.getString("last")%></u></td>
        <td width="20%" align="left"><u><%= Lang.getString("first")%></u></td>
        <td width="20%" ><u><%= Lang.getString("location")%></u></td>
        <td width="20%" ><u><%= Lang.getString("persNo")%></u></td>
        <td width="20%" ></td>
        </tr>
<%     
     do { 

        Pers_num = PersFile.getTrim(Reg.myResult.getString(1)); 
        Lname = PersFile.getTrim(Reg.myResult.getString(2));
        Fname = PersFile.getTrim(Reg.myResult.getString(3));
        Name = PersFile.setRightName(Fname + " " + Lname);
        Phone = PersFile.getTrim(Reg.myResult.getString(4));
        Location = PersFile.getTrim(Reg.myResult.getString(5));
        Depart = PersFile.getTrim(Reg.myResult.getString(6));
        Vehicle = PersFile.getTrim(Reg.myResult.getString(8));
        ServDate = PersFile.getTrim(Reg.myResult.getString(9));
        if (ServDate.compareTo("1992-00-00") < 0) {
          ServDate = "";
        } else {
          ServDate = Dt.getSimpleDate(Dt.getDateFromXBase(ServDate));
        }
     %>          
            <tr>
            <td width="20%" <%=backcolor%> align="left"><%= Lname%></td>
            <td width="20%" <%=backcolor%> align="left"><%= Fname%></td>
            <td width="20%" <%=backcolor%>><%= Location%></td>
            <td width="20%" <%=backcolor%>><%= Pers_num%></td>
            <td width="20%" <%=backcolor%>><a href="javascript: void selectUser('<%= Pers_num%>','<%= ess.Utilities.getJSArrayString(Name)%>','<%= Phone%>','<%= ess.Utilities.getJSArrayString(Location)%>','<%= Depart%>','<%= Vehicle%>','<%= ServDate%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select")%></span></a></td>
            </tr>

     <%     newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;

     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ManagerList.jsp java.lang exception");
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

function selectUser(a,b,c,d,e,f,g){
  with(window.opener.parent.main.document.forms[0]) {
    PERS_NUM.value = a;
    NAME.value = b;
    PHONE.value = c;
    LOCATION.value = d;
    DEPART.value = e;
    VEHICLE.value = f;
    SERVDATE.value = g;
    window.opener.parent.main.departMapping(DEPART, departname);
  }
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
</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>No employees</title>
    <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
    </head>
    <body>
    <h1><%= Lang.getString("userSea")%></h1>
    <% Log.println("[400] ManagerList.jsp Selection only.");
    } //if (Reg.setResultSet(SQLCommand)) 
%>
  <form method="POST" action="UserInfo.jsp" onSubmit="return SubmitSearch()">
    <h2><br><%= Lang.getString("selectLasNamSta")%>
    <input type="text" name="lastname" size="16" value="%"> 
    <input type="submit" value= "<%= Lang.getString("butSea")%>" name="Search"></h2>
    <br><em><%= Lang.getString("useCauAllUse")%></em>
    <input type="hidden" name="email" value>
    <input type="hidden" name="ccode" value>
    <input type="hidden" name="database" value>
  </form>
  <script language=JavaScript>
  function SubmitSearch() {
   with(document.forms[0]) {
    var xyz = window.opener.parent.contents.alltrim(lastname.value);
    if (xyz.length > 0) {
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



