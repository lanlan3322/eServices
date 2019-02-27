<%--
DupSigner.jsp - Checks for dup signer in columns 1 and 2 
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
public boolean CheckDupSigner(ess.PersonnelTable PT, String FirstSigner, String DupAllowed, String SignerColumn) {
   boolean retVal = false;
   // Need to change this sometime
   if (DupAllowed.toUpperCase().equals("YES") || SignerColumn.equals("SIGN1") || FirstSigner == null) {
      retVal = true;
   } else {
      if (PT.persnum.equals(FirstSigner)) {
         retVal = false;
      } else {
         retVal = true;
      }
   }
   return retVal;
}

public boolean ifOnceAndOnlyOnce(ess.PersonnelTable PT, boolean atLeastOnce,
		                         String AdminSigner, String FirstSigner, String SecondSigner) {
	   boolean retVal = false;
	   if (atLeastOnce) {
	         if (PT.persnum.equals(AdminSigner) || PT.persnum.equals(FirstSigner) || PT.persnum.equals(SecondSigner) ) {
	            retVal = false;
	         } else {
	            retVal = true;
	         }
	   }
	   return retVal;
}

public boolean ifSeemsOK(ess.PersonnelTable PT, boolean DupAllowed, boolean atLeastOnce,
                              String AdminSigner, String FirstSigner, String SecondSigner, boolean limitOK) {
	
   boolean retVal = false;
   
   if (DupAllowed && limitOK) {
	   retVal = true;
   } else {
	   if (limitOK && !PT.persnum.equals(AdminSigner) 
		   && !PT.persnum.equals(FirstSigner) && !PT.persnum.equals(SecondSigner) ) {
		   retVal = true;
	   } else {
	     if (atLeastOnce) {
            if (PT.persnum.equals(AdminSigner) || PT.persnum.equals(FirstSigner) || PT.persnum.equals(SecondSigner) ) {
               retVal = false;
            } else {
               retVal = true;
            }
	     }
	   }
   }
   return retVal;
}

%>

