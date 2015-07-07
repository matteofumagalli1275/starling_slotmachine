package 
{
	/**
	 * ...
	 * @author Matteo Fumagalli
	 */
	public class Assets 
	{
		
		// Embed the Atlas XML
		[Embed(source="../assets/output/sprites.xml", mimeType="application/octet-stream")]
		public static const SpritesXml:Class;
		 
		// Embed the Atlas Texture:
		[Embed(source="../assets/output/sprites.png")]
		public static const sprites:Class;
		
	}

}