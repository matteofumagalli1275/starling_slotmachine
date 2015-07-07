package starling.extensions.Slot.Wheels
{
	import flash.geom.Rectangle;
	import starling.extensions.Slot.Wheels.Rotations.WheelRotation;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class Wheel extends Sprite
	{
		private var _icons:Vector.<Texture>;
		private var _img_icons:Vector.<Icon>;

		private var _rows:int;
		private var _offy:Number;
		private var _icon_height:Number;
		private var _icon_width:Number;
		private var _state:int;
		private var _rotation_handler:WheelRotation;
		
		public static const _STABLE_:int = 0;
		public static const _PAUSED_:int = 1;
		public static const _ROTATING_:int = 2;
		
		public static const EVENT_END_ROTATION:String = "end_rotation";
		
		
		public function Wheel( n_rows:int, list_icons:Vector.<Texture>, offy:Number, default_value:int = 0)
		{
			if(n_rows<=0)
			{
				throw new ArgumentError("ERR_RULLO_1 - invalid cols passed during the initialization");
			}
			this._icons = list_icons;
			//this._cursor_rotation = 0;
			this._img_icons = new Vector.<Icon>();
			this._rows = 0;
			this._offy = offy;
			this.resize(n_rows,default_value);
			this._state = _STABLE_;
			
		}
		public function get(row:int):int
		{
			if(row<0 || row>=(_img_icons.length-1))
			{
				throw new ArgumentError("ERR_RULLO_GET_1 - invalid row passed during the set, row: " + row.toString());
			}
			else if(_state!=_STABLE_)
				throw new  Error("ERR_RULLO_GET_2 - the wheel is not in a correct position. you can't get or set a value during rotation. state:" + _state);
			//else if(_cursor_rotation!=0)
			//	throw new  Error("ERR_RULLO_GET_2 - the wheel is not in a correct position. remember you can't get or set a value during rotation. cursor:" + cursor_rotation.toString());
			return _img_icons[row].value;
		}
		public function set(row:int,value:int,changetexture:Boolean = true):void
		{
			if(row<0 || row>=(_img_icons.length))
			{
				throw new ArgumentError("ERR_RULLO_SET_1- invalid row passed during the set, row: " + row.toString());
			}
			else if(changetexture==true && (value>=_icons.length || value<0))
			{
				throw new ArgumentError("ERR_RULLO_SET_2 - invalid value passed during the set, value: " + value.toString());
			}
			else if(_state!=_STABLE_)
				trace("Warning: WARN_RULLO_SET_1, setting icon while rotating");
			//else if(_cursor_rotation!=0)
			//	throw new  Error("ERR_RULLO_SET_3 - the wheel is not in a correct position. remember you can't get or set a value during rotation. cursor:" + cursor_rotation.toString());
			_img_icons[row].value = value;
			if(changetexture==true)
				_img_icons[row].image.texture = _icons[value];
		}

		public function resize(new_rows:Number,default_value:int):void
		{
			var posy:Number = 0;
			var dimx:Number = 0;
			var dimy:Number = 0;
			var i:int = 0;
			if(new_rows<=0)
			{
				throw new ArgumentError("ERR_RULLO_RESIZE_1 - invalid cols passed during the resize, cols: " + new_rows.toString());
			}
			if(_icons.length<=0)
			{
				throw new ArgumentError("ERR_RULLO_RESIZE_2 - invalid icons passed during the resize, lenght: " + _icons.length.toString());
			}
			
			if(this._rows>0)
				this._img_icons[this._img_icons.length-1].image.y + this._img_icons[_img_icons.length-1].image.height + _offy;
			dimx = this._icons[default_value].frame.width;
			dimy = this._icons[default_value].frame.height;
			
			if(new_rows>this._rows)
			{

				for(i=this._rows;i<(new_rows);i++)
				{
					_img_icons.push(new Icon(default_value,new Image(this._icons[default_value])));
					
					this._img_icons[i].image.x = 0;
					this._img_icons[i].image.y = posy;
					
					posy +=_img_icons[i].image.height + this._offy;
					
					if(this._img_icons[i].image.width!=dimx)
						throw new ArgumentError("ERR_RULLO_RESIZE_3 - width must be the same for every icon, dimx: " + dimx.toString() + " | image width: " + this._img_icons[i].image.width.toString());
					if(this._img_icons[i].image.height!=dimy)
						throw new ArgumentError("ERR_RULLO_RESIZE_4 - height must be the same for every icon, dimy: " + dimy.toString() + " | image width: " + this._img_icons[i].image.height.toString());
					
					this.addChild(this._img_icons[i].image);
				}
			}
			else if(new_rows<this._img_icons.length)
			{
				
				for(i=this._rows;i!=new_rows;i--)
				{
					this.removeChild(_img_icons[i].image);
					_img_icons[i].image.dispose();
					_img_icons.splice(i,1);
				}
			}

			//at the top
			//hidden_icon.image.y = 0 - _offy - hidden_icon.image.height;
			
			this._icon_height = _img_icons[0].image.height;
			this._icon_width = _img_icons[0].image.width;
			this.clipRect = new Rectangle(0,0,dimx,(this._img_icons[0].image.height + this._offy) * (this._img_icons.length) - this._offy);
			this._rows = new_rows;
		}
		
		//VARIOUS GET AND SET
		public function get rows():int
		{
			return this._rows;
		}
		public function get icon_height():int
		{
			return this._icon_height;
		}
		public function get icon_width():int
		{
			return this._icon_width;
		}
		public function get offy():int
		{
			return this._offy;
		}
		public function set icons(new_icons:Vector.<Texture>):void
		{
			this._icons = new_icons;
		}
		
		public function get icons():Vector.<Texture>
		{
			return this._icons;
		}
		

		public function set img_icons(new_img_icons:Vector.<Icon>):void
		{
			this._img_icons = new_img_icons;
		}
		
		public function get img_icons():Vector.<Icon>
		{
			return this._img_icons;
		}
		public function set state(new_state:int):void
		{
			this._state = new_state;
		}
		
		public function get state():int
		{
			return this._state;
		}
		
		public function set rotation_handler(new_handler:WheelRotation):void
		{
			this._rotation_handler = new_handler;
		}
		
		public function get rotation_handler():WheelRotation
		{
			return this._rotation_handler;
		}

	}
}