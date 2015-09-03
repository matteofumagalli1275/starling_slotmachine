package 
{
	import starling.extensions.Slot.Util.ExtendedTransisions;
	import starling.extensions.Slot.Wheels.Icon;
	import starling.extensions.Slot.Wheels.Rotations.WheelRotation;
	import starling.extensions.Slot.Wheels.Rotations.WheelRotationRealistic;
	import starling.extensions.Slot.Wheels.Wheel;
	import starling.extensions.Slot.Wheels.WheelMatrix;
	import starling.display.Button;
	import starling.display.ButtonState;
	import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
    import starling.utils.Color;
	import starling.animation.Transitions;
	import starling.core.Starling;
 
    public class Game extends Sprite
    {
		private static const TOTAL_ROW:int = 3;
		private static const TOTAL_COLS:int = 5;
		private static const ICON_OFFSET_X:int = 13;
		private var assets:AssetManager;
		private var icons:Vector.<Texture>;
		private var background:Image;
		private var container:Image;
		private var wheelmatrix:WheelMatrix;
		private var button_start:Button;
		private var button_server:Button;
		
        public function Game()
        {
			ExtendedTransisions.RegisterDefaults();
			assets = new AssetManager();
			assets.verbose = true;
			assets.enqueue(Assets);
			assets.loadQueue(function(ratio:Number):void
			{
				if (ratio == 1.0)
					Init();
			});
        }
		
		public function Init():void
		{
			icons = new Vector.<Texture>();
			var icons_strings:Vector.<String> = assets.getTextureNames("icona");
			for (var i:int = 0; i < icons_strings.length; i++ )
			{
				icons.push(assets.getTexture(icons_strings[i]));
				trace("icon " + i + " loaded");
			}
			
			background = new Image(assets.getTexture("background.png"));
			if (background != null)
				trace("background loaded");
			container = new Image(assets.getTexture("container.png"));
			if (container != null)
				trace("container loaded");
				
			button_start = new Button(assets.getTexture("button.png"), "START");
			button_start.addEventListener(Event.TRIGGERED, onStartPressed);
			
			button_server = new Button(assets.getTexture("button.png"), "ANSWER");
			button_server.addEventListener(Event.TRIGGERED, onAnswerPressed);
			button_server.color = Color.YELLOW;
			button_server.enabled = false;
			
			InitScene();
		}
		
		public function InitScene():void
		{
			container.x = Starling.current.viewPort.width / 2 - container.width / 2;
			container.y =  Starling.current.viewPort.height / 2 - container.height / 2;
			button_start.x = Starling.current.viewPort.width / 2 - button_start.width;
			button_start.y = (container.y + container.height);
			button_server.x = button_start.x + button_start.width;
			button_server.y = button_start.y;

			//Each wheel is a column
			var list_wheels:Vector.<Wheel> = new Vector.<Wheel>();
			for (var i:int = 0; i < TOTAL_COLS; i++)
			{
				var wheel:Wheel = new Wheel(TOTAL_ROW, icons, 0);
				wheel.x = container.x + (wheel.width + ICON_OFFSET_X) * i + ICON_OFFSET_X;
				wheel.y = int(container.y);
				wheel.rotation_handler = new WheelRotationRealistic(wheel);
				list_wheels.push(wheel);
			}
			wheelmatrix = new WheelMatrix(list_wheels);
			wheelmatrix.addEventListener(WheelMatrix.EVENT_END_ROTATION, onEndRotation);
			
			addChild(background);
			addChild(wheelmatrix);
			addChild(container);
			addChild(button_start);
			addChild(button_server);
		}
		
		public function onStartPressed(evt:Event):void
		{
			var base_duration:Number = 4;
			var base_off_icons:Number = 18;
			var off_sec:Number = 0.3;
			for (var i:int = 0; i < wheelmatrix.wheels.length; i++)
			{
				var wheel:Wheel = wheelmatrix.wheels[i];
				var rotation_handler:WheelRotationRealistic = wheelmatrix.wheels[i].rotation_handler as WheelRotationRealistic;
				/*
				 * List of icons that will rotate, the result on the screen is calculated like this: 
				 * last_icon_index = N - off_icons%N  (this will be the icon on the bottom)
				 * So in this case:
				 * rotation_handler.SetIcons(7, 2, 1, 0, 1, 7, 2, 2, 2, 4, 3); 
				 * (correct sequence is (oi,oi,oi,7, 2, 1, 0, 1, 7, 2, 2, 2, 4, 3) where 'oi' is the old icon)
				 * target icons will be 7,2,1 with off_icons = 3 ( 14 - 11%14 ) = 3
				 * */
				rotation_handler.setForceSameBehaviour(true, base_off_icons, base_duration, true);
				
				rotation_handler.SetIcons(7, 2, 1, 0, 1, 7, 2, 2, 2, 4, 3);
				/* SetTransition params:
				 * - transition function, check starling'animation tutorial
				 * - off_icons: number of icons that will rotate, if the number is bigger than the parameters given to SetIcons no problem. It's a circular list.
				 * - duration (in seconds) of the rotation
				*/
				//rotation_handler.SetTransition(ExtendedTransisions.WHEEL_OUT_BOUNCE, base_off_icons, base_duration);
				rotation_handler.SetTransition(ExtendedTransisions.WHEEL_OUT_BOUNCE,  (base_duration + i * off_sec) * base_off_icons/base_duration, base_duration + i * off_sec);
				/* BeginRotation params:
				 * - delay (in seconds)
				 * - point of loop beetween 0 and 1. Usually is set to 0.5 or -1. The reason of this is to handle async server response.
				 *   If there is no response from the server the rotation will be looped in that point of the transaction. If -1 there is no server
				 *   response handling.
				 *   To communicate a server response call GotAnswer() of the rotation handler and override the target icons.
				*/
				rotation_handler.BeginRotation(0, 0.5, 1500);
			}
			button_start.enabled = false;
			button_server.enabled = true;
		}
		
		public function onAnswerPressed(evt:Event):void
		{
			for (var i:int = 0; i < wheelmatrix.wheels.length; i++)
			{
				var wheel:Wheel = wheelmatrix.wheels[i];
				var rotation_handler:WheelRotationRealistic = wheelmatrix.wheels[i].rotation_handler as WheelRotationRealistic;
				rotation_handler.setTarget(0,1,2);
				rotation_handler.gotAnswer();
			}
			button_server.enabled = false;
		}
		
		public function onEndRotation(evt:Event):void
		{
			button_start.enabled = true;
		}
		
		
    }

}