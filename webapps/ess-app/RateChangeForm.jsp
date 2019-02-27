<!--
RateChangeForm.jsp - Prints out a conversion form if required - used by AuditReport.jsp
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

assumes bean ESS is defined,

-->
<h2><%= Lang.getString("currencyConOpt") %></h2>
<form name="RateChange" action="<%= PersFile.getWebServer() %>/<%= PersFile.getAppFolder() %>/RateChange.jsp" onSubmit="return FXSubmit(document.RateChange)">
  <input type="hidden" name="voucher" value="">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="ratetype" value>
  <table border="0" cellpadding="2" cellspacing="0" width="90%" class="tableBGColor" style="border: 1px solid">
     <tr>
       <td width="11%"><%= Lang.getLabel("xrate") %></td>
       <td width="30%"><input type="text" name="xrate" size="9" value tabindex="2" onChange="makeRate(document.RateChange.xrate)"><small>(<%= Lang.getString("ENSURE_RATE_IS_CURRENT") %>)</small></td>
     </tr>
     <tr>
       <td width="11%"><%= Lang.getLabel("ratedivisor") %></td>
       <td width="30%"><select name="ratedivisor" size="1" tabindex="3">
         <option selected value="0">Divide for <%= homeCurrency %></option>
         <option value="1">Multiply for <%= homeCurrency %></option>
       </select></td>
     </tr>
     <tr>
       <td width="11%"><%= Lang.getLabel("xdate") %></td>
       <td width="30%"><input type="text" name="xdate" size="13" tabindex="4"><a HREF="javascript:doNothing()" onClick="setDateField(document.RateChange.xdate,'<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html')"><img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" tabindex="5" WIDTH="16" HEIGHT="16"></a><font size="1"><%= Lang.getString("popCal") %></font></td>
     </tr>
     <tr>
       <td width="11%"><%= Lang.getLabel("xsource") %></td>
       <td width="30%"><input type="text" name="xsource" size="36" tabindex="6"></td>
     </tr>
     <tr>
        <td width="11%"></td>
        <td width="30%"><input type="submit" value="<%= Lang.getString("CHANGE_REPORT_CURRENCY") %>" name="Change"></td>
     </tr>
  </table>
</form>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/fx1.js"></script>
<script>

function makeRate (obj) {
  if (!isNaN(obj.value) && !isEmpty(obj.value)) {
    obj.value = format(obj.value,4);
  }
}

function format (expr, decplaces) {
  var sign = "";
  var str;
  var numx = parseFloat(expr); 
  if (numx < 0 ) {
    sign = "-";
    str = "" + Math.round(-1 * numx * Math.pow(10,decplaces));
  } else {
    str = "" + Math.round(numx * Math.pow(10,decplaces));
  }
  while (str.length <= decplaces) {
    str = "0" + str;
  }
  var decpoint = str.length - decplaces;
  return sign + str.substring(0,decpoint) + "." + str.substring(decpoint,str.length);
}

function isEmpty(x) {
  if (x == null || x == "") {
    return true;
  } else {
    return false;
  }
}

function FXSubmit(thisForm) {
  var retVal;
  if (isNaN(thisForm.xrate.value) 
         || !checkdate(thisForm.xdate) 
         || !doDateChkToday(thisForm.xdate)
         || !checkLength(thisForm.xrate, "<%= Lang.getString("xrate") %>", 0) 
         || !checkLength(thisForm.xsource, "<%= Lang.getString("xsource") %>", 2) ) {  //add amount parameter to divorce from exact location  
   
    alert("<%= Lang.getString("ERROR_INVALID_CURRENCY_DATA") %>"); 
    retVal = false;
  } else {
    if (confirm("<%= Lang.getString("CONFIRM_CURRENCY_CHANGE") %>")) {
      var currList = new Array(5);
      currList[0] = [FXFormNames[0],"<%= ESS.getCurrency() %>"]; //units
      currList[1] = [FXFormNames[1],thisForm.xrate.value]; //xrate
      currList[2] = [FXFormNames[2],thisForm.ratedivisor.options[thisForm.ratedivisor.selectedIndex].value]; //ratetype
      currList[3] = [FXFormNames[3],thisForm.xdate.value]; //xdate
      currList[4] = [FXFormNames[4],thisForm.xsource.value];  //xsource
      parent.contents.setDBPair(parent.PersDBase,"currency",currList);
      parent.contents.setDBPair(parent.PersDBase,"last_currency",currList[0][1]);
      parent.contents.setDBPair(parent.WorkDBase,"last_currency",currList[0][1]);
      retVal = true;
    } else {
      retVal = false;
    }
  }
  return retVal;
}

function checkLength(object, fname, nchars) {
        var check = object.value;
        if (check.length > nchars) {
                return true;
        } else
        alert(fname + "<%= Lang.getString("MUST_BE_GREATER_THAN") %>" + nchars + "<%= Lang.getString("characters") %>");
        object.focus();
        object.select();
}

function setCurrency(thisForm,x) {
  var ResultSet = new Array(0);
  ResultSet = parent.contents.getDBSingle(parent.PersDBase,"currency","units",x);
  if (ResultSet.length > 0) {
    thisForm.xrate.value = parent.contents.getDBString(ResultSet[0],"xrate","test");
    thisForm.ratetype.value = parent.contents.getDBString(ResultSet[0],"ratetype","0");
    thisForm.xdate.value = parent.contents.getDBString(ResultSet[0],"xdate","test");
    thisForm.xsource.value = parent.contents.getDBString(ResultSet[0],"xsource","test");
  } else {
    thisForm.xrate.value = "";
    thisForm.ratetype.value = "0";
    thisForm.xdate.value = "";
    thisForm.xsource.value = "";
  }
  thisForm.ratedivisor.selectedIndex = thisForm.ratetype.value; 
}

function arrayIndex(xArray, yString) {
  var k = -1;
  for (i = 0; i < xArray.length; i++) {
    if (xArray[i] == yString) {
        k = i;
        i = xArray.length;
    }
  }
  return k;
}

function setPullDownList(TheForm, Tag, Value) {
     j = 0;
     var x;  // is list text
     var y = Value.length;
     do {
       x = TheForm.elements[Tag].options[j].text;
       if (x.length > y) x = x.substring(0,y);
       if (x == Value) {
          TheForm.elements[Tag].selectedIndex = j;
          j = TheForm.elements[Tag].length;
       }
       j = j + 1;
     } while (j < TheForm.elements[Tag].length); 
}

function setPullDownRateType(TheForm, Tag, Value) {
     j = 0;
     do {
       if (TheForm.elements[Tag].options[j].value == Value) {
          TheForm.elements[Tag].selectedIndex = j;
       }
       j = j + 1;
     } while (j < TheForm.elements[Tag].length); 
}

</script>

