var nav = null;

function createViewInWindow(win, viewInfo)
{
	var mod = require(viewInfo.viewName);
	
	mod.initialize(viewInfo);
	mod.create(win);
	win.addEventListener('close', function() {
		mod.cleanup();
	});	
	
	return win;
}

exports.openAppWindow = function(viewInfo) {
	var appWin = Ti.UI.createWindow({
		backgroundColor: 'white',
		layout: 'vertical',
		tabBarHidden: true
	});
	
	if (Ti.Platform.name == 'android') {
		createViewInWindow(appWin, viewInfo);
		win.exitOnClose = true;
	} else {
		var win = Ti.UI.createWindow({
			backgroundColor: 'white',
			layout: 'vertical'
		});
		createViewInWindow(win, viewInfo);
		nav = Ti.UI.iPhone.createNavigationGroup({
			window: win
		});
		appWin.add(nav);
	}
	
	appWin.open();
}

exports.push = function(viewInfo) {
	var win = Ti.UI.createWindow({
		backgroundColor: 'white',
		layout: 'vertical'
	});
	
	createViewInWindow(win, viewInfo);
	
	if (Ti.Platform.name == 'android') {
		win.open({ modal: true, animated: true });
	} else {
		nav.open(win, { animated: true });
	}
}
