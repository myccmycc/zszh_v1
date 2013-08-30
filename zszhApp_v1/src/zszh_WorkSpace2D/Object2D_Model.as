package zszh_WorkSpace2D
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Image;

	public class Object2D_Model extends Object2D_Base
	{
		public var _topImage:Image;
		private var _topImageLoader:Loader;
		
		private var _boundsColor:uint;

		public var _resourcePath:String;
		public var _modelName:String;
	
		private var _popupMenu:PopupMenu_Mode2D;
		public function Object2D_Model(resourcePath:String,modelName:String)
		{
			super();
			_resourcePath=resourcePath;
			_modelName=modelName;
			_boundsColor=0xffffff;
			addEventListener(FlexEvent.CREATION_COMPLETE,OnCreation_Complete);
		}
		
		override public function Object2DUpdate():void
		{
			if(_popupMenu)
				PopUpManager.removePopUp(_popupMenu);
			
			if(_selected)
			{
				var rect:Rectangle=this.getRect(this);
				trace(rect);
				graphics.clear();
				graphics.lineStyle(1,_boundsColor);//白线
				graphics.drawRect(rect.x,rect.y,rect.width,rect.height);
				graphics.endFill();
				
			}
			else
			{
				graphics.clear();
				graphics.endFill();
			}
		}
		private function OnCreation_Complete(e:FlexEvent):void
		{
			_topImageLoader = new Loader();
			_topImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			var topImageFile:String=_resourcePath+"top.png"
			_topImageLoader.load(new URLRequest(topImageFile));
			
			function onComplete(e:Event):void
			{
				_topImage=new Image();
				_topImage.source=Bitmap(_topImageLoader.content);
				_topImage.width=_topImageLoader.content.width;
				_topImage.height=_topImageLoader.content.height;
				addChild(_topImage);
			}
			addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE,MouseMove);
			addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			addEventListener(MouseEvent.MOUSE_UP,MouseOut);
			addEventListener(MouseEvent.RIGHT_CLICK,MouseCLICK);	
		}	
		
		private var _bMouseDown:Boolean=false;
		private function MouseDown(e:MouseEvent):void
		{
			_bMouseDown=true;
		}
		private function MouseMove(e:MouseEvent):void
		{
			if(_bMouseDown)
				this.startDrag(false);
			e.stopPropagation();
		}
		private function MouseUp(e:MouseEvent):void
		{
			this.SetSelected(true);
			this.stopDrag();
			_bMouseDown=false;
			e.stopPropagation();
		}
		
		private function MouseOut(e:MouseEvent):void
		{
			this.stopDrag();
			_bMouseDown=false;
			e.stopPropagation();
		}
		
		private function MouseCLICK(e:MouseEvent):void
		{
			SetSelected(true);
			_popupMenu=new PopupMenu_Mode2D;
			PopUpManager.addPopUp(_popupMenu,this,false);
			
			var pt:Point = new Point(e.target.x+e.target.width/2, e.target.y+e.target.height/2);
			pt = e.target.localToGlobal(pt);
			_popupMenu.move(pt.x,pt.y);
			e.stopPropagation();
		}
				
	}
}