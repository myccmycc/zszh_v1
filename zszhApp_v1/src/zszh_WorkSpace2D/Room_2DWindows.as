package zszh_WorkSpace2D
{

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
	import zszh_WorkSpace2D.PopupMenu_Room2D_Wall;
	
	public class Room_2DWindows extends Object2D_Base
	{
		private var _popupWindowMenu:PopupMenu_Room2D_Wall;
		
		
		private var _P0:Point;
		private var _P1:Point;
		
		private var _lineColor:uint;
		private var _lineColorSelected:uint;
		private var _windowColor:uint;
		
		public function Room_2DWindows(p0:Point,p1:Point)
		{
			super();
			_P0=p0;
			_P1=p1;
			
			_lineColor=0xff0000;
			_lineColorSelected=0x00ff00;
			_windowColor=0xffff00;
			
			addEventListener(FlexEvent.CREATION_COMPLETE,OnCreation_Complete);
			addEventListener(MouseEvent.RIGHT_CLICK,WallCLICK);
			addEventListener(MouseEvent.MOUSE_OVER,WallMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,WallMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN,WallMouseDown);
		}
		
		
 
		

		private function OnCreation_Complete(e:FlexEvent):void
		{
			Update();
		}
		private function Update():void
		{
			graphics.clear();
			graphics.lineStyle(1,_lineColor);//白线
			graphics.beginFill(_windowColor,0.8);
			graphics.moveTo(_P0.x,_P0.y);
			graphics.lineTo(_P1.x,_P1.y);
			graphics.endFill();
		}
		
		
		//----------------wall mouse move event ---------------------------------------
		
		private function WallMouseOver(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			e.stopPropagation();
		}
		private function WallMouseOut(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			e.stopPropagation();
		}
		
		private function WallCLICK(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			if(_popupWindowMenu)
			{
				PopUpManager.removePopUp(_popupWindowMenu);
				_popupWindowMenu=null;
			}
			_popupWindowMenu=new PopupMenu_Room2D_Wall();
			PopUpManager.addPopUp(_popupWindowMenu,this,false);
		
			var pt:Point = new Point(e.localX, e.localY);
			pt = e.target.localToGlobal(pt);
			_popupWindowMenu.move(pt.x,pt.y);
			e.stopPropagation();
			
		}
		
	
		private var startPoint:Point=new Point;
		private var bStart:Boolean=false;
		

		private function WallMouseDown(e:MouseEvent):void
		{
			if(!_selected)
				return;
		  
			bStart=true;
			startPoint.x=this.mouseX;
			startPoint.y=this.mouseY;
	
			
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,WallMouseMove);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,WallMouseUp);
			e.stopPropagation();
		}
		
		private function WallMouseUp(e:MouseEvent):void
		{
		  	SetSelected(true);
			bStart=false;

			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,WallMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,WallMouseUp);
		}
		private function WallMouseMove(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			if(!bStart)
				return;
			startPoint.x=this.mouseX;
			startPoint.y=this.mouseY;
		}
		
		
	}
}