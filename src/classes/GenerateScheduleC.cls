public class GenerateScheduleC {

    List<Asset> assets;



    public List<Asset> getAssets() {

        if(assets == null) assets = [select name from asset limit 10];

        return assets;

    }
    
    static testmethod void runTest()
    {
    	GenerateScheduleC c = new GenerateScheduleC();
    	c.getAssets();
    }

}