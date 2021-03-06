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
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
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
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
         </tr>
     </thead>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
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
            <td width="10%" <%=backcolor%>><%= created%></td>
            <td width="10%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
            <td width="5%"  <%=backcolor%>><%= repdate%></td>
            <td width="10%" <%=backcolor%>><%= persname%></td>
            <td width="5%"  <%=backcolor%>><%= repamt%></td>
            <td width="10%" <%=backcolor%>><%= repStat %></td>
            <td width="30%" <%=backcolor%>><%= reason%></td>
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

<div id="approveSection" style="BORDER-BOTTOM: 1px solid; BORDER-LEFT: 1px solid; BORDER-TOP: 1px solid; BORDER-RIGHT: 1px solid">
    <form method="POST" accept-charset="ISO-8859-1" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/RejectSave.jsp">
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
      <input type="hidden" name="password" value="">
    <div class="col1of2" style="display:none">
        <input class="actiontype" type="radio" value="result" name="actiontype">Approve<br />
        <input class="actiontype" type="radio" name="actiontype" checked value="reject">Reject<br />
	</div>
    <div class="col1of2">
        <label for="msgdata">Comments to reject this leave application:</label>
        <textarea rows="2" name="msgdataRaw" cols="29" onChange="resolveMsgData()"></textarea>
	</div>
    <div class="col1of1">
		<input type="button" id="btApprove" value="<%= Lang.getString("REPORT_PROCESS_ACCORDINGLY") %>" name="B2" onClick="Javascript: void Approve()">
    </div>
    </form>
	</div>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/Reject_LeaveJS.jsp?reference=<%= reference%>&voucher=<%= voucher%>&status=<%= status%>&rcpt2=<%= rcpt2%>&reply2=<%= reply2%>&NeedPassword=<%= NeedPassword%>"/>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    </div>        
<% } //if (Reg.setResultSet(SQLCommand)) 
%> 
<% } else { %>
   <%@ include file="../ajax/ReloginRedirectMsg.jsp" %>
<% } %>
