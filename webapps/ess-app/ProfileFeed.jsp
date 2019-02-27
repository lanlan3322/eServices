<%--
ProfileFeed.jsp - Downloads prepops and control info to a LESS browser
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

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "DB"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "DD"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>
<% 
String database = request.getParameter("database");
String email = request.getParameter("email"); 
String profileDateString = request.getParameter("profiledate"); 

// The following three lines have been added to make it work with Carol's and
// Andy's machine - I think that this is ruining the security system - sooooo
// either fix why the personnel session is not transferring correctly or
// add a password check here...(latter probably the easier)
PersFile.setDB(database,DBUser,DBPassword); 
PersFile.setSQLTerminator(DBSQLTerminator);
PersFile.setSQLStrings();

Log.println("[000] ProfileFeed.jsp email: " + email);
Log.println("[000] ProfileFeed.jsp database: " + database);
Log.println("[000] ProfileFeed.jsp profiledate: " + profileDateString);

boolean pFlag = PersFile.setPersInfo(email);
 
String CCode = "";

// need to get a handle on the security of this and the submit process.
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 

Log.println("[000] ProfileFeed.jsp ccode #1: " + CCode);
Log.println("[000] ProfileFeed.jsp ccode #2: " + PersFile.getChallengeCode());

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
// end of section that was remarked out for Kohler's test

// if (pFlag) {

Log.println("[000] ProfileFeed.jsp successful login: " + email);


%>

<%@ include file="SystemInfo.jsp" %>
<%@ include file="StatusInfo.jsp" %>
<%


DOM.setConnection(PersFile.getConnection());   //used later on to get the guidelines

boolean downloadProfile;

String ESSProfileName = SystemDOM.getDOMTableValueFor("configuration","essprofile","ESSProfile.js");
String prepopulated = SystemDOM.getDOMTableValueFor("configuration","prepopulateditems","No");
String selectItems = SystemDOM.getDOMTableValueFor("prepopulateditems","selectallitems","SELECT recno(),* FROM STATEMNT WHERE (VND_STAT = 'NW' OR RTRIM(VND_STAT) = '') AND RTRIM(EXP_CODE) = '$card$' AND RTRIM(CARD_NUM) = '$number$'" + PersFile.getSQLTerminator());
String updateItem = SystemDOM.getDOMTableValueFor("prepopulateditems","updateitem","UPDATE STATEMNT SET VND_STAT = 'XX' WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());

boolean prepops = prepopulated.equalsIgnoreCase("YES");


if ((profileDateString == null) || profileDateString.equalsIgnoreCase("null") || profileDateString.equals(""))
{
  Log.println("[000] ProfileFeed.jsp no ESSProfile date detected - will download");
  downloadProfile = true;
} else {
  DD.setDate(DD.getDateFromGMTDate(profileDateString));  //Less profile
  java.io.File companyProfileJS = new java.io.File(ESSProfileName);
  java.util.Date centralProfileModified = new java.util.Date(companyProfileJS.lastModified());
  Log.println("[000] ProfileFeed.jsp servers ESSProfile date: " + centralProfileModified.toString());
  Log.println("[000] ProfileFeed.jsp clients ESSProfile date: " + DD.getDate().toString());
  downloadProfile = centralProfileModified.after(DD.getDate());
  if (downloadProfile) Log.println("[000] ProfileFeed.jsp ESSProfile will be downloaded");
}


DB.setConnection(PersFile.getConnection());

String[] Cards = new String[100];
String[] Numbers = new String[100]; 

//String SQLCommand = SystemDOM.getDOMTableValueFor("personneltable","persinfosql");
String SQLCommand = SystemDOM.getDOMTableValueFor("prepopulateditems","selectcards");
SQLCommand = DB.SQLReplace(SQLCommand,"$email$",PersFile.getEmailAddress());
SQLCommand = DB.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());

Log.println("[000] ProfileFeed.jsp: " + SQLCommand); 

int current_card = -1;
int total_cards = -1;
boolean breakout = false;

if (DB.setResultSet(SQLCommand)) {
  if (prepops)
  {
    if (DB.setResultSet(SQLCommand)) {
      do {
        total_cards = total_cards + 1;
        Cards[total_cards] = DB.myResult.getString("CHARGE").trim();
        Numbers[total_cards] = DB.myResult.getString("CARD").trim();
      } while (DB.myResult.next());
 
      if (total_cards > -1) {
        do {
          current_card = current_card + 1;
          breakout = DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) ,"$number$",Numbers[current_card]) );
        } while (!breakout && current_card < total_cards);
      }
    }
  } 
}
%>  

<%@ page contentType="text/html" %>
<html>
<% if (prepops && (current_card > -1)) { %>
<head>
<title>Credit Card Feed</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body onLoad="javascript:void FillForm()">
<p><strong><big>Downloading data<big></strong>
</p>

<% 
   String status; 
   String reference;
   String cardtype;
   String amount;
   String recordCursor;
   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor; 
   boolean update_error = false;


   try { 
%>
      Prepopulated transactions have been found...<br>
      <!--<rowset>   
<%    while (current_card <= total_cards) {
      do { 
        status = DB.myResult.getString("STATUS"); 
        cardtype = DB.myResult.getString("CHARGE").trim();
        amount = makeCurrency(DB.myResult.getString("AMOUNT").trim());
        recordCursor = DB.myResult.getString(1).trim();
        reference = status+";"+cardtype + ";"+ Numbers[current_card].trim() + ";" + ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("VND_REF").trim())) + ";" + amount + ";" + recordCursor ; 
%>
          <row>
          <status><%= status %></status>
          <cardtype><%= cardtype%></cardtype>
          <transactiondate><%= DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString("VND_TDATE"))))%></transactiondate>
          <amount><%= amount %></amount>
          <vendorinfo><%= DB.myResult.getString("INFO").trim()%></vendorinfo>
          <vendorref><%= DB.myResult.getString("REFERENCE").trim()%></vendorref>
          <transactiontype><%= DB.myResult.getString("SIC").trim()%></transactiontype>
          </row>
<% 
          SQLCommand = DB.SQLReplace(updateItem,"$recordcursor$",recordCursor);
          if (DB.doSQLExecute(SQLCommand) == -1) {
            update_error = true; 
%>
            <br><br>Error update status in statement file - contact technical support<br><br>
<%
          }

      } while (DB.myResult.next());
      do {
        current_card += 1;
        if (!Cards[current_card].trim().equals("") && !Numbers[current_card].trim().equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) , "$number$",Numbers[current_card]) )) {
          breakout = true;    
        } else {
          breakout = false;
        }
      } while(current_card < 3 && !breakout);
      Log.println("[000] ProfileFeed.jsp pre-populated transactions found: " + email);
    } 
   } catch (java.lang.Exception ex) {
      System.out.println("Error in the result set");
      Log.println("[500] ProfileFeed.jsp Error in result set: " + email);
   }
%>
      </rowset>--> 

<% } else { %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Introduction Page</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body onLoad="javascript:void FillForm()">
<!--<prepopulated></prepopulated>-->


<% } 
// Personal Data (later add logic in class to strip chars upto the first "<"
%>
Downloading personal data and configuration information...<br>
Please be patient.
<!--<users>
   <default>
    <personnelnumber><%=PersFile.getPersNum()%></personnelnumber>
    <firstname><%=PersFile.fname%></firstname>
    <lastname><%=PersFile.lname%></lastname>
    <location><%=PersFile.location%></location>
    <department><%=PersFile.getDepartment()%></department>
    <email><%=PersFile.getEmailAddress()%></email>
    <phone><%=PersFile.phone%></phone>
    <manager><%=PersFile.getManager()%></manager>
    <level><%=PersFile.level%></level>
    <guideline><%=PersFile.guideline%></guideline>
    <vehiclenumber>xxxxxx</vehiclenumber>
    <category><%=PersFile.category%></category>
    <odometerreading>xxxxxx</odometerreading>
    <mileagerate><%=PersFile.mileage%></mileagerate>
   </default>
</users>-->

<%
   if (downloadProfile) {
%>
<!--<%= getBinaryFile(ESSProfileName, Log) %>
-->
<% Log.println("[000] ProfileFeed.jsp profile update envoked for " + email + ", " + profileDateString);
   } else {
%>
<!-- -->
<%
   }

   DOM.setDOMFromTable("GUIDE");
   if (DOM.getDOMProcessed())
   {
%>
<!--<%=DOM.toString() %>-->   
<%
   } else {
%>
<!-- -->  
<%
   }

   DOM.setDOMFromTable("ACCOUNT");
   if (DOM.getDOMProcessed())
   {
%>
<!--<%=DOM.toString() %>-->   
<%
   } else {
%>
<!-- -->  
<%
   }
   DOM.setDOMFromTable("CHARGE");
   if (DOM.getDOMProcessed())
   {
%>
<!--<%=DOM.toString() %>-->   
<%
   } else {
%>
<!-- -->  
<%
   }
   DOM.setDOMFromTable("COMPANY");
   if (DOM.getDOMProcessed())
   {
%>
<!--<%=DOM.toString() %>-->   
<%
   } else {
%>
<!-- -->  
<%
   }
%>

<!--<%=SystemDOM.toString() %>-->   

<!--<%=StatusDOM.toString() %>-->   


<form method="POST" action="http://localhost:8085/SaveProfile.jsp">
<input type="hidden" name="prepop" value>
<input type="hidden" name="persdata" value>
<input type="hidden" name="jscode" value>
<input type="hidden" name="guidelines" value>
<input type="hidden" name="accounts" value>
<input type="hidden" name="charges" value>
<input type="hidden" name="companies" value>
<input type="hidden" name="system" value>
<input type="hidden" name="status" value>
</from>

<script>

function FillForm() {
  grab();
  document.forms[0].submit();
}

function grab() 
{
  var code = document.all
  var stuff 
  j = 0;
  for (var i = 0; i < code.length; i++) {  
    if (code[i].nodeName == "!" || code[i].nodeName == "#comment") {        //put in another check so we can have more than 1 comment
      stuff = code[i].innerHTML;
      stuff = stuff.replace(/<!--/,"");
      stuff = stuff.replace(/-->/,"");
      j = j + 1
      if (j == 1) document.forms[0].prepop.value = stuff;
      if (j == 2) document.forms[0].persdata.value = stuff;
      if (j == 3) document.forms[0].jscode.value = stuff;
      if (j == 4) document.forms[0].guidelines.value = stuff;
      if (j == 5) document.forms[0].accounts.value = stuff;
      if (j == 6) document.forms[0].charges.value = stuff;
      if (j == 7) document.forms[0].companies.value = stuff;
      if (j == 8) document.forms[0].system.value = stuff;
      if (j == 9) document.forms[0].status.value = stuff;



    }
  }
}

</script>
</body>
</html>

<% 
     Log.println("[000] ProfileFeed.jsp end");

   } else { %>
   <%@ include file="ReloginLocalMsg.jsp" %>
<% } %>

<%!
public String makeCurrency(String f) {
    String retVal = "";
    int i = f.indexOf(".");
    if (i > -1) {
        String s = f + "00";
        retVal = s.substring(0, i + 3);     
    } else {
        retVal = f + ".00";
    }
    return retVal;
}  

public String ensureSpace(String f) {
   if (f == null || f.equals("")) {
     f = " ";
   }
   return f;
}

private String getBinaryFile(String localFile, ess.AuditTrail Log) {
   // File LookAtThisFile;
   // Long LongFileLength;
   String content = "";
   int inByte;
   String additionalContent;
        
// This method sends file information back to the caller.
// If the file is not found a bad request routine creates an error message.

   try {
       java.io.File inFile = new java.io.File(localFile);
       java.io.BufferedInputStream in = new java.io.BufferedInputStream(new java.io.FileInputStream(inFile));
       int bufferSize = in.available();
       byte[] buffer= new byte[bufferSize];            

       Log.println("[000] Include File: " + localFile + " inFile.length = " + inFile.length());

       int bytesRead = 0;

       while ((bytesRead = in.read(buffer,0,bufferSize)) != -1) 
       {
          additionalContent = new String(buffer); 
          content += additionalContent;  
       }

   } catch (java.io.FileNotFoundException e) {
       Log.println("[500] file not found exception: " + localFile + e.getMessage());
       return "";
   } catch (java.io.IOException e) {
       Log.println("[500] Exception (1) reading the include file: " + localFile + e.getMessage());
       return "";
   } 
   return content;
}


%>

