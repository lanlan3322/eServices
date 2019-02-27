<%--
RemoveWorkInclude.jsp - removes the safe-store copy of the report from XMLR/tmp 
Copyright (C) 2004,2013 R. James Holton

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

This is a version of the RemoveWork.jsp file that can be included in the
SaveXML and SubmitDbase jsps so that any report that is saved will not
leave the temporary file in place.

--%>

<% 

Log.println("[000] ajax/RemoveWorkInclude.jsp owner is " + ownersName);

String reg_dbase = Sys.getSystemString("XML_FOLDER","E:\\Register\\");
String fileName = reg_dbase + "/tmp/" + ownersName + ".xml";
//   String fileName = "c:/ess/ess/xmlr/tmp/" + ownersName + ".xml";

try {
	java.io.File removeFile = new java.io.File(fileName);
	if (removeFile.exists()) {
		if (removeFile.delete()) {
			Log.println("[000] ajax/RemoveWorkInclude.jsp OK: " + fileName);
		} else {
			Log.println("[000] ajax/RemoveWorkInclude.jsp Not Deleted: " + fileName);
		}
	} else {
		Log.println("[000] ajax/RemoveWorkInclude.jsp Does not exist: " + fileName);		
	}
} catch (java.lang.Exception e) {
	e.printStackTrace(); 
	Log.println("[500] ajax/RemoveWorkInclude.jsp Failed - See stack trace: " + fileName);
}
%>