<%--
ApproveReportJS.jsp - displays report along with approval option [js code]
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />
      
<%@ page contentType="text/html" %>
<% 
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");
   String reply2 = request.getParameter("reply2");
   String rcpt2 = request.getParameter("rcpt2");
   String NeedPassword = request.getParameter("NeedPassword");
%>   
function initForm() {
  document.forms[formStartNumber].name.value = parent.getDBValue(parent.Header,"name");
  document.forms[formStartNumber].reference.value = "<%= reference %>";
  document.forms[formStartNumber].voucher.value = "<%= voucher %>";
  document.forms[formStartNumber].email.value = parent.getDBValue(parent.Header,"email");
  document.forms[formStartNumber].company.value = parent.company;
  document.forms[formStartNumber].ccode.value = parent.CCode;
  document.forms[formStartNumber].database.value = parent.database;
  document.forms[formStartNumber].status.value = "<%= status %>";
  document.forms[formStartNumber].action.value = "result";
  document.forms[formStartNumber].actiontype[1].checked = true;
  document.forms[formStartNumber].rcpt2.value = "<%= rcpt2 %>";
  document.forms[formStartNumber].reply2.value = "<%= reply2 %>";
  document.forms[formStartNumber].newdepart.value = "";

//figure something out for reject
}
var submitSafetyFlag = true;

function Approve(){
  if (submitSafetyFlag) {
    var xfound = false;
    with (document.forms[formStartNumber]) {
      for (var i = 0; i < actiontype.length; i++) {
        if (actiontype[i].checked == true) {
          action.value = actiontype[i].value;
          xfound = true;
        }
      }

      if (!xfound) {
        alert("<%=Lang.getString("APP_CHECK")%>");
      } else if (action.value == "assign") {
        if (msgdataRaw.value.length < 1) {
           alert("<%=Lang.getString("APP_NEED_MSG")%>");
           msgdataRaw.focus();
        } else {
			document.forms[formStartNumber].newdepart.value = departmentname.options[departmentname.selectedIndex].value;
           if (confirm("<%=Lang.getString("APP_ASSIGN")%>")) {
             resolveMsgData();
             postSimpleForm(parent.defaultApps + 'ajax/RejectSave.jsp',document.forms[formStartNumber]);
             submitSafetyFlag = false;
           }
        }
      } else if (action.value == "reject") {
        if (msgdataRaw.value.length < 1) {
           alert("<%=Lang.getString("APP_NEED_MSG")%>");
           msgdataRaw.focus();
        } else {
           if (confirm("<%=Lang.getString("APP_PROCEED")%>")) {
             resolveMsgData();
             postSimpleForm(parent.defaultApps + 'ajax/RejectSave.jsp',document.forms[formStartNumber]);
             submitSafetyFlag = false;
           }
        }
      } else if (action.value == "result") {
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          if (confirm("<%=Lang.getString("APP_CONFIRM")%>")) {
       <% }
       %>
           resolveMsgData();
           postSimpleForm(parent.defaultApps + 'ajax/RejectSave.jsp',document.forms[formStartNumber]);
           submitSafetyFlag = false;
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          }
       <% }
       %>


      } else {
        alert("<%=Lang.getString("APP_ACTION_ERROR")%>");
      }
    }
    return;
  }
}

function resolveMsgData(x) {
   with (document.forms[formStartNumber])
   {
      msgdata.value = parent.XMLReplace(msgdataRaw.value);
      password.value = parent.XMLReplace(password.value);
      email.value = parent.XMLReplace(email.value);
   }
}

function screenLoad() {
      initForm();
      return true;
}

function screenUnload() {
      return true;
}

