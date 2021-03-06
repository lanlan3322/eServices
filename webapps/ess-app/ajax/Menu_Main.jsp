<%@ page contentType="text/html" %>
<!-- The calling program needs to support SystemDOM and PersFile-->
<script>
function ESSMenu() {
 
  this.M = new Array();
  this.voucher = "";
  this.voucherViewed = "";

  this.M[0] = "<li><a href=\"javascript: parent.HideAttendance();void parent.NewieIfNotSaved(webServer + '/' + webFolder + '/' + language + '/' + '<%= PersFile.getEntryScreen() %>')\" title=\"<%= Lang.getString("start_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butClaimNR.png' /></a></li>";
  this.M[1] = "<li><a href=\"javascript: void parent.loadHTMLScreenAJAX('<%= PersFile.getEntryScreen() %>')\" title=\"<%= Lang.getString("current_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butLeaveNR.png' /></a></li>";
  this.M[2] = "<li><a href=\"javascript: parent.HideAttendance();void parent.loadHTMLScreenAJAX('start_leave.html')\" title=\"<%= Lang.getString("leave_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butLeaveNR.png' /></a></li>";
  this.M[3] = "<li><a href=\"javascript: parent.HideAttendance();void parent.PersWithDBase(parent.defaultApps + 'ajax/Inventory.jsp?downlevel=','approvallevel','1')\" title=\"<%= Lang.getString("inventory_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butInventoryNR.png' /></a></li>";
  this.M[4] = "<li><a id=\"approvalLink\" href=\"javascript: void parent.loadHTMLScreenAJAX('submitWithGuide.html')\" title=\"<%= Lang.getString("submit_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butSubmitNR.png' /></a></li>";
  this.M[5] = "<li><a href=\"javascript: void parent.PersWindow(parent.defaultApps + 'ajax/receipts/UploadSelect.jsp?viewed=' + myESSMenu.voucherViewed)\" title=\"<%= Lang.getString("attachReceipts_desc") %>\"><%= Lang.getString("attachReceipts") %></a></li>";
  this.M[6] = "<li><a href=\"javascript: parent.HideAttendance();void parent.PersWithDBase(parent.defaultApps + 'ajax/ApproveList.jsp?downlevel=','approvallevel','1')\" title=\"<%= Lang.getString("approve_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butApprovalNR.png' /></a></li>";
  this.M[7] = "<li><a href=\"javascript: parent.HideAttendance();void parent.PersWindow(parent.defaultApps + 'ajax/HistoryList.jsp')\"><span class=\"ExpenseLink\" title=\"<%= Lang.getString("previous_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butHistoryNR.png' /></a></li>";
  this.M[8] = "<li><a href=\"javascript: parent.HideAttendance();void parent.loadHTMLScreenAJAX('about.html')\" title=\"<%= Lang.getString("product_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butHelpNR.png' /></a></li>";
  this.M[9] = "<li><a href=\"javascript: parent.ShowAttendance();void parent.loadHTMLScreenAJAX('attendance_edit.html')\" title=\"<%= Lang.getString("attendance_desc") %>\"><img src='<%= PersFile.getWebServer() %>/<%= essWebFolder %>/images/butAttendanceNR.png' /></a></li>";
  this.M[10] = "<li><a href=\"javascript: void alert(Log.display())\">Show-Log</a></li>";

  this.set = function(arr) {
    var x = "";
    var spacer = ""
    for (var i = 0; i < arr.length; i++)
    {
        x = x + spacer + arr[i];
        spacer = "";      
    }
    document.getElementById("essmenu").innerHTML = x;
  } 
  this.setAll = function() {
     this.setReport();//this.set(this.M);
  }
  this.setReport = function() {
  // base menu when no report is present in memory - Maybe change name to setNoReport
     this.set(new Array(this.M[0],this.M[2],this.M[3],this.M[6],this.M[9],this.M[7],this.M[8]));
  }
  this.setNewReport = function() {
	  this.setReport();
  // menu when a report is being edited
     /*if (parent.getNameValue(parent.Header,"reference") != "" ) 
     {
          this.set(new Array(this.M[0],this.M[2],this.M[3],this.M[4],this.M[6],this.M[7],this.M[5],this.M[8]));
          this.voucherViewed = parent.getNameValue(parent.Header,"reference");
     } else
     {
          this.set(new Array(this.M[0],this.M[2],this.M[3],this.M[4],this.M[6],this.M[7],this.M[8]));
     }*/
  }
  this.setMenu = function() {
	  this.setReport();
  // used when a report is in memory but when on another screen
     //this.set(new Array(this.M[0],this.M[1],this.M[2],this.M[6],this.M[7],this.M[8]));   //removed 3 and 4, save and submit
  }  
  this.setReceiptNewReport = function(x) {
	  this.setReport();
  // Only allows a new report - used if a report is not in memory
     /*this.set(new Array(this.M[0],this.M[2],this.M[6],this.M[7],this.M[5],this.M[8]));
     this.voucher = x;
     this.voucherViewed = x;*/
  }
  this.setReceiptMenu = function(x) {
	  this.setReport();
  // x is the voucher number of a report
     /*this.set(new Array(this.M[0],this.M[1],this.M[2],this.M[6],this.M[7],this.M[5],this.M[8]));  //removed 3 and 4, save and submit
     this.voucher = x;
     this.voucherViewed = x;*/
  }
}

var myESSMenu = new ESSMenu();
myESSMenu.setReport();


function testLog() {  //Used for debugging JS, can be removed in production

   this.x = "";
   this.logIsOn = <%= SystemDOM.getDOMTableValueFor("configuration","xreportlog","true") %>;  //later set to false via the system.xml via the user class
   if (!this.logIsOn) this.x = "<%= Lang.getString("JAVASCRIPT_LOGISOFF","Log recording is turned off") %>";
   
   this.println = function(y,z)
   {
      if (this.logIsOn) this.x = this.x + "<br>[" + y + "]==>" + z;
   }
   
   this.printForSure = function(y,z)
   {
      this.x = this.x + "<br>[" + y + "]==>" + z;
   }
   
   this.display = function()
   {
      this.println("testLog","Ending Log");
      document.getElementById("main").innerHTML = this.x;
      switchScript("shared/blank.js");
      this.x = "";
      this.println("User Agent",navigator.appVersion);
   }
}
var Log = new testLog();
</script>
