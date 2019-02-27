<%--
InstantCompany.jsp - Creates a company in the Updates central database with changes
Copyright (C) 2008 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />     

<%@ include file="DBAccessInfo.jsp" %>
<%
Log.println("[271] InstantCompany");
%>
<%@  include file="Headers.jsp" %>
<%
db.setDB(DBDatabase,DBUser,DBPassword);
db.setSQLTerminator(DBSQLTerminator);
SysTable.setConnection(db.getConnection());
SysTable.setSQLTerminator(db.getSQLTerminator());

String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
java.io.File SystemFile = new java.io.File(system_file);
SystemDOM.setDOM(SystemFile);

String RefuseEmail = SystemDOM.getDOMTableValueFor("eraas","refuseemail","");
java.util.StringTokenizer RE = new java.util.StringTokenizer(RefuseEmail, ";");
int numberOfDomains = RE.countTokens();
String[] Domains = new String[numberOfDomains];
int i = 0;
while (RE.hasMoreTokens())
{
   Domains[i++] = RE.nextToken().toLowerCase();
}

//Notes for future updates
// 1. Handle duplcate email addresses

boolean noErrorCondition = true;
String SQLUpdate;
String companyName = request.getParameter("DESCRIP");
String menu = request.getParameter("MENU");
String receipts = "1"; 
String company = SysTable.getSystemIncString("COMPANY_SEQUENCE");
String language = request.getParameter("LANGUAGE"); 

String purposeScreen;
String entryScreen;
String hotelScreen = "trans12fxnj.html";

if (menu.equals("1"))
{
	purposeScreen = "head2j.html";
	entryScreen = "screenSimple.html";
} else if (menu.equals("2"))
{
	purposeScreen = "head2k.html";
	entryScreen = "screen.html";
} else
{
	purposeScreen = "head2b.html";
	entryScreen = "screen.html";
}

if (receipts.equals("1"))
{
	if (menu.equals("1"))
	{
		menu = "3";
	} else if (menu.equals("2"))
	{
		menu = "4";
	}
}
	
if (language.equals("fr")) {
SQLUpdate = "INSERT INTO COMPANY VALUES ( '$company$','$descrip$','','Canada Dollar','Kilometers','ess-app/Report.jsp','ESS.gif','50','100','EXP','$company$','EXP','EXP','EXP','STD','CAN','EXP','generaloffset','steps','','$language$','','1','$company$','$purpose$','$screen$','$hotel$')";
entryScreen = "screen.html";  //French has gotten a simple screen yet.
} else {
SQLUpdate = "INSERT INTO COMPANY VALUES ( '$company$','$descrip$','','US Dollar','Miles','ess-app/Report.jsp','ESS.gif','50','100','EXP','$company$','EXP','EXP','EXP','STD','EXP','EXP','generaloffset','steps','','$language$','','1','$company$','$purpose$','$screen$','$hotel$')";
}

SQLUpdate = db.SQLReplace(SQLUpdate,"$descrip$",companyName);
SQLUpdate = db.SQLReplace(SQLUpdate,"$purpose$",purposeScreen);
SQLUpdate = db.SQLReplace(SQLUpdate,"$screen$",entryScreen);
SQLUpdate = db.SQLReplace(SQLUpdate,"$language$",language);
SQLUpdate = db.SQLReplace(SQLUpdate,"$hotel$",hotelScreen);
noErrorCondition = setItem(db,SQLUpdate,company);
String statusMessage = "";

String lname_admin = request.getParameter("LNAME");
String fname_admin = request.getParameter("FNAME");
String email_admin = request.getParameter("EMAIL");
String phone_admin = request.getParameter("PHONE");
String reports_done = request.getParameter("REPORTS");

String manager = "";
String lname = lname_admin;
String fname = fname_admin;


String checkedEmail = checkEmail(db, email_admin, Log);
if (noErrorCondition && checkedEmail.equals("") && OKDomain(Domains,email_admin, Log))
{
    manager = setUser(db, SysTable, company, lname, fname, companyName, email_admin, menu, "99999", "Admin", phone_admin, language, reports_done);
    if (!manager.equals("")) { 
       statusMessage += "<br> Password for " + email_admin + " (administrator) is: " + fname + company;
       statusMessage += "<br> This user is the administrator and can access the Admin menu.";
       if (!SendNotice(email_admin, fname, company, companyName, SysTable, Log)) {
    	   statusMessage += "<br> Notification Email not sent to " + email_admin + ".";
       }
    }
} else {
	statusMessage += "<br> Administrator email is duplicate, invalid or public domain, account not created for (" + email_admin + ").";
	statusMessage += "<br> If you have already used this email for an account and forgot the password contact <a href=\"mailto:service@expenseservices.com\">service@expenseservices.com</a>.";
	statusMessage += "<br> If you wish to start a new company either use a different email or contact <a href=\"mailto:service@expenseservices.com\">service@expenseservices.com</a>.";
	statusMessage += "<br> The administrator must use a private domain. Public domains (e.g., gmail, yahoo, etc.) are not accepted.";
	statusMessage += "<br> No other users will be added.";
	manager = "";
	noErrorCondition = false;
}

String email = request.getParameter("EMAIL_MGR");
if (email_admin.equalsIgnoreCase(email)) {
    statusMessage += "<br> The administrator is acting as the manager/approver for all other accounts.";
} else {
	statusMessage += "<br> The administrator is the approver for the manager.";
}



if (noErrorCondition && !manager.equals("") && !email_admin.equalsIgnoreCase(email))
{
	checkedEmail = checkEmail(db, email, Log);
	if (checkedEmail.equals(""))
		// if (checkedEmail.equals("") && OKDomain(Domains,email))		
	{
       lname = request.getParameter("LNAME_MGR");
       fname = request.getParameter("FNAME_MGR");
       manager = setUser(db, SysTable, company, lname, fname, companyName, email, menu, manager, "Approver", "999-9999", language, reports_done); 
       // if (!manager.equals("") && !SendNotice(email, fname, company, companyName, SysTable, Log)) statusMessage += "<br> Notification Email not sent to " + email + ".";
       if (!manager.equals("")) { 
           statusMessage += "<br> Password for " + email + " (manager) is: " + fname + company;
           statusMessage += "<br> This user is the approver/manager for any following acounts.";
           if (!SendNotice(email, fname, company, companyName, SysTable, Log)) {
        	   statusMessage += "<br> Notification Email not sent to " + email + ".";
           }
        }
	} else {
		statusMessage += "<br> Manager email is duplicate, account not created (" + email + ").";
		statusMessage += "<br> No other users will be added.";
		manager = "";
	}
}


String persnum = "";
email = request.getParameter("EMAIL_1");
if (noErrorCondition && !manager.equals("") && !email.equals(""))
{
	checkedEmail = checkEmail(db, email, Log);
	if (checkedEmail.equals(""))
		// if (checkedEmail.equals("") && OKDomain(Domains,email))		
	{
	   lname = request.getParameter("LNAME_1");
	   fname = request.getParameter("FNAME_1");
	   persnum = setUser(db, SysTable, company, lname, fname, companyName, email, menu, manager, "Reporter", "999-9999", language,  reports_done); 
       // if (!persnum.equals("") && !SendNotice(email, fname, company, companyName, SysTable, Log)) statusMessage += "<br> Notification Email not sent to " + email + ".";
       if (!persnum.equals("")) { 
           statusMessage += "<br> Password for " + email + " is: " + fname + company;
           if (!SendNotice(email, fname, company, companyName, SysTable, Log)) {
        	   statusMessage += "<br> Notification Email not sent to " + email + ".";
           }
        }
	} else {
		statusMessage += "<br> Reporter 1's email is duplicate, account not created (" + email + ").";
	}
}

email = request.getParameter("EMAIL_2");
if (noErrorCondition && !manager.equals("") && !email.equals(""))
{
	checkedEmail = checkEmail(db, email, Log);
	if (checkedEmail.equals(""))
		// if (checkedEmail.equals("") && OKDomain(Domains,email))		
	{
	   lname = request.getParameter("LNAME_2");
	   fname = request.getParameter("FNAME_2");
	   persnum = setUser(db, SysTable, company, lname, fname, companyName, email, menu, manager, "Reporter", "999-9999", language,  reports_done); 
       // if (!persnum.equals("") && !SendNotice(email, fname, company, companyName, SysTable, Log)) statusMessage += "<br> Notification Email not sent to " + email + ".";
       if (!persnum.equals("")) { 
           statusMessage += "<br> Password for " + email + " is: " + fname + company;
           if (!SendNotice(email, fname, company, companyName, SysTable, Log)) {
        	   statusMessage += "<br> Notification Email not sent to " + email + ".";
           }
        }
	} else {
		statusMessage += "<br> Reporter 2's email is duplicate, account not created (" + email + ").";
	}
}

email = request.getParameter("EMAIL_3");
if (noErrorCondition && !manager.equals("") && !email.equals(""))
{
	checkedEmail = checkEmail(db, email, Log);
	if (checkedEmail.equals(""))
		// if (checkedEmail.equals("") && OKDomain(Domains,email))		
	{
	   lname = request.getParameter("LNAME_3");
	   fname = request.getParameter("FNAME_3");
	   persnum = setUser(db, SysTable, company, lname, fname, companyName, email, menu, manager, "Reporter", "999-9999", language, reports_done); 
       // if (!persnum.equals("") && !SendNotice(email, fname, company, companyName, SysTable, Log)) statusMessage += "<br> Notification Email not sent to " + email + ".";
       if (!persnum.equals("")) { 
           statusMessage += "<br> Password for " + email + " is: " + fname + company;
           if (!SendNotice(email, fname, company, companyName, SysTable, Log)) {
        	   statusMessage += "<br> Notification Email not sent to " + email + ".";
           }
        }
    } else {
	    statusMessage += "<br> Reporter 3's email is duplicate, account not created (" + email + ").";
    }
}

if (noErrorCondition)
{
	SQLUpdate = "INSERT INTO DEPART VALUES ( 'GENERAL','General Management Department','GEN','$company$','','','','','default','1');";
	noErrorCondition = setItem(db,SQLUpdate,company);
} else {
	// noErrorCondition = false;
    statusMessage += "<br> General department was not created.";

}

if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'AIR_PREPAID','AIRFARE CO. PAID','99999','','AIRFARE CO','',0.00,'0','1','1','AIR-PREPD','','0','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'AIRFARE','AIRFARE PERSONALLY PAID','50510','','AIRFARE EMP','',0.00,'1','2','','','','0','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'MILEAGE','PERSONAL CAR MILEAGE','50510','','MILEAGE','',0.00,'','1','','','','','','','','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'TOLLS','GROUND TRANSPORTATION TOLLS','50510','','TOLLS','',5.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'PARKING','GROUND TRANSPORATION PARKING','50510','','PARKING','',25.00,'1','1','','','','1','1','1','1','','','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'LIMO_TAXI','GROUND TRANSPORTATION LIMO/TAX','50510','','LIMO TAXI','',25.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'CAR_RENTAL','GROUND TRANSPORTATION CAR RENT','50510','','CAR RENTAL','',25.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'RENTAL_GAS','GROUND TRANS. RENTAL CAR GAS','50510','','RENTAL GAS','',25.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'LUNCH','MEALS-LUNCH','50540','','MEALS','',25.00,'1','1','','','','1','1','1','1','','','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'ENTERTAINMENT','ENTERTAINMENT','50540','','ENTERTAINMENT','',0.00,'1','1','','','','1','1','1','1','1','1','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'SUPPLIES','SUPPLIES','50590','','SUPPLIES','',25.00,'1','1','','','','1','1','1','1','','','1','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'DUES_SUBS','DUES & SUBSCRIPTIONS','50580','','DUES SUBS','',25.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'PHONE_CELL','PHONE CELLULAR','60520','','PHONE CELL','',25.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'TRAINING','TRAINING','50260','','TRAINING','',0.00,'1','1','','','','1','1','1','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'LODGING','LODGING','50520','','LODGING','',0.00,'1','1','','','','','','','1','','','','1','','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'PERSONAL','PERSONAL USAGE ACOUNT','99999','','PERSONAL','',0.00,'','5','1','','','','','','1','','','','1','HOTEL','$company$')",company);
// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'GST','GST TAX','20375','','GST','',0.00,'1','2','1','','1','1','1','1','1','','','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'BREAKFAST','BREAKFAST','50540','','MEALS','',25.00,'1','1','','','','1','1','1','1','','','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'DINNER','DINNER','50540','','MEALS','',25.00,'1','1','','','','1','1','','1','','','','1','HOTEL','$company$')",company);
if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO ACCOUNT VALUES ( 'MISC','MISC','50550','','MISC','',0.00,'','4','','','','1','1','1','1','','','','1','HOTEL','$company$')",company);

// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO CHARGE VALUES ( 'CASH','CASH-EMPLOYEE','20040','','1','1','1','','$company$')",company);
// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO CHARGE VALUES ( 'ADVANCE','Advance Account','11800','','','','1','','$company$')",company);
// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO CHARGE VALUES ( 'CASH-RETD','Cash Returned w/Rep.','20041','','','','2','','$company$')",company);
// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO CHARGE VALUES ( 'PREPAID','PREPAID','99999','','','1','1','','$company$')",company);
// if (noErrorCondition) noErrorCondition = setItem(db,"INSERT INTO CHARGE VALUES ( 'AIR-PREPD','AIR PREPAID','99999','','','','2','','$company$')",company);

if (!noErrorCondition) statusMessage += "<br> Expense types have not been setup.";

if (noErrorCondition)
{
	SendAnEmail("5105938185@txt.att.net","service@expenseservices.com",companyName + " successful", "Successful: " + companyName + ", " + fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin + ", " + reports_done + ", " + purposeScreen, SysTable);
	SendAnEmail("jim@rjholton.com","service@expenseservices.com",companyName + " successful", "Successful: " + companyName + ", " + fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin + ", " + reports_done + ", " + purposeScreen, SysTable);
	//SendAnEmail("jimholton@yahoo.com","service@expenseservices.com",companyName + " successful", fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin, SysTable);
} else {
	SendAnEmail("5105938185@txt.att.net","service@expenseservices.com",companyName + " not successful", "Failure: " + companyName + ", " + fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin + ", " + reports_done + ", " + purposeScreen, SysTable);
	SendAnEmail("jim@rjholton.com","service@expenseservices.com",companyName + " not successful", "Failure: " + companyName + ", " + fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin + ", " + reports_done + ", " + purposeScreen, SysTable);
	//SendAnEmail("jimholton@yahoo.com","service@expenseservices.com",companyName + " not successful", fname_admin + " " + lname_admin + ", " + phone_admin + ", " + company + ", " + email_admin, SysTable);
}


%> 

<html>
<body>

<%

String message;
if (noErrorCondition)
{
%>
<strong><em>Results of your process: <%= companyName%> has been setup correctly as company number <%= company%><%= statusMessage %></em></strong>
<br><br><br>
<em>Unless noted above, password are being sent to your users via email</em>
<br><br><br>
<em><a href="/ess/<%=language %>/XLogin.html">Click here to login in</a>.</em>

<%
} else {
%>
<strong><em>
<%= statusMessage %>
<br><br>
Results of your process: Company setup was not completed.  You either entered
invalid information or there was a technical problem.  Please try again.  If your problem 
continues, please contact technical support.<br>  
<br><a href="/support.html">Contact support.</a></em></strong>
<%
}
%>
<script>
//This is a test so far
</script>
</body>
</html>

<%!
static boolean setItem(ess.AdisoftDbase db, String SQL, String company)
{
	boolean retVal = true;
	SQL = db.SQLReplace(SQL,"$company$",company);
	if (db.doSQLExecute(SQL) != 1) retVal = false;
	return retVal;
}

static String setUser(ess.AdisoftDbase db, ess.ServerSystemTable Sys, String company,
		               String lname, String fname, String descrip, String email, 
		               String menu, String manager, String usertype, String phone, String language, String reports_done)
{
	String retVal = "";
	String persnum = Sys.getSystemIncString("PERSNUM_SEQUENCE");  
	
	String SQL = "INSERT INTO USER VALUES ( '$persnum$','$lname$','$fname$','$descrip$','$phone$','$email$','GENERAL','$company$','','','$menu$',10000.00,'','2013-06-01','STD','$manager$','$extra1$','$reports$',0.0000,'','','','','0000-00-00','','1','1','$fname$$company$','A/P','','1999-12-31','','$usertype$','$language$','$country$','$dateformat$','$numberformat$','')";
	SQL = db.SQLReplace(SQL,"$persnum$", persnum);
	SQL = db.SQLReplace(SQL,"$lname$", lname);
	SQL = db.SQLReplace(SQL,"$fname$", fname);
	SQL = db.SQLReplace(SQL,"$descrip$", descrip);
	SQL = db.SQLReplace(SQL,"$email$", email);
	SQL = db.SQLReplace(SQL,"$menu$", menu);
	SQL = db.SQLReplace(SQL,"$manager$", manager);
	SQL = db.SQLReplace(SQL,"$usertype$", usertype);
	SQL = db.SQLReplace(SQL,"$phone$", phone);
	SQL = db.SQLReplace(SQL,"$language$", language);
	SQL = db.SQLReplace(SQL,"$country$", "");
	SQL = db.SQLReplace(SQL,"$dateformat$", "yyyy-MM-dd");	
	SQL = db.SQLReplace(SQL,"$numberformat", "period");
	if (manager.equals("99999"))
	{
		SQL = db.SQLReplace(SQL,"$extra1$", "email");
		SQL = db.SQLReplace(SQL,"$reports$", reports_done);
	} else {
		SQL = db.SQLReplace(SQL,"$extra1$", "");
		SQL = db.SQLReplace(SQL,"$reports$", "");
	}	
	if (setItem(db, SQL, company)) 
	{
		retVal = persnum;
		ess.AuditTrail.println("[270] InstantCompany: " + descrip + "," + company+ "," + persnum + "," + email+ "," + fname + " " + lname + "," + manager + "," + menu);
	}
	return persnum;
}

private boolean OKDomain(String[] Domains, String email, ess.AuditTrail Log)
{
	email = email.toLowerCase();
	boolean retVal = true;
	for(int i = 0; i < Domains.length; i++)
	{
		if (email.indexOf(Domains[i]) > -1)
		{
			retVal = false;
			Log.println("[483] InstantCompany: OKDomain failed for : " + email);
			i = Domains.length;
			
		}		
	}
	return retVal;
				
}


static String checkEmail(ess.AdisoftDbase db, String email, ess.AuditTrail Log)
{
	String retVal = "";
	String SQL = "SELECT EMAIL FROM USER WHERE EMAIL = '$email$'";
	SQL = db.SQLReplace(SQL,"$email$", email);
	if (db.setResultSet(SQL)) 
	{
		retVal = email;
		Log.println("[482] InstantCompany: checkEmail duplicate for : " + email);
	} else {
		Log.println("[282] InstantCompany: checkEmail passed for : " + email);
	}
	return retVal;
}
private boolean SendNotice(String email, String fname, String company, String companyName, ess.ServerSystemTable SendInfo, ess.AuditTrail Log)
{
	boolean retVal = false;
	String MSG = "You have been setup on the automated expense reporting system\n";
	MSG += "at Expenseservices.net.  You can access the application at:\n\n";
	MSG += "http://www.expenseservices.net\n\n";
	MSG += "Your email address is: " + email + "\n";
	MSG += "Your temporary password is: " + fname + company + "\n";
	MSG += "You can change your password with the help menu option after you login.";
	if (SendAnEmail(email,"service@expenseservices.com",companyName + " expense reporting setup", MSG, SendInfo))
	{
		Log.println("[284] InstantCompany: SendNotice to: " + email);
		retVal = true;
	} else {
		Log.println("[484] InstantCompany: SendNotice failed for : " + email);
	}
	return retVal;
}

%>
<%@ include file="SendAnEmail.jsp" %>

