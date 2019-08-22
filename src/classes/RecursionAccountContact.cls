public class RecursionAccountContact {
    
    private static boolean alreadyRun = false;

    public static boolean hasAlreadyRun() {
        return alreadyRun;
    }
 
    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request 
    public static void setAlreadyRun() {
        alreadyRun = true;
    }
}