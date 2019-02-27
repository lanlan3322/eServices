<%--
CreateRegister.jsp - creates an XMLR file for user
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
private boolean CreateRegister(ess.PersonnelSession P,ess.AuditTrail L) {
   boolean retVal = true; 
   ess.ReportContainer RC = new ess.ReportContainer();
   RC.setConnection(P.getConnection());
   RC.setSQLTerminator(P.getSQLTerminator());
   RC.setOwner(P.getEmailAddress());
   if (RC.getDOMProcessed()) {
     L.println("[400] CreateRegister.jsp Register already exists for: " + P.getEmailAddress()); 
   } else {
     RC.persist();
     L.println("[270] CreateRegister.jsp Register created for: " + P.getEmailAddress()); 
   }
   return retVal; 
}

%>