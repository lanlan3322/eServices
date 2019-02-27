<%--
StatementLineItem.jsp - class representing a receipt item for the prepop conversion 
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

<%!

private class StatementLineItem {
  public String screen = "";
  public String status = "";
  public String charge = "";
  public String originalCharge = "";
  public String acctno = "";
  public String reference = "";
  public String amount = "";
  public String rcptdate = "";
  public String xref = "";
  public String purpose = "";
  public String expensetype = "";
  public String expensetypename = "";
  public String expenseamount = "";
  public String expensecomment = "";
  public String recordCursor = "";
  public String rcpttype = "";
  public String subtype = "";
  public String begdate = "";
  public String enddate = "";
  public String recamt = "";
  public String units = "";
  public String xsource = "";
  public String xdate = "";
  public String xrate = "";
  public String prepopstatus = "";
  public String prepopreference = "";
  public String scanref = "";
  
  public StatementLineItem () {
  }
  
  public String toString() {
   String retVal = "<receipt type = \"" + screen + "\">";
   retVal += lineStr("rcpttype",rcpttype);
   retVal += lineStr("subtype",subtype);
   retVal += lineStr("rcptdate",rcptdate);
   retVal += lineStr("amount",amount);
   retVal += lineStr("charge",charge);
   retVal += lineStr("refer",reference);
   retVal += lineStr("expense_1_xref",xref);
   retVal += lineStr("expense_1_purpose",purpose);
   retVal += lineStr("expense_1_expensetype",expensetype);
   if (!expensetypename.equals("")) retVal += lineStr("expense_1_expensetypename",expensetypename);
   retVal += lineStr("expense_1_amount",expenseamount);
   retVal += lineStr("expense_1_comment",expensecomment);
   retVal += lineStr("begdate",begdate);
   retVal += lineStr("enddate",enddate);
   retVal += lineStr("recamt",recamt);
   retVal += lineStr("units",units);
   retVal += lineStr("xsource",xsource);
   retVal += lineStr("xdate",xdate);
   retVal += lineStr("xrate",xrate);
   retVal += lineStr("okstatus",prepopstatus);
   retVal += lineStr("okref",prepopreference);
   retVal += lineStr("scanref",scanref);
   retVal += "</receipt>";
   return retVal;
  }

  private String lineStr(String S, String T) {
    if (T == null || T.equals("")) {
      return "";
    } else {
      return "<" + S + ">" + T.trim() + "</" + S + ">";
    }
  }

}

%>