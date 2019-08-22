/*Description : Class to avoid recursive trigger calls.*/

public class CaseTriggerRunOnce{
	public static boolean alreadyRun = false;

    public static boolean hasAlreadyRun(){
        return alreadyRun;
    } 
    
    public static void setAlreadyRun(){
        alreadyRun = true;
    }
}