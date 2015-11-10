@isTest
private class TestCryptoUtils {

    static testMethod void runTest() {
	
        String Input = '0807060504030201';
		String Output = '';			
		Integer[] inputValue= new Integer[16];
		
		for(Integer i =0; i < 16;i++)		
		{			
		    inputValue[i] = Character.toAscii(Input.substring(i,i+1));
		
		}
		
		Long[] key = new Integer[]{1234,5678,5678,5678};
		
		Integer [] outputValues 
		    = CryptoUtils.CustomAESWithObfuscate(new Integer[] { 1234,5678,5678,5678 },				
											             CryptoUtils.HexStringToCodePoint('1234567812345678'),				
											             System.today(),
											             System.today() + 2);
											             
		Output += 'Encrypted Value';
		for(Integer i=0; i< 16;i++)
		{
			Output += outputValues [i] + ',' ;
		}
		
		System.Debug(Output);
		
		CryptoUtils.generateEncryptionKey();
		
		Long [] RK = new Integer[]{1234,5678,5678,5678};
		CryptoUtils.RefObject  X0 = new CryptoUtils.RefObject(2147483648L);
		CryptoUtils.RefObject  X1 = new CryptoUtils.RefObject(2147483648L);  
		CryptoUtils.RefObject  X2 = new CryptoUtils.RefObject(2147483648L);
		CryptoUtils.RefObject  X3 = new CryptoUtils.RefObject(2147483648L); 
		Long Y0 = 2147483648L; 
		Long Y1 = 2147483648L; 
		Long Y2 = 2147483648L; 
		Long Y3 = 2147483648L;
		
		CryptoUtils.AESRROUND(RK,X0,X1,X2,X3,Y0,Y1,Y2,Y3);
		CryptoUtils.AESRROUND(RK,X0,X1,X2,X3,Y0,Y1,Y2,Y3);
		CryptoUtils.setbits(1234, 5678, 1234, 8910);
		
		CAESContext cty = new CAESContext();
		cty.buf = new Long[44];
        cty.nr = 10;
		
		CryptoUtils.AESSetKeyDec(cty, new Integer[]{1234,5678,5678,5678,3434,54545,34343,12323}, 128);	
		
		CryptoUtils.AESGetExpandedkeyDec(new Integer[]{1234,5678,5678,5678,3434,54545,34343,12323}, 128);
			
			
    }
}