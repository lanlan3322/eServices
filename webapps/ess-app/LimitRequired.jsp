<%--
LimitRequired.jsp - determines if users has the $ limit to approve a report
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

<%-- I switched the multiplier around.  Not sure this is correct? 
     Need to look at how handling the base currency
--%>


<%!
public boolean CheckLimit(ess.PersonnelTable PT, String ReceiptAmount, String reportCurrency, String LimitRequired, String CEOLimit, ess.Currency Currency, ess.AuditTrail Log, String signAnyway)
{
   boolean signOff = false;
   if (signAnyway.equalsIgnoreCase("YES")) signOff = true;
   boolean retVal = signOff || CheckLimit(PT, ReceiptAmount, reportCurrency, LimitRequired, CEOLimit, Currency, Log);
   return retVal;
}
public boolean CheckLimit(ess.PersonnelTable PT, String ReceiptAmount, String reportCurrency, String LimitRequired, String CEOLimit, ess.Currency Currency, ess.AuditTrail Log) {
   boolean retVal = false;
   boolean checked = false;
   java.lang.Double Report;
   java.lang.Double ApprovalLimit;
   double multiplier = (double) 0.00;
Log.println("[000] LimitRequired.jsp - Currency: " + reportCurrency);   
   if (CEOLimit.equals("") || CEOLimit.equalsIgnoreCase("NO")) {
	   retVal = true;
   } else if ( CEOLimit.equalsIgnoreCase("YES") && PT.isCEO() ) {
      retVal = true;
   } else { 
      checked = true;
      multiplier = Currency.getRate(reportCurrency);
      ApprovalLimit = java.lang.Double.valueOf(CEOLimit);
      Report = java.lang.Double.valueOf(ReceiptAmount);
      if ((ApprovalLimit.doubleValue() >= multiplier * Report.doubleValue()) || PT.isCEO()) {  //JH 2008-03-07
         retVal = true;
      } else {
         retVal = false;
      }
   }
   if (retVal == true) {
      if (LimitRequired.toUpperCase().equals("NO")) {
         retVal = true;
      } else {
         if (!checked) {
            multiplier = Currency.getRate(reportCurrency);
         }
         ApprovalLimit = java.lang.Double.valueOf(PT.limit);
         Report = java.lang.Double.valueOf(ReceiptAmount);
         if (ApprovalLimit.doubleValue() >= multiplier * Report.doubleValue()) {  //JH 2008-03-07
            retVal = true;
         } else {
            retVal = false;
         }
      }
   }
   return retVal;
}

public boolean isNotCEOLimit(String ReceiptAmount, String reportCurrency, String LimitRequired, String CEOLimit, ess.Currency Currency, ess.AuditTrail Log) {
   boolean retVal = false;
   boolean checked = false;
   java.lang.Double Report;
   java.lang.Double ApprovalLimit;
   double multiplier = (double) 0.00;
   if (CEOLimit.equals("") || CEOLimit.equalsIgnoreCase("NO")) {
      retVal = false;
   } else if ( CEOLimit.equalsIgnoreCase("YES")) {
      retVal = true;
   } else { 
      checked = true;
      multiplier = Currency.getRate(reportCurrency);
      ApprovalLimit = java.lang.Double.valueOf(CEOLimit);
      Report = java.lang.Double.valueOf(ReceiptAmount);
      if ((ApprovalLimit.doubleValue() >= multiplier * Report.doubleValue())) {  //JH 2008-03-07
         retVal = true;
      } else {
         retVal = false;
      }
   }
   return retVal;
}

public boolean isDummy(String xName, String x, ess.AuditTrail Log)
{
    Log.println("[000] isDummy  " + xName + ": " + x);
    return true;
}
%>

