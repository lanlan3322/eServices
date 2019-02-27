<%--
RandomSampleSelect.jsp - used in random audit function
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

public String randomSampleStatus(ess.StateTable st, ess.AdisoftDOM StatusDOM, String currentStatus, ess.AuditTrail Logfile)
{
   String promotedStatus = currentStatus;                
   final String randomMethod = "RANDOMSELECT";
   if (st.canPerform(currentStatus, randomMethod) == true)
   {
       /* Do the random select and set the status appropriately
          1. get the sample size from the Status file
          2. instansiate the Random select class
          3. get the return value
          4. get the right value from the state table
       */
       String sampleString = StatusDOM.getDOMTableValueWhere("default","status",currentStatus,"randomsampleratio");
       if (!sampleString.equals(""))
       {
    	   if (!sampleString.equals("0"))
    	   {
              double sampleRatio = Double.valueOf(sampleString).doubleValue(); 
              java.util.Random r = new java.util.Random();
              double d = r.nextDouble();   
              double sampleSelect = d * sampleRatio;

              if (sampleSelect < (double) 1)
              {
                 promotedStatus = st.getPositiveStatus(currentStatus, "RANDOMSELECT");
              } else {
                 promotedStatus = st.getNegativeStatus(currentStatus, "RANDOMSELECT");    
              }
    	   }
        } else {
           Logfile.println("[500] RandomSampleSelect.jsp: RANDOM_SELECT - no ratio for " + currentStatus);   
        }
    }
    return promotedStatus;
}                    
%>