<%--
ItemsGather.jsp - Gathers prepopulated items in array to download to browser for reconcilement
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
<jsp:useBean id = "DD"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "Logfile"
     class="ess.AuditTrail"
     scope="application" />
<% 
String email = request.getParameter("email"); 
//boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
%>
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%
String database = request.getParameter("database");
DB.setConnection(PersFile.getConnection()); 

Reporter.setConnection(PersFile.getConnection()); 
Reporter.setSQLTerminator(DBSQLTerminator);
Reporter.setSQLStrings();

String reporterNum = request.getParameter("employee"); 
boolean rFlag = Reporter.setPersNumInfo(reporterNum);
String vendor = request.getParameter("vendor"); 

Logfile.println("[000] ItemsGather.jsp employee = " + email);

String selectItems1 = SystemDOM.getDOMTableValueFor("reconcilement","selectallcarditems","");
String selectItems2 = SystemDOM.getDOMTableValueFor("reconcilement","selectallreceiptitems","");

String selectTable1 = SystemDOM.getDOMTableValueFor("reconcilement","carditemtable","");
String selectTable2 = SystemDOM.getDOMTableValueFor("reconcilement","receiptitemtable","");

String[] Cards = new String[100];
String[] tables = new String[100];
String[] Numbers = new String[100]; 
String[] selectItems = new String[100];
String[] multiply = new String[100];

String SQLCommand = SystemDOM.getDOMTableValueFor("prepopulateditems","selectcards");
SQLCommand = DB.SQLReplace(SQLCommand,"$email$",Reporter.getEmailAddress().toUpperCase());
SQLCommand = DB.SQLReplace(SQLCommand,"$persnum$",Reporter.getPersNum());

int current_card = -1;
int total_cards = -1;

boolean breakout = false;

boolean vendorSpecified = (vendor != null && !vendor.equals("")); 
boolean getReceiptSearch = true;  //added this flag JH 2006-11-07 maybe change if we revert back to accounts
if (rFlag)
{
  if (DB.setResultSet(SQLCommand)) {
    do {                                              //This gets both sides for reconcilement
      total_cards = total_cards + 1;
      Cards[total_cards] = DB.myResult.getString("CHARGE").trim();
      if (!vendorSpecified || vendor.equals(Cards[total_cards]))
      {
         Numbers[total_cards] = DB.myResult.getString("CARD").trim();
         selectItems[total_cards] = selectItems1; //This gets the prepopulated-side
         multiply[total_cards] = "-1";
         tables[total_cards] = selectTable1;
         if (getReceiptSearch && !Cards[total_cards].equals("")) {  
            total_cards = total_cards + 1;
            Cards[total_cards] = Cards[total_cards - 1];//some passed in value
            Numbers[total_cards] = reporterNum;//some passed in value
            selectItems[total_cards] = selectItems2; //This get the receipt-side
            multiply[total_cards] = "1";         
            tables[total_cards] = selectTable2;
            getReceiptSearch = false;
         }
      }
    } while (DB.myResult.next());
  
  } 



  // Adding in the items based on personnel number such as ADVANCE
  String[]  UsePersNum = SystemDOM.getDOMTableArrayFor("reconcilement","usepersonnelnumber");

  if (UsePersNum.length > 0)   //Must deal with the vendor being specified.
  {
    for (int i = 0; i < UsePersNum.length; i++) {
      total_cards = total_cards + 1;
      Cards[total_cards] = UsePersNum[i];
      if (!vendorSpecified || vendor.equals(Cards[total_cards]))
      {
        Numbers[total_cards] = Reporter.getPersNum();
        selectItems[total_cards] = selectItems1;
        multiply[total_cards] = "-1";
        tables[total_cards] = selectTable1;
        if (!Cards[total_cards].equals("")) {
           total_cards = total_cards + 1;
           Cards[total_cards] = Cards[total_cards - 1];
           Numbers[total_cards] = Reporter.getPersNum();
           selectItems[total_cards] = selectItems2;
           multiply[total_cards] = "1";         
           tables[total_cards] = selectTable2;
        }
      }
  } 

} else {
      Logfile.println("[400] ItemsGather.jsp -> reporter has not been found");
%>    <option value="[]">Employee has not been located</option>
<%
}

  current_card = total_cards;
// Is this really necessary now...  
  for (int i = 0; i < total_cards; i++)
  {
    if (Cards[i] != null && !Cards[i].equals("") && Numbers[i] != null && !Numbers[i].equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems[i],"$card$",Cards[i]) ,"$number$",Numbers[i]) )) {
       current_card = i;
       i = total_cards;
    }
  }  

  String recordCursor;
  String status; 
  String cardtype;
  String multipleFlag = "-1";
  String sideStr;
  String amount;
  String transdate;
  String statedate;
  String reference;
  String merchant;
  String tableName;
  String backcolor = "class=\"offsetColor\"";
  String oldbackcolor = "";
  String newbackcolor; 

  try {
    while (current_card < total_cards) {
      do { 
        recordCursor = DB.myResult.getString(1);
        // status = DB.myResult.getString(2); 
        cardtype = DB.myResult.getString(3).trim();
        amount = makeCurrency(DB.myResult.getString(4));
        transdate = DB.myResult.getString(5); 
        statedate = DB.myResult.getString(6);
        reference = DB.myResult.getString(7); 
        merchant = DB.myResult.getString(8); 
        tableName = tables[current_card];
        multipleFlag = multiply[current_card];
        if (multipleFlag.equals("1"))
        {
            sideStr = "EXPENSE";
        } else {
            sideStr = "VENDOR ";
        }
        
%>    <option value="['<%= tableName %>', '<%= recordCursor %>', <%= multipleFlag %>, <%= amount %>, '<%= transdate %>']"><%= sideStr %> | <%= cardtype %> | <%= DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(transdate))) %> | <%= DD.getSimpleDate(DD.getDateFromXBase(statedate)) %> | <%= amount %> | <%= reference %></option>
<% 
      } while (DB.myResult.next());
        do {
          current_card += 1;
          if (Cards[current_card] != null 
             && !Cards[current_card].trim().equals("") 
             && Numbers[current_card] != null
             && !Numbers[current_card].trim().equals("") 
             && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems[current_card],"$card$",Cards[current_card]) , "$number$",Numbers[current_card]) )) 
          {
             breakout = true;    
          } else {
             breakout = false;
          }
        } while(current_card < 7 && !breakout);
    }  // top while loop
  } catch (java.lang.Exception ex) {
    Logfile.println("[500] Error in the result set");
    Logfile.println("[500] " + ex.toString());
  }
}  
%>
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

%>
