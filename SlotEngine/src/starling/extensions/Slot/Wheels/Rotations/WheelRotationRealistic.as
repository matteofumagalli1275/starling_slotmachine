package starling.extensions.Slot.Wheels.Rotations
{
	import starling.extensions.Slot.Wheels.Icon;
	import starling.extensions.Slot.Wheels.Wheel;
	import starling.extensions.Slot.Wheels.Rotations.WheelRotation;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;

	/**
	 * Every icon is moved according to the cursor_rotation. To blend/filter the icon at the begging
	 * you can do that to the wheel.
	 * 
	 * @see WheelRotation.init_rotation
	 * */
	public class WheelRotationRealistic extends WheelRotation
	{
		private var hidden_icon:Icon;
		private var _rotation_values:Vector.<int>;
		private var state:int;
		private var _cursor_rotation:Number;
		private var off_icons:int;
		private var duration:int;
		private var transition:Object;
		private var pending_target:Vector.<int>;
		
		
		private var tween:Tween = null;
		private var tween_loop:Tween = null;
		private var tween_end:Tween = null;

		private const _INITIALIZED_:int = 0;
		private const _READY_:int = 1;
		private const _MAIN_PHASE_:int = 2;
		private const _GOT_ANSWER_:int = 3;
		
		public function WheelRotationRealistic(wheel:Wheel)
		{
			super(wheel);
			this._cursor_rotation = 0;
			//hidden at the top
			init_hidden_icon();
			_cursor_rotation = 0;
			pending_target = null;
			state = _INITIALIZED_;
		}

		/**
		 *  @param - destination position of the rotation, giving <b>-1</b> means that the rotation will loop till a target is given<br/>
		 * 	@param -
		 * Tells what values display during the rotation, you can put the result where you want, just be sure to rotate the wheel
		 * correctly afterwards.
		 * Example<br/>
		 * Suppose you have these icons in the wheel:<br/>
		 * 0<br/>
		 * 1<br/>
		 * 2<br/>
		 * passing  0,0,1,2,3 will result 0,1,2,0,0,1,2,3<br/>
		 * the first three are in this case our icons, the next are the icons that will be displayed with rotation.
		 * so if you scroll the wheel with a negative value of 120 (supposed height of a single icon) the result will be:<br/>
		 * 1<br/>
		 * 2<br/>
		 * 0<br/>
		 * with a positive value nothing chanes, it just takes the last item like a circular list.<br/>
		 * 3<br/>
		 * 0<br/>
		 * 1<br/>
		 * */
	    public function SetIcons(...values):void
		{
			var i:int = 0;
			if(state!= _INITIALIZED_ && state!=_READY_)
				throw new Error("SetIcons_1 - you cant initialize the rotation till it ends");
			_rotation_values = new Vector.<int>();

			for(i=0;i<(wheel.img_icons.length);i++) 
			{
				_rotation_values.push(wheel.img_icons[i].value);
				wheel.img_icons[i].value = -1; //invalid value
			}
			if(values[0] is Vector.<int>)
			{
				for(i=0;i<values[0].length;i++) 
				{
					if(values[0][i] is int)
						_rotation_values.push(values[0][i]);
					else
						throw new ArgumentError("SetIcons_2 - you must pass integers");
				}
			}
			else
			{
				for(i=0;i<values.length;i++) 
				{
					if(values[i] is int)
						_rotation_values.push(values[i]);
					else
						throw new ArgumentError("SetIcons_3 - you must pass integers");
				}
			}

			state = _READY_;
		}
		

		/**
		 * @param transition function, check starling's animation tutorial
		 * @param number of icons that will rotate, if the number is bigger than the parameters given to SetIcons no problem. It's a circular list.
		 * @param duration (in seconds) of the rotation
		*/
		public function SetTransition(transition:Object,off_icons:int,duration:int):void
		{
			tween = new Tween(this,duration,transition);
			tween_end = new Tween(this,duration,transition);
			this.off_icons = off_icons;
			this.duration = duration;
			this.transition = transition;
		}
		/** 
		 * @param delay (in seconds)
		 * @param point of loop beetween 0 and 1. Usually is set to 0.5 or -1. The reason of this is to handle async server response.
		 *   If there is no response from the server the rotation will be looped in that point of the transaction. If -1 there is no server
		 *   response handling.
		 *   To communicate a server response call GotAnswer() of the rotation handler.
		 * */
	   public function BeginRotation(delay:Number,point_of_loop:Number=-1):void
		{
		   var self:WheelRotationRealistic = this;
		   var speed:Number = 0;	
		   init_hidden_icon();
		   tween.reset(this,this.duration,this.transition);
		   tween_end.reset(this,this.duration,this.transition);
		   tween.animate("cursor_rotation",off_icons * wheel.icon_height);
		   tween.delay = delay;
		   tween.onComplete = end_rotation;
		   
		   if(point_of_loop!=-1)
		   {
			   //approssimo una velocità lineare in base all'andamento della funzione
			   var end_cursor:Number = tween.getEndValue("cursor_rotation");
			   var total_time:Number = tween.totalTime;
			   var delta_s:Number = tween.transitionFunc(point_of_loop)*end_cursor - tween.transitionFunc(point_of_loop - 0.01)*end_cursor;
			   var delta_t:Number = total_time/100;
			   speed = delta_s / delta_t;
			   tween_end.onComplete = tween.onComplete;
			   tween.onUpdate = function():void
			   {
				   if(tween.progress >= point_of_loop && state != _GOT_ANSWER_)
				   {
					   var old_pos:int = tween.getEndValue("cursor_rotation") *tween.progress ;
					   Starling.juggler.remove(tween);
					   tween_loop = new Tween(self,((_rotation_values.length*wheel.icon_height)/speed),Transitions.LINEAR);
					   tween_loop.animate("cursor_rotation",old_pos + _rotation_values.length*wheel.icon_height);
					   tween_loop.repeatCount = 0;
					   tween_loop.onUpdate = function():void
					   {
						   if(state == _GOT_ANSWER_)
							tween_loop.repeatCount = 1;
					   }
					   tween_loop.onComplete = function():void
					   {
						   Starling.juggler.add(tween);
						   tween.onUpdate= null;
					   }
					   Starling.juggler.add(tween_loop);
				   }
			   }
		   }
		   this.state = _MAIN_PHASE_;
		   this.wheel.state = Wheel._ROTATING_; //ex super
		   Starling.juggler.add(tween);
		}
		
	   
		/**
		 * <b>REMBER TO CALL INIT_ROTATION BEFORE</b></br>
		 * There is no control for performance reason.</br>
		 * To know how to position the icons simulating a rotation i keep track of an offset value called <b>cursor</b>, 
		 * so i can know what icon are  on the screen and assign them the correct texture and position. the array of values of the width
		 * have a number of cols determined with the initialization/resizing, so how can i display 4 icons if i have 3 DisplayObject?</br>
		 * I use a temporary resource called <b>hidden_icon</b> that is the extra icon that is entering into the stage.
		 * @see Icon
		 * */
		public function update_rotation(cursor:Number):void
		{

			var tmp_icon:Icon;
			var index_rotation_icons:int;
			var i:int;
			var tmp_cursor:int;
			var tmp:int;
			var icon_on_screen:Vector.<int> = new Vector.<int>;

			tmp_cursor = -1*cursor;
			for(i=0;i<wheel.img_icons.length;i++)
			{
				tmp = (tmp_cursor)/(wheel.img_icons[0].image.height+wheel.offy); //force conversion to int
				index_rotation_icons = ((tmp+i) %_rotation_values.length) ;
				
				if(index_rotation_icons<0)
					index_rotation_icons = _rotation_values.length + index_rotation_icons;
					
				icon_on_screen.push(index_rotation_icons);
				
				wheel.img_icons[i].image.texture = wheel.icons[_rotation_values[index_rotation_icons]];

				wheel.img_icons[i].image.y = int((wheel.icon_height + wheel.offy) * i  + cursor%(wheel.icon_height+wheel.offy));

			}
			if(cursor<0)
			{
				index_rotation_icons = ((tmp_cursor)/(wheel.icon_height+wheel.offy) + wheel.img_icons.length ) %_rotation_values.length;
				hidden_icon.image.texture = wheel.icons[_rotation_values[index_rotation_icons]];
				hidden_icon.image.y = int((wheel.icon_height + wheel.offy) * wheel.img_icons.length  - tmp_cursor%(wheel.icon_height+wheel.offy));
			}
			else if(cursor>=0)
			{

				tmp = (tmp_cursor)/(wheel.icon_height+wheel.offy);
				index_rotation_icons = ((tmp-1) %_rotation_values.length) ;
				if(index_rotation_icons<0)
					index_rotation_icons = _rotation_values.length + index_rotation_icons;
				hidden_icon.image.texture = wheel.icons[_rotation_values[index_rotation_icons]];
				hidden_icon.image.y = int((wheel.icon_height + wheel.offy) * -1  + cursor%(wheel.icon_height+wheel.offy));
			}
			icon_on_screen.push(index_rotation_icons);
			
			//update pending_target if the icons to change aren't visible
			if (pending_target != null && pending_target.length > 0)
			{
				for (i = 0; i < wheel.img_icons.length; i++)
				{
					index_rotation_icons = rotation_values.length - off_icons % rotation_values.length + i;
					if (index_rotation_icons < 0)
						index_rotation_icons += _rotation_values.length;
					
					if (icon_on_screen.indexOf(index_rotation_icons) != -1)
						return;
				}
				
				for (i = 0; i < wheel.img_icons.length; i++)
				{
					index_rotation_icons = rotation_values.length - off_icons % rotation_values.length + i;
					if (index_rotation_icons < 0)
						index_rotation_icons += _rotation_values.length;
					rotation_values[index_rotation_icons] = pending_target[i];
				}
				
				pending_target = null;
			}
		}

		/**Check if the wheel is in a correct position, if it is values will be changed.
		 * If it isn't the wheel will be forced to the correct destination position (last icons of the rotation_values
		 * */
		
		override public function end_rotation():void
		{
			var tmp_cursor:int;
			var i:int;
			var tmp:int;
			var index_rotation_icons:int;
			
			if(_cursor_rotation%(wheel.icon_height+wheel.offy) == 0)
			{
				tmp_cursor = -1*_cursor_rotation;
				for(i=0;i<wheel.img_icons.length;i++)
				{
					tmp = (tmp_cursor)/(wheel.icon_height+wheel.offy); //force conversion to int
					index_rotation_icons = ((tmp+i) %_rotation_values.length) ;
					if(index_rotation_icons<0)
						index_rotation_icons = _rotation_values.length + index_rotation_icons;
					wheel.img_icons[i].value = _rotation_values[index_rotation_icons];
				}
			}
			else
				throw new Error("END_ROTATION 1 - rotation stopped in an invalid position,cursor: " + _cursor_rotation.toString());
			wheel.removeChild(hidden_icon.image);
			_rotation_values.length = 0;
			hidden_icon = null;
			_cursor_rotation = 0;
			pending_target = null;
			this.state = _READY_;
			super.end_rotation();

		}
		
		public function setTarget(...values):void
		{
			
			if (values[0] is int)
			{
				pending_target = new Vector.<int>;
				for (var i:int = 0; i < values.length; i++)
				{
					pending_target.push(values[i]);
				}
			}
			else if (values[0] is Vector.<int>)
			{
				pending_target = values[0];
			}
			else
			 throw new Error("SET_TARGET 1 - VALUES MUST BE A LIST OF INT");
		}
		
		override public function gotAnswer():void
		{
			state = _GOT_ANSWER_;
		}
		
		private function init_hidden_icon():void
		{
			hidden_icon = new Icon(-1,new Image(wheel.icons[0]));
			hidden_icon.image.x = 0;
			hidden_icon.image.y = 0 - wheel.offy - wheel.icon_height;
			wheel.addChild(hidden_icon.image);
		}
		
		
		public function set cursor_rotation(scroll:Number):void
		{
			update_rotation(scroll);
			_cursor_rotation=scroll;
		}
		
		public function get cursor_rotation():Number
		{
			return _cursor_rotation;
		}
		
		
		public function get rotation_values():Vector.<int>
		{
			return _rotation_values;
		}

	}
}