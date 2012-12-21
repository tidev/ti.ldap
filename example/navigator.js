var nav = null;

function createViewInWindow(win, viewInfo)
{
	// Attempt to load the view
	var mod = require('views/' + viewInfo.viewName);
	// Allow the view to initialize
	mod.initialize(viewInfo);
	// Create the view in the current window
	mod.create(win);
	// Register to be notified when the window closes so the module can cleanup
	win.addEventListener('close', function() {
		mod.cleanup();
	});	
	
	return win;
}

exports.openAppWindow = function (viewInfo)
{
	var appWin = Ti.UI.createWindow({
		backgroundColor:'white',
		layout:'vertical',
		tabBarHidden:true
	});

	if (Ti.Platform.name == 'android') {
		createViewInWindow(appWin, viewInfo);
		appWin.exitOnClose = true;
	} else {
		var win = Ti.UI.createWindow({
			backgroundColor:'white',
			layout:'vertical'
		});
		createViewInWindow(win, viewInfo);
		nav = Ti.UI.iPhone.createNavigationGroup({
			window:win
		});
		appWin.add(nav);
	}

	appWin.open();
};

exports.push = function (viewInfo)
{
	var win = Ti.UI.createWindow({
		backgroundColor:'white',
		layout:'vertical'
	});

	createViewInWindow(win, viewInfo);

	if (Ti.Platform.name == 'android') {
		win.open({ modal:true, animated:true });
	} else {
		nav.open(win, { animated:true });
	}
};
