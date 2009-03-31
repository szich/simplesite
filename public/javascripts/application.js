// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function ToggleContent(elementID, startContent, endContent) {
	element = document.getElementById(elementID);
	if( element.innerHTML == startContent )
		element.innerHTML = endContent;
	else
		element.innerHTML = startContent;
}

//Effect.SlideUpAndDown = function(element) {
//  element = $(element);

function MoveOption(fromList, toList) {
  // Find all of the selected items and move them to the toList.
  for (var i=0; i<fromList.length; i++) {
    if (fromList.options[i].selected) {
      toList.options[toList.length++] = new Option(fromList.options[i].text, fromList.options[i].value);
      fromList.options[i] = null;
      i--; // Adjust the counter since we just removed an item.
    }
  }
}

// This is a bit of hack to so that Rails can 'see'
// ALL of the elements that are in a multiselect list.
function SelectAll(list) {
  for (var i=0; i<list.length; i++)
    list.options[i].selected = true;
}
