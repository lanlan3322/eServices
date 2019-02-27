

<% Log.println("[000] custom/PrintHistoryReport.jsp - G/L finished - " + email); %>
<div class="pageBreakInside">
<%=ESSDisplay.printTitle(Lang.getString("APP_REPORT"),PersFile.getCompanyName(),false) %>
</div>
<div class="pageBreakInside">
<%= ESSDisplay.printHeader() %>
</div>
<br/>
<div class="pageBreakInside">
<%= ESSDisplay.printPurpose() %>
</div>
<div class="pageBreakInside">
<%= ESSDisplay.printAdvanceItems() %>
<% essCustom.StHDB2ESS ESS = ESSDisplay; %>
<%@ include file="../ScanImageList.jsp" %>

</div>
<div class="pageBreakInside">
<%=ESSDisplay.printExpenses() %>
</div>
<div class="pageBreakInside">
 <%= ESSDisplay.printExpenseSummary() %>
</div>
<br/>
<big>
<div class="pageBreakInside">
<%=ESSDisplay.printEApproval() %>
</div>
</big>
<div class="pageBreakInside">
<%=ESSDisplay.printAuditInfo() %>
</div>
<br>

<% Log.println("[000] custom/PrintHistoryReport.jsp - End - " + email); %>



