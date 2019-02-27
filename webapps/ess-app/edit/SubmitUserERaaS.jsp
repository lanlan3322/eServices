<%--
SubmitUserERaaSdit.jsp - Updates the user file and adds a personnel number if required
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
<jsp:useBean id = "db"
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
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Hash"
	class="ess.AdisoftHash"
	scope="session" />    

<%@ include file="../DBAccessInfo.jsp" %>

<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
//String database = request.getParameter("database");

boolean errorCondition = false; 
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
//if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
if (pFlag) { 
%>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="EditInfo.jsp" %>
<%
db.setConnection(PersFile.getConnection()); 
db.setSQLTerminator(PersFile.getSQLTerminator());
%> 
<html>
<body>
<strong><em>Results of your edit:</em></strong>
<%

   String[] encrypts = new String[0];  //plugging this for now
   String screenName = request.getParameter("screenname");
   String xaction = request.getParameter("xaction");

   String hashType = SystemDOM.getDOMTableValueFor("configuration","hashtype","none");
   Log.println("[000] SubmitEdit.jsp hash type: " + hashType);
   
   Log.println("[000] SubmitEdit.jsp screen name: " + screenName + ", xaction: " + xaction ); 

   String tableName = EditDOM.getDOMTableValueFor(screenName,"table");
   String sqltableName = EditDOM.getDOMTableValueFor(screenName,"sqltable",tableName);

   String editScreenName = EditDOM.getDOMTableValueFor(screenName,"editscreen");

   java.util.List checks = EditDOM.getElement(screenName).getChildren("check");

   String schemaFileName = SystemDOM.getDOMTableValueFor("configuration","xmlschema");
  
   java.io.File schemaFile = new java.io.File(schemaFileName);
   TableDOM.setDOM(schemaFile);

   org.jdom.Element schemaElement = TableDOM.getElement(tableName);

   org.jdom.Element columns = schemaElement.getChild("columns");

   org.jdom.Element rowKey = schemaElement.getChild("key");
   
   String sqlMethod = SystemDOM.getDOMTableValueFor("sql","insertmethod");
   String sqlLockTable = SystemDOM.getDOMTableValueFor("sql","locktablesql","");     //not used yet
   String sqlUnlockTable = SystemDOM.getDOMTableValueFor("sql","unlocktablesql",""); //noteused yet


   db.setSQLDateType(SystemDOM.getDOMTableValueFor("sql","datesqlformat"));
   db.setSQLDateStr(SystemDOM.getDOMTableValueFor("sql","datesql"));
   db.setSQLNo(SystemDOM.getDOMTableValueFor("sql","nosql"));
   db.setSQLYes(SystemDOM.getDOMTableValueFor("sql","yessql"));
   if (xaction.equalsIgnoreCase("UPDATE")) {
     db.setAcceptNulls("No");  //Assuming that we do this because if we zero out a 
   } else {                    //value that we want it replaced. 
     db.setAcceptNulls(SystemDOM.getDOMTableValueFor("sql","acceptnulls"));
   }
   db.setSQLBlankDate(SystemDOM.getDOMTableValueFor("sql","blankdate"));
   db.setSQLReservedWordList(SystemDOM.getDOMTableValueFor("sql","reservedwordlist"));
    
   db.setInputDateFormat(PersFile.getDateFormat());
   
   java.util.ArrayList values = new java.util.ArrayList(); 
   String ParamName;
   String ParamValue;

   String[] Params;
   org.jdom.Element chk;
   String chk_method;
   String chk_returns;
   boolean chk_ret_value;
   String chk_sql;
   String chk_message;
   String chk_allowblank;
   String blankReturn;


   for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
      Params = new String[2];
      ParamName = (String) e.nextElement();
      ParamValue = request.getParameter(ParamName); 
      Params[0] = ParamName;
      if (ParamValue == null) ParamValue = "";
      if (ParamName.equals("PERS_NUM") &&  ParamValue.equals("")) 
      {
         ParamValue = SysTable.getSystemIncString("PERSNUM_SEQUENCE");
         if (ParamValue.length() < 5)
         {
             ParamValue = "00000" + ParamValue;
             ParamValue = ParamValue.substring(ParamValue.length() - 5);
         }
      }
      if (ParamName.equals("PASSWORD") &&  hashType.equalsIgnoreCase("md5")) 
      {
         ParamValue = Hash.Hash(ParamValue);
      }

      Params[1] = ParamValue;     
      values.add(Params);
   }

// Place check call here, if true leave acction as is - if false create a substitute action
// Checks:  1. Exists as a field in a table
//          2. Exists as an element value in a xml config file
//          3. Doesn't exist as a field in a table

   boolean passedChecks = true;
   String errorMessage = "Cannot post transaction - please review:";
   if (!checks.isEmpty())
   {
      for (int j = 0; j < checks.size(); j++)
      {
          chk = (org.jdom.Element) checks.get(j);
          chk_method = TableDOM.getSubElementText(chk,"method");
          chk_returns = TableDOM.getSubElementText(chk,"returns");
          chk_sql = TableDOM.getSubElementText(chk,"sql");
          chk_message = TableDOM.getSubElementText(chk,"message");
          chk_allowblank = TableDOM.getSubElementText(chk,"allowblank");
          Log.println("[000] SubmitEdit.jsp method: " + chk_method + ", returns: " + chk_returns);
//Log.println("[000] SubmitEdit.jsp chk_allowblank: " + chk_allowblank + ", value: " + db.getSQLArrayValue(values, chk_allowblank));

          blankReturn = db.getSQLArrayValue(values, chk_allowblank); 
          if (blankReturn == null || !blankReturn.equals(""))
          {
//Log.println("[000] SubmitEdit.jsp -checking");
             if (chk_method.equalsIgnoreCase("BOTH") || xaction.equalsIgnoreCase(chk_method))
             {
                chk_sql = db.SQLReplaceWArray(chk_sql, values, "$", "$");
                chk_sql = db.SQLReplace(chk_sql,"$persnum$",db.repStr(PersFile.getPersNum()));
       
                if (chk_sql.indexOf("=") == 0) 
                {
                  chk_ret_value = ess.Utilities.equalStrings(chk_sql);
                } else {
                  chk_ret_value = db.setResultSet(chk_sql);
                  // db.closeResultSet(); JH 2009-06-08
                }
                if (chk_ret_value)
                {
                  if (chk_returns.equalsIgnoreCase("false"))
                  {
                     errorMessage += "<br>";
                     errorMessage += chk_message;
                     passedChecks = false;
                  }    
                } else { 
                  if (chk_returns.equalsIgnoreCase("true"))
                  {
                     errorMessage += "<br>";
                     errorMessage += chk_message;
                     passedChecks = false;
                  }    
                }
             }
          } 
      }
   }

   if (!passedChecks)
   {
%>
   <strong><em><%= errorMessage %></em></strong><br>
<%

   } else if (xaction.equalsIgnoreCase("INSERT") && db.setPersistance(sqlMethod,sqltableName,rowKey,columns,values,encrypts))
   {
%>
   <strong><em>Information has been added to the central database</em></strong><br>
<%
   } else if (xaction.equalsIgnoreCase("UPDATE") && db.setUpdate(sqlMethod,sqltableName,rowKey,columns,values))
   {
%>
   <strong><em>Information has been updated in the central database</em></strong><br>
<%
   } else {
%>
   <strong>Error in updating the database!</strong><br>
<%
   }
%>
<br><br><strong><em>End of process</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWindow('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/edit/<%= editScreenName %>')" tabindex="1"><em><strong>New Edit Screen</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 
// put the check else here and the failure logic

} else { 
     Log.println("[400] SubmitEdit.jsp security object removed for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>



