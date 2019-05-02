# Q Cordova Pluign

cordova plugins add https://github.com/Qbix/cordova-pluign-q --variable URL_SCHEME="<openurl>"

## schema
Get openUrl schema. Returns String value.

### Supporded platforms
- __iOS__

__Example__:
```js
Q.Cordova.schema(function(schema){console.log(schema);}, function(err){console.log(err)})
```

## readQConfigValue
Get config value by key. Returns String value.

### Parameters
__key__: `key` of property wanted to be returned. There are available next property keys:
"cacheBaseUrl"
"pathToBundle"
"injectCordovaScripts"
"bundleTimestamp"
"enableLoadBundleCache"
"pingUrl"
"url"
"baseUrl"
"openUrlScheme"
"userAgentSuffix"

### Supporded platforms
- __iOS__
- __Android__

__Example__:
```js
Q.Cordova.readQConfigValue(key,function(schema){console.log(schema);}, function(err){console.log(err)})
```

## info
Get info about nativa app properties. Returns JSON object with `Q.appId` and `Q.udid` values.

### Supporded platforms
- __iOS__
- __Android__

__Example__:
```js
Q.Cordova.info(function(info){console.log(info);}, function(err){console.log(err)})
```

## chooseLink
Open native view where user can navigate through webbrowser and select some link. Selected link will receive in `successCallback`. Return selected link as String.

### Parameters
-__initialUrl__: `initialUrl` which browser open automatically after invoking this method.
-__isMetadata__: if true, receives metadata(title, keywords, description) in `metadataCallback`

### Supporded platforms
- __iOS__

__Example__:
```js
Q.Cordova.chooseLink(initialUrl, isMetadata, successCallback, metadataCallback, errorCallback)
```

## chooseImage
Open native view where user can navigate through webbrowser and select some image. Link on selected image will receive in `successCallback`. Return selected image as link.

### Parameters
-__initialUrl__: `initialUrl` which browser open automatically after invoking this method.
-__isMetadata__: if true, receives metadata(title, keywords, description) in `metadataCallback`

### Supporded platforms
- __iOS__

__Example__:
```js
Q.Cordova.chooseImage(initialUrl, isMetadata, successCallback, metadataCallback, errorCallback)
```
