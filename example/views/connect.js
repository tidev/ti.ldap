/*
 * View for specifying connection information
 */

var ldap = require('ti.ldap');
var platform = require('utility/platform');

var connection = null;
var loading = null;
var u = platform.u;

exports.initialize = function() {
};

exports.cleanup = function() {
    connection = null;
    loading = null;
};

exports.create = function(win) {
    win.title = 'Connect';
    
    win.add(Ti.UI.createLabel({
        text: 'Enter server connection information',
        top: 10+u, left: 10+u, right: 10+u,
        color: '#000', textAlign: 'left',
        height: Ti.UI.SIZE || 'auto'
    }));

    var uri = Ti.UI.createTextField({
        hintText: 'host (ldap://127.0.0.1:389)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(uri);
 
    var connect = Ti.UI.createButton({
        title: 'Connect',
        top: 10+u, left: 10+u, right: 10+u, bottom: 10+u,
        height: 40+u
    });
    win.add(connect);

    connect.addEventListener('click', function() {
        doConnect({
            uri: uri.value
        });
    });
    
    loading = platform.addActivityIndicator(win, "Connecting...");
};

function doConnect(data) {
    var android = (Ti.Platform.name === 'android');
    // Android needs a bks
    var certFileName = android ? 'ldap-studio_slapd_cert-146.bks' : 'ldap-studio_slapd_cert.pem';
    var certFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, certFileName);

    var tempCertFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'tempCert.pem');
    var caCertFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'cacert.pem');

    // Delete the old `tempCertFile` before copying thew new cert
    if (tempCertFile.exists()) {
        tempCertFile.deleteFile();
    }
    // Copy the cert to the `applicationDataDirectory`.
    // Android can't use a cert that is in the `resourcesDirectory`.
    tempCertFile.write(certFile.read());

    loading.show();
    connection = ldap.createConnection({
        // Set global request timelimit to 5 seconds
        timeLimit: 5,
        useTLS: true,
        certFile: tempCertFile,
        caCertFile: caCertFile // CA cert not used on Android but it doesn't hurt to pass it in
    });
    connection.connect(data,
        function() {
            loading.hide();
            require('utility/navigator').push({
                viewName: 'bind',
                connection: connection
            });
        },
        function(e) {
            loading.hide();
            alert(e.message);
        });
}
