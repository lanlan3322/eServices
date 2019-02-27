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

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
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
Reg.setConnection(PersFile.getConnection()); 
   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
%>
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="../SendAnEmail.jsp" %>
<%

// these are used in conjunction with the SQL found in system.xml
   //String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
	String SQLCommand = request.getParameter("reporttype");
	String taskToRun = request.getParameter("taskToRun");
	String daysToRun = request.getParameter("daysToRun");
	String departToRun = request.getParameter("departToRun");
	String usersToRun = request.getParameter("usersToRun");

	if(taskToRun.equals("Create Report"))
	{
	   String begDateStr = request.getParameter("begdate");
	   String endDateStr = request.getParameter("enddate");
	   String begDateSQL = "";
	   String endDateSQL = "";
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
		SQLCommand = SQLCommand + DBSQLTerminator;
	   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDateSQL);
	   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDateSQL);
	   if (Reg.setResultSet(SQLCommand)) { %>
     <h1><%= Lang.getString("LEAVE_HISTORY")%></h1>
<%
     String persname;
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String reason;
	 String created;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     int adjustment = 0; //see status.xml
%>

     <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>Name</th>
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
 
    try {
     do { 
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

     %>          
            <tr>
<%
			String SQLCommand3 = "SELECT FNAME FROM USER WHERE PERS_NUM =";
			SQLCommand3 += reference + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand3)) {
%>
			<td width="5%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(1))%></td>
			<%}else{%>
            <td width="5%" <%=backcolor%>><%= reference%></td>
			<%}%>
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
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp java.lang exception possibly voucher: " + voucher);
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString()); 
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%  
  } //try
%>
  </table>

<% if (!xfound) { %>
<h2>
<%= Lang.getString("REPORTS_NOT_FOUND") %><br>
</h2>
<% } %>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand)) 
%>          
<%   }//if create report
	else if(taskToRun.equals("Daily scripts")){
		%>In working...<%
	}
	else if(taskToRun.equals("Yearly scripts")){
		%>In working...<%
	}
	else if(taskToRun.equals("Half year scripts")){
		%>In working...<%
	}
	else if(taskToRun.equals("Bring forward usage")){
		%>In working...<%
	}
	else if(taskToRun.equals("Add/Deduct for group")){
		%>In working...<%=daysToRun%>,<%=departToRun%><%
	}
	else{
		%>Not valid script selection...<%
	}
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



