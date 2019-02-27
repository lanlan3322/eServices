<%--
HistoryList.jsp - List out reports from central database
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
     
     
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>
<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");

     String persname = "";
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference = "";
     String repdate = "";
     String repamt = "";
     String repStat = "";
     String repDBStat = "";
	 String reason = "";
	 String created = "";   
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor = "";
	 String persnumber = PersFile.persnum;
	String leaveNum = ""; 
	String leaveTotal = ""; 
	 
boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
//if (pFlag) { 
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 


	 String SQLCommand_Leave = SystemDOM.getDOMTableValueFor("history","reporter_leave_pending");
	SQLCommand_Leave = Reg.SQLReplace(SQLCommand_Leave,"$persnum$",persnumber);
	if (Reg.setResultSet(SQLCommand_Leave)) { 
    try {
     //do { 
//SQL order RP_STAT, PERS_NUM, VOUCHER, PVOUCHER, SUB_DATE, NAME,RE_AMT
        repStat = PersFile.getTrim(Reg.myResult.getString(1)); 
        reference = PersFile.getTrim(Reg.myResult.getString(2)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(3));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(4));
        repdate = PersFile.getTrim(Reg.myResult.getString(5));  
        persname = PersFile.getTrim(Reg.myResult.getString(6));
        
        repamt = PersFile.getTrim(Reg.myResult.getString(7)); 
		reason = PersFile.getTrim(Reg.myResult.getString(8)); 
		created = PersFile.getTrim(Reg.myResult.getString(9)); 
		leaveNum = PersFile.getTrim(Reg.myResult.getString(10)); 
		leaveTotal = PersFile.getTrim(Reg.myResult.getString(11));
		String newLeaveStatue = "New";
%>
<span id="personalData"><%= Lang.getString("PERSONAL_DATA_BEING_UPDATED") %></span>
<br><br>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SaveXMLJS_leave.jsp?email=<%= ownersName%>&reference=<%= leaveNum%>&ccode=<%= CCode%>&status=<%= newLeaveStatue%>"/>

<%     //} while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%  
  } //try
 } else {%>
<script language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/startJS_leave.jsp"/>
<%	} //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>




