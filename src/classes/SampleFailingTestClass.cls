/*This is the sample test class used for first production deployment.*/

@isTest
public class SampleFailingTestClass { 

    public static testmethod void failingTest() {
        SampleDeployClass.getPhone();
        SampleDeployClass.helloMethod();
        Account acc = new Account(Name= 'fred',phone = '867-5309');
        insert acc;

        Account retAcc = [select id, phone from Account where id=:acc.id][0];
        System.assertEquals('867-5309', retAcc.phone); // Always fails.
    }
}