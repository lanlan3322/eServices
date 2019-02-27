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
<%@ include file="../../SendAnEmail.jsp" %>

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

<html>
<body>

<strong><em>Following persons have been assigned for stock checking:</em></strong><br>
<%
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   String SQLCommand;
   String item2Remove;
   String tableName;

   String xxx = request.getParameter("reference");
   Log.println("[000] EditRemove.jsp - reference: " + xxx);
   java.util.StringTokenizer rp = new java.util.StringTokenizer(xxx, ";"); 
   
	String domain_email = SystemDOM.getDOMTableValueFor("configuration", "domain_mail", "services@elc.com.sg");
	String audit_email = SystemDOM.getDOMTableValueFor("configuration", "audit_mail", "services@elc.com.sg");
	String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
   String action = request.getParameter("xaction");
   boolean actionFlag;
   if (true){//action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] EditRemove.jsp - Invalid action by " + ownersName);
   }

   int sqlReturn = 1;
   //String list = "";
   //SQLCommand = "UPDATE USER SET BILLEXP='" + action + "' WHERE ";
   while (rp.hasMoreTokens() && actionFlag) {  

     item2Remove = rp.nextToken().trim();
     item2Remove = ess.Utilities.getIncomingXMLString(item2Remove);
     tableName = getTableName(item2Remove, DOM, Log);

	 //list += getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt) + " OR ";
     //SQLCommand = "DELETE ";
     //SQLCommand += "FROM " +  tableName + " ";
     //SQLCommand += "WHERE " + getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt) + PersFile.getSQLTerminator();
     SQLCommand = "UPDATE USER SET BILLEXP='" + action + "' ";
     SQLCommand += "WHERE " + getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt) + PersFile.getSQLTerminator();
   
     //SQLCommand = SQLCommand + list.substring(0, list.length()-4) + PersFile.getSQLTerminator();
	 sqlReturn = Reg.doSQLExecute(SQLCommand);
     if (sqlReturn == 1) {
%>  
           <br> Stock checking nominees updated User ID: <%=item2Remove %> 
<%          
           Log.println("[000] inventoryAssign.jsp 111 - " + SQLCommand);
     } else { 
%>
         <br> SQL: <%=SQLCommand %> -- database access problem, investigate deletion!
<%       Log.println("[500] inventoryAssign.jsp - 115 " + SQLCommand + " has return code of [" + java.lang.Integer.toString(sqlReturn) + "]");
     }
	 
	 if(action.equalsIgnoreCase("1")){
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String newDate = currentDate.replace("-","");
		newDate = newDate.substring(4,8);
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(2,6);
		String newNum = newDate + currentTime;//persnumber.replace("0","") + currentTime.replace("0","");
		String userID = getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt);
		SQLCommand = "INSERT INTO DB_STOCKCHECK (STOCKCHECK_ID, STOCKCHECK_BY, STOCKCHECK_START, STOCKCHECK_STATUS) VALUES ('";
		SQLCommand = SQLCommand + newNum + "', ";
		SQLCommand = SQLCommand + userID.substring(11, userID.length()) + ", '";
		SQLCommand = SQLCommand + currentDate + "', '";
		SQLCommand = SQLCommand + "0')" + PersFile.getSQLTerminator();
		sqlReturn = Reg2.doSQLExecute(SQLCommand);
		if (sqlReturn == 1) {
%>  
           <br> Stock checking pending by User ID: <%=item2Remove %> 
<%          
           Log.println("[000] inventoryAssign.jsp 130 - " + SQLCommand);
		   //need to send email to user start
				String email_user = "services@elc.com.sg";
				SQLCommand = "SELECT EMAIL FROM USER WHERE PERS_NUM =" + userID.substring(11, userID.length()) + PersFile.getSQLTerminator();
				if (Reg.setResultSet(SQLCommand)) { 
					email_user = PersFile.getTrim(Reg.myResult.getString(1));			
				}	
				String subject = "You have been assigned to do stock check";
				String sEmailMsg = "\n" + "  Please proceed with stock check.";
				sEmailMsg += "\n" + "  Update your checking result at : http://services.elc.com.sg";
				Log.println("[500] inventoryAssign.jsp - assign stock check email to: " + email_user);
				if(!SendAnEmail(email_user, pal_address, subject, sEmailMsg, SendInfo))
				{
					Log.println("[500] InventoryConfirm.jsp - notification email failure" + email_user);
				}
				subject = "Stock check is assigned!";
				sEmailMsg = "\n" + "  Please wait for stock check to be finished.";
				sEmailMsg += "\n" + "  Stock check user id: " + userID.substring(11, userID.length()) + "; Email:" + email_user;
				Log.println("[500] inventoryAssign.jsp - assign stock check email to: " + domain_email);
				if(!SendAnEmail(domain_email, pal_address, subject, sEmailMsg, SendInfo))
				{
					Log.println("[500] InventoryConfirm.jsp - notification email failure" + domain_email);
				}
				Log.println("[500] inventoryAssign.jsp - assign stock check email to: " + audit_email);
				if(!SendAnEmail(audit_email, pal_address, subject, sEmailMsg, SendInfo))
				{
					Log.println("[500] InventoryConfirm.jsp - notification email failure" + audit_email);
				}
			//need to send email to user finish
		} else { 
%>
			<br> SQL: <%=SQLCommand %> -- database access problem, investigate deletion!
<%       	Log.println("[500] inventoryAssign.jsp - 134 " + SQLCommand + " has return code of [" + java.lang.Integer.toString(sqlReturn) + "]");
		}
	 }
   } 
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