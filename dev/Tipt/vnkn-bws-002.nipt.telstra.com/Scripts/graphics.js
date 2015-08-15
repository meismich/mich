// General form display utilities

function initSelection()
{
  // If defined, this function cleans up (removes) some
  // display elements.  This is necessary after a server
  // error to remove some elements that have already had
  // html generated and output.  See jspError.jsp.
  if (document.removeSomeElements)
  	document.removeSomeElements();
  	
  var i, j, form;

  // if there is an anchor for form result named 'result_anchor', move to it
  for (j=0; j<document.anchors.length; j++)
  {
    if (document.anchors[j].name == "result_anchor") {
       top.location.replace("#result_anchor");
       return;
    }
  }

  for (j=0; j<document.forms.length; j++)
  {
    form = document.forms[j];
    for (i=0; i<form.elements.length; i++)
    {
      if (
          (
           form.elements[i].type == "text" ||
           form.elements[i].type == "password" ||
           form.elements[i].type == "select-multiple" ||
           form.elements[i].type == "select-one" ||
           form.elements[i].type == "radio" ||
           form.elements[i].type == "checkbox"
          ) &&
          (
           !form.elements[i].disabled &&
           (form.elements[i].style.display != "none")
          )
         )
      {
        doFocus(form.elements[i]);
        return;
      }
    }
  }
}

function doFocus(element)
{
  try {
    element.focus();
  }
  catch (e) {
    // consume the error
  }
}

function highlight(lnk,descr)
{
  status = descr;
  return true;
}

function unhighlight(lnk)
{
  status = "";
}