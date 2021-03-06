<%--
StandardAuditTop.jsp - Standard top for various displays
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


<table width="100%">

<tr>
<td width="50%">
<p align="left">
<a href="javascript: void document.ReportList.submit()">
<span class="ExpenseReturnLink">
<%= Lang.getString("retToPrev")%>
</span></a>
</p>
</td>
<td width="50%">
<p align="right">
<a href="javascript: void parent.main.print()">
<span class="ExpenseReturnLink">
<%= Lang.getString("print")%>
</span></a>
</p>
</td>
</tr>

<tr>
<td width="50%">
<p align="left">
<a href="#receiptsSection">
<span class="ExpenseReturnLink">
<%= Lang.getString("gotoReceipts")%>
</span></a>
</p>
</td>
<td width="50%">
<p align="right">
<a href="#signoffSection">
<span class="ExpenseReturnLink">
<%= Lang.getString("signoff")%>
</span></a>
</p>
</td>
</tr>

</table>