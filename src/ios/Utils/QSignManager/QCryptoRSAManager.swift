import UIKit

// Singleton instance
private let _singletonInstance = QCryptoRSAManager()

// Constants
private let kQCryptoRSAManagerApplicationTag = "com.q.cordova.keypair"
private let kQCryptoRSAManagerKeyType = kSecAttrKeyTypeRSA
private let kQCryptoRSAManagerKeySize = 2048
private let kQCryptoRSAManagerCypheredBufferSize = 1024
private let kQCryptoRSAManagerSecPadding: SecPadding = .PKCS1

enum AsymmetricCryptoException: Error {
    case unknownError
    case duplicateFoundWhileTryingToCreateKey
    case keyNotFound
    case authFailed
    case unableToAddPublicKeyToKeyChain
    case wrongInputDataFormat
    case unableToEncrypt
    case unableToDecrypt
    case unableToSignData
    case unableToVerifySignedData
    case unableToPerformHashOfData
    case unableToGenerateAccessControlWithGivenSecurity
    case outOfMemory
}

@objc(QCryptoRSAManager) open class QCryptoRSAManager: NSObject {

    /** Shared instance */
    class var sharedInstance: QCryptoRSAManager {
        return _singletonInstance
    }
    
    // MARK: - Manage keys
    
    func createSecureKeyPair(_ completion: ((_ success: Bool, _ error: AsymmetricCryptoException?) -> Void)? = nil) {
        // private key parameters
        let privateKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag as AnyObject
        ]
        
        // private key parameters
        let publicKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag as AnyObject
        ]
        
        // global parameters for our key generation
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String:          kQCryptoRSAManagerKeyType,
            kSecAttrKeySizeInBits as String:    kQCryptoRSAManagerKeySize as AnyObject,
            kSecPublicKeyAttrs as String:       publicKeyParams as AnyObject,
            kSecPrivateKeyAttrs as String:      privateKeyParams as AnyObject,
            ]
        
        // asynchronously generate the key pair and call the completion block
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var pubKey, privKey: SecKey?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &pubKey, &privKey)
            
            if status == errSecSuccess {
                DispatchQueue.main.async(execute: { completion?(true, nil) })
            } else {
                var error = AsymmetricCryptoException.unknownError
                switch (status) {
                case errSecDuplicateItem: error = .duplicateFoundWhileTryingToCreateKey
                case errSecItemNotFound: error = .keyNotFound
                case errSecAuthFailed: error = .authFailed
                default: break
                }
                DispatchQueue.main.async(execute: { completion?(false, error) })
            }
        }
    }
    
    func getPublicKeyData() -> Data? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true
            ] as [String : Any]
        var data: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &data)
        if status == errSecSuccess {
            return data as? Data
        } else { return nil }
    }
    
    func getPublicKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    func getPrivateKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    func keyPairExists() -> Bool {
        return self.getPublicKeyData() != nil
    }
    
    func deleteSecureKeyPair(_ completion: ((_ success: Bool) -> Void)?) {
        // private query dictionary
        let deleteQuery = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: kQCryptoRSAManagerApplicationTag,
            ] as [String : Any]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            let status = SecItemDelete(deleteQuery as CFDictionary) // delete private key
            DispatchQueue.main.async(execute: { completion?(status == errSecSuccess) })        }
    }
    
    func getSecureKeyPairWithAutogenerate(_ completion: ((_ privateKey: SecKey?, _ publicKey:SecKey?) -> Void)?) {
    
        if(!self.keyPairExists()) {
            self.createSecureKeyPair({ (success, error) in
                if success {
                    completion?(self.getPrivateKeyReference(), self.getPublicKeyReference());
                } else {
                    completion?(nil, nil);
                }
            });
        } else {
            completion?(self.getPrivateKeyReference(), self.getPublicKeyReference());
        }
        
    }
    
    // MARK: - Cypher and decypher methods
    
    func encryptMessageWithPublicKey(_ message: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let publicKeyRef = self.getPublicKeyReference() {
                // prepare input input plain text
                guard let messageData = message.data(using: String.Encoding.utf8) else {
                    completion(false, nil, .wrongInputDataFormat)
                    return
                }
                let plainText = (messageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: messageData.count)
                let plainTextLen = messageData.count
                
                // prepare output data buffer
                var cipherData = Data(count: SecKeyGetBlockSize(publicKeyRef))
                let cipherText = cipherData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var cipherTextLen = cipherData.count
                
                let status = SecKeyEncrypt(publicKeyRef, .PKCS1, plainText, plainTextLen, cipherText, &cipherTextLen)
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(status == errSecSuccess, cipherData, status == errSecSuccess ? nil : .unableToEncrypt)
                    cipherText.deinitialize()
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    func decryptMessageWithPrivateKey(_ encryptedData: Data, completion: @escaping (_ success: Bool, _ result: String?, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                // prepare input input plain text
                let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
                let encryptedTextLen = encryptedData.count
                
                // prepare output data buffer
                var plainData = Data(count: kQCryptoRSAManagerCypheredBufferSize)
                let plainText = plainData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var plainTextLen = plainData.count
                
                let status = SecKeyDecrypt(privateKeyRef, .PKCS1, encryptedText, encryptedTextLen, plainText, &plainTextLen)
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    if status == errSecSuccess {
                        // adjust NSData length
                        plainData.count = plainTextLen
                        // Generate and return result string
                        if let string = NSString(data: plainData as Data, encoding: String.Encoding.utf8.rawValue) as? String {
                            completion(true, string, nil)
                        } else { completion(false, nil, .unableToDecrypt) }
                    } else { completion(false, nil, .unableToDecrypt) }
                    plainText.deinitialize()
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    // MARK: - Sign and verify signature.
    
    func signMessageWithPrivateKey(_ message: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var error: AsymmetricCryptoException? = nil
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                // result data
                var resultData = Data(count: SecKeyGetBlockSize(privateKeyRef))
                let resultPointer = resultData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var resultLength = resultData.count
                
                if let plainData = message.data(using: String.Encoding.utf8) {
                    // generate hash of the plain data to sign
                    var hashData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
                    let hash = hashData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                        return bytes
                    })
                    CC_SHA1((plainData as NSData).bytes.bindMemory(to: Void.self, capacity: plainData.count), CC_LONG(plainData.count), hash)
                    
                    // sign the hash
                    let status = SecKeyRawSign(privateKeyRef, SecPadding.PKCS1SHA1, hash, hashData.count, resultPointer, &resultLength)
                    if status != errSecSuccess { error = .unableToEncrypt }
                    else { resultData.count = resultLength }
                    hash.deinitialize()
                } else { error = .wrongInputDataFormat }
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    if error == nil {
                        // adjust NSData length and return result.
                        resultData.count = resultLength
                        completion(true, resultData as Data, nil)
                    } else { completion(false, nil, error) }
                    //resultPointer.destroy()
                })
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    func verifySignaturePublicKey(_ data: Data, signatureData: Data, completion: @escaping (_ success: Bool, _ error: AsymmetricCryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var error: AsymmetricCryptoException? = nil
            
            if let publicKeyRef = self.getPublicKeyReference() {
                // hash data
                var hashData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
                let hash = hashData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                CC_SHA1((data as NSData).bytes.bindMemory(to: Void.self, capacity: data.count), CC_LONG(data.count), hash)
                // input and output data
                let signaturePointer = (signatureData as NSData).bytes.bindMemory(to: UInt8.self, capacity: signatureData.count)
                let signatureLength = signatureData.count
                
                let status = SecKeyRawVerify(publicKeyRef, SecPadding.PKCS1SHA1, hash, Int(CC_SHA1_DIGEST_LENGTH), signaturePointer, signatureLength)
                
                if status != errSecSuccess { error = .unableToDecrypt }
                
                // analyze results and call the completion in main thread
                hash.deinitialize()
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(status == errSecSuccess, error)
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, .keyNotFound) }) }
        }
    }
    
    func sha256(string: String) -> NSString? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined() as NSString
    }
    
    
}



