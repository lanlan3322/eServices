<%--
GeneratePVoucher.jsp - constructs a pvoucher number
Copyright (C) 2013 R. James Holton

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

private String contructPVoucher(String x, ess.ServerSystemTable SysInfo) {
   String alternatePrefix = SysInfo.getSystemString("configuration","alternateprefix","");
   x = alternatePrefix + x.substring(x.length() - (8 - alternatePrefix.length()));
   return x;
}

%>