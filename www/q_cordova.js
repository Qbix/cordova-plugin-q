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
    if(htmlDocument !== undefined) {
        var titleElements = htmlDocument.getElementsByTagName("title");
        if(titleElements.length > 0) {
            data.title = titleElements[0].innerHTML;
        } else {
            data.title="";
        }
        data.keyboards = getMetaContent(htmlDocument, "keywords");
        data.description = getMetaContent(htmlDocument, "description");
    }
    return data
}
               
module.exports = {
    schema: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "getSchema", []);
    },
    chooseLink: function(initialUrl, isMetadata, successCallback, metadataCallback, errorCallback) {
        var innerFunction = function(params) {
            if(params["link"] != undefined) {
               successCallback(params["link"]);
            }
            if (isMetadata) {
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
            }
            if(isMetadata) {
               var data = parseHtml(params["html"])
               metadataCallback(data);
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
    },
    setSelectMenuShown: function(isShow, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "setSelectMenuShown", [isShow]);
    }
};
