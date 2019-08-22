public class RunOnce {

    public static boolean alreadyRun = false;
    public static boolean alreadyRunOrphan = false;
    
    public static boolean hasAlreadyRun() {
        return alreadyRun;
    }
 
    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request 
    public static void setAlreadyRun() {
        alreadyRun = true;
    }

    public static void serAlreadyRunOrphan(){
          alreadyRunOrphan = true;
        
    }
    
    public static boolean hasAlreadyRunOrphan(){
           return alreadyRunOrphan;
        
    }
}