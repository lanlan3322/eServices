<%--
AuditList.jsp - List out reports to be audited - allows batch auditing
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
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CanApprove"
     class="ess.Approver"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log" 
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />  
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   


<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
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
<%@ include file="DepartInfo.jsp" %>
<%
   Log.println("[000] AuditList.jsp - start: " + ownersName); 

   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 

   Reporter.setConnection(PersFile.getConnection());
   Reporter.setSQLTerminator(PersFile.getSQLTerminator());
   Reporter.setSQLStrings();

   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   CanApprove.setConnection(PersFile.getConnection());
   CanApprove.setSQLTerminator(PersFile.getSQLTerminator()); 
   CanApprove.setUpFiles();
   CanApprove.setApprover(PersFile);

   String PData =  request.getParameter("persdbase");
   if (PData != null) {
      Log.println("[000] AuditList.jsp - Audit access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] AuditList.jsp - Audit access by " + ownersName);
   }

   String NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_audit","yes");
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String downlevel = request.getParameter("downlevel");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
   
   String SQLCommand_Balance = SystemDOM.getDOMTableValueFor("history","reporter_balance_all");
	String ANNUAL_BAL="0";
	String ANNUAL_ENT="0";
	String MARRIAGE_BAL="0";
	String MARRIAGE_ENT="0";
	String CHILDCARE_BAL="0";
	String CHILDCARE_ENT="0";
	String MEDICAL_BAL="0";
	String MEDICAL_ENT="0";
	String HOSPITAL_BAL="0";
	String HOSPITAL_ENT="0";
	String PATERNITY_BAL="0";
	String PATERNITY_ENT="0";
	String MATERNITY_BAL="0";
	String MATERNITY_ENT="0";
	String COMP_BAL="0";
	String COMP_ENT="0";
	String COMP_NEXTOFKIN_BAL="0";
	String COMP_NEXTOFKIN_ENT="0";
	String OFINLIEU_BAL="0";
	String OFINLIEU_ENT="0";
	String RESERVIST_BAL="0";
	String RESERVIST_ENT="0";
	String UNPAID_BAL="0";
	String UNPAID_ENT="0";
	String BRING_FORWARD="0";
	String ADVANCE_LEAVE="0";
	String PENDING_LEAVE="0";

   if (Reg.setResultSet(SQLCommand_Balance)) {
		%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Report Selection:</title>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
	 (function() {
		for(var n=8, r=document.querySelector("tbody>tr"), p=r.parentNode; n--; p.appendChild(r.cloneNode(true)));
		})();
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/tables.css" type="text/css">
     </head>
	 <br/>
	 <br/>
     <h1>All leave balance</h1>
     <body onLoad="initForm()">
	<div class="scrollingtable">
		<div>
			<div>
				<table>
					<thead>
		<tr>
			 <th><div label="Name"></div></th>
             <!--<th class="ExpenseTag" width="5%" <%=backcolor%>>Reference</th>-->
			 <!--<th class="ExpenseTag" width="10%" <%=backcolor%>>Email</th>-->
             <th><div label="Annual"></div></th>
             <th><div label="Medical"></div></th>
             <th><div label="OIL"></div></th>
             <th><div label="Reservist"></div></th>
             <th><div label="Unpaid"></div></th>
             <th><div label="Pending"></div></th>
             <th><div label="BF"></div></th>
             <th><div label="Marriage"></div></th>
             <th><div label="Childcare"></div></th>
             <th><div label="Hospital"></div></th>
             <th><div label="Paternity"></div></th>
             <th><div label="Maternity"></div></th>
             <!--<th class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate Next-of-kin</th>-->
             <th><div label="Comp"></div></th>
              <th class="scrollbarhead"></th> <!--ALWAYS ADD THIS EXTRA CELL AT END OF HEADER ROW-->
         </tr>
    </thead>
    <!-- Table Header -->

    <!-- Table Body -->
    <tbody>
<% 
    try {
     do { 
		ANNUAL_BAL=PersFile.getTrim(Reg.myResult.getString(1));
		ANNUAL_ENT=PersFile.getTrim(Reg.myResult.getString(2));
		MARRIAGE_BAL=PersFile.getTrim(Reg.myResult.getString(3));
		MARRIAGE_ENT=PersFile.getTrim(Reg.myResult.getString(4));
		CHILDCARE_BAL=PersFile.getTrim(Reg.myResult.getString(5));
		CHILDCARE_ENT=PersFile.getTrim(Reg.myResult.getString(6));
		MEDICAL_BAL=PersFile.getTrim(Reg.myResult.getString(7));
		MEDICAL_ENT=PersFile.getTrim(Reg.myResult.getString(8));
		HOSPITAL_BAL=PersFile.getTrim(Reg.myResult.getString(9));
		HOSPITAL_ENT=PersFile.getTrim(Reg.myResult.getString(10));
		PATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(11));
		PATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(12));
		MATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(13));
		MATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(14));
		COMP_BAL=PersFile.getTrim(Reg.myResult.getString(15));
		COMP_ENT=PersFile.getTrim(Reg.myResult.getString(16));
		COMP_NEXTOFKIN_BAL=PersFile.getTrim(Reg.myResult.getString(17));
		COMP_NEXTOFKIN_ENT=PersFile.getTrim(Reg.myResult.getString(18));
		OFINLIEU_BAL=PersFile.getTrim(Reg.myResult.getString(19));
		OFINLIEU_ENT=PersFile.getTrim(Reg.myResult.getString(20));
		RESERVIST_BAL=PersFile.getTrim(Reg.myResult.getString(21));
		RESERVIST_ENT=PersFile.getTrim(Reg.myResult.getString(22));
		UNPAID_BAL=PersFile.getTrim(Reg.myResult.getString(23));
		UNPAID_ENT=PersFile.getTrim(Reg.myResult.getString(24));
		BRING_FORWARD=PersFile.getTrim(Reg.myResult.getString(25));
		ADVANCE_LEAVE=PersFile.getTrim(Reg.myResult.getString(26));
		PENDING_LEAVE=PersFile.getTrim(Reg.myResult.getString(27));
		String PERS_NAME=PersFile.getTrim(Reg.myResult.getString(28));  
		String PERS_NUM=PersFile.getTrim(Reg.myResult.getString(29));
		String PERS_EMAIL=PersFile.getTrim(Reg.myResult.getString(30));
		//start count pending leave
		String SQLCommand_CountPending = "SELECT COUNT(LEAVE_STATUS) FROM LEAVERECORD WHERE LEAVE_STATUS = 'Pending' AND PERS_NUM = '";
		SQLCommand_CountPending += PERS_NUM;
		SQLCommand_CountPending += "'";
		SQLCommand_CountPending += PersFile.getSQLTerminator();
		if (Reg2.setResultSet(SQLCommand_CountPending)) {
			PENDING_LEAVE = PersFile.getTrim(Reg2.myResult.getString(1));
		}
		//end count pending leave
%>          
            <tr>
            <td width="5%" <%=backcolor%>><%= PERS_NAME%></td>
            <!--<td width="5%" align="center" <%=backcolor%>><%= PERS_NUM%></td>-->
            <!--<td width="10%" <%=backcolor%>><%= PERS_EMAIL%></td>-->
             <td  width="5%" <%=backcolor%>><%=ANNUAL_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=MEDICAL_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=OFINLIEU_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=RESERVIST_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=UNPAID_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=PENDING_LEAVE%></td>
             <td  width="5%" <%=backcolor%>><%=BRING_FORWARD%></td>
             <td  width="5%" <%=backcolor%>><%=MARRIAGE_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=CHILDCARE_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=HOSPITAL_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=PATERNITY_BAL%></td>
             <td  width="5%" <%=backcolor%>><%=MATERNITY_BAL%></td>
             <!--<td  width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_BAL%></td>-->
             <td  width="10%" <%=backcolor%>><%=COMP_BAL%></td>
            </tr>
<%          
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] AuditList.jsp Language Error");
    Log.println("[500] AuditList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
%>
				</tbody>
				</table>
			</div>
		</div>
	</div>
		</body>
	  </html>

<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reporter.close();
Log.println("[000] AuditList.jsp - Done: " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>