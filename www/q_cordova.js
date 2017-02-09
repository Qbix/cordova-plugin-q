/*global cordova, module*/

module.exports = {
    hello: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "QCordova", "hello", []);
    },
    openUrl: function(url, options, onSuccess, onError) {
        SafariViewController.isAvailable(function (available) {
            if (available) {
            	options.url = url;
              	SafariViewController.show(options,onSuccess,onError);
            } else if(cordova.InAppBrowser != null && !options.openUrlSupport) {
              	var inAppBrowserRef = cordova.InAppBrowser.open(url, '_blank', 'location=yes');
              	inAppBrowserRef.addEventListener('loadstart', function(){
                	onSuccess({event:"opened"})
              	});
              	inAppBrowserRef.addEventListener('loadstop', function(){
              		onSuccess({event:"loaded"});
              	});
              	inAppBrowserRef.addEventListener('loaderror', onError);
              	inAppBrowserRef.addEventListener('exit', function(){
              		onSuccess({event:"closed"});
              	});
            } else {
              	window.open(url, '_system', 'location=yes');
              	onSuccess({event:"unknown"});
            }
        });
    },
    schema: function(successCallback, errorCallback) {
    	this.readQConfigValue("openUrlScheme", successCallback, errorCallback);
    },
    readQConfigValue: function(key, successCallback, errorCallback) {
		  cordova.exec(successCallback, errorCallback, "QCordova", "readQConfigValue", [key]);
    },
    chooseLink: function(initialUrl, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "chooseLink", [initialUrl]);
    },
    chooseImage: function(initialUrl, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "chooseImage", [initialUrl]);
    },
    changeInnerUrlEvent: function(url, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "changeInnerUrlEvent", [url]);
    },
    chooseImageEvent: function(image, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "chooseImageEvent", [image]);
    }
};
