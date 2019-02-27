
//Based on code originally provided by Robert W. Husted, 1999
//Modifications and additions by Jim Holton, 2001-2010

var calDateFormat    = parent.dateFormat;
var DBCCode = parent;
var CalPDArea = parent;
var selectedLanguage = parent.language;
var dateExtractor = new DateSubstr(calDateFormat);

var inDate;

topBackground    = "white";         // BG COLOR OF THE TOP FRAME
bottomBackground = "white";         // BG COLOR OF THE BOTTOM FRAME
tableBGColor     = "black";         // BG COLOR OF THE BOTTOM FRAME'S TABLE
cellColor        = "lightgrey";     // TABLE CELL BG COLOR OF THE DATE CELLS IN THE BOTTOM FRAME
headingCellColor = "white";         // TABLE CELL BG COLOR OF THE WEEKDAY ABBREVIATIONS
headingTextColor = "black";         // TEXT COLOR OF THE WEEKDAY ABBREVIATIONS
dateColor        = "blue";          // TEXT COLOR OF THE LISTED DATES (1-28+)
focusColor       = "#ff0000";       // TEXT COLOR OF THE SELECTED DATE (OR CURRENT DATE)
hoverColor       = "darkred";       // TEXT COLOR OF A LINK WHEN YOU HOVER OVER IT
fontStyle        = "12pt arial, helvetica";           // TEXT STYLE FOR DATES
headingFontStyle = "bold 12pt arial, helvetica";      // TEXT STYLE FOR WEEKDAY ABBREVIATIONS

bottomBorder  = false;        // TRUE/FALSE (WHETHER TO DISPLAY BOTTOM CALENDAR BORDER)
tableBorder   = 0;            // SIZE OF CALENDAR TABLE BORDER (BOTTOM FRAME) 0=none

var isNav = false;
var isIE  = false;

if (navigator.appVersion.indexOf("MSIE") > -1) {
      isIE = true;
} else {
      isNav = true;
}

buildCalParts();

function CalWinSize(x,y) {
    if (DBCCode.setDBPair) {
      DBCCode.setDBPair(CalPDArea.PersDBase, "calendar-x", "" + x);
      DBCCode.setDBPair(CalPDArea.PersDBase, "calendar-y", "" + y);
    }
}

function setDateField(dateField, xHTML) {
    if (xHTML == null)  xHTML = CalPDArea.webServer + "/" + CalPDArea.webFolder + "/calendar.html";
    calDateField = dateField;
    inDate = dateField.value;  //jh 9/27/03 remember date
    setInitialDate();
    calDocTop    = buildTopCalFrame();
    calDocBottom = buildBottomCalFrame();
    var x = DBCCode.getDBString(CalPDArea.PersDBase, "calendar-x", "210");
    var y = DBCCode.getDBString(CalPDArea.PersDBase, "calendar-y", "230");
    var optionString = "dependent,width=" + x + ",height=" + y + ",title,resizable,titlebar";
    top.newWin = window.open(xHTML,"cal",optionString);
}

function setInitialDate() {
    var thisYear;
    //calDate = new Date(inDate);
    calDate = loadDateObj(inDate);
    if (isNaN(calDate)) {
        calDate = new Date();
    }    
    calDay  = calDate.getDate();
    thisYear = calDate.getFullYear();
    //if (thisYear < 100) {
    //  if (thisYear > 80) {
    //    thisYear += 1900;
    //  } else {
    //    thisYear += 2000;
    //  }
      calDate.setYear(thisYear);
    //}
    calDate.setDate(1);
}


function showCalendar(dateField) {

    setDateField(dateField);

    calDocFrameset = 
        "<HTML><HEAD><TITLE>JavaScript Calendar</TITLE></HEAD>\n" +
        "<FRAMESET ROWS='70,*' FRAMEBORDER='0'>\n" +
        "  <FRAME NAME='topCalFrame' SRC='javascript:parent.opener.calDocTop' SCROLLING='no'>\n" +
        "  <FRAME NAME='bottomCalFrame' SRC='javascript:parent.opener.calDocBottom' SCROLLING='no'>\n" +
        "</FRAMESET>\n";

    top.newWin = window.open("javascript:parent.opener.calDocFrameset", "calWin", winPrefs);
    top.newWin.focus();
}


function buildTopCalFrame() {

    var calDoc =
        "<HTML>" +
        "<HEAD>" +
        "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" +
        "</HEAD>" +
        "<BODY BGCOLOR='" + topBackground + "'>" +
        "<FORM NAME='calControl' onSubmit='return false;'>" +
        "<CENTER>" +
        "<TABLE CELLPADDING=0 CELLSPACING=1 BORDER=0>" +
        "<TR><TD COLSPAN=7>" +
        "<CENTER>" +
        getMonthSelect() +
        "<INPUT NAME='year' VALUE='" + calDate.getFullYear() + "'TYPE=TEXT SIZE=4 MAXLENGTH=4 onChange='parent.opener.setYear()'>" +
        "</CENTER>" +
        "</TD>" +
        "</TR>" +
        "<TR>" +
        "<TD COLSPAN=7>" +
        "<INPUT TYPE=BUTTON NAME='previousYear' VALUE='<<'    onClick='parent.opener.setPreviousYear()'>" +
        "<INPUT TYPE=BUTTON NAME='previousMonth' VALUE=' < '   onClick='parent.opener.setPreviousMonth()'>" +
        "<INPUT TYPE=BUTTON NAME='today' VALUE='" + getJSX("JS_TODAY") + "' onClick='parent.opener.setToday()'>" +
        "<INPUT TYPE=BUTTON NAME='nextMonth' VALUE=' > '   onClick='parent.opener.setNextMonth()'>" +
        "<INPUT TYPE=BUTTON NAME='nextYear' VALUE='>>'    onClick='parent.opener.setNextYear()'>" +
        "</TD>" +
        "</TR>" +
        "</TABLE>" +
        "</CENTER>" +
        "</FORM>" +
        "</BODY>" +
        "</HTML>";

    return calDoc;
}


function buildBottomCalFrame() {       

    var calDoc = calendarBegin;

    month   = calDate.getMonth();
    year    = calDate.getFullYear();


    day     = calDay;

    var i   = 0;

    var days = getDaysInMonth();

    if (day > days) {
        day = days;
    }

    var firstOfMonth = new Date (year, month, 1);

    var startingPos  = firstOfMonth.getDay();
    days += startingPos;

    var columnCount = 0;

    for (i = 0; i < startingPos; i++) {

        calDoc += blankCell;
	columnCount++;
    }

    var currentDay = 0;
    var dayType    = "weekday";

    for (i = startingPos; i < days; i++) {

	var paddingChar = "&nbsp;";

        if (i-startingPos+1 < 10) {
            padding = "&nbsp;&nbsp;";
        }
        else {
            padding = "&nbsp;";
        }

        currentDay = i-startingPos+1;

        if (currentDay == day) {
            dayType = "focusDay";
        }
        else {
            dayType = "weekDay";
        }

        calDoc += "<TD align=center bgcolor='" + cellColor + "'>" +
                  "<a class='" + dayType + "' href='javascript:parent.opener.returnDate(" + 
                  currentDay + ")'>" + padding + currentDay + paddingChar + "</a></TD>";

        columnCount++;

        if (columnCount % 7 == 0) {
            calDoc += "</TR><TR>";
        }
    }

    for (i=days; i<42; i++)  {

        calDoc += blankCell;
	columnCount++;

        if (columnCount % 7 == 0) {
            calDoc += "</TR>";
            if (i<41) {
                calDoc += "<TR>";
            }
        }
    }

    calDoc += calendarEnd;

    return calDoc;
}


function writeCalendar() {

    calDocBottom = buildBottomCalFrame();

    top.newWin.frames['bottomCalFrame'].document.open();
    top.newWin.frames['bottomCalFrame'].document.write(calDocBottom);
    top.newWin.frames['bottomCalFrame'].document.close();
}


function setToday() {

    calDate = new Date();

    var month = calDate.getMonth();
    var year  = calDate.getFullYear();

    top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex = month;

    top.newWin.frames['topCalFrame'].document.calControl.year.value = year;

    writeCalendar();
}


function setYear() {

    var year  = top.newWin.frames['topCalFrame'].document.calControl.year.value;

    if (isFourDigitYear(year)) {
        calDate.setFullYear(year);
        writeCalendar();
    }
    else {
        top.newWin.frames['topCalFrame'].document.calControl.year.focus();
        top.newWin.frames['topCalFrame'].document.calControl.year.select();
    }
}


function setCurrentMonth() {

    var month = top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex;

    calDate.setMonth(month);
    writeCalendar();
}


function setPreviousYear() {

    var year  = top.newWin.frames['topCalFrame'].document.calControl.year.value;

    if (isFourDigitYear(year) && year > 1000) {
        year--;
        calDate.setFullYear(year);
        top.newWin.frames['topCalFrame'].document.calControl.year.value = year;
        writeCalendar();
    }
}


function setPreviousMonth() {

    var year  = top.newWin.frames['topCalFrame'].document.calControl.year.value;
    if (isFourDigitYear(year)) {
        var month = top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex;

        if (month == 0) {
            month = 11;
            if (year > 1000) {
                year--;
                calDate.setFullYear(year);
                top.newWin.frames['topCalFrame'].document.calControl.year.value = year;
            }
        }
        else {
            month--;
        }
        calDate.setMonth(month);
        top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex = month;
        writeCalendar();
    }
}


function setNextMonth() {

    var year = top.newWin.frames['topCalFrame'].document.calControl.year.value;

    if (isFourDigitYear(year)) {
        var month = top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex;

        if (month == 11) {
            month = 0;
            year++;
            calDate.setFullYear(year);
            top.newWin.frames['topCalFrame'].document.calControl.year.value = year;
        }
        else {
            month++;
        }
        calDate.setMonth(month);
        top.newWin.frames['topCalFrame'].document.calControl.month.selectedIndex = month;
        writeCalendar();
    }
}


function setNextYear() {

    var year  = top.newWin.frames['topCalFrame'].document.calControl.year.value;
    if (isFourDigitYear(year)) {
        year++;
        calDate.setFullYear(year);
        top.newWin.frames['topCalFrame'].document.calControl.year.value = year;
        writeCalendar();
    }
}


function getDaysInMonth()  {

    var days;
    var month = calDate.getMonth()+1;
    var year  = calDate.getFullYear();

    if (month==1 || month==3 || month==5 || month==7 || month==8 ||
        month==10 || month==12)  {
        days=31;
    }
    else if (month==4 || month==6 || month==9 || month==11) {
        days=30;
    }
    else if (month==2)  {
        if (isLeapYear(year)) {
            days=29;
        }
        else {
            days=28;
        }
    }
    return (days);
}


function isLeapYear (Year) {

    if (((Year % 4)==0) && ((Year % 100)!=0) || ((Year % 400)==0)) {
        return (true);
    }
    else {
        return (false);
    }
}


function isFourDigitYear(year) {

    if (year.length != 4) {
        top.newWin.frames['topCalFrame'].document.calControl.year.value = calDate.getFullYear();
        top.newWin.frames['topCalFrame'].document.calControl.year.select();
        top.newWin.frames['topCalFrame'].document.calControl.year.focus();
    }
    else {
        return true;
    }
}


function getMonthSelect() {

    if (selectedLanguage == "fr") {
        monthArray = new Array('Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                               'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre');
    }
    else if (selectedLanguage == "de") {
        monthArray = new Array('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
                               'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember');
    }
    else if (selectedLanguage == "es") {
        monthArray = new Array('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                               'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre');
    }
    else {
        monthArray = new Array('January', 'February', 'March', 'April', 'May', 'June',
                               'July', 'August', 'September', 'October', 'November', 'December');
    }

    var activeMonth = calDate.getMonth();

    monthSelect = "<SELECT NAME='month' onChange='parent.opener.setCurrentMonth()'>";

    for (i in monthArray) {
        
        if (i == activeMonth) {
            monthSelect += "<OPTION SELECTED>" + monthArray[i] + "\n";
        }
        else {
            monthSelect += "<OPTION>" + monthArray[i] + "\n";
        }
    }
    monthSelect += "</SELECT>";

    return monthSelect;
}


function createWeekdayList() {
    if (selectedLanguage == "fr") {
        weekdayList  = new Array('Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi');
        weekdayArray = new Array('Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa');
    }
    else if (selectedLanguage == "de") {
        weekdayList  = new Array('Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag');
        weekdayArray = new Array('So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa');
    }
    else if (selectedLanguage == "es") {
        weekdayList  = new Array('Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado')
        weekdayArray = new Array('Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa');
    }
    else {
        weekdayList  = new Array('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
        weekdayArray = new Array('Su','Mo','Tu','We','Th','Fr','Sa');
    }
    var weekdays = "<TR BGCOLOR='" + headingCellColor + "'>";
    for (i in weekdayArray) {
        weekdays += "<TD class='heading' align=center>" + weekdayArray[i] + "</TD>";
    }
    weekdays += "</TR>";
    return weekdays;
}


function buildCalParts() {
    calendarBegin = "";
    calendarEnd = "";
    weekdays = createWeekdayList();
    blankCell = "<TD align=center bgcolor='" + cellColor + "'>&nbsp;&nbsp;&nbsp;</TD>";

    calendarBegin =
        "<HTML>" +
        "<HEAD>" +
        "<STYLE type='text/css'>" +
        "<!--" +
        "TD.heading { text-decoration: none; color:" + headingTextColor + "; font: " + headingFontStyle + "; }" +
        "A.focusDay:link { color: " + focusColor + "; text-decoration: none; font: " + fontStyle + "; }" +
        "A.focusDay:hover { color: " + focusColor + "; text-decoration: none; font: " + fontStyle + "; }" +
        "A.weekday:link { color: " + dateColor + "; text-decoration: none; font: " + fontStyle + "; }" +
        "A.weekday:hover { color: " + hoverColor + "; font: " + fontStyle + "; }" +
        "-->" +
        "</STYLE>" +
        "</HEAD>" +
        "<BODY BGCOLOR='" + bottomBackground + "'" +
        "<CENTER>";

        if (isNav) {
            calendarBegin += 
                "<TABLE CELLPADDING=0 CELLSPACING=1 BORDER=" + tableBorder + " ALIGN=CENTER BGCOLOR='" + tableBGColor + "'><TR><TD>";
        }

        calendarBegin +=
            "<TABLE CELLPADDING=0 CELLSPACING=1 BORDER=" + tableBorder + " ALIGN=CENTER BGCOLOR='" + tableBGColor + "'>" +
            weekdays +
            "<TR>";


    calendarEnd = "";

        if (bottomBorder) {
            calendarEnd += "<TR></TR>";
        }

        if (isNav) {
            calendarEnd += "</TD></TR></TABLE>";
        }

        calendarEnd +=
            "</TABLE>" +
            "</CENTER>" +
            "</BODY>" +
            "</HTML>";
}


function jsReplace(inString, find, replace) {

    var outString = "";

    if (!inString) {
        return "";
    }

    if (inString.indexOf(find) != -1) {
        t = inString.split(find);

        return (t.join(replace));
    }
    else {
        return inString;
    }
}


function doNothing() {
}


function makeTwoDigit(inValue) {

    var numVal = parseInt(inValue, 10);

    if (numVal < 10) {

        return("0" + numVal);
    }
    else {
        return numVal;
    }
}


function returnDate(inDay)
{

    calDate.setDate(inDay);

    var day           = calDate.getDate();
    var month         = calDate.getMonth()+1;
    var year          = calDate.getFullYear();
    var monthString   = monthArray[calDate.getMonth()];
    var monthAbbrev   = monthString.substring(0,3);
    var weekday       = weekdayList[calDate.getDay()];
    var weekdayAbbrev = weekday.substring(0,3);

    outDate = calDateFormat;

    if (calDateFormat.indexOf("DD") != -1) {
        day = makeTwoDigit(day);
        outDate = jsReplace(outDate, "DD", day);
    }
    else if (calDateFormat.indexOf("dd") != -1) {
        outDate = jsReplace(outDate, "dd", day);
    }

    if (calDateFormat.indexOf("MM") != -1) {
        month = makeTwoDigit(month);
        outDate = jsReplace(outDate, "MM", month);
    }
    else if (calDateFormat.indexOf("mm") != -1) {
        outDate = jsReplace(outDate, "mm", month);
    }

    if (calDateFormat.indexOf("yyyy") != -1) {
        outDate = jsReplace(outDate, "yyyy", year);
    }
    else if (calDateFormat.indexOf("yy") != -1) {
        var yearString = "" + year;
        var yearString = yearString.substring(2,4);
        outDate = jsReplace(outDate, "yy", yearString);
    }
    else if (calDateFormat.indexOf("YY") != -1) {
        outDate = jsReplace(outDate, "YY", year);
    }

    if (calDateFormat.indexOf("Month") != -1) {
        outDate = jsReplace(outDate, "Month", monthString);
    }
    else if (calDateFormat.indexOf("month") != -1) {
        outDate = jsReplace(outDate, "month", monthString.toLowerCase());
    }
    else if (calDateFormat.indexOf("MONTH") != -1) {
        outDate = jsReplace(outDate, "MONTH", monthString.toUpperCase());
    }

    if (calDateFormat.indexOf("Mon") != -1) {
        outDate = jsReplace(outDate, "Mon", monthAbbrev);
    }
    else if (calDateFormat.indexOf("mon") != -1) {
        outDate = jsReplace(outDate, "mon", monthAbbrev.toLowerCase());
    }
    else if (calDateFormat.indexOf("MON") != -1) {
        outDate = jsReplace(outDate, "MON", monthAbbrev.toUpperCase());
    }

    if (calDateFormat.indexOf("Weekday") != -1) {
        outDate = jsReplace(outDate, "Weekday", weekday);
    }
    else if (calDateFormat.indexOf("weekday") != -1) {
        outDate = jsReplace(outDate, "weekday", weekday.toLowerCase());
    }
    else if (calDateFormat.indexOf("WEEKDAY") != -1) {
        outDate = jsReplace(outDate, "WEEKDAY", weekday.toUpperCase());
    }

    if (calDateFormat.indexOf("Wkdy") != -1) {
        outDate = jsReplace(outDate, "Wkdy", weekdayAbbrev);
    }
    else if (calDateFormat.indexOf("wkdy") != -1) {
        outDate = jsReplace(outDate, "wkdy", weekdayAbbrev.toLowerCase());
    }
    else if (calDateFormat.indexOf("WKDY") != -1) {
        outDate = jsReplace(outDate, "WKDY", weekdayAbbrev.toUpperCase());
    }

    inDate = outDate;  //jh 09/27/2003 remember date
    calDateField.value = outDate;

    calDateField.focus();
    
    if ((typeof(startCalDate) != "undefined") && (startCalDate != null)) calendarReturn(outDate);  //jh 2007-11-05
    top.newWin.close()
}


// Date format check items added...
function checkdate(objName, bottomLimit) {
        if (bottomLimit == null) bottomLimit = genericDateStr("01", "01", "2012");  //
        var retVal = false;
        //var datefield = objName;
        if (chkdate(objName) == false) {
           alert(getJSX("JSC_FORMAT") + " " + calDateFormat + getJSX("JSC_PLEASE") + " (err = " + err + ")");
           objName.focus();
           //datefield.select();
        } else {
           if (isDateLess(bottomLimit,objName.value)) {        
             retVal = true;
           } else {
             alert(getJSX("JSC_OLD"));
             // alert(getJSX("JSC_OLD") + " " +  bottomLimit);
             var output = ''; for (property in objName) {   output += property + ': ' + objName[property]+'; '; }  
             Log.println("checkdate",output);
             // Log.println("checkdate","caller is " + arguments.callee.caller.toString()); 
             Log.println("checkdate",stacktrace());
             objName.focus();
           }
        }
        return retVal
}
var err = 0;
function chkdate(objName) {
        //var strDatestyle = "US";  //United States date style
        //var strDatestyle = "EU";  //European date style
        var strDate;
        var strDateArray;
        var strDay;
        var strMonth;
        var strYear;
        var intday;
        var intMonth;
        var intYear;
        var booFound = false;
        var datefield = objName;
        var strSeparatorArray = new Array("-"," ","/",".");
        var intElementNr;
        err = 0;
        strDate = datefield.value;
        if (strDate.length < 1) {
                return true;
        }
        if (strDate.length > 5) {
            strDay = getDate(strDate);    //jh 2010-01-25
            strMonth = getMonth(strDate);
            strYear = getYear(strDate);
        } else {
            return false;
        }
        if (strYear.length == 2) {   
           if (strYear > "80") {
              strYear = '19' + strYear;
           } else {
              strYear = '20' + strYear;
           }
        }
        if (strYear.length == 1 || strYear.length ==3 || strYear.length > 4) {
                return false;
        }
 
        intday = parseInt(strDay, 10);
        if (isNaN(intday)) {
                err = 2;
                return false;
        }
        intMonth = parseInt(strMonth, 10);
        if (isNaN(intMonth)) {
                for (i = 0;i<12;i++) {
                        if (strMonth.toUpperCase() == strMonthArray[i].toUpperCase()) {
                                intMonth = i+1;
                                //strMonth = strMonthArray[i];
                                i = 12;
                        }
                }
                if (isNaN(intMonth)) {
                        err = 3;
                        return false;
                }        }
        intYear = parseInt(strYear, 10);
        if (isNaN(intYear)) {
                err = 4;
                return false;
        }
        if (intMonth>12 || intMonth<1) {
                err = 5;
                return false;
        }
        if ((intMonth == 1 || intMonth == 3 || intMonth == 5 || intMonth == 7 || intMonth == 8 || intMonth == 10 || intMonth == 12) && (intday > 31 || intday < 1)) {
                err = 6;
                return false;
        }
        if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && (intday > 30 || intday < 1)) {
                err = 7;
                return false;
        }
        if (intMonth == 2) {
                if (intday < 1) {
                        err = 8;
                        return false;
                }
                if (LeapYear(intYear) == true) {
                        if (intday > 29) {
                                err = 9;
                                return false;
                        }
                }
                else {
                        if (intday > 28) {
                                err = 10;
                                return false;
                        }
                }
        }
        datefield.value = genericDateStr("" + intMonth, "" + intday, "" + strYear);  //jh 2010-01-25
        return true;
}
function LeapYear(intYear) {
        if (intYear % 100 == 0) {
                if (intYear % 400 == 0) { return true; }
        }
        else {
                if ((intYear % 4) == 0) { return true; }
        }
        return false;
}

function doDateCheck(from, to) {
//pass in values - future pass in the obj
  
  var begDateObj = new HTMLElementSimulation(from);
  var endDateObj = new HTMLElementSimulation(to);
  var retVal = false;
  var ndays = 100;
  if (checkdate(begDateObj) && checkdate(endDateObj))
  {
    if (isDateLess(from, to)) {
     if (dateNotGreaterDays(endDateObj, ndays)) {  
        retVal = true;
     } 
    } else {
     if (from == "" || to == "") { 
      alert(getJSX("JSC_BOTH"));
     } else { 
      alert(getJSX("JSC_AFTER"));
     }
    }
  }
  return retVal;
}

function HTMLElementSimulation(dateString)
{
  this.value = dateString;
  this.focus = function () { };
}

function isDateLess(less, greater) {
//pass in value
   var xless = loadDateObj(less);           //jh 2010-01-25
   var xgreater = loadDateObj(greater);
  // var nless = xless.getTime();
  // var ngreater = xgreater - xgreater.getTime();
  // var xless = Date.parse(less);
  // var xgreater = Date.parse(greater)
  //if (nless.length < ngreater.length || ((nless.length == ngreater.length) && (nless <= ngreater)) ) {
 
  if (xless <= xgreater) {
    return true;
  } else {
    return false;
  }
}

function doDateChkToday(x) {
//pass in the obj - only good for screen check
  var xdate = loadDateObj(x.value);           //jh 2010-01-25
  var currentDate = new Date();
//  if (Date.parse(x.value) <= currentDate) {
  if (xdate <= currentDate) {
    return true;
  } else {
    alert(getJSX("JSC_POST"));
    x.focus();
    return false;
  }
}


function doBetweenChk(rDate, from, to) {
//pass in the .value or string - good for background date check as well as screen
  xDate = loadDateObj(rDate);   //jh 2010-01-25
  xfrom = loadDateObj(from);
  xto = loadDateObj(to);

  if ((xDate <= xto) && (xfrom <= xDate)) {
    return true;
  } else {
    if (from == "" || to == "") { 
      alert(getJSX("JSC_ALL"));
    } else { 
      alert(getJSX("JSC_BETWEEN"));
    }
    return false;
  }
}

function dateNotGreaterDays(x, ndays) {
  var retVal = checkdate(x);
  if (retVal){
    var checkDate = new Date();
    checkDate = Date.parse(checkDate.toString()) + (ndays * 86400000);  //number is milliseconds in a day
    checkDate = Date(checkDate);                //??
    var rDate = loadDateObj(x.value);           //jh 2010-01-25
    if (rDate >= checkDate) {
      alert(getJSX("JSC_FUTURE1") + " " + ndays + " " + getJSX("JSC_FUTURE2"));
      if (x.focus) x.focus();
      retVal = false;
    }
  }
  return retVal;
}

function doPurpDateChk(rDate,rXref) {
  var resultItem = parent.contents.getResultWhere(parent.contents.HeadList,"xref",rXref);
  if (resultItem != null) {
    var beg = parent.contents.getItemValue(resultItem,"begdate");
    var end = parent.contents.getItemValue(resultItem,"enddate");
    return doBetweenChk(rDate,beg,end);
  } else {
    alert(getJSX("JSC_PURPOSE"));
    return false;
  }
}

function getPurpDate(rXref,cDate) {
  if (!cDate) cDate = "begdate";
  if (!rXref) {
    rXref = parent.defPurpose;
  } else {
    parent.defPurpose = rXref;
  }
  var resultItem = parent.contents.getResultWhere(parent.contents.HeadList,"xref",rXref);
  if (resultItem == null) resultItem = parent.contents.HeadList[parent.contents.HeadList.length - 1];
  return parent.contents.getItemValue(resultItem,cDate);  
}


function smallDateCheck(obj) {  //need to pass in an obj - see HTMLElementSimulation() for simulation if needed
  var sdate = obj.value;
  var oneChar;
  var newDate = parent.dateFormat;
  var looksOK = true;
  var dateObj;
  if ((sdate.indexOf("/") == -1) && (sdate.length > 3) && (sdate.length < 9)) { 
    for (var i = 0; i < sdate.length; i++) {
      oneChar = sdate.substring(i,i+1);
      if (oneChar < "0" || oneChar > "9") {
        looksOK = false;
        i = sdate.length;
      }    
    }
    if (looksOK) {
      if (sdate.length == 4) {
         dateObj = new Date();
         newDate = genericDateStr(sdate.substring(0,2),sdate.substring(2,4),dateObj.getFullYear());
       } else if (sdate.length == 5) {
         dateObj = new Date();
         newDate = genericDateStr(sdate.substring(0,1),sdate.substring(1,3),dateObj.getFullYear());                 
      } else if (sdate.length == 7) {
         newDate = genericDateStr(sdate.substring(0,1),sdate.substring(1,3),sdate.substr(3));                 
      } else { 
         newDate = genericDateStr(sdate.substring(0,2),sdate.substring(2,4),sdate.substr(4));                 
      }
    }
    obj.value = newDate;
  }
  return looksOK;
}

function genericDateStr(month, day, year)
{
    var newDate = calDateFormat;     //same as parent.dateFormat
    normalMonth = "0" + month;
	normalMonth = normalMonth.substr(normalMonth.length - 2,2);
    normalDay = "0" + day;
	normalDay = normalDay.substr(normalDay.length - 2,2);
    newDate = newDate.replace(/MM/,"" + normalMonth);  //can also use reg exp /MM/g for global replace
    newDate = newDate.replace(/dd/,"" + normalDay);
    newDate = newDate.replace(/yyyy/,"" + year);
    return newDate;
}

function loadDateObj(dateStr){   //need a well formatted date for the locale
   var dateObj = new Date();
   if (dateStr != null) {
      var monthValue = parseInt(getMonth(dateStr),10) - 1;
      
      var dayValue = parseInt(getDate(dateStr),10);
      var yearValue = parseInt(getYear(dateStr,10));
      dateObj.setMonth(monthValue);
      dateObj.setDate(dayValue);
      dateObj.setYear(yearValue);
   }
   return dateObj
}   

function getMonth(dateStr) {   
   return dateRemoveLeadZero(getDateSubStr(dateStr,"MM")) ;
}

function getDate(dateStr) {
   return dateRemoveLeadZero(getDateSubStr(dateStr,"dd"));
}
      
function getYear(dateStr) {
   return getDateSubStr(dateStr,"yyyy");
}

function getDateSubStr(dateStr,itemStr) {
   return dateExtractor.getSubstr(dateStr,itemStr);
} 

function dateRemoveLeadZero(x) {
  var retVal;
  if (x.substr(0,1) == "0") {
     retVal = x.substr(1);
  } else {
     retVal = x;
  }
  return retVal;   
}

function DateSubstr(strDateFormat) {   //object - used here to create the dateExtractor used in the getDate, getYear... functions
    var strDelimitor;
    var strSeparatorArray = new Array(" ","/","-",".");
    var strPositionArray;
        
    for (var intElementNr = 0; intElementNr < strSeparatorArray.length; intElementNr++) 
	{
        if (strDateFormat.indexOf(strSeparatorArray[intElementNr]) != -1) {
		    strDelimitor = strSeparatorArray[intElementNr];
            strPositionArray = strDateFormat.split(strDelimitor);
			intElementNr = strSeparatorArray.length;
        }
    }
    this.getSubstr = function (dateStr,itemStr)
	{
    
	    var iPosition;
		var retStr = "";
	    for (var i = 0; i < strPositionArray.length; i++)
		{
		    if (itemStr.indexOf(strPositionArray[i]) == 0)  //finding "MM", "dd", etc. cell for order
	        {
				for (var j = 0; j < i; j++)
				{
					dateStr = dateStr.substring(dateStr.indexOf(strDelimitor) + 1);
				}
				iPosition = dateStr.indexOf(strDelimitor);
				if (iPosition != -1) 
				{
					retStr = dateStr.substring(0, iPosition);
				} else {
					retStr = dateStr;
                }
				i = strPositionArray.length;
			}
		}
		return retStr;
	}
}   

function stacktrace()
{
 try {
 re = /function\W+([\w-]+)/i;

 var f = arguments.callee;
 var s = "";
 while (f)
 {
  s += (re.exec(f))[1] + '('; 

  for (i = 0; i < f.arguments.length - 1; i++)
  {
   s += "'" + f.arguments[i] + "', ";
  }

  //if (arguments.length > 0)
  //{
  // s += "'" + f.arguments[i] + "'";
  //}

  s += "); ";

  f = f.arguments.callee.caller;
 }
 } catch (e) {
   s = "(trace not available)";
 }
 return s;
}


