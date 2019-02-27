<%-- 
usage = http://127.0.0.1:8080/ess-app/SetLocale.jsp?language=en&country=US
--%>

<%
String myLanguage = request.getParameter("language");
String myCountry = request.getParameter("country");
java.util.Locale myL = new java.util.Locale(myLanguage,myCountry);
java.util.Locale.setDefault(myL);
%>
Default locale for ESS server set to <%= java.util.Locale.getDefault()%> 
