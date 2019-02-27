<%--
DepartRouteRule.jsp - routine to extract a routing rule
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
--%>

<%!
public String getRoutingRuleName(ess.AdisoftDOM Departments, String ReportDepart, String ReporterDepart, ess.AuditTrail Log) {
   String retVal = "default";

   if (ReportDepart.equals(""))
   {
     ReportDepart = ReporterDepart;
   }

   retVal = Departments.getDOMTableValueWhere("depart",ReportDepart,"guide");
   if (retVal.equals("")) 
   {
     retVal = "default";
    //Log.println("[000] DepartRouteRule.jsp default");
   } else {
    //Log.println("[000] DepartRouteRule.jsp " + retVal);
   }
    
   return retVal;
}
%>

