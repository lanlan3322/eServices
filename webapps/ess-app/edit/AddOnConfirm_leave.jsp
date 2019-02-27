<%--
EditRemove.jsp - removes an item from the table 
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
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="session" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />
<%@ include file="../DBAccessInfo.jsp" %>

<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
Reg2.setConnection(PersFile.getConnection()); 
Reg2.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
String ownersName = request.getParameter("email");
Log.println("[000] EditRemove.jsp - name: " + ownersName);
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%> 
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../SchemaInfo.jsp" %>
<%@ include file="../../SendAnEmail.jsp" %>

<html>
<body>

<strong><em>Following items have been changed (new value/old value):</em></strong><br>
<%
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   String SQLCommand;
   String item2Remove;
   String tableName;

   String xxx = request.getParameter("reference");
   Log.println("[000] EditRemove.jsp - reference: " + xxx);
   java.util.StringTokenizer rp = new java.util.StringTokenizer(xxx, ";"); 
   
   String action = request.getParameter("xaction");
   String days = request.getParameter("days");
   String reason = request.getParameter("reason");
	reason = reason.replaceAll("'","\\\\'");
   String leavetype = request.getParameter("type");
   boolean actionFlag;
   if (action.equals("apply")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] EditRemove.jsp - Invalid action by " + ownersName);
   }

	String SQLCommand4 = "SELECT USER.MANAGER, USER.DEPART, LEAVEINFO.ANNUAL_BAL, LEAVEINFO.UNPAID_BAL,LEAVEINFO.PERS_NUM, USER.FNAME, LEAVEINFO.OFINLIEU_BAL, LEAVEINFO.MARRIAGE_BAL, LEAVEINFO.CHILDCARE_BAL, LEAVEINFO.MEDICAL_BAL, LEAVEINFO.HOSPITAL_BAL, LEAVEINFO.PATERNITY_BAL, LEAVEINFO.MATERNITY_BAL, LEAVEINFO.COMP_BAL, LEAVEINFO.RESERVIST_BAL FROM USER JOIN LEAVEINFO ON USER.PERS_NUM = LEAVEINFO.PERS_NUM" + PersFile.getSQLTerminator();
	if (Reg2.setResultSet(SQLCommand4)) {
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String currentTime = Dt.getLocalTime();
		String manager = PersFile.getManager();
		String depart = PersFile.getDepartment();
		String oldAnnual = "0";
		String oldUnpaid = "0";
		String newAnnual = "0";
		String newUnpaid = "0";
		String newLeaveStatus = "Credit";
		String persnum = "0";
		String name = "";
		String oldOffInLieu = "0";
		String oldMarriage = "0";
		String oldChildcare = "0";
		String oldMedical = "0";
		String oldHospitalisation = "0";
		String oldPaternity = "0";
		String oldMaternity = "0";
		String oldCompassionate = "0";
		String oldReservist = "0";
		boolean changed = false;
		try {
		 do { 
			manager = PersFile.getTrim(Reg2.myResult.getString(1));
			depart = PersFile.getTrim(Reg2.myResult.getString(2));
			oldAnnual = PersFile.getTrim(Reg2.myResult.getString(3));
			oldUnpaid = PersFile.getTrim(Reg2.myResult.getString(4));
			persnum = PersFile.getTrim(Reg2.myResult.getString(5));
			name= PersFile.getTrim(Reg2.myResult.getString(6));
			oldOffInLieu = PersFile.getTrim(Reg2.myResult.getString(7));
			oldMarriage = PersFile.getTrim(Reg2.myResult.getString(8));
			oldChildcare = PersFile.getTrim(Reg2.myResult.getString(9));
			oldMedical = PersFile.getTrim(Reg2.myResult.getString(10));
			oldHospitalisation = PersFile.getTrim(Reg2.myResult.getString(11));
			oldPaternity = PersFile.getTrim(Reg2.myResult.getString(12));
			oldMaternity = PersFile.getTrim(Reg2.myResult.getString(13));
			oldCompassionate = PersFile.getTrim(Reg2.myResult.getString(14));
			oldReservist = PersFile.getTrim(Reg2.myResult.getString(15));
			String newLeaveNum = persnum.replace("0","") + currentTime.replace(":","");
			changed = false;
			if(xxx.indexOf(persnum) != -1){
				changed = true;
			}
			if(!changed){
				continue;
			}
			float daysNum = Float.parseFloat(days);
			if(daysNum < 0){
				newLeaveStatus = "Offset";
			}
			SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_leave_new");
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnum);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",depart);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavevo$",manager);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavenum$",newLeaveNum);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetotal$",days);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavecreated$",currentDate);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetype$",leavetype);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefrom$",currentDate);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$","AM");
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leaveto$",currentDate);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetoampm$","PM");
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavestatus$",newLeaveStatus);
		   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavereason$",reason);
		   int SQLResult = Reg.doSQLExecute(SQLCommand);
			String strType = leavetype;
		   if(leavetype.equalsIgnoreCase("Add-on")){
			leavetype = "ANNUAL";
		   }
		   float old = Float.parseFloat(oldAnnual);
		   if(leavetype.equalsIgnoreCase("Off In Lieu")){
				old = Float.parseFloat(oldOffInLieu);
				strType = "OFINLIEU";
		   }
		   else if(leavetype.equalsIgnoreCase("Marriage")){
				old = Float.parseFloat(oldMarriage);
		   }
		   else if(leavetype.equalsIgnoreCase("Childcare")){
				old = Float.parseFloat(oldChildcare);
		   }
		   else if(leavetype.equalsIgnoreCase("Medical")){
				old = Float.parseFloat(oldMedical);
		   }
		   else if(leavetype.equalsIgnoreCase("Paternity")){
				old = Float.parseFloat(oldPaternity);
		   }
		   else if(leavetype.equalsIgnoreCase("Maternity")){
				old = Float.parseFloat(oldMaternity);
		   }
		   else if(leavetype.equalsIgnoreCase("Unpaid")){
				old = Float.parseFloat(oldUnpaid);
		   }
		   else if(leavetype.equalsIgnoreCase("Hospitalisation")){
				old = Float.parseFloat(oldHospitalisation);
				strType = "HOSPITAL";
		   }
		   else if(leavetype.equalsIgnoreCase("Compassionate")){
				old = Float.parseFloat(oldCompassionate);
				strType = "COMP";
		   }
		   else if(leavetype.equalsIgnoreCase("Reservist")){
				old = Float.parseFloat(oldReservist);
		   }
			float value = old + daysNum;
			if(value < 0 && leavetype.equalsIgnoreCase("Annual")){
				newAnnual = "0";
				newUnpaid = String.valueOf(Float.parseFloat(oldUnpaid) + value);
				String SQLCommand3 = "UPDATE LEAVEINFO SET " + strType + "_BAL = '0',UNPAID_BAL='" + newUnpaid + "' WHERE PERS_NUM ='" + persnum + "'" + PersFile.getSQLTerminator();
				SQLResult = Reg.doSQLExecute(SQLCommand3);
			}
			else{
			   newAnnual = String.valueOf(value);
			   String SQLCommand2 = "UPDATE LEAVEINFO SET " + strType + "_BAL ='" + newAnnual + "' WHERE PERS_NUM ='" + persnum + "'" + PersFile.getSQLTerminator();
			   SQLResult = Reg.doSQLExecute(SQLCommand2);
			}
		 //SQLCommand = "DELETE ";
		 //SQLCommand += "FROM " +  tableName + " ";
		 //SQLCommand += "WHERE " + getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt) + PersFile.getSQLTerminator();
		//sqlReturn = 1;//Reg.doSQLExecute(SQLCommand);
		   String SQLCommand5 = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + persnum + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand5)) {
				String pal_address = "services@elc.com.sg";
			   String email = PersFile.getTrim(Reg.myResult.getString(1));
			   String subject = "HR updated leave record: Reason-" + reason;
			   String msg = "There is leave updated by HR: ";
			String sEmailMsg = "\n  Leave Details:\n";
				sEmailMsg += "    User Name:         " + name + "\n";
				sEmailMsg += "    Date:              " + currentDate + "\n";
				sEmailMsg += "    Total:             " + days + "\n";
				sEmailMsg += "    Type:              " + leavetype + "\n";
				sEmailMsg += "    Reason:          " + reason + "\n";
				sEmailMsg += "    Action:           " + newLeaveStatus + "\n";
				sEmailMsg += "    Old Balance:        " + old + "\n";
				sEmailMsg += "    New Balance:      " + newAnnual + "\n";
			   SendAnEmail(email, pal_address, subject, msg+sEmailMsg, SendInfo);
				String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");
				SendAnEmail(eMailHR, pal_address, subject, msg+sEmailMsg, SendInfo);
		   }
%>  
           <br> User: <%=name %>(<%=persnum %>) ; Days: <%=days %> ; Type: <%=strType%> ; New value: <%=newAnnual %> ; Old value: <%=old %>; Action:<%=newLeaveStatus%>.
           <br> 
<% 
     } while (Reg2.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] AuditList.jsp Language Error");
    Log.println("[500] AuditList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
	}//if (Reg.setResultSet(SQLCommand4))
%>
<br><br><strong><em>End of process</em></strong>
<p align="center"><a href="javascript: void history.go(-2)" tabindex="1"><em><strong>Go to previous edit screen</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 
} else { 
     Log.println("[400] EditRemove.jsp security object removed for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>

<%!
public String getRemoveString(String x, ess.AdisoftDOM DOM, ess.SchemaDOM s, String tableName, ess.AuditTrail L, String dateFormat, String dateType, ess.AdisoftDbase Reg, ess.CustomDate Dt)
{
      String delimitWith = " AND ";
      String delimiter = "";
      String equalSign = " = ";
      String valueString = "";
      String columnType;
      String columnName;
      String dateValue;
        
      DOM.setDOM(x);
      org.jdom.Element removeElement = DOM.getRootElement();
      java.util.List keyList = removeElement.getChildren();
      org.jdom.Element keyElement;
      for (int i = 0; i < keyList.size(); i++)
      {
         keyElement = (org.jdom.Element) keyList.get(i); 
         columnName = keyElement.getName();           
         valueString +=delimiter + columnName;
         
         columnType = s.getAttributeValue(tableName, columnName, "type");
         L.println("[000] EditRemove.jsp.getRemoveString element: " + keyElement.toString());

         if (columnType.equalsIgnoreCase("numeric"))   //need to handle record #
         {

           valueString += equalSign + repStr(keyElement.getText());

         } else if (columnType.equalsIgnoreCase("date")){

           if (dateType.equals("MM/DD/YYYY")) { 
              dateValue = Dt.getSimpleDate(Dt.getDateFromXBase(repStr(keyElement.getText())));
           } else if (dateType.equalsIgnoreCase("DD-MMM-YYYY")){    // Oracle
              dateValue = Dt.getOracleDate(Dt.getDateFromXBase(repStr(keyElement.getText())));
           } else if (dateType.equalsIgnoreCase("WEB")){    // Web GMT format primarily for REGISTER table
              dateValue = Dt.getGMTDate(Dt.getDateFromStr(repStr(keyElement.getText())));
           } else {    // s/b YYYY-MM-DD
              dateValue = repStr(keyElement.getText());
           }

           valueString += equalSign + Reg.SQLReplace(dateFormat,"$date$",dateValue);

         } else {

           valueString += equalSign + "'" + repStr(keyElement.getText()) + "'";

         }  
         delimiter = delimitWith;
      }
      return valueString;
}
   
public static String repStr(String x) {
   x = repStr(x, "\"","'");
   x = repStr(x, "\\","\\\\"); // was "&#92"
   x = repStr(x, "\n","\\n");  // was "&#10;"
   x = repStr(x, "\r","");
   x = repStr(x, "'","\\'");

   return x; 
}
   
public static String repStr(String x, String oldChar, String newChar) 
{
   int startLocate = 0;
   int oldLength = oldChar.length();
   int newLength = newChar.length();
      
   int locate = x.indexOf(oldChar, startLocate);
   while (locate != -1) {
      x = x.substring(0,locate) + newChar + x.substring(locate + oldLength);
      startLocate = locate + newLength;
      locate = x.indexOf(oldChar, startLocate);
   }
   return x;
}
   

public String getTableName(String x, ess.AdisoftDOM DOM, ess.AuditTrail L)
{
     DOM.setDOM(x);
     org.jdom.Element rootElement = DOM.getRootElement();
     org.jdom.Attribute tableAttribute = rootElement.getAttribute("table"); //JH 2007-05-24 OK as is
     String valueString = tableAttribute.getValue();
     return valueString;
}

%>