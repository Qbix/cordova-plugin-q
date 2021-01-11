//
//  QSignUtils.swift
//  Qbix
//
//  Created by Igor on 6/30/17.
//
//

import Foundation
import SwiftyRSA
import CommonCrypto

private let _singletonInstance = QSignUtils()

struct QSignError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
}

@objc class QSignUtils: NSObject {
    /** Shared instance */
    @objc class func sharedInstance() -> QSignUtils {
        return _singletonInstance
    }
    
    @objc  func signWithHmac(_ password:String, inputParameters parameters: [String:Any]) -> [String:Any]? {
        let unEncryptedString: String
        do {
            unEncryptedString = try self.getStringToSign(parameters)
        } catch let error as QSignError {
            return nil
        } catch {
            return nil
        }
        
        print(unEncryptedString)
        print(password)
        var signParameters = NSMutableDictionary(dictionary: parameters);
        
        signParameters["Q.hmac"] = QCryptoRSAManager.sharedInstance.hmacSha1(string:unEncryptedString, password: password);
        
        return signParameters as? [String : Any]
    }
    
    @objc func sign(_ password:String, inputParameters parameters: [String:Any]) -> [String:Any]? {
        NSLog("START")
        let unEncryptedString: String
        do {
            unEncryptedString = try self.getStringToSign(parameters)
        } catch let error as QSignError {
            return nil
        } catch {
            return nil
        }
        
        print(unEncryptedString)
        print(password)
        var signParameters =  NSMutableDictionary(dictionary: parameters);
        
        signParameters["Q.hmac"] = QCryptoRSAManager.sharedInstance.hmacSha1(string:unEncryptedString, password: password);
        
        if(QCryptoRSAManager.sharedInstance.isSecureKeyPairWithAutogenerate()) {
            let privateKeyRef = QCryptoRSAManager.sharedInstance.getPrivateKeyReference()
            guard let clear = try? ClearMessage(string: unEncryptedString, using: .utf8) else {
                return nil;
            }
            guard let privateKey = try? PrivateKey(reference: privateKeyRef!) else {
                return nil;
            }
            guard let signature = try? clear.signed(with: privateKey, digestType: .sha512) else {
                return nil;
            }
            
            let base64String = signature.base64String
            
            signParameters["Q.sig"] = base64String;
            signParameters["Q.pubkey"] = QCryptoRSAManager.sharedInstance.getExportedPublicKey();
            
            return signParameters as? [String : Any]
        }
        return nil
    }
    
    @objc func sign(_ password:String, inputParameters parameters: [String:Any], completion: @escaping (_ signParameters: [String:Any], _ error: String?) -> Void) {
        
        let unEncryptedString: String
        do {
            unEncryptedString = try self.getStringToSign(parameters)
        } catch let error as QSignError {
            completion([:], error.message);
            return
        } catch {
            completion([:], "Internal error. Invalid input data")
            return
        }
        
        var signParameters = NSMutableDictionary(dictionary: parameters);
        signParameters["Q.hmac"] = QCryptoRSAManager.sharedInstance.hmacSha1(string:unEncryptedString, password: password);
        
        QCryptoRSAManager.sharedInstance.getSecureKeyPairWithAutogenerate { (_ privateKeyRef:SecKey?, _ publicKeyRef:SecKey?) in
            
            guard let clear = try? ClearMessage(string: unEncryptedString, using: .utf8) else {
                completion([:], "Internal error. Invalid not encrypt data");
                return;
            }
            guard let privateKey = try? PrivateKey(reference: privateKeyRef!) else {
                completion([:], "Internal error. Invalid private key");
                return;
            }
            guard let signature = try? clear.signed(with: privateKey, digestType: .sha512) else {
                completion([:], "Internal error. Invalid encrypted result");
                return;
            }
            
            let base64String = signature.base64String
            
            signParameters["Q.sig"] = base64String;
            signParameters["Q.pubkey"] = QCryptoRSAManager.sharedInstance.getExportedPublicKey();
            completion(signParameters as! [String : Any], nil);
        }
    }
    
    func sha256(string: String) -> Data? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData
    }
    
    func getStringToSign(_ parameters: [String:Any]) throws -> String {
        guard let parameterString = try stringFromHttpParameters(parameters) else {
            throw QSignError(message: "Invalid input key:value object")
        }
        
        return parameterString
    }
    
    func addingPercentEncodingForURLQueryValue(_ message:String) -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return message.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func isArray(_ object:Any) -> Bool {
        return object is [Any]
    }
    
    func stringFromHttpParameters(_ parametes:[String:Any]) throws -> String? {
        
        let sortedKeys = parametes.keys.sorted()
        
        let parameterArray = try sortedKeys.map { (key) -> String in
            var realValue = ""
            guard let value = parametes[key] else {
                throw QSignError(message: "Invalid input data. Not found value for key: \(key)")
            }
            if isArray(value) {
                let valueArray = (value as! [Any])
                
                realValue = try (value as! [Any]).map({ (item:Any) -> String in
                    if(isArray(item)) {
                        throw QSignError(message: "Invalid input data. It has nested array in array")
                    }
                    return String(describing: item)
                }).joined(separator: ",")
            } else {
                realValue = String(describing:value)
            }
            
                let percentEscapedKey = addingPercentEncodingForURLQueryValue(key)!
                let percentEscapedValue = addingPercentEncodingForURLQueryValue(realValue)!
                return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        let filtered = parameterArray.filter({ (parameter) -> Bool in
            return parameter != ""
        })
        
        return filtered.joined(separator: "&")
    }
}
