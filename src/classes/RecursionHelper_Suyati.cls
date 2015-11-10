public class RecursionHelper_Suyati {

 private static boolean alreadyranonce = false;


    public static boolean hasAlreadyRanOnce() {
        return alreadyranonce;
    }

    // By setting the variable to true, it maintains this  
    // new value throughout the duration of the request  
    // (or testMethod)  
    
    public static void setAlreadyCreatedFollowUpTasks() {
        alreadyranonce = true;
    }
 }