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
<%@ include file="DBAccessInfo.jsp" %>
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
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String lastname = request.getParameter("lastname");
   
   String SQLType; 
   if (PersFile.isAuditor())
   {
	   SQLType = "userlistsql";
   } else {
       SQLType = "useradminsql";
   }
   Log.println("[000] UserList.jsp SQLType:" + SQLType);
   String SQLCommand = SystemDOM.getDOMTableValueFor("personneltable",SQLType);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$lname$",Reg.repStr(lastname.toUpperCase()) + "%");
   SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",PersFile.getCompany());   
   Log.println("[000] UserList.jsp SQL:" + SQLCommand);

   if (Reg.setResultSet(SQLCommand)) { %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Report Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <h1>User List</h1><h2>
<%   
     String Pers_num = ""; 
     String Lname = "";
     String Fname = "";
     String Name = "";
     String Phone = "";
     String Location = "";
     String Depart = "";
     String Email = "";
     String Currency = "";
     String UserCompany = "";
     
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
     do { 

        Pers_num = PersFile.getTrim(Reg.myResult.getString(1)); 
        Lname = PersFile.getTrim(Reg.myResult.getString(2));
        Fname = PersFile.getTrim(Reg.myResult.getString(3));
        Name = PersFile.setRightName(Fname + " " + Lname);
        Phone = PersFile.getTrim(Reg.myResult.getString(4));
        Location = PersFile.getTrim(Reg.myResult.getString(5));
        Depart = PersFile.getTrim(Reg.myResult.getString(6));
        Email = PersFile.getTrim(Reg.myResult.getString(7));
        Currency = PersFile.getTrim(Reg.myResult.getString(10));
        if (Currency == null || Currency.equals("")) Currency = PersFile.getTrim(Reg.myResult.getString(11));
        UserCompany = PersFile.getTrim(Reg.myResult.getString(12));
        
     %>          
            <tr>
            <td width="20%" <%=backcolor%> align="center"><%= Lname%></td>
            <td width="20%" <%=backcolor%> align="center"><%= Fname%></td>
            <td width="20%" <%=backcolor%>><%= Depart%></td>
            <td width="20%" <%=backcolor%>><%= Location%></td>
            <td width="20%" <%=backcolor%>><%= Phone%></td>
            <td width="20%" <%=backcolor%>><a href="javascript: void x([['persnum','<%= Pers_num%>'],['name','<%= ess.Utilities.getJSArrayString(Name)%>'],['phone','<%= Phone%>'],['location','<%= ess.Utilities.getJSArrayString(Location)%>'],['depart','<%= Depart%>'],['currency','<%= Currency%>'],['company','<%= UserCompany%>']])"><span class="ExpenseReturnLink">Select</span></a></td>
            </tr>

     <%     newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;

     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
	  ex.printStackTrace();
    Log.println("[500] UserList.jsp java.lang exception");
%>
    <h2>Error in the SQL logic - contact support.</h2>
<%  
  } //try
  Reg.close();
%>
  </table>

<p align="right"><a class="ExpenseReturnLink" href="javascript: void parent.contents.TransWindow(parent.contents.defaultHead + 'head1b.html')" tabindex="2">Return to report header screen</a></p>

<p><h2>Note: Use the "Select" link to the right of the person to select that person for your expense report.</h2></p>

<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addmerchant.js"></script>
<script>
function x(AddValue) {

  if (parent.contents.setNameValue(parent.contents.Header, "persnum", AddValue[0][1]) &&
    parent.contents.setNameValue(parent.contents.Header, "name", AddValue[1][1]) &&
    parent.contents.setNameValue(parent.contents.Header, "phone", AddValue[2][1]) &&
    parent.contents.setNameValue(parent.contents.Header, "location", AddValue[3][1]) && 
    parent.contents.setNameValue(parent.contents.Header, "depart", AddValue[4][1]) &&
    parent.contents.setNameValue(parent.contents.Header, "company", AddValue[6][1])) 
    {

    var currency = AddValue[5][1];
    if (currency != "") {
        parent.contents.setNameValue(parent.contents.Header, "currency", currency);
        parent.contents.setGeneralLimit(currency);
    } else {
       parent.contents.generalLimit = parent.contents.getDefaultLimit();
    }   

    MerchantType = "reporter";
    //CCode.setDBPair(PersDataArea.PersDBase,MerchantType,AddValue);
    parent.contents.TransWindow(parent.contents.defaultHead + 'head1b.html')

  } else {
     alert("Error in data - cannot update personal database.\nPlease review current report header.");
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
    <p><div class="ExpenseTag">
    <%=PersFile.name%>, No employees have been found matching the specified description.
    <% Log.println("[400] UserList.jsp No employees where found."); %>
    </div></p>
    </body>
    <p align="right"><a class="ExpenseReturnLink" href="javascript: void parent.contents.TransWindow(parent.contents.defaultHead + 'head1b.html')" tabindex="2">Return to report header screen</a></p>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>


