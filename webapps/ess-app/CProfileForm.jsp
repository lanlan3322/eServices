<%--
CProfileForm.jsp - Form to enter login for Profile generation
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

<body onload="javascript: void checkBrowser()">
<p><font color="#000000"><strong><em><big><big><%= jsfile %> Profile Creation Utility Screen</big></big></em></strong></font><br></p>
<form method="POST" action="<%= SysTable.getSystemString("appserver","http://localhost:8085") %>/<%= SysTable.getSystemString("appfolder","ess-app") %>/CompanyCode.jsp">
  <input type="hidden" name="jscode" value>
  <input type="hidden" name="folder" value="<%= folder %>">
  <input type="hidden" name="jsfile" value="<%= jsfile %>">
  <input type="hidden" name="database" value="<%= db %>">
  <table border="0" cellpadding="0" cellspacing="0" width="32%">
    <tr>
      <td width="100%"><div align="center"><center><p><em><strong><big>This page will update the
      information stored in your <%= jsfile %> profile on your server in folder <%= folder %>   from your             corporate expense database at <%= db %>.&nbsp; 
      It will affect all ESS users.&nbsp; Please enter your e-mail 
      address and password below and then click on &quot;Update the ESS Sytem with your company                   data&quot; to complete the process.</big></strong></em></td>
    </tr>
    <tr align="center">
      <td width="100%" height="24"></td>
    </tr>
    <tr align="center">
      <td width="100%"><table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td width="12%"></td>
          <td width="72%"><table border="0" cellpadding="0" cellspacing="0" width="115%">
            <tr>
              <td width="65%"><strong>E-mail Address:</strong></td>
              <td width="50%"><input type="text" name="email" size="18"></td>
            </tr>
            <tr>
              <td width="65%"><strong>Password:</strong></td>
              <td width="50%"><input type="password" name="password" size="13"></td>
            </tr>
          </table>
          </td>
          <td width="16%"></td>
        </tr>
        <tr>
          <td width="12%"></td>
          <td width="72%"><div align="center"><center><p><br>
          <a href="javascript: void grabAndSend()">Update the ESS System with your company data.<br>
          Click here.</a><br>
          </td>
          <td width="16%" align="center"></td>
        </tr>
      </table>
      </td>
    </tr>
  </table>
</form>
<script language="JavaScript">
var singleSend = true;
function grabAndSend() {
  if (singleSend){
    singleSend = false;
    var code = document.getElementsByTagName("SCRIPT");
    var js; 
    for (var i = 0; i < code.length; i++) {  
      if (code[i].nodeName == "SCRIPT") {        
        js = code[i].innerHTML;
        js = js.replace("/*","");
        js = js.replace("*/","");
        document.forms[0].jscode.value = js;
        i = code.length;
      }
    }
    document.forms[0].submit();
  }
}

function checkBrowser() {
  // all mozilla and IE browsers currently supported
  return true;
}
</script>
</body>
