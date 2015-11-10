trigger generateEncryptedKey on Asset (before Update) {

    for(Asset a : trigger.new)
    {
          if(a.CreateEncryptionKeys__c.equalsIgnoreCase('TRUE')
             && a.Encryption_Key_01__c == null)
          {
               //a.Encryption_Key__c = CryptoUtils.generateEncryptionKey();
               a.Encryption_Key_01__C = Math.abs(Crypto.getRandomInteger());
               a.Encryption_Key_02__C = Math.abs(Crypto.getRandomInteger());
               a.Encryption_Key_03__C = Math.abs(Crypto.getRandomInteger());
               a.Encryption_Key_04__C = Math.abs(Crypto.getRandomInteger());
               
          }
    }

}