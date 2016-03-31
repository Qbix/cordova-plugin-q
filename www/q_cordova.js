/*global cordova, module*/

module.exports = {
    hello: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "QCordova", "hello", [name]);
    }
};
