/*********************************************************************************
Name:           Check_MVR_Future_Call
Author:         Swapnil Gholap
Purpose:        Helper class to check MVR record updated from MVR Customer component Button "Mark all Clean for this Account" to avoid Callout
Created Date:   13 Aug 2018

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class Check_MVR_Future_Call {        
    private static boolean isCalledFromMVR_Button = false;
      
    
    public static void updateFlag(){
        isCalledFromMVR_Button = true;
    } 
   
    public static boolean isCalledFromMVR_BTN(){
        System.debug('--isCalledFromMVR_Button-'+isCalledFromMVR_Button);
        if(isCalledFromMVR_Button){             
             System.debug('--return true--');
             return true;
        }else{
            System.debug('--return False--'+isCalledFromMVR_Button);
            return isCalledFromMVR_Button;
        }    
	}
}