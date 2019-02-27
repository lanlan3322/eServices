<%--
StatXlation.jsp - provides the screen description for any status
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
public String StatXlation(String StatusCode, String RoutingRule, ess.AdisoftDOM StDOM) {
// RoutingRule is current treated as hardcoded to "default" for now.
// Need to have included the StatusInfo.jsp module in the calling jsp
  String retVal = "";
  if (StatusCode != null && !StatusCode.trim().equals("") ) 
  {
    retVal = StDOM.getDOMTableValueWhere("default","translation",StatusCode,"screen");
  }
  return retVal;
}
%>

