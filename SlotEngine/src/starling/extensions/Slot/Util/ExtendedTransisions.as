package starling.extensions.Slot.Util
{
	import starling.animation.Transitions;
	import starling.errors.AbstractClassError;

	public class ExtendedTransisions
	{
		public static const  WHEEL_IN_BOUNCE:String = "WheelInBounce";
		public static const  WHEEL_OUT_BOUNCE:String = "WheelOutBounce";
		public static const  WHEEL_IN_OUT_BOUNCE:String = "WheelInOutBounce";
		public static const  WHEEL_OUT_BOUNCE_PLAIN:String = "WheelInOutBouncePlain";
		
		public function ExtendedTransisions()
		{
			throw new AbstractClassError();
		}
		
		public static function RegisterDefaults():void
		{
			Transitions.register(WHEEL_IN_BOUNCE,
				function(ratio:Number):Number
				{
					var s:Number = 0.8;
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
				
			Transitions.register(WHEEL_OUT_BOUNCE_PLAIN,
				function(ratio:Number):Number
				{
					var m:Number = 1.15;
					var pl:Number = 0.9; //Revert point
					var x1:Number = pl;
					var y1:Number = m * pl;
					var x2:Number = 1;
					var y2:Number = 1;
					
					var d1:Number = y2 - y1;
					var d2:Number = x2 - x1;
					var m2:Number = d1 / d2;
					var c2:Number = (-x1) / d2 * d1 + y1;
					var y:Number;
					
				
					if (ratio >= pl)
						y = (m2 * ratio) + c2;
					else
						y = m * ratio;
						
					if (y >= 0.9999 && y <1)
						y = 1;
					return y;
					
				});	
		}
		
	}
}