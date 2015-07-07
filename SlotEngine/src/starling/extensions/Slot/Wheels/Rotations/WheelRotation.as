package starling.extensions.Slot.Wheels.Rotations
{
	import flash.errors.IllegalOperationError;
	import starling.extensions.Slot.Wheels.Wheel;
	
	import starling.animation.IAnimatable;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	
	/**
	 * Super class of every WheelRotation.
	 * @see WheelRotationRealistic
	 * */
	public class WheelRotation
	{
		protected var wheel:Wheel;
		private var old_touchable:Boolean;

		public function WheelRotation(wheel:Wheel)
		{
			this.wheel = wheel;
			old_touchable = this.wheel.touchable;
			this.wheel.touchable=false;
			this.wheel.state = Wheel._STABLE_;
		}
		
	 	public function end_rotation():void
		{
			this.wheel.touchable=old_touchable;
			this.wheel.state = Wheel._STABLE_;
			this.wheel.dispatchEventWith(Wheel.EVENT_END_ROTATION);
		}
		
		public function gotAnswer():void
		{
			throw new IllegalOperationError("Call the correct GotAnswer. Cast to WheelRotationRealistic or whatever");
		}
	

	}
}