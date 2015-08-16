var digits = "0123456789";
var lowercaseLetters = "abcdefghijklmnopqrstuvwxyz";
var uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var alphanumeric = digits + uppercaseLetters + lowercaseLetters;
var validDomainNameChars = alphanumeric + "-_.";
var whitespace = " \t\n\r";
var minPasswordLength = 1;
var minUserIDLength = 2;

// Error handling support.
//
// All validation functions should return false to indicate an error.
// Calling functions should use getLastError() to determine the details
// of the error.

var bwLastError = "";

function getLastError()
{
  return bwLastError;
}
function setError(s)
{
  bwLastError = s;
  return false;
}

// Utility functions.
//
// Used by other functions within this script file.

function isEmpty(s)
{
   return ((s == null) || (s.length == 0));
}

function isWhitespace(s)
{
  var pattern = /^\s*$/;
  return pattern.test(s);
}

// Formatting support.
//
// These functions prepare fields for validation by eliminating
// excess whitespace, converting to standard presentation, etc.

function trim(s)
{
  var result = "";
  var pieces;
  var z;
  pieces = s.split(/[\r\n\t ]/);
  for(z=0; z < pieces.length; z++)
  {
    if(pieces[z].length > 0)
    {
      if(result.length>0) result += " ";
      result += pieces[z];
    }
  }
  return result;
}

function formatName(n)
{
  var stdName = n.value;
  var index = stdName.indexOf('"');

  while (index >= 0)
  {
    if (index > 0) stdName = stdName.substr(0, index) + stdName.substr(index+1);
    else stdName = stdName.substr(1);

    index = stdName.indexOf('"');
  }

  n.value = trim(stdName);
}

function formatPort(n)
{
  var intValue = parseInt(n.value,10);
  
  if (intValue != NaN)
  {
    if (intValue < 0) intValue = -1 * intValue;
    n.value = intValue;
  }
}

// Validate that the number is all digits and is
// between or equal to the values of min and max.
function isValidNumber(field, number, min, max) {
 
  if (number.length == 0) {
    return setError(errorText(1001, field));
  }
  if (!isInteger(number)) {
    return setError(errorText(1001, field));   
  }
  if ((min <= number) && (number <= max)) {
    // do nothing... the number is valid.
  } else {
    // case 386: return "Value must be >= <1> and <= <2>";  
    return setError(errorText(386, field, min, max));
  }
  return true;
}

// Validate that the number is all digits and is
// greater than or equal to the value of min.
function isValidNumberMinInclusive(field, number, min) {
  if (number.length == 0) {
    return setError(errorText(1001, field));
  }

  if (!isInteger(number)) {
    return setError(errorText(1001, field));   
  }
  
  if (number < min) {
    return false; 
  }

  return true;
}

function isValidPassword(password)
{
  if (password == null)
  {
    return setError(errorText(1000, errorText(2021)));
  }
  if (password.length == 0)
  {
    return setError(errorText(1000, errorText(2021)));
  }
  if (password.length < minPasswordLength)
  {
    return setError(errorText(1000, errorText(2021)));
  }
  
  return true;
}

function isDigit (c)
{
   return ((c >= "0") && (c <= "9"));
}

function isAlpha (c)
{
  var lowercase = ((c >= "a") && (c <= "z"));
  var uppercase = ((c >= "A") && (c <= "Z"));
  return (lowercase || uppercase);
}

function isInteger (s)
{
   var i, c;

   if (isEmpty(s))
   {
     return setError(errorText(380));
   }

   for (i = 0; i < s.length; i++)
   {
      c = s.charAt(i);

      if (!isDigit(c))
      {
         return setError(errorText(381, s.charAt(i)));
      }
   }

   return true;
}

function isFloat (s)
{
  return /^((\d+(\.\d*)?)|((\d*\.)?\d+))$/.test(trim(s));
}

function isIntegerInRange (s, min, max)
{
   var num;

   if (!isInteger(s)) return false;

   num = parseInt(s);

   if (num < min)
   {
      return setError(errorText(382, min));
   }
   else if (num > max)
   {
      return setError(errorText(383, max));
   }

   return true;
}

function isFloatInRange (num, min, max)
{
   if (!isFloat(num)) return false;

   if (num < min)
   {
      return setError(errorText(382, min));
   }
   else if (num > max)
   {
      return setError(errorText(383, max));
   }

   return true;
}

// Valid LinePort should not contain '@'
function isValidLinePort(s)
{
  if (s.indexOf("@") != -1)
    return false;
  else
    return true;
}

function checkForDnOrClids(dn, gclid)
{
  var confirmResult = true;
  if( dn == "None" )
  {
    if(gclid == "")
    {
      confirmResult = confirm(errorText(608));
    }
  }
  return confirmResult;
}

function checkdate(objName) 
{  
  if (chkdate(objName) == false) 
  {    
    document.conferenceData.startDate.value="";
    alert("Invalid Date: Please try again.");
    document.conferenceData.startDate.select();    
    document.conferenceData.startDate.focus();
    return false;
  }
  if (doDateCheck(objName.value) == false) 
  {
    document.conferenceData.startDate.value="";
    alert("Invalid Date: cannot be before today's date");
    document.conferenceData.startDate.select();    
    document.conferenceData.startDate.focus();
    return false;
  }
  else 
  {
    return true;
  }
}


function chkdate(objName) 
{
  var strDatestyle = "US"; //United States date style

  var strDate;
  var strDateArray;
  var strDay;
  var strMonth;
  var strYear;
  var intday;
  var intMonth;
  var intYear;
  var booFound = false;
  var datefield = objName;
  var strSeparatorArray = new Array("-"," ","/",".");
  var intElementNr;
  var err = 0;
  var strMonthArray = new Array(12);
  strMonthArray[0] = "1";
  strMonthArray[1] = "2";
  strMonthArray[2] = "3";
  strMonthArray[3] = "4";
  strMonthArray[4] = "5";
  strMonthArray[5] = "6";
  strMonthArray[6] = "7";
  strMonthArray[7] = "8";
  strMonthArray[8] = "9";
  strMonthArray[9] = "10";
  strMonthArray[10] = "11";
  strMonthArray[11] = "12";
  strDate = datefield.value;
  if (strDate.length < 1) 
  {
    return true;
  }
  for (intElementNr = 0; intElementNr < strSeparatorArray.length; intElementNr++) 
  {
    if (strDate.indexOf(strSeparatorArray[intElementNr]) != -1) 
    {
	strDateArray = strDate.split(strSeparatorArray[intElementNr]);
	if (strDateArray.length != 3) 
	{
	  err = 1;
	  return false;
	}
	else 
	{
	  strDay = strDateArray[0];
	  strMonth = strDateArray[1];
	  strYear = strDateArray[2];
	}
	booFound = true;
    }
  }
  if (booFound == false) 
  {
    if (strDate.length>5) 
    {
	strDay = strDate.substr(0, 2);
	strMonth = strDate.substr(2, 2);
	strYear = strDate.substr(4);
    }
    else
    {
    	err = 2; 
    	return false;
    }
  }
  if (strYear.length == 2) 
  {
    strYear = '20' + strYear;
  }

  if (strDatestyle == "US") 
  {
    strTemp = strDay;
    strDay = strMonth;
    strMonth = strTemp;
  }
  intday = parseInt(strDay, 10);
  if (isNaN(intday)) 
  {
    err = 3;
    return false;
  }
  intMonth = parseInt(strMonth, 10);
  if (isNaN(intMonth)) 
  {
    for (i = 0;i<12;i++) 
    {
	if (strMonth.toUpperCase() == strMonthArray[i].toUpperCase()) 
	{
	  intMonth = i+1;
	  strMonth = strMonthArray[i];
	  i = 12;
	}
    }
    if (isNaN(intMonth)) 
    {
	err = 4;
	return false;
    }
  }
  intYear = parseInt(strYear, 10);
  if (isNaN(intYear)) 
  {
    err = 5;
    return false;
  }
  if (intMonth>12 || intMonth<1) 
  {
    err = 6;
    return false;
  }
  if ((intMonth == 1 || intMonth == 3 || intMonth == 5 || intMonth == 7 || intMonth == 8 || intMonth == 10 || intMonth == 12) && (intday > 31 || intday < 1)) 
  {
    err = 7;
    return false;
  }
  if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && (intday > 30 || intday < 1)) 
  {
    err = 8;
    return false;
  }
  if (intMonth == 2) 
  {
    if (intday < 1) 
    {
	err = 9;
	return false;
    }
    if (LeapYear(intYear) == true) 
    {
	if (intday > 29) 
	{
	  err = 10;
	  return false;
	}
    }
    else 
    {
	if (intday > 28) 
	{
	  err = 11;
	  return false;
    	}
    }
  }  
  
  if (strDatestyle == "US") 
  {
    datefield.value = strMonthArray[intMonth-1] + "/" + intday+"/" + strYear;
  }
  else 
  {
    datefield.value = intday + " " + strMonthArray[intMonth-1] + " " + strYear;
  }  
  return true;
}


function LeapYear(intYear) 
{
  if (intYear % 100 == 0) 
  {
    if (intYear % 400 == 0) 
    { 
      return true; 
    }
  }
  else 
  {
    if ((intYear % 4) == 0) 
    { 
      return true; 
    }
  }
  return false;
}

function doDateCheck(from)
{
  var today = new Date();  
  var todayToStr = (today.getMonth()+1)+"/"+today.getDate()+"/"+today.getYear();  
  if (Date.parse(from) < Date.parse(todayToStr)) 
  {
    return false;
  }
  else 
  {
    return true;
  }
}


function IsValidTime(timeStr) 
{
  // Checks if time is in HH:MM AM/PM format. 
  
  timeStr.value = trim(timeStr.value.toUpperCase());

  var timePat = /^(\d{1,2}):(\d{2})?(\s?(AM|am|PM|pm))?$/;
  
  var matchArray = timeStr.value.match(timePat);
  if (matchArray == null) 
  {
    timeStr.value="";    
    alert("Time is not in a valid format.");    
    timeStr.focus();
    return false;
  }
  hour = matchArray[1];
  minute = matchArray[2];
  ampm = matchArray[4];
  
   
  if (ampm=="") { ampm = null }

  
  if (hour <= 12 && ampm == null) 
  {
    timeStr.value="";
    alert("You must specify AM or PM.");
    timeStr.focus();
    return false;
  }    
  else if  (hour > 12) 
  {
    timeStr.value="";
    alert("Invalid Time: you can't specify military time.");
    timeStr.focus();
    return false;
  }
  if (minute<0 || minute > 59) 
  {
    timeStr.value="";
    alert ("Minute must be between 0 and 59.");
    timeStr.focus();
    return false;
  }
  return false;
}

/* Don't write anything on this function.
 * It should act as an abstract function, if a web page needs to do anything onLoad event
 * this function should be overridden in a local JS file and it will get called by the
 * bwFormTemplate.jsp body onLoad event. 
 */
function doThisOnLoad()
{
  // Don't write anything here.
}