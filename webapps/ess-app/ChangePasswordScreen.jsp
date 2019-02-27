<%--
ChangePwdScreen.jsp - Entrance to the ESS system
Copyright (C) 2004,2011 R. James Holton

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


<% if (PersFile.active.equals("1")) { %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Password Change Screen</title>
<link rel="icon" href="favicon.ico" type="image/x-icon" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="/ess/expenseLinko.css" media="screen" />
<!--[if lt IE 8]>
<link rel="stylesheet" type="text/css" href="/ess/expenseLinko_ie8.css" media="screen" />
<![endif]-->
<!--[if lt IE 7]>
<link rel="stylesheet" type="text/css" href="/ess/expenseLinko_ie7.css" media="screen" />
<![endif]-->
</head>

<body onLoad="init()">

<div id="loginLogo" class="ESSName"><h1 height="100px">&nbsp;</h1></div>

<div id="infoLogin">
         <h4>Password Change Screen</h4>
            <br>Enter your new password twice to change from your current password to a new password.<br><br><br>
        <form>    
          <input type="hidden" name="company" value="ess">
          <input type="hidden" name="changeScreen" value>
          <input type="hidden" name="loginScreen" value="/ess/en/XLogin.html">
          <input type="hidden" name="email" value="<%= PersFile.getEmailAddress() %>">
              <label for="password">New Password:&nbsp;</label>
              <input type="password" name="newPwd1" size="13"><br><br>
              <label for="password">New Password Again:&nbsp;</label>
              <input type="password" name="newPwd2" size="13">
           <input id="btEnter2" type="submit" value="Change Password" name=" ">
        </form>
</div>
<!--- site specific lists, generated from tables --->
<script language="Javascript" src="/ess-app/ajax/ESSProfile.jsp">
</script>
<script language="Javascript" id="companyScript" src="/ess-app/ajax/Company.jsp">
</script>
<script LANGUAGE="JavaScript" SRC="/ess/trim.js"></script>
<script>
function init() {
    document.forms[0].action = "<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ChangePassword.jsp";
    document.forms[0].changeScreen.value = "<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ChangePasswordScreen.jsp";
    document.forms[0].loginScreen.value = "<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/XLogin.jsp";
}
</script>

</body>
</html>

<% } else { %>
         <HTML><BODY>
         <strong><em>You cannot change your password now because the session has expired.<br>
         Please login with you previous password and try again.</em></strong><br><br>
         </BODY></HTML>
<% } %>