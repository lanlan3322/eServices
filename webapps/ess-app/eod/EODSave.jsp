<%--
EODSave.jsp - Runs the EOD jobs to produce various output files
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
     scope="session" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>

<%

String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
   SysTable.setConnection(PersFile.getConnection());   //SystemInfo.jsp handled differently here
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
   }
   NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");

   if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
   }
   CCode = request.getParameter("ccode"); 
%>
  <%@ include file="../StatusInfo.jsp" %>
  <%@ include file="../DepartInfo.jsp" %>
<%

  session.putValue("loginAttempts", new java.lang.Integer(0));

  String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
  String database = request.getParameter("database");

  Reporter.setConnection(PersFile.getConnection());
  Reporter.setSQLTerminator(PersFile.getSQLTerminator()); 
  Reporter.setSQLStrings();

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());

  boolean errorCondition = false; 
 
%>
<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>The following report(s) have been processed:</em></strong><br>
<%  
   String report2Approve;
   String report2AppStat;
   String SQLCommand;
   String persnum;
   boolean xFlag;
   String repstat;
   String persname;
   byte[] bArray;    //used for encrypted values
   String E;         //     ditto
   String approvalType;
   String repDBStat;
   String nextStep;
   String newStatusCode;
   String receiptAmount;
   String limitRequired; 
   String firstSigner;
   String signerColumn;
   String dupAllowed; 
   String dateColumn;
   String userReference;
   String subTable;
   String depart;
   String newNotifyPerson;
   String secondSigner;
   String adminSigner;
   String newDuplicate;
   String newLimit;
   String notifyMsg;
   String newApprovalType;
   String newSignerColumn;
   String newDateColumn;
   String centralReference;
   String oldStep;

   String retSQL = SystemDOM.getDOMTableValueFor("releasepayments","retrievesql","");
   String upSQL = SystemDOM.getDOMTableValueFor("releasepayments","updatesql","");

   int SQLResult;
   int SQLResult2;

   String newNextStep;
   String newNewStatusCode;

   int voucherNumber = 0;

   String newAsOfDate = Dt.xBaseDate.format(Dt.date);
   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   if (SQLType.equals("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.simpleDate.format(Dt.date));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",newAsOfDate);
   } 

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 
   
   boolean actionFlag;
   ess.FeedAPI F;
   
   String[] feedNames = SystemDOM.getDOMTableArrayFor("endofday","feed");
   java.util.Vector feeds = new java.util.Vector();
   int NumberOfFeeds = feedNames.length;
   
   if (NumberOfFeeds > 0){
      actionFlag = true;
      for (int i = 0; i < NumberOfFeeds; i++) {
        F = (ess.FeedAPI) (Class.forName(feedNames[i])).newInstance();
        F.init(SystemDOM,PersFile.getConnection()); 
        feeds.add(F);
      }
   } else {
      actionFlag = false;
%>    <br><strong><em>Error with feed definition in system.xml - contact support!</em></strong>
<%   Log.println("[500] EODSave.jsp - no feed objects found");
   }
   
   while (rp.hasMoreTokens() && actionFlag) {
     report2Approve = rp.nextToken().trim() ;
     report2AppStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     
     Log.println("[000] EODSave.jsp starting: " + report2Approve);
     ess.DB2ESS Rep2 = new ess.DB2ESS();
     Rep2.setConnection(PersFile.getConnection(),PersFile.getSQLTerminator()); 
     Rep2.setDenormalizeClient(true);

     Rep2.set(report2Approve);

     if (Rep2.getReportFound()) {

        persnum = Rep2.getPersNum();  //personnel number
        //repstat = PersFile.getTrim(Reg.myResult.getString(2));  //report status
        persname = Rep2.getReportName(); //report name
        //receiptAmount = PersFile.getTrim(Reg.myResult.getString(4)); //receipt amount
        //userReference = PersFile.getTrim(Reg.myResult.getString(5)); //user reference
        //depart = PersFile.getTrim(Reg.myResult.getString(6));        //department
        //centralReference = PersFile.getTrim(Reg.myResult.getString(7)); //report reference

        //subTable = getRoutingRuleName(DepartDOM, depart, PersFile. depart, Log);

        // Don't know if we need these...
        //signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner");

        xFlag = Reporter.setPersNumInfo(persnum); 
        
        if (xFlag ) {   
          for (int i = 0; i < NumberOfFeeds; i++) {
             F = (ess.FeedAPI) feeds.get(i);
             F.post(Reporter, (ess.XML2ESS) Rep2);
             // Need some kind of status checking after this
          }  
%>
          <br> Report <%=report2Approve %> for <%= persname %>

     <% } else { %>  
          <br> Cannot process <%=report2Approve %> with current Status of <%= report2AppStat %>  
               &nbsp;-- Reporter has not been found - (<%=persnum %>)
            <% Log.println("[500] EODSave.jsp - Cannot approve " + report2Approve + " - reporter not found"); 
              
        }  //Done with the find reporter logic 
     %> 
     
     
  <% } //If the SQL select is OK
   } //While the tokens are still there

   for (int i = 0; i < NumberOfFeeds; i++) {
      F = (ess.FeedAPI) feeds.get(i);
      F.close();
      // Need some kind of status checking after this
   }  

%>    
 
<br><br><strong><em>End of processing</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWithDBase('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/eod/EODReport.jsp?downlevel=','approvallevel','1')" tabindex="1"><em><strong>Review the end-of-day report</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 

Log.println("[000] EODSave.jsp finished");

} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] EODSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% } 

}
%>
<%@ include file="../UnScramble.jsp" %>
<%@ include file="../StatXlation.jsp" %>
<%@ include file="../DepartRouteRule.jsp" %>




