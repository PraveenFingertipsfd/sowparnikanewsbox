public without sharing class GenerateOTP {
    public static String generateUniqueOTP(){
        String randomIntegerString = string.valueOf(Math.abs(Crypto.getRandomInteger()));
        String otp = randomIntegerString.substring(0,4);
        system.debug(otp);
        return otp; 
    }
    
    public static String checkForDuplicateOTPs(){
        String randomIntegerString = string.valueOf(Math.abs(Crypto.getRandomInteger()));
        String otp = randomIntegerString.substring(0,4);
        system.debug(otp);
        return otp; 
    }
}