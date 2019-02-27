function screenLoad() {
	
	var x = document.getElementById("about_name");
	x.innerHTML = parent.getNameValue(parent.myHeader, "name")
	var x = document.getElementById("about_pers_num");
	x.innerHTML = parent.getNameValue(parent.myHeader, "persnum")
	var x = document.getElementById("guideline");
	var depart = parent.getNameValue(parent.myHeader, "depart");
	if(depart.indexOf("PWD") > -1){
		x.innerHTML = "<div id='guideline'><a href='/ess-app/POWERdrive_HR Guide.pdf'>HR Guideline</a></div>";
	}
	else if(depart.indexOf("ELCS") > -1){
		x.innerHTML = "<div id='guideline'><a href='/ess-app/eLCs_HR Guide.pdf'>HR Guideline</a></div>";
	}
	
   return true;
}

function screenUnload() {
  return true;
}
