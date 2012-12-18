var searchResult = null;
var table = null;

exports.initialize = function(viewInfo) {
	searchResult = viewInfo.searchResult;
}

exports.cleanup = function() {
	searchResult = null;
	table = null;
}

exports.create = function(win) {
	win.title = 'Search Entries';
	
	table = Ti.UI.createTableView({
		width: Ti.UI.FILL,
		height: Ti.UI.FILL
	});
	win.add(table);
	table.addEventListener('click', function(e) {
		if (e.row.hasChild) {
        	require('navigator').push({
        		entry: e.row.entry,
        		viewName: 'attributes',
        	});			
		};
	});
	
	populateTable();
}

function populateTable() {
	function createRow(entry) {
		var dn = entry.getDn();
		var attribute = entry.firstAttribute();
		var row = Ti.UI.createTableViewRow({
			title: dn,
			entry: entry,
			hasChild: (attribute != null)
		});

		return row;
	}

	var tableRows = [];
	if (searchResult) {
		var entry = searchResult.firstEntry();
		while (entry) {
			tableRows.push(createRow(entry));
			entry = searchResult.nextEntry();
		}
	}
	table.setData(tableRows);
}


