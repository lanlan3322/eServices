// instantCompany.js
// Copyright 2008,2011 R. James Holton, All rights reserved

function FillForm() {
}

var dupFlagOK = true;
function updateValues() {
  retVal = true;
  with (document.forms[0])
  {
    if (AGREE.selectedIndex == 0)
    {
       alert("You must agree to the user agreement and disclaimer");
       retVal = false;
    }
    if (PHONE.value.length < 9)
    {
       alert("You must supply a valid phone number");
       retVal = false;
    }
  
    if (DESCRIP.value.length < 3)
    {
       alert("Company name must be greater than 2 characters");
       retVal = false;
    }
    if (FNAME.value.length < 2)
    {
       alert("You must specify your first name");
       retVal = false;
    }
    if (LNAME.value.length < 2)
    {
       alert("You must specify your last name");
       retVal = false;
    }
    if (EMAIL.value.length < 7 || EMAIL.value.indexOf("@") == -1)
    {
       alert("Your email address is not valid");
       retVal = false;
    }
    if (FNAME_MGR.value.length < 2)
    {
       alert("You must specify the first name of the approving manager");
       retVal = false;
    }
    if (LNAME_MGR.value.length < 2)
    {
       alert("You must specify the last name of the approving manager");
       retVal = false;
    }
    if (EMAIL_MGR.value.length < 7 || EMAIL.value.indexOf("@") == -1)
    {
       alert("The approving manager's email address is not valid");
       retVal = false;
    }
    if (EMAIL_1.value.length > 0 && (EMAIL_1.value.indexOf("@") == -1 || FNAME_1.value.length < 2 || LNAME_1.value.length < 2 ))
    {
       alert("Reporter 1 information is not filled out correctly");
       retVal = false;
    }
    if (EMAIL_2.value.length > 0 && (EMAIL_2.value.indexOf("@") == -1 || FNAME_2.value.length < 2 || LNAME_2.value.length < 2 ))
    {
       alert("Reporter 2 information is not filled out correctly");
       retVal = false;
    }
    if (EMAIL_3.value.length > 0 && (EMAIL_3.value.indexOf("@") == -1 || FNAME_3.value.length < 2 || LNAME_3.value.length < 2 ))
    {
       alert("Reporter 3 information is not filled out correctly");
       retVal = false;
    }
  }
  return retVal;
}

function moveInfo(x,y) {
   if (alltrim(y.value) == "") y.value = x.value;
}

function alltrim(arg) {
  return ltrim(rtrim(arg));
}

function rtrim(arg) {
  var trimvalue = "";
  var arglen = arg.length;
  if (arglen < 1) return trimvalue;
  var lastpos = -1;
  var i = arglen;
  while (i >= 0) {
    if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
      lastpos = i;
      break;
    }
    i--;
  }
  trimvalue = arg.substring(0,lastpos+1);
  return trimvalue;
}


function ltrim(arg) {
  var trimvalue = "";
  var arglen = arg.length;
  if (arglen < 1) return trimvalue;
  var i = 0;
  pos = -1;
  while (i < arglen) {
    if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
      pos = i;
      break;
    }
    i++;
  }
  trimvalue = arg.substring(pos);
  return trimvalue;
}



