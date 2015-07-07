package starling.extensions.Slot.Wheels
{
	import starling.display.Image;
	
	public class Icon
	{
		public var value:int;
		public var image:Image;
		public var state:int;
		public var animation:Object;
		public var border:Object;
		
		public static var NO_ANIMATION:int = 0;
		public static var YES_ANIMATION:int = 1;
		

		public function Icon(_value:int,_image:Image = null)
		{
			value = _value;
			image = _image;
			state = NO_ANIMATION;
			animation = null;
			border = null;
		}

	}
}