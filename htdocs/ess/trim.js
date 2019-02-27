
function trim(arg,func) {
	var trimvalue = "";
        if (func == null) func = "both"

	arglen = arg.length;
	if (arglen < 1) return trimvalue;

	if (func == "left" || func== "both") {
		i = 0;
		pos = -1;
		while (i < arglen) {
			if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
				pos = i;
				break;
			}
			i++;
		}
	}

	if (func == "right" || func== "both") {
		var lastpos = -1;
		i = arglen;
		while (i >= 0) {
			if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
				lastpos = i;
				break;
			}
			i--;
		}
	}

	if (func == "left") {
			trimvalue = arg.substring(pos,arglen-1);
		}

	if (func == "right") {
		trimvalue = arg.substring(0,lastpos+1);
	}

	if (func == "both") {
		trimvalue = arg.substring(pos,lastpos + 1);
	}

	return trimvalue;

}
