<%@ page contentType="text/html" %>

<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />     

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<% 
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String database = request.getParameter("database");
   //String reference  = request.getParameter("reference");//per_num
   //String voucher  = request.getParameter("voucher");
   String persnumber = request.getParameter("persnumber");
   String reply2 = request.getParameter("email");
   String depart = request.getParameter("depart");
   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");
   byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String persname; 
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
	 String oldVoucher = "";
	 String newVoucher = "";

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String begDateSQL = "";
   String endDateSQL = "";

   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));

   String begDateXB = "";
   String endDateXB = "";

   if (SQLType.equals("MM/DD/YYYY")) { 
     begDateXB = begDateStr;
     endDateXB = endDateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")) {    // oracle
     if (begDateStr != null && !begDateStr.equals("")) begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     if (endDateStr != null && !endDateStr.equals("")) endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
   } else {    // s/b YYYY-MM-DD
     begDateXB = begDateSQL;
     endDateXB = endDateSQL;
   }
boolean pFlag = PersFile.setPersInfo(reply2); 
String CCode = "";
double dGSTRate = 1.07;
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {

	Reg.setConnection(PersFile.getConnection()); 
   String SQLCommand = "SELECT * FROM EXPENSE JOIN REPORT ON EXPENSE.VOUCHER = REPORT.VOUCHER WHERE REPORT.RP_STAT = 'H4' AND REPORT.CUR_DATE >= '" + begDateXB + "' AND REPORT.CUR_DATE <= '" + endDateXB + "' AND REPORT.PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();

   Log.println("[000] HistoryReportPrint.jsp SQL:" + SQLCommand);
   Log.println("[000] HistoryReportPrint.jsp begDate:" + begDateXB);
   Log.println("[000] HistoryReportPrint.jsp endDate:" + endDateXB);

   if (Reg.setResultSet(SQLCommand)) { 
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes("NAME");
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString("NAME"));
        }
		//depart = PersFile.getTrim(Reg.myResult.getString("DEPART"));

%>
<html>
<head>
<link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
<script type="text/javascript">
  if (screen.width < 1024) {
    var link = document.getElementsByTagName( "link" )[ 0 ];
    link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
  }
</script>
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
</head>
<body>

<br/>
<% if (depart.equals("PWD")) { %>
<img src="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/ReportTitlePWD.jpg"></img>
<% } else if (depart.equals("ELCS")) { %>    
<img src="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/ReportTitleELCS.jpg"></img>
<% dGSTRate = 1.06;} else { %>    
<img src="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/ReportTitleELC.jpg"></img>
<% } %> 

<hr/>
<strong>
<h1>Expense Claim Summary<br/>
Date: <%=endDateStr%></h1>
</strong>
	<table border="0" cellspacing="0" width="90%">
		<tr>
			<td width="35%" align='left'><strong>Name:</strong> <%= persname%></td>
			<td width="15%" align='left'><strong>Depart:</strong> <%= depart%></td>
			<td width="30%" align='left'><strong>Period:</strong> <%= begDateStr%> - <%= endDateStr%></td>
		</tr>
	</table>

<hr/>
<%  
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String preference = "";
     String reference;
     String repdate;
     String repamt;
     String dueamt;
     String repStat;
	 String payement;
	 double amountTotal = 0.0;
	 String strTotalAmount = "0.0";
     int adjustment = 0; //see status.xml
     int reportCount = 0;


%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" align='center' bordercolordark="#008080">
		 <tr>
			 <td width="13%" <%=backcolor%> align='center'><u>Date</u></td>
			 <td width="15%" <%=backcolor%> align='center'><u>Type</u></td>
			 <td width="45%" <%=backcolor%> align='center'><u>Comment</u></td>
			 <td width="15%" <%=backcolor%> align='center'><u>Amount</u></td>
			 <td width="10%" <%=backcolor%> align='center'><u>GST</u></td>
			 <td width="2%" <%=backcolor%>></td>
		 </tr>
<%  newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
    try {
     
     do { 

        voucher = PersFile.getTrim(Reg.myResult.getString("VOUCHER"));
        preference = PersFile.getTrim(Reg.myResult.getString("PVOUCHER"));
        repStat = PersFile.getTrim(Reg.myResult.getString("RP_STAT")); 
		payement = PersFile.getTrim(Reg.myResult.getString("HISTORY")); 
        reference = PersFile.getTrim(Reg.myResult.getString("PERS_NUM")); //used for subordinate lookup
        repdate = PersFile.getTrim(Reg.myResult.getString("CUR_DATE")); //original submission date 
        if (repdate == null) repdate = "";
        if (!repdate.equals("")) repdate = Dt.getStrFromDate(Dt.getDateFromXBase(repdate), PersFile.getDateFormat());      //Dt.getSimpleDate(Dt.getDateFromXBase(repdate));
        repamt = PersFile.getTrim(Reg.myResult.getString("RC_AMT")); 
        dueamt = PersFile.getTrim(Reg.myResult.getString("RE_AMT")); 
		   ESSDisplay.setConnection(PersFile.getConnection());
		   ESSDisplay.setSQLTerminator(PersFile.getSQLTerminator());
		   ESSDisplay.setUpFiles();
		   ESSDisplay.setLanguage(PersFile.getLanguage());
		   ESSDisplay.setDateFormat(PersFile.getDateFormat());
		   ESSDisplay.setDecimal(PersFile.getDecimal());
		   ESSDisplay.setSeparator(PersFile.getSeparator());
		   ESSDisplay.setSummaries("audithistory");
		   
		   GL.setConnection(PersFile.getConnection());
		   GL.setSQLTerminator(PersFile.getSQLTerminator());
		   GL.setLanguage(PersFile.getLanguage());   //Not active in legacy yet
		   GL.setDateFormat(PersFile.getDateFormat());
		   GL.setDecimal(PersFile.getDecimal());
		   GL.setSeparator(PersFile.getSeparator());
		//   GL.setSystemTable(Sys);   {optional for older classes}
		   GL.setUpFiles();

		   ESSDisplay.reset();
		   ESSDisplay.setDenormalizeClient(true);
		   ESSDisplay.set(voucher);
		   ESSDisplay.setReportReferenceName("Voucher");
		   PersFile.setReportViewed(ESSDisplay.getPreviousNumber());
			ess.DB2ESS ESS = ESSDisplay;
		   //if (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1) 
        if (repdate != null) {
          xFlag = true;   
          if (xFlag) { 
            reportCount = reportCount + 1;
			newVoucher = voucher;
		if (!newVoucher.equals(oldVoucher)){%>
         <tr>
			 <td width="100%" <%=backcolor%> align='left' colspan="6">
					<hr/><strong>Report: <%= voucher%></strong>
					<%@ include file = "ScanImageList.jsp" %>
					<br/><strong>CHEQUE DBS BANK / GIRO: </strong><input type="text" <%=backcolor%> style="border: none" readonly value="<%= payement%>"></input>
				</td>
		 </tr>
		<%			
			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
		}%>
		<tr>
			 <td width="13%" <%=backcolor%> align='left'><%=repdate%></td>
			 <td width="15%" <%=backcolor%> align='center'><%=PersFile.getTrim(Reg.myResult.getString("EXPENSE"))%></td>
			 <td width="45%" <%=backcolor%> align='center'><%=PersFile.getTrim(Reg.myResult.getString("EXPENSE.COMMENT"))%></td>
			 <td width="15%" <%=backcolor%> align='center'><div id="amount<%=reportCount%>"><%=PersFile.getTrim(Reg.myResult.getString("EXPENSE.AMOUNT"))%></div></td>
			 <td width="10%" <%=backcolor%> align='center'><div id="gst<%=reportCount%>">0.0</div></td>
			 <td width="3%"  <%=backcolor%> align='left'><input type="checkbox" name="select_this_report" onclick="handleClick(this,<%=reportCount%>,<%=PersFile.getTrim(Reg.myResult.getString("EXPENSE.AMOUNT"))%>,<%=dGSTRate%>);"></input></td>
		 </tr>

<%          xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
			amountTotal = amountTotal + java.lang.Float.parseFloat(PersFile.getTrim(Reg.myResult.getString("EXPENSE.AMOUNT")));
			strTotalAmount = String.format("%.2f",amountTotal);
			oldVoucher = voucher;
          }
        }
		
     } while (Reg.myResult.next());
%>
      </table>
<hr/><br/>
	<table border="0" cellspacing="0" width="90%" align='center'>
		<tr>
			<td width="20%" align='left'><strong>Total amount</strong></td>
			<td width="5%" align='left'>$</td>
			<td width="75%" align='left'><div id="TotalAmount"><%=strTotalAmount%></div></td>
		</tr>
		<tr>
			<td width="20%" align='left'><strong>GST</strong></td>
			<td width="5%" align='left'>$</td>
			<td width="75%" align='left'><div id="gstTotal">0.0</div></td>
		</tr>
		<tr>
			<td width="20%" align='left'><strong>Grand Total</strong></td>
			<td width="5%" align='left'>$</td>
			<td width="75%" align='left'><div id="grandTotal"><%=strTotalAmount%></div></td>
		</tr>
	</table>
<br/>
<hr/>
<br/>
	<table border="0" cellspacing="0" width="90%">
		<tr>
			<td width="50%" align='left'><strong>Requested By:</strong>__________________</td>
			<td width="50%" align='center'><strong>Verified By:</strong>__________________</td>
		</tr>
		<tr>
			<td width="50%" align='left'><strong>Dated Sending out: </strong>__________________</td>
			<td width="50%" align='center'><strong>Received By: </strong>__________________</td>
		</tr>
	</table>
<br/>
<hr/>
<!--<div align="center"><a href="www.elc.com.sg"><u>www.elc.com.sg</u></a></div>-->
<br/>
<%@ include file="StandardBottom.jsp" %>
<%

  } catch (java.lang.Exception ex) {
    Log.println("[500] HistoryReportPrint.jsp java.lang exception possibly voucher : " + voucher);
%>
    </table>
    <strong><em><br>Error in the SQL logic - contact support.<br></em></strong>
<%  
  } //try
  Reg.close();
%>

<% if (!xfound) { %>
<strong><em>
<%= Lang.getString("noRepFou")%><br>
</em></strong>
<% } %>
          
<script type="text/javascript">
	function handleClick(cb,index,amount,gstRate) {
		//var gstRate = 1.07;
		var amountTotal = parseFloat(amount);
		var amountAfterGST = (amountTotal/gstRate).toFixed(2);
		var gstAmount = (amountTotal - amountAfterGST).toFixed(2);
		var amountID = 'amount' + parseInt(index);
		var gstID = 'gst' + parseInt(index);
		var textAmount = cb.checked?amountAfterGST.toString():amountTotal.toString();
		var textGST = cb.checked?gstAmount.toString():"0.0";
		var elemAmount = document.getElementById(amountID);
		elemAmount.innerHTML = textAmount;
		var elemGST = document.getElementById(gstID);
		elemGST.innerHTML = textGST;
		
		gstAmount = cb.checked?gstAmount:(gstAmount * (-1));
		var elemTotalGST = document.getElementById("gstTotal");
		var oldTotalGST = elemTotalGST.innerHTML;
		var newTotalGST = parseFloat(oldTotalGST) + parseFloat(gstAmount);
		elemTotalGST.innerHTML = newTotalGST.toFixed(2).toString();
		
		var elemTotalAmount = document.getElementById("grandTotal");
		var grandTotal = elemTotalAmount.innerHTML;
		var newTotalAmount = parseFloat(grandTotal) - newTotalGST;
		document.getElementById("TotalAmount").innerHTML = newTotalAmount.toFixed(2).toString();
	}
</script>
</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    </head>
    <body>
    <p><big><big><strong><%=PersFile.name%>, <%= Lang.getString("noExpFou")%>
    <% Log.println("[400] HistoryReportPrint.jsp No expense reports where found."); %>
    </strong></big></big></p>
    </body>
    <script>
    //<%= SQLCommand %>//
    </script>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 

%>
<%@ include file="UnScramble.jsp" %>


