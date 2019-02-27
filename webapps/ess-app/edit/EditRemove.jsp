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

<%@ include file="../DBAccessInfo.jsp" %>

<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
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

<strong><em>Following items have been removed:</em></strong><br>
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
   boolean actionFlag;
   if (action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] EditRemove.jsp - Invalid action by " + ownersName);
   }

   int sqlReturn;
   while (rp.hasMoreTokens() && actionFlag) {  

     item2Remove = rp.nextToken().trim();
     item2Remove = ess.Utilities.getIncomingXMLString(item2Remove);
     tableName = getTableName(item2Remove, DOM, Log);

     SQLCommand = "DELETE ";
     SQLCommand += "FROM " +  tableName + " ";
     SQLCommand += "WHERE " + getRemoveString(item2Remove, DOM, SchemaDOM, tableName, Log, SQLDateReplace, SQLType, Reg, Dt) + PersFile.getSQLTerminator();
     sqlReturn = Reg.doSQLExecute(SQLCommand);
     if (sqlReturn == 1) {
%>  
           <br> Item <%=item2Remove %> 
<%          
           Log.println("[000] EditRemove.jsp 1 - " + item2Remove);
     } else { 
%>
         <br> Item <%=item2Remove %> -- database access problem, investigate deletion!
<%       Log.println("[500] EditRemove.jsp - record removal " + item2Remove + " has return code of [" + java.lang.Integer.toString(sqlReturn) + "]");
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