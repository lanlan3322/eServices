<%--
SubmitEdit.jsp - Updates central database with changes
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
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
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
  Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator());
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
      if (ParamName.equals("PASSWORD") &&  hashType.equalsIgnoreCase("md5"))
      {
         ParamValue = Hash.Hash(ParamValue);
      }
      Params[1] = ParamValue;
      Log.println("[000] SubmitEdit.jsp input parameters: " + Params[0] + ", " + Params[1]);
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
                  // db.closeResultSet();  //JH 2009-05-27
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
      String fName = request.getParameter("FNAME");
   String lName = request.getParameter("LNAME");
   String sName = fName + " " + lName;
   String dep = request.getParameter("DEPART");
   String num = request.getParameter("PERS_NUM");
   String dateReceivedFromUser = request.getParameter("SERVDATE");
    String joindate = Dt.getSQLDate(Dt.getDateFromStr(dateReceivedFromUser,PersFile.getDateFormat()));

    //calculate ent Start
    int startDay = Integer.parseInt(joindate.substring(8,10));
    float startMonth = Float.parseFloat(joindate.substring(5,7));
    int startYear = Integer.parseInt(joindate.substring(0,4));
    int ent = (int) Math.round((13.0 - startMonth) * 14.0 / 12.0);
    if(startDay > 1){
      boolean bCheck = true;
      for(int i = 1;i<startDay && bCheck;i++){
        java.util.Calendar cal = new java.util.GregorianCalendar(startYear, (int)startMonth - 1, i);
        int dayOfWeek = cal.get(java.util.Calendar.DAY_OF_WEEK);
        if(java.util.Calendar.SUNDAY != dayOfWeek && java.util.Calendar.SATURDAY != dayOfWeek){
          ent = ent -1;
          bCheck = false;
        }
      }
    }

    String entString  = String.valueOf(ent);
    //calculate ent End

  String SQLCommand1 = "INSERT INTO leaveinfo VALUES ('";
  SQLCommand1 += num;
  SQLCommand1 += "', '" + entString + "', '" + entString + "','0','0','0','0','14','14','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0')" + PersFile.getSQLTerminator();
	String currentDate = Dt.simpleDate.format(Dt.date);
  String SQLCommand2 = "INSERT INTO `leaveyears`(`NAME`, `YEAR`, `PERS_NUM`, `DEPART`, `SERDATE`, `ENT`, `ADDON`, `OIL`, `BRINGFORWARD`, `TOTAL`, `COMMENTS`) VALUES ('";
  SQLCommand2 += sName + "', '";
  SQLCommand2 += currentDate.substring(currentDate.length()-4,currentDate.length()) + "', '";
  SQLCommand2 += num + "', '";
  SQLCommand2 += dep + "', '";
  SQLCommand2 += joindate + "','" + entString + "','0','0','0','" + entString + "','')" + PersFile.getSQLTerminator();

%>
   <strong><em>Information has been added to the central database</em></strong><br>
   <% Reg.doSQLExecute(SQLCommand1);
   Reg.doSQLExecute(SQLCommand2);
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
