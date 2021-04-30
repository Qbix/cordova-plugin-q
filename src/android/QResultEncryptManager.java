package com.q.cordova.plugin;

import android.content.Context;
import android.util.Base64;
import android.util.Pair;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class QResultEncryptManager {
    private Map<String, Pair<String, String>> keys = new HashMap<>();
    private QResultEncryptManager(){}
    public static QResultEncryptManager instance;
    public static QResultEncryptManager getInstance() {
        if(instance == null) {
            instance = new QResultEncryptManager();
        }
        return instance;
    }

    public boolean isAllowEncryption() {
        return true;
    }

    public String getPubKey() {
        return QCryptoRSAManager.getInstance().getPublicKeyBase64();
    }

    public String decodeRSA(String encrypted) {
        try {
            return QCryptoRSAManager.getInstance().decrypt(Base64.decode(encrypted, Base64.NO_WRAP));
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String decryptAes(String encryptedBase64, String keyBase64, String ivBase64) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec keySpec = new SecretKeySpec(Base64.decode(keyBase64, Base64.NO_WRAP), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(Base64.decode(ivBase64, Base64.NO_WRAP));
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
            byte[] decryptedText = cipher.doFinal(Base64.decode(encryptedBase64, Base64.NO_WRAP));
            return new String(decryptedText);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public String encryptAes(String payload, String keyBase64, String ivBase64) {
        try {
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec keySpec = new SecretKeySpec(Base64.decode(keyBase64, Base64.NO_WRAP), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(Base64.decode(ivBase64, Base64.NO_WRAP));
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            byte[] encryptedText = cipher.doFinal(payload.getBytes());
            return Base64.encodeToString(encryptedText, Base64.NO_WRAP);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public void setEncryptKeyForCallbackId(String aesBase64Key, String aesBase64Iv, String callbackId) {
        keys.put(callbackId, new Pair<>(aesBase64Key, aesBase64Iv));
    }

    public  Pair<String, String> getEncryptKeyForCallbackId(String callbackId) {
        Pair<String, String> response = keys.get(callbackId);
        keys.remove(callbackId);
        return response;
    }

//    + (NSString *)decrypt:(NSString *)encryptedBase64String withKey:(NSString*)keyBase64 andIv:(NSString*)ivBase64 error:(NSError **)error {
//        NSData* key = [[NSData alloc] initWithBase64EncodedString:keyBase64 options:0];
//        NSData* iv = [[NSData alloc] initWithBase64EncodedString:ivBase64 options:0];
//        NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:encryptedBase64String options:0];
//        NSMutableData *result = [QResultEncryptManager doAES:dataToDecrypt withKey:key andIv:iv context:kCCDecrypt error:error];
//        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//    }
}
