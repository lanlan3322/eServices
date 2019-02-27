<%--
ApproveReport.jsp - displays report along with approval option
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
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<!-- check on the scope of the ServerSystemTavle -->
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />        
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />   
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />     
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Reg2"
     class="ess.AdisoftDbase"
     scope="page" />
	 
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<% 
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
   String database = request.getParameter("database");
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");
   String reply2 = request.getParameter("email");
   String rcpt2 = request.getParameter("rcpt2");
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;

boolean pFlag = PersFile.setPersInfo(reply2); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
   Sys.setConnection(PersFile.getConnection()); 
   Sys.setSQLTerminator(PersFile.getSQLTerminator()); //JH 2006-3-1
   String NeedPassword = Sys.getSystemString("pwd_approval","yes");
   String SQLCommand_Leave = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM =";
	SQLCommand_Leave += status + PersFile.getSQLTerminator();
%>
     <h1>Leave Details</h1>
<%if (Reg.setResultSet(SQLCommand_Leave)) { 

     String persname;
     String pvoucher = "";
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String reason;
	 String created;
	 String total;
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
%>

     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>&nbsp;</th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" <%=backcolor%>>Total</th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
         </tr>
     </thead>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
		total = PersFile.getTrim(Reg.myResult.getString(5)); 
        persname = PersFile.getTrim(Reg.myResult.getString(10));
        repStat = PersFile.getTrim(Reg.myResult.getString(12)); 
        reference = PersFile.getTrim(Reg.myResult.getString(1)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(8));
        repdate = PersFile.getTrim(Reg.myResult.getString(9));  
        repamt = PersFile.getTrim(Reg.myResult.getString(11)); 
		reason = PersFile.getTrim(Reg.myResult.getString(13)); 
		created = PersFile.getTrim(Reg.myResult.getString(6)); 
		String leaveNum = PersFile.getTrim(Reg.myResult.getString(4)); 
        //Log.println("[000] HistoryList.jsp voucher: " + voucher + ", " + repdate);
		created = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(created)),PersFile.getDateFormat());
		pvoucher = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(pvoucher)),PersFile.getDateFormat());
		persname = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(persname)),PersFile.getDateFormat());
     %>          
            <tr>
			<td width="5%" <%=backcolor%>>&nbsp;</td>
            <td width="10%" <%=backcolor%> align="center"><%= created%></td>
            <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
            <td width="10%" <%=backcolor%> align="center"><%= pvoucher%></td>
            <td width="5%"  <%=backcolor%> align="center"><%= repdate%></td>
            <td width="10%" <%=backcolor%> align="center"><%= persname%></td>
            <td width="5%"  <%=backcolor%> align="center"><%= repamt%></td>
            <td width="5%" <%=backcolor%>><%= total %></td>
            <td width="5%" <%=backcolor%> align="center"><%= repStat %></td>
            <td width="30%" <%=backcolor%> align="center"><%= reason%></td>
<%
			String SQLCommand2 = "SELECT PERS_NUM FROM SCAN WHERE SCAN_REF =";
			SQLCommand2 += leaveNum + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand2)) {
				if(PersFile.getTrim(Reg2.myResult.getString(1)).equalsIgnoreCase(reference)){
%>
            <td width="5%" <%=backcolor%>><a href="javascript: void window.open('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/receipts/ReceiptView.jsp?image=<%= leaveNum%>','Receipt_<%= leaveNum%>','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><%= leaveNum%></a></td>
			<%}
			else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}}else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}%>
            </tr>
  </table>
<hr/>
<table id="approveSection">
    <form method="POST" accept-charset="ISO-8859-1" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditSave_leave.jsp">
      <input type="hidden" name="email" value>
      <input type="hidden" name="company" value>
      <input type="hidden" name="ccode" value>
      <input type="hidden" name="database" value>
      <input type="hidden" name="voucher" value>
      <input type="hidden" name="reference" value>
      <input type="hidden" name="status" value>
      <input type="hidden" name="action" value>
      <input type="hidden" name="rcpt2" value>
      <input type="hidden" name="reply2" value>
      <input type="hidden" name="msgdata" value>
      <input type="hidden" name="newdepart" value>
      <input type="hidden" type="password" name="password" value="">
    <tr class="col1of2" style="display:none">
		<td>
			<input class="actiontype" type="radio" value="result" name="actiontype">Approve<br />
			<input class="actiontype" type="radio" name="actiontype" checked value="reject">Reject
		</td>
	</tr>
    <tr class="col1of2">
		<td>
        <label for="msgdata">Comments to reject this leave application:</label>
		</td>
	</tr>
    <tr class="col1of2">
		<td>
        <textarea rows="2" name="msgdataRaw" cols="29" onChange="resolveMsgData()"></textarea>
		</td>
	</tr>
	</tr>
    <tr class="col1of2">
		<td>
		<input type="button" id="btApprove" value="<%= Lang.getString("REPORT_PROCESS_ACCORDINGLY") %>" name="B2" onClick="Javascript: void Approve()">
		</td>
	</tr>
    </form>
</table>
<script text="javascript">
function initForm() {
  document.forms[0].name.value = parent.contents.getDBValue(parent.Header,"name");
  document.forms[0].reference.value = "<%= reference %>";
  document.forms[0].voucher.value = "<%= leaveNum %>";
  document.forms[0].email.value = parent.contents.getDBValue(parent.Header,"email");
  document.forms[0].company.value = parent.company;
  document.forms[0].ccode.value = parent.CCode;
  document.forms[0].database.value = parent.database;
  document.forms[0].status.value = "<%= reason %>";
  document.forms[0].action.value = "reject";
  document.forms[0].actiontype[1].checked = true;
  document.forms[0].rcpt2.value = "<%= rcpt2 %>";
  document.forms[0].reply2.value = "<%= reply2 %>";
  document.forms[0].newdepart.value = "";

//figure something out for reject
}
var submitSafetyFlag = true;

function Approve(){
  if (submitSafetyFlag) {
    var xfound = false;
    with (document.forms[0]) {
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
			document.forms[0].newdepart.value = departmentname.options[departmentname.selectedIndex].value;
           if (confirm("<%=Lang.getString("APP_ASSIGN")%>")) {
             resolveMsgData();
             //postSimpleForm(parent.defaultApps + 'ajax/AuditSave_leave.jsp',document.forms[0]);
			 submit();
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
             submit();
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
           submit();
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
   with (document.forms[0])
   {
      msgdata.value = parent.contents.XMLReplace(msgdataRaw.value);
      password.value = parent.contents.XMLReplace(password.value);
	  email.value = parent.contents.getDBValue(parent.Header,"email");
       ccode.value = parent.CCode;
	   voucher.value = <%= leaveNum %>;
	   status.value = "<%= reason%>";
	   reference.value = <%= reference%>;
   }
}

function screenLoad() {
      initForm();
      return true;
}

function screenUnload() {
      return true;
}

</script>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    </div>        
<% } //if (Reg.setResultSet(SQLCommand)) 
%> 
<% } else { %>
   <%@ include file="../ajax/ReloginRedirectMsg.jsp" %>
<% } %>
