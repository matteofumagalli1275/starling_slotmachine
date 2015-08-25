package starling.extensions.Slot.Util
{
	import starling.animation.Transitions;
	import starling.errors.AbstractClassError;

	public class ExtendedTransisions
	{
		public static const  WHEEL_IN_BOUNCE:String = "WheelInBounce";
		public static const  WHEEL_OUT_BOUNCE:String = "WheelOutBounce";
		public static const  WHEEL_IN_OUT_BOUNCE:String = "WheelInOutBounce";
		
		public function ExtendedTransisions()
		{
			throw new AbstractClassError();
		}
		
		public static function RegisterDefaults():void
		{
			Transitions.register(WHEEL_IN_BOUNCE,
				function(ratio:Number):Number
				{
					var s:Number = 0.7;
					return Math.pow(ratio, 2) * ((s + 1.0)*ratio - s);
				});	
			
			Transitions.register(WHEEL_OUT_BOUNCE,
				function(ratio:Number):Number
				{
					var invRatio:Number = ratio - 1.0;
					var s:Number = 0.8;
					return Math.pow(invRatio, 2) * ((s + 1.0)*invRatio + s) + 1.0;
				});	
			
			Transitions.register(WHEEL_IN_OUT_BOUNCE,
				function(ratio:Number):Number
				{
					if (ratio < 0.5) return 0.5 * Transitions.getTransition(WHEEL_IN_BOUNCE)(ratio*2.0);
					else return 0.5 * Transitions.getTransition(WHEEL_OUT_BOUNCE)((ratio-0.5)*2.0) + 0.5;
				});	
		}
		
	}
}