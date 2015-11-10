public class CAESContext
{
	public Long nr; 
	/*!< number of rounds */
	 
	public Long[] buf;
	
	public CAESContext()
	{ 
		buf = new Long[44];
		nr = 10;
	}
}