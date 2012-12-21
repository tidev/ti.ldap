/*
 * View for displaying attributes for the selected entry
 */

var u = Ti.Android != undefined ? 'dp' : 0;

var entry = null;
var table = null;

exports.initialize = function (viewInfo)
{
	// The entry property contains the selected entry proxy
	entry = viewInfo.entry;
};

exports.cleanup = function ()
{
	entry = null;
	table = null;
};

exports.create = function (win)
{
	win.title = 'Attributes';

	table = Ti.UI.createTableView({
		width:Ti.UI.FILL,
		height:Ti.UI.FILL
	});
	win.add(table);

	populateTable();
};

function populateTable() {
	function createRow(attribute, value) {
		var row = Ti.UI.createTableViewRow({
			backgroundColor: 'white',
			layout: 'vertical'
		});
		row.add(Ti.UI.createLabel({
			text: attribute,
			textAlign: 'left',
			font: {fontSize:18+u, fontWeight:'bold'},
			left: 4
		}));
		row.add(Ti.UI.createLabel({
			text: value ? value : "Attribute has no value",
			textAlign: 'left',
			font: {fontSize:14+u},
			left: 4,
			color: 'darkgray'	
		}));

		return row;
	}

	var tableRows = [];
	if (entry) {
		var attribute = entry.firstAttribute();
		while (attribute) {
			// Retrieve the attribute values -- this code assumes that each
			// attribute is a string value. Use `getValuesLen` to retrieve 
			// binary attribute values as blobs
			var values = entry.getValues(attribute);
			if (values) {
				for (var i=0; i<values.length; i++) {
					tableRows.push(createRow(attribute, values[i]));
				}
			} else {
				tableRows.push(createRow(attribute, null));
			}
			attribute = entry.nextAttribute();
		}
	}
	table.setData(tableRows);
}


