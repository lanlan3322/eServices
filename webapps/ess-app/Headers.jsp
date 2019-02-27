<%
	String HeaderParamName;
	String HeaderParamValue;
	Log.println("[307] Headers: Remote IP, " + request.getRemoteAddr());
	for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
		HeaderParamName = (String) e.nextElement();
		HeaderParamValue = request.getHeader(HeaderParamName); 
		Log.println("[307] Headers: " + HeaderParamName + " value, " + HeaderParamValue);
	}
%>