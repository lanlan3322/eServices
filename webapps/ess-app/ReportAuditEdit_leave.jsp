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
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
Reg.setConnection(PersFile.getConnection()); 
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
	String persnumber = request.getParameter("newLeavePer");
	String ANNUAL_BAL = request.getParameter("ANNUAL_BAL");
	String ANNUAL_ENT = request.getParameter("ANNUAL_ENT");
	String MARRIAGE_BAL = request.getParameter("MARRIAGE_BAL");
	String MARRIAGE_ENT = request.getParameter("MARRIAGE_ENT");
	String CHILDCARE_BAL = request.getParameter("CHILDCARE_BAL");
	String CHILDCARE_ENT = request.getParameter("CHILDCARE_ENT");
	String MEDICAL_BAL = request.getParameter("MEDICAL_BAL");
	String MEDICAL_ENT = request.getParameter("MEDICAL_ENT");
	String HOSPITAL_BAL = request.getParameter("HOSPITAL_BAL");
	String HOSPITAL_ENT = request.getParameter("HOSPITAL_ENT");
	String PATERNITY_BAL = request.getParameter("PATERNITY_BAL");
	String PATERNITY_ENT = request.getParameter("PATERNITY_ENT");
	String MATERNITY_BAL = request.getParameter("MATERNITY_BAL");
	String MATERNITY_ENT = request.getParameter("MATERNITY_ENT");
	String COMP_BAL = request.getParameter("COMP_BAL");
	String COMP_ENT = request.getParameter("COMP_ENT");
	String COMP_NEXTOFKIN_BAL = request.getParameter("COMP_NEXTOFKIN_BAL");
	String COMP_NEXTOFKIN_ENT = request.getParameter("COMP_NEXTOFKIN_ENT");
	String OFINLIEU_BAL = request.getParameter("OFINLIEU_BAL");
	String OFINLIEU_ENT = request.getParameter("OFINLIEU_ENT");
	String RESERVIST_BAL = request.getParameter("RESERVIST_BAL");
	String RESERVIST_ENT = request.getParameter("RESERVIST_ENT");
	String UNPAID_BAL = request.getParameter("UNPAID_BAL");
	String UNPAID_ENT = request.getParameter("UNPAID_ENT");
	String BRING_FORWARD = request.getParameter("BRING_FORWARD");
	String ADVANCE_LEAVE = request.getParameter("ADVANCE_LEAVE");
	String ADD_ON = request.getParameter("ADD_ON");
	String email = "services@elc.com.sg";
	String name = "";

      String SQLCommand = "UPDATE LEAVEINFO SET ANNUAL_BAL=";
       SQLCommand += ANNUAL_BAL;
       SQLCommand += ", ANNUAL_ENT=";
       SQLCommand += ANNUAL_ENT;
       SQLCommand += ", MARRIAGE_BAL=";
       SQLCommand += MARRIAGE_BAL;
       SQLCommand += ", MARRIAGE_ENT =";
       SQLCommand += MARRIAGE_ENT;
       SQLCommand += ", CHILDCARE_BAL =";
       SQLCommand += CHILDCARE_BAL;
       SQLCommand += ", CHILDCARE_ENT =";
       SQLCommand += CHILDCARE_ENT;
       SQLCommand += ", MEDICAL_BAL =";
       SQLCommand += MEDICAL_BAL;
       SQLCommand += ", MEDICAL_ENT =";
       SQLCommand += MEDICAL_ENT;
       SQLCommand += ", HOSPITAL_BAL =";
       SQLCommand += HOSPITAL_BAL;
       SQLCommand += ", HOSPITAL_ENT =";
       SQLCommand += HOSPITAL_ENT;
       SQLCommand += ", PATERNITY_BAL =";
       SQLCommand += PATERNITY_BAL;
       SQLCommand += ", PATERNITY_ENT =";
       SQLCommand += PATERNITY_ENT;
       SQLCommand += ", MATERNITY_BAL =";
       SQLCommand += MATERNITY_BAL;
       SQLCommand += ", MATERNITY_ENT =";
       SQLCommand += MATERNITY_ENT;
       SQLCommand += ", COMP_BAL =";
       SQLCommand += COMP_BAL;
       SQLCommand += ", COMP_ENT =";
       SQLCommand += COMP_ENT;
       SQLCommand += ", COMP_NEXTOFKIN_BAL =";
       SQLCommand += COMP_NEXTOFKIN_BAL;
       SQLCommand += ", COMP_NEXTOFKIN_ENT =";
       SQLCommand += COMP_NEXTOFKIN_ENT;
       SQLCommand += ", OFINLIEU_BAL =";
       SQLCommand += OFINLIEU_BAL;
       SQLCommand += ", OFINLIEU_ENT =";
       SQLCommand += OFINLIEU_ENT;
       SQLCommand += ", RESERVIST_BAL =";
       SQLCommand += RESERVIST_BAL;
       SQLCommand += ", RESERVIST_ENT =";
       SQLCommand += RESERVIST_ENT;
       SQLCommand += ", UNPAID_BAL =";
       SQLCommand += UNPAID_BAL;
       SQLCommand += ", UNPAID_ENT =";
       SQLCommand += UNPAID_ENT;
       SQLCommand += ", BRING_FORWARD =";
       SQLCommand += BRING_FORWARD;
       SQLCommand += ", ADVANCE_LEAVE =";
       SQLCommand += ADVANCE_LEAVE;
       SQLCommand += ", PENDING_LEAVE =";
       SQLCommand += ADD_ON;
       SQLCommand += " WHERE PERS_NUM =";
       SQLCommand += persnumber;
		SQLCommand += PersFile.getSQLTerminator();

	   int SQLResult = Reg.doSQLExecute(SQLCommand);
	   SQLResult = 0;
	   if(SQLResult > -1){
			String SQLCommand2 = "SELECT EMAIL,FNAME FROM USER WHERE PERS_NUM = " + persnumber + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand2)) {
				email = PersFile.getTrim(Reg.myResult.getString(1));
				name = PersFile.getTrim(Reg.myResult.getString(2));
			}
		   
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <title>Leave updated</title>
     </head>
     <body>
		<p><big><em><strong><font face="Arial">The following leave information have been updated:</font></strong></em></big></p>
		<p><big><em><strong><font face="Arial"><%=name%></font></strong></em></big></p>
		<p><big><em><strong><font face="Arial"><%=email%></font></strong></em></big></p>
		 <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
		 <thead>
			 <tr>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>&nbsp;</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Annual</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Marriage</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Childcare</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Medical</td>
				 <td class="ExpenseTag" width="10%" <%=backcolor%>>Hospitalisation</td>
				 <td class="ExpenseTag" width="10%" <%=backcolor%>>Paternity</td>
				 <td class="ExpenseTag" width="10%" <%=backcolor%>>Maternity</td>
				 <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate Next-of-kin</td>
				 <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate</td>
				 <td class="ExpenseTag" width="15%" <%=backcolor%>>Off In Lieu</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Reservist</td>
				 <td class="ExpenseTag" width="5%" <%=backcolor%>>Unpaid</td>
			 </tr>
		 </thead>      
				<tr>
				 <td width="5%" <%=backcolor%>>BAL</td>
				 <td width="5%" <%=backcolor%>><%=ANNUAL_BAL%></td>
				 <td width="5%" <%=backcolor%>><%=MARRIAGE_BAL%></td>
				 <td width="5%" <%=backcolor%>><%=CHILDCARE_BAL%></td>
				 <td width="5%" <%=backcolor%>><%=MEDICAL_BAL%></td>
				 <td width="10%" <%=backcolor%>><%=HOSPITAL_BAL%></td>
				 <td width="10%" <%=backcolor%>><%=PATERNITY_BAL%></td>
				 <td width="10%" <%=backcolor%>><%=MATERNITY_BAL%></td>
				 <td width="10%" <%=backcolor%>><%=COMP_BAL%></td>
				 <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_BAL%></td>
				 <td width="15%" <%=backcolor%>><%=OFINLIEU_BAL%></td>
				 <td width="5%" <%=backcolor%>><%=RESERVIST_BAL%></td>
				 <td width="5%" <%=backcolor%>><%=UNPAID_BAL%></td>
				</tr>
		 <%     
				newbackcolor = backcolor;
				backcolor = oldbackcolor; 
				oldbackcolor = newbackcolor;
		%>
				<tr>
				 <td width="5%" <%=backcolor%>>ENT</td>
				 <td width="5%" <%=backcolor%>><%=ANNUAL_ENT%></td>
				 <td width="5%" <%=backcolor%>><%=MARRIAGE_ENT%></td>
				 <td width="5%" <%=backcolor%>><%=CHILDCARE_ENT%></td>
				 <td width="5%" <%=backcolor%>><%=MEDICAL_ENT%></td>
				 <td width="10%" <%=backcolor%>><%=HOSPITAL_ENT%></td>
				 <td width="10%" <%=backcolor%>><%=PATERNITY_ENT%></td>
				 <td width="10%" <%=backcolor%>><%=MATERNITY_ENT%></td>
				 <td width="10%" <%=backcolor%>><%=COMP_ENT%></td>
				 <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_ENT%></td>
				 <td width="15%" <%=backcolor%>><%=OFINLIEU_ENT%></td>
				 <td width="5%" <%=backcolor%>><%=RESERVIST_ENT%></td>
				 <td width="5%" <%=backcolor%>><%=UNPAID_ENT%></td>
				</tr>
	  </table>

<div class="ExpenseTag">Bring Forward: <%= BRING_FORWARD %></div>
<div class="ExpenseTag">Advance: <%= ADVANCE_LEAVE %></div>	</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    </head>
    <body>
    <p><big><big><strong>Create new pending leave failed!</strong></big></big></p>
    </body>
    <script>
    //<%= SQLCommand %>//
    </script>
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



