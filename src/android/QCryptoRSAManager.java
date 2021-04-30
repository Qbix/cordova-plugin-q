package com.q.cordova.plugin;

import android.security.keystore.KeyProperties;
import android.util.Base64;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

public class QCryptoRSAManager {
    private KeyPair keyPair;
    private QCryptoRSAManager(){}
    public static com.q.cordova.plugin.QCryptoRSAManager instance;
    public static com.q.cordova.plugin.QCryptoRSAManager getInstance() {
        if(instance == null) {
            instance = new com.q.cordova.plugin.QCryptoRSAManager();
            try {
                instance.createKeyPair();
            } catch (NoSuchAlgorithmException e) {
                e.printStackTrace();
                throw new RuntimeException("Failed to create keypair");
            }
        }
        return instance;
    }

    private void createKeyPair() throws NoSuchAlgorithmException {
        KeyPairGenerator generator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA);

        generator.initialize(2048, new SecureRandom());
        keyPair = generator.genKeyPair();
    }

    public String getPublicKeyBase64() {
        byte[] publicKeyBytes = Base64.encode(keyPair.getPublic().getEncoded(), 0);
        String pubKey = new String(publicKeyBytes);
        pubKey = "-----BEGIN PUBLIC KEY-----\n" + pubKey + "-----END PUBLIC KEY-----\n";
        try {
            return Base64.encodeToString(pubKey.getBytes("UTF-8"), Base64.DEFAULT);
        } catch (UnsupportedEncodingException e) {
            return null;
        }
    }

    public String decrypt(byte[] encryptedBytes) throws InvalidKeyException, NoSuchPaddingException, NoSuchAlgorithmException, BadPaddingException, IllegalBlockSizeException, UnsupportedEncodingException {
        Cipher cipher1 = Cipher.getInstance("RSA/None/PKCS1Padding");
        cipher1.init(Cipher.DECRYPT_MODE, keyPair.getPrivate());
        byte[] decryptedBytes = cipher1.doFinal(encryptedBytes);
        String decrypted = new String(decryptedBytes);
        return decrypted;
    }

}