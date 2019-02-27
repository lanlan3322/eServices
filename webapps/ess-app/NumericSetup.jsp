<%-- Need PersFile defined --%>


<% 
java.text.DecimalFormatSymbols numericRepresentation = new java.text.DecimalFormatSymbols();
//char aPeriod = '.';
//char aComma = ',';
numericRepresentation.setDecimalSeparator(PersFile.getDecimalSeparator());
numericRepresentation.setGroupingSeparator(PersFile.getGroupingSeparator());
java.text.DecimalFormat money = new java.text.DecimalFormat("0.00",numericRepresentation);
%>
