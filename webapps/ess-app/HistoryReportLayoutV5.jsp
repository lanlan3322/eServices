

<% Log.println("[000] custom/PrintHistoryReport.jsp - G/L finished - " + email); %>
<div class="pageBreakInside">
<%=V2ESSDisplay.printTitle(Lang.getString("APP_REPORT"),PersFile.getCompanyName(),false) %>
</div>
<div class="pageBreakInside">
<%= V2ESSDisplay.printHeader() %>
</div>
<br/>
<div class="pageBreakInside">
<%= V2ESSDisplay.printPurpose() %>
</div>
<div class="pageBreakInside">
<%= V2ESSDisplay.printAdvanceItems() %>
<% ess.V5DB2ESS ESS = V2ESSDisplay; %>
<%@ include file="../ScanImageList.jsp" %>
</div>
<div class="pageBreakInside">
<%=V2ESSDisplay.printExpenses() %>
</div>
<div class="pageBreakInside">
 <%= V2ESSDisplay.printExpenseSummary() %>
</div>
<div class="pageBreakInside">
<%= V2ESSDisplay.printDepartSummary() %>
</div>
<br/>
<big>
<div class="pageBreakInside">
<%=V2ESSDisplay.printEApproval() %>
</div>
</big>
<div class="pageBreakInside">
<%=V2ESSDisplay.printAuditInfo() %>
</div>
<br>

<% Log.println("[000] ajax/HistoryReportLayoutV5.jsp - End - " + email); %>



