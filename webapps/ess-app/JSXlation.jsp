<%--
JSXlation.jsp - Produces the js used for editing purposes
Copyright (C) 2010 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" /> 
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<%     
Lang.setLanguage(PersFile.getLanguage());
String delimitor = ",";
String JSXLationTable = "[";
JSXLationTable = JSXLationTable + createPair("JS_REPORT_COPIED", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CANNOT_PROCEED1", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_RESUBMIT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CANNOT_PROCEED2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CANNOT_PROCEED3", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_NO_CHANGES", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CANNOT_PROCEED4", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_LOAD_ERROR", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_TRANSWINDOW", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_DELETE?", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_DEL_RECEIPTS", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_DEL_SPLIT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_UPDATE_ERROR", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_INVALID_BROWSER", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_NO_REPORT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_PROCESSING", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_SAFESTORE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_NO_AJAX", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JS_ATTENDEE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_FORMAT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_PLEASE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_OLD", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_BOTH", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_AFTER", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_POST", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_ALL", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_BETWEEN", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_FUTURE1", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_FUTURE2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSC_PURPOSE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_FX_FLD", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CHECKED1", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_CHECKED2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_SUBLIST", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_NUMERIC", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_AMOUNT0", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_PERS0", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_LESS", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_INPUT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_BLANK", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_ALL", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_STRING", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_NUMERIC", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_LIST", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_NUMERIC2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_GREATER", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_LESS", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_MISSING", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_SHORT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_LONG", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_REQ", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_LIMIT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSV_CHAR", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_LOGOUT", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JS1_NOT_SAVED", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_NEW_REPORT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_MAKE_COPY", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP1", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP3", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP4", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP5", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS1_REP6", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("expenseRepSelList", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("persnum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("lookUp", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("reportStatus", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("previousRefNum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("centralRefNum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("companyCode", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("beginningDate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("endingDate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("orderBy", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectCentralRef", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectSubmissionDateAsc", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectSubmissionDateDes", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectReportStatus", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectPersnum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectPreviousRef", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butDisplayList", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("instructions", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectStat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("enterPerNum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("enterDatVal", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("clickDisBut", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("hello", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("audit", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("editAudit", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("reportSel", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("process", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("releasePay", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("logout", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("checkedRepPro", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("New", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Forwarded", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Forwarded_2nd", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Reviewed", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Approved", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Rejected", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Manager_Reject", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Audited", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Pending", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Pending2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Paid", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Complete", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("All", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("reportHedInf", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("correctIt", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("name", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("phone", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("location", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("departement", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("reportDate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("comment", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("receiptsRec", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("weekEnd", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("vehiclleNo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("dateSer", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("reportCur", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("enterOdoInf", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("start2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("finish", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("total", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("business", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("returnRepDis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("accessCenDatEmp", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectLasNamSta", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butOkAcc", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butReset", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butSea", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("receiptMaj", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("refer", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("receiptInt", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("receiptDate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("currency", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectCur", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("foreignAmo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("paidBy", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("merchant", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("newMer", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("checkingDat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("lodgingOnl", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("newLocation", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("expenseAccLis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("expenses", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("remainingDis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("expdate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("charge", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("purpose", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("attendeeLis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("personal", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("departmentNum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("depart", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Yes", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("No", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butRemove", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butNew", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butUpdateExpLis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butUpdateRepRec", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("mileageCla", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("date", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("rate", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("setProRat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("amount", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("purposeVis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("fromLoc", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("toLoc", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butUpdateRepMilCla", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("advance", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("advanceIssDat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("advanceAmo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("advanceRefNum", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("butAddAdvRep", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("genericSimDatInq", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("simpleDatInq", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("reportRun", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("firstDat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("secondDat", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("fieldOne", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("fieldTwo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("displayLis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectTypRep", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("enterReqDatVal", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("clickDisLisBut", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("simpleInq", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("userSea", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("useCauAllUse", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("departmentSea", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("selectDepSta", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("personnelNumSel", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("last", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("first", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("persNo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("userLis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("useSelLinUpdScr", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("departementSel", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("glMap", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("billable", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JSS_NEED_REASON", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_CORRECT_REPORT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_PROCESSING", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_NEED_ATTS", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_SELECT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_NEED_CMT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_INV_RATE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_FROM_REQ", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_TO_REQ", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_HOTEL_EDIT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_HOTEL_CREATE", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JSS_CANCEL", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_DELETE_LINE", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JSS_CANCEL_DONE", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("clientno", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("client", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("newClient", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("returnRepDis", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("updateWithPurpose", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("newAcctProj", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("add2UrList", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("project", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("title", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("cancel", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("contactPerson", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("remark", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("billExpenses", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("email_audit_subject", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("email_audit_notify", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("email_approver_notify", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("submit_screen_msg", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("expensePur", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("miles", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Miles", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Kilometers", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("stepNo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("expenseType", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("menuCon", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JS_TODAY", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("REC_UPL_SEARCH", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JS_THE_END", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("okRef", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("Cost", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Gallons", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Pers_Miles", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("Pers_Kms", Lang);

JSXLationTable = JSXLationTable + delimitor + createPair("JS2_ODO_ERROR1", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS2_ODO_ERROR2", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_ODO_ADD", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("JS_ODO_DEDUCT", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("fromOdo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("toOdo", Lang);
JSXLationTable = JSXLationTable + delimitor + createPair("view", Lang);
JSXLationTable = JSXLationTable + "]";
%>
var JSXlationTable = <%= JSXLationTable %>;

function getJSX(x) {
  y = getNameValue(JSXlationTable,x);
  if (y == "") y = x;
  return y;
}
<%! 
private String createPair(String label, ess.Language Lang) {
  String xlate = Lang.getDataString(label);
  return "[\"" + label + "\",\"" + xlate + "\"]";
}
%>     
