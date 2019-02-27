//project.js - contains specialized code for tieing stepno to a set of expense types
// Copyright 2009 R. James Holton, All rights reserved
//insert into head2* requires 3 steps
//1. add this script with a script tag
//2. add ID="stepDescription" to the td cell you want updated
//3. call setStepNoList from the initialization function with the list box
//4. optionally add a confirm box to the save check
//Insert into the submit process requires 2 steps
//1. add this script with a script tag
//2. call confirmAirFare from the submit process

var stepNoList = [["",""],["Commercial","<b>All direct-billed airfare paid for by Kohler Co. must be claimed after each trip has occurred. This also includes tickets charged to the company Ghost card account.</b>"],["Corporate","Used one of the Corporate Air fleet to arrive at or return."],["None","No air travel needed or ticket was paid for by another company or vendor."]];

function setStepNoList(selectObj) 
{
	selectObj.length = 0;
    parent.contents.setListWithValue(selectObj, stepNoList);
	eval("selectObj.onchange=function(){setStepNoDescription(document.forms[0]." + selectObj.name + ")}"); 
}

function setStepNoDescription(selectObj)
{
	document.getElementById("stepDescription").innerHTML = selectObj.options[selectObj.selectedIndex].value;
}

function confirmAircraft(selectObj)  //This should be moved elsewhere.
{
  retVal = true;
  if (selectObj.selectedIndex < 1)
  {
    alert("Aircraft type is required");
	retVal = false;
  }
  return retVal;
}



var checkHeadListItem = "stepno";
var checkHLValues = ["Commercial","COMMERCIAL"];
var checkTailListItem = ["expensetype","expense_1_expensetype","expense_2_expensetype","expense_3_expensetype","expense_4_expensetype","expense_5_expensetype","expense_6_expensetype","expense_7_expensetype","expense_8_expensetype","expense_9_expensetype","expense_10_expensetype"];
var requiredTLValues = ["AIRFARE"];

// This function checks that the stepno has whatever expense types are required.
function checkPurposeBalanced()
{
	var retVal = true;
	var retArray;
	for (var i = 0; i < checkHLValues.length; i++)
	{
		retArray = parent.contents.getResultWhere(parent.contents.HeadList, checkHeadListItem, checkHLValues[i]);
		if ((retArray != null) && (retArray.length > 0))
		{
			i = checkHLValues.length;
			retVal = false;
			for (var j = 0; j < checkTailListItem.length; j++)
			{
			    for (var k = 0; k < requiredTLValues.length; k++)
				{
			        retArray = parent.contents.getResultWhere(parent.contents.TailList, checkTailListItem[j], requiredTLValues[k]);
					if ((retArray != null) && (retArray.length > 0))
					{
						retVal = true;
						j = checkTailListItem.length;
						k = requiredTLValues.length;
					}
				}
			}
		}
	}			
	return retVal;
}
	
function confirmAirfare()
{
	if (checkPurposeBalanced() == false)
	{
		if (confirm("You have indicated commercial air travel but have not applied an airfare expense. You need to apply an airfare expense for this trip.\n\nDo you wish to continue?") == false)
		{
			parent.contents.ListMemory();
		}
	}
	return true;
}


		