/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

/**
 * Creates the exec bridge used to notify the native code of
 * commands.
 */


var cordova = require('cordova');
var utils = require('cordova/utils');
var base64 = require('cordova/base64');
const IS_ALLOW_ENCRYPT = true;

function massageArgsJsToNative (args) {
    if (!args || utils.typeName(args) !== 'Array') {
        return args;
    }
    var ret = [];
    args.forEach(function (arg, i) {
        if (utils.typeName(arg) === 'ArrayBuffer') {
            ret.push({
                CDVType: 'ArrayBuffer',
                data: base64.fromArrayBuffer(arg)
            });
        } else {
            ret.push(arg);
        }
    });
    return ret;
}

function massageMessageNativeToJs (message) {
    if (message.CDVType === 'ArrayBuffer') {
        var stringToArrayBuffer = function (str) {
            var ret = new Uint8Array(str.length);
            for (var i = 0; i < str.length; i++) {
                ret[i] = str.charCodeAt(i);
            }
            return ret.buffer;
        };
        var base64ToArrayBuffer = function (b64) {
            return stringToArrayBuffer(atob(b64)); // eslint-disable-line no-undef
        };
        message = base64ToArrayBuffer(message.data);
    }
    return message;
}

function convertMessageToArgsNativeToJs (message) {
    var args = [];
    if (!message || !Object.prototype.hasOwnProperty.call(message, 'CDVType')) {
        args.push(message);
    } else if (message.CDVType === 'MultiPart') {
        message.messages.forEach(function (e) {
            args.push(massageMessageNativeToJs(e));
        });
    } else {
        args.push(massageMessageNativeToJs(message));
    }
    return args;
}

var iOSExec = function () {
    // detect change in bridge, if there is a change, we forward to new bridge

    // if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.cordova && window.webkit.messageHandlers.cordova.postMessage) {
    //     bridgeMode = jsToNativeModes.WK_WEBVIEW_BINDING;
    // }

    var successCallback, failCallback, service, action, actionArgs;
    var callbackId = null;
    if (typeof arguments[0] !== 'string') {
        // FORMAT ONE
        successCallback = arguments[0];
        failCallback = arguments[1];
        service = arguments[2];
        action = arguments[3];
        actionArgs = arguments[4];

        // Since we need to maintain backwards compatibility, we have to pass
        // an invalid callbackId even if no callback was provided since plugins
        // will be expecting it. The Cordova.exec() implementation allocates
        // an invalid callbackId and passes it even if no callbacks were given.
        callbackId = 'INVALID';
    } else {
        throw new Error(
            'The old format of this exec call has been removed (deprecated since 2.1). Change to: ' + // eslint-disable-line
                "cordova.exec(null, null, 'Service', 'action', [ arg1, arg2 ]);"
        );
    }

    // If actionArgs is not provided, default to an empty array
    actionArgs = actionArgs || [];

    // Register the callbacks and add the callbackId to the positional
    // arguments if given.
    if (successCallback || failCallback) {
        callbackId = service + cordova.callbackId++;
        cordova.callbacks[callbackId] = { success: successCallback, fail: failCallback };
    }

    actionArgs = massageArgsJsToNative(actionArgs);

    // CB-10133 DataClone DOM Exception 25 guard (fast function remover)
    var key = localStorage.getItem(ENCRYPTION_KEY);
    var iv =  RANDOM_IV;
    if (IS_ALLOW_ENCRYPT) {
        if(key !== null && iv != null) {
            var decodedKey = CryptoJS.enc.Base64.parse(key);
            var decodedIV = CryptoJS.enc.Base64.parse(iv);
            
            var rsaEncrypt = new JSEncrypt();
            
            var decodedPubKey = CryptoJS.enc.Base64.parse(window.Q_PUB_KEY).toString(CryptoJS.enc.Utf8);
            rsaEncrypt.setPublicKey(decodedPubKey);
                                                   
            var encryptedCallbackId = CryptoJS.AES.encrypt(callbackId, decodedKey, { iv: decodedIV }).ciphertext.toString(CryptoJS.enc.Base64);
            var encryptedServiceId = CryptoJS.AES.encrypt(service, decodedKey, { iv: decodedIV }).ciphertext.toString(CryptoJS.enc.Base64);
            var encryptedAction = CryptoJS.AES.encrypt(action, decodedKey, { iv: decodedIV }).ciphertext.toString(CryptoJS.enc.Base64);
            var encryptedArgs = CryptoJS.AES.encrypt(JSON.stringify(actionArgs), decodedKey, { iv: decodedIV }).ciphertext.toString(CryptoJS.enc.Base64);
            
            const encryptedKeys = rsaEncrypt.encrypt(decodedKey.toString(CryptoJS.enc.Base64)+":"+decodedIV.toString(CryptoJS.enc.Base64));
            var command = [encryptedCallbackId, encryptedServiceId, encryptedAction, encryptedArgs, encryptedKeys];
            window.webkit.messageHandlers.cordova.postMessage(command);
        }
    } else {
        var command = [callbackId, service, action, JSON.parse(JSON.stringify(actionArgs))];
        window.webkit.messageHandlers.cordova.postMessage(command);
    }
};

iOSExec.nativeCallback = function (callbackId, status, message, keepCallback, debug, origin) {
    var success = status === 0 || status === 1;
    Promise.resolve().then(function () {
        iOSExec.broadcastToIFrame(origin, callbackId, success, status, message, keepCallback)
    });
};
    
window.addEventListener("message", (event) => {
    try {
        const payload = JSON.parse(event.data);
        if(payload.hasOwnProperty("callbackId") &&
           payload.hasOwnProperty("success") &&
           payload.hasOwnProperty("status") &&
           payload.hasOwnProperty("args") &&
           payload.hasOwnProperty("keepCallback")) {
            
            var key = localStorage.getItem(ENCRYPTION_KEY);
            var iv = RANDOM_IV;//localStorage.getItem(IV_KEY);
            if (IS_ALLOW_ENCRYPT) {
                if(key !== null && iv != null) {
                    var decodedKey = CryptoJS.enc.Base64.parse(key);
                    const decodedIV = CryptoJS.enc.Base64.parse(iv);
                    
                    try {
                    var decryptedCallbackId = CryptoJS.AES.decrypt(payload.callbackId, decodedKey, { iv: decodedIV }).toString(CryptoJS.enc.Utf8);
                    payload.callbackId = decryptedCallbackId;
                    
                    var decryptedMessage = CryptoJS.AES.decrypt(payload.args, decodedKey, { iv: decodedIV }).toString(CryptoJS.enc.Utf8);
                    payload.args = convertMessageToArgsNativeToJs(decryptedMessage);
                    } catch(e) {
//                        console.log("Error decode: "+window.origin+"; error: "+e);
                    }
                }
            } else {
                payload.args = convertMessageToArgsNativeToJs(payload.args);
            }
            cordova.callbackFromNative(payload.callbackId, payload.success, payload.status, payload.args, payload.keepCallback);
        }
    } catch(e) {
//        console.warn("Error parse event.data: "+e);
    }
});

iOSExec.broadcastToIFrame = function(origin, callbackId, success, status, args, keepCallback) {
   var arguments = {
       callbackId: callbackId,
       success:success,
       status:status,
       args:args,
       keepCallback:keepCallback
   }
   var message = JSON.stringify(arguments);
   if(window.location.origin == origin) {
       window.postMessage(message, origin);
   } else {
       const iframes = iOSExec.getAllIFrames(document);
       for (i = 0; i < iframes.length; ++i) {
           try {
               const originFromFrame = new URL(iframes[i].src).origin;
               if(originFromFrame === origin) {
                   iframes[i].contentWindow.postMessage(message, origin);
               }
           } catch(err) {
               console.error("Error to postMessage to frame: "+err);
           }
       }
   }
}

iOSExec.getAllIFrames = function(document) {
    const iframes = document.getElementsByTagName("iframe");
//    if(iframes.length > 0) {
//        for(i=0; i < iframes.length; i++) {
//            iframes.concat(ios.iOSExec.getAllIFrames(iframes[i]));
//        }
//    }
    return iframes;
}
    
// for backwards compatibility
iOSExec.nativeEvalAndFetch = function (func) {
    try {
        func();
    } catch (e) {
        console.log(e);
    }
};

// Proxy the exec for bridge changes. See CB-10106

function cordovaExec () {
    var cexec = require('cordova/exec');
    var cexec_valid =
        typeof cexec.nativeFetchMessages === 'function' &&
        typeof cexec.nativeEvalAndFetch === 'function' &&
        typeof cexec.nativeCallback === 'function';
    return cexec_valid && execProxy !== cexec ? cexec : iOSExec;
}

function execProxy () {
    cordovaExec().apply(null, arguments);
}

execProxy.nativeFetchMessages = function () {
    return cordovaExec().nativeFetchMessages.apply(null, arguments);
};

execProxy.nativeEvalAndFetch = function () {
    return cordovaExec().nativeEvalAndFetch.apply(null, arguments);
};

execProxy.nativeCallback = function () {
    return cordovaExec().nativeCallback.apply(null, arguments);
};
    
function randomString(length) {
    var result           = [];
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
      result.push(characters.charAt(Math.floor(Math.random() * charactersLength)));
    }
    return result.join('');
}

let ENCRYPTION_KEY = "ENCRYPTION_KEY";
var RANDOM_IV = CryptoJS.lib.WordArray.random(128/8).toString(CryptoJS.enc.Base64);
if (localStorage.getItem(ENCRYPTION_KEY) === null ) {
    console.log("Generate AES");
    var salt = randomString(25);
    var hash = CryptoJS.SHA256(salt);
    var key = CryptoJS.PBKDF2(randomString(45), hash, { keySize: 256/32, iterations: 1000 });
    localStorage.setItem(ENCRYPTION_KEY, key.toString(CryptoJS.enc.Base64));
} else {
    console.log("Key already generated and will use from localStorage");
}

module.exports = execProxy;

if (
    window.webkit &&
    window.webkit.messageHandlers &&
    window.webkit.messageHandlers.cordova &&
    window.webkit.messageHandlers.cordova.postMessage
) {
    // unregister the old bridge
    cordova.define.remove('cordova/exec');
    // redefine bridge to our new bridge
    cordova.define('cordova/exec', function (require, exports, module) {
        module.exports = execProxy;
    });
}
