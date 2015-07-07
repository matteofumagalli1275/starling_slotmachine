package starling.extensions.Slot.Wheels
{
	//import mx.collections.ArrayList;
	
	import starling.display.MovieClip;
	import starling.display.Sprite;

	/**
	 * It contains all the wheels of the slot, merging the singolar wheels.
	 * This should be used for set and get icons, calculate wins etc...
	 * */
	public class WheelMatrix extends Sprite
	{
		private var _wheels:Vector.<Wheel>;
		public static const EVENT_END_ROTATION:String = "end_rotation";
		
		/**Possible parameters:<br/>
		 * - Vector. type[Wheel] <br/>
		 * - wheel1,wheel2,wheel3,...
		 * */
		public function WheelMatrix(..._wheels):void
		{
		    if(_wheels.length>0)
			{
				if(_wheels.length==1 && _wheels[0] is Vector.<Wheel>)
				{
					this._wheels = new Vector.<Wheel>();
					for each(var wheel:Wheel in _wheels[0])
					{
						if(wheel is Wheel)
						{
							this._wheels.push(wheel);
							this.addChild(wheel);
						}
						else
						{
							this._wheels.length = 0;
							this.removeChildren();
							throw new ArgumentError("WheelMatrix_1 - Invalid argument");
						}
					}
				}
				else
				{
					this._wheels = new Vector.<Wheel>();
					for each(var _wheel:Wheel in _wheels)
					{
						if(_wheel is Wheel)
						{
							this._wheels.push(_wheel);
							this.addChild(_wheel);
						}
						else
						{
							this._wheels.length = 0;
							this.removeChildren();
							throw new ArgumentError("WheelMatrix_2 - Invalid argument");
						}
					}
				}
			}		
			else
				throw new ArgumentError("WheelMatrix_3 - Invalid argument, length: " + _wheels.length.toString());
			for(var index:int=0;index<this._wheels.length;index++)
			{
				
				this._wheels[index].addEventListener(Wheel.EVENT_END_ROTATION,handle_end_rotation);
			}
			
		}
		
		public function SetWheelOffX(offx:int):void
		{
			for(var i:int = 0; i<(this._wheels.length); i++)
			{
				this._wheels[i].x = offx*i;
			}
		}
		
		
		/**
		 * Check if every wheelmatrix is stable (not rotating or paused), if it's an event
		 * "end_rotation" will be thrown attached to the wheelmatrix
		 * */
		private function handle_end_rotation():void
		{
			var all_stopped:Boolean = true;
			var index:int;
			for(index=0;index<_wheels.length;index++)
			{
				if(this._wheels[index].state != Wheel._STABLE_)
					all_stopped=false;

			}

			if(all_stopped==true)
			{
				/*for(index=0;index<this._wheels.length;index++)
				{
					this._wheels[index].removeEventListeners("end_rotation");
				}*/
				this.dispatchEventWith(EVENT_END_ROTATION);
			}				

		}

		public function set wheels(wheels:Vector.<Wheel>):void
		{
			this._wheels = wheels;
		}
		
		public function get wheels():Vector.<Wheel>
		{
			return this._wheels;
		}
		
		public static function set_values(wheel_tmp:WheelMatrix,values:Vector.<int>):void
		{
			for(var i:int=0;i<wheel_tmp.wheels.length;i++)
			{
				for(var j:int=0;j<wheel_tmp.wheels[i].img_icons.length;j++)
				{
					wheel_tmp.wheels[i].set(j,values[i+j*wheel_tmp.wheels.length],true);
				}
			}
		}
	}
}