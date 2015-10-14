package
{
	import flash.display.Sprite;
	import starling.core.Starling;
	

	[SWF(width="800", height="600", frameRate="60", backgroundColor="#000000")]
	public class Main extends Sprite 
	{
		private var mStarling:Starling;
		
		public function Main() 
		{
			mStarling = new Starling(Game, stage);
            mStarling.start();
		}
		
	}
	
}