<%--
TransactionLogUpdate.jsp - sends a message via the SMTP server
Copyright (C) 2004,2011 R. James Holton

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
<%--
TransLogUpdate method is used by programs that update files to store status, etc change information that is either not
currently captured or to save it to a permanent file or update a bucket that is not currently handled and may be
optional.  Currently used to place the time in in the EXTRA1 report column.

Paramters:

1. Log - initialized AdisoftDbase class
2. 
   Dt - initialized CustomDate object AND
   SystemDOM - initialized AdisoftDOM with the system.xml file loaded AND
   updateType - element from **** that describes SQL string to execute
OR 
   updateSQL - String, SQL to execute with $ replacements.  A null or "No" means to bypass
   
3. voucher - String, replaces $voucher$
4. pvoucher - String, replaces $pvoucher$
5. persnum - String, replaces $persnum$
6. status - String, replaces $status$
7. sqlDate - String, replaces $date$
8. timeString - String, replaces $time$ [optional CustomDate, SystemDOM and updateType are used]

note the sqlDate should include any required formating, including single quotes.  The others assume single quotes

example of usage in ApproveSave.jsp:

TransLogUpdate(Reg, Dt, SystemDOM, "approval", report2Approve, userReference, PersFile.persnum, newStatusCode, SQLDate) {
	
--%>

<%!

private void TransLogUpdate(ess.AdisoftDbase Log, ess.CustomDate Dt, ess.AdisoftDOM SystemDOM, String updateType, String voucher, String pvoucher, String persnum, String status, String sqlDate) 
{
    	TransLogUpdate(Log, SystemDOM, updateType, voucher, pvoucher, persnum, status, sqlDate, Dt.getLocalTime());
}


private void TransLogUpdate(ess.AdisoftDbase Log, ess.AdisoftDOM SystemDOM, String updateType, String voucher, String pvoucher, String persnum, String status, String sqlDate, String timeString) 
{
	String updateSQL = SystemDOM.getDOMTableValueFor("transactionlog", updateType,"no");
    if (updateSQL != null && updateSQL.length() > 0 && !updateSQL.equalsIgnoreCase("no") )
    {
    	boolean x = TransLogUpdate(Log, updateSQL, voucher, pvoucher, persnum, status, sqlDate, timeString);
    }
}
	 

private boolean TransLogUpdate(ess.AdisoftDbase Log, String updateSQL, String voucher, String pvoucher, String persnum, String status, String sqlDate, String timeString) 
{
	boolean SQLResult = false;
	updateSQL = Log.SQLReplace(updateSQL,"$voucher$",voucher);
	updateSQL = Log.SQLReplace(updateSQL,"$pvoucher$",pvoucher);
	updateSQL = Log.SQLReplace(updateSQL,"$persnum$",persnum);
	updateSQL = Log.SQLReplace(updateSQL,"$status$",status);
	updateSQL = Log.SQLReplace(updateSQL,"$date$",sqlDate);
	updateSQL = Log.SQLReplace(updateSQL,"$time$",timeString);
    try {
    	SQLResult = (Log.doSQLExecute(updateSQL) == 1);
    } catch (java.lang.NullPointerException ex) {
        Log.writeLog("[500] TransactionLogUpdate.jsp null pointer exception");
        Log.writeLog("[500] " + ex.toString());
        ex.printStackTrace();
    } catch (java.lang.Exception ex){
        Log.writeLog("[500] TransactionLogUpdate.jsp exception");
        Log.writeLog("[500] " + ex.toString());
        ex.printStackTrace();
    }
    return SQLResult;
}

%>

