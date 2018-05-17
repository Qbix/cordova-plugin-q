/*global cordova, module*/

function getMetaContent(document, property) {
    var metas = document.getElementsByTagName('meta');
    for (var i=0; i<metas.length; i++) {
        if (metas[i].getAttribute("name") == property) {
            return metas[i].getAttribute("content");
        }
    }
               
    return "";
}
        
function parseHtml(html) {
    var data = {};
    var htmlDocument = document.createElement('html');
    htmlDocument.innerHTML = html;
               
               
    data.html = html;
    data.title = htmlDocument.getElementsByTagName("title")[0].innerHTML;
    data.keyboards = getMetaContent(htmlDocument, "keywords");
    data.description = getMetaContent(htmlDocument, "description");
    return data
}
               
module.exports = {
    hello: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "QCordova", "hello", []);
    },
    // openUrl: function(url, options, onSuccess, onError) {
    //     SafariViewController.isAvailable(function (available) {
    //         if (available) {
    //         	options.url = url;
    //           	SafariViewController.show(options,onSuccess,onError);
    //         } else if(cordova.InAppBrowser != null && !options.openUrlSupport) {
    //           	var inAppBrowserRef = cordova.InAppBrowser.open(url, '_blank', 'location=yes');
    //           	inAppBrowserRef.addEventListener('loadstart', function(){
    //             	onSuccess({event:"opened"})
    //           	});
    //           	inAppBrowserRef.addEventListener('loadstop', function(){
    //           		onSuccess({event:"loaded"});
    //           	});
    //           	inAppBrowserRef.addEventListener('loaderror', onError);
    //           	inAppBrowserRef.addEventListener('exit', function(){
    //           		onSuccess({event:"closed"});
    //           	});
    //         } else {
    //           	window.open(url, '_system', 'location=yes');
    //           	onSuccess({event:"unknown"});
    //         }
    //     });
    // },
    schema: function(successCallback, errorCallback) {
    	this.readQConfigValue("openUrlScheme", successCallback, errorCallback);
    },
    readQConfigValue: function(key, successCallback, errorCallback) {
		  cordova.exec(successCallback, errorCallback, "QCordova", "readQConfigValue", [key]);
    },
    chooseLink: function(initialUrl, isMetadata, successCallback, metadataCallback, errorCallback) {
        var innerFunction = function(params) {
            if(params["link"] != undefined) {
               successCallback(params["link"]);
            } else if (isMetadata) {
               var data = parseHtml(params["html"])
               metadataCallback(data);
            }
        }
               
        cordova.exec(innerFunction, errorCallback, "QCordova", "chooseLink", [initialUrl]);
    },
    chooseImage: function(initialUrl, isMetadata, successCallback, metadataCallback, errorCallback) {
        var innerFunction = function(params) {
            if(params["link"] != undefined) {
               successCallback(params["link"]);
            } else if(isMetadata) {
               var data = parseHtml(params["html"])
               metadataCallback(params);
            }
        }
        cordova.exec(innerFunction, errorCallback, "QCordova", "chooseImage", [initialUrl]);
    },
    changeInnerUrlEvent: function(url, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "changeInnerUrlEvent", [url]);
    },
    chooseImageEvent: function(image, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "chooseImageEvent", [image]);
    },
    sign: function(parameters, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "sign", [parameters]);
    },
    info: function(successCallback, errorCallback) {
       cordova.exec(successCallback, errorCallback, "QCordova", "info");
    }
};
