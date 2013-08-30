package zszh_WorkSpace2D
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
	public class Wall_2DCorner extends Sprite
	{
		private var _selected:Boolean;
		
		public function Wall_2DCorner()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,OnAddToStage);
		}
		
		public function SetSelected(b:Boolean):void
		{
			_selected=b;
		}
		public function GetSelected():Boolean
		{
			return _selected;
		}
		
		
		
		private function OnAddToStage(e:Event):void
		{
			addEventListener(MouseEvent.MOUSE_OVER,CornerMouseOVER);
			addEventListener(MouseEvent.MOUSE_OUT,CornerMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN,CornerMouseDown);
		}
		
		public function Draw(px:Number,py:Number):void
		{
			graphics.clear();
			graphics.lineStyle(1,0x000000);
			graphics.beginFill(0xffffff,1);
			graphics.drawCircle(px,py,10);
			graphics.endFill();
		}
		
		//---------------corner mouse event---------------------------------------------
		private function CornerMouseOVER(e:MouseEvent):void
		{
			CursorManager.setCursor(FlexGlobals.topLevelApplication.imageCursor);
		}
		private function CornerMouseOut(e:MouseEvent):void
		{
			CursorManager.removeAllCursors();
		}
		
		
		
		//---------------corner mouse event---------------------------------------------
		private var startPoint:Point=new Point;
		private var bStart:Boolean=false;
		
		private var cornerName:String;
		private var cornerNumber:String;
		
		private function CornerMouseDown(e:MouseEvent):void
		{
			
			trace("-------------------CornerMouseDown--------------------");
			
			bStart=true;
			startPoint.x=this.stage.mouseX;
			startPoint.y=this.stage.mouseY;
			
			cornerName=e.target.name;
			cornerNumber =cornerName.slice(10,11);
			trace("CornerMouseDown::cornerName:"+cornerName);
			trace("CornerMouseDown::cornerNumber:"+cornerNumber);		
			
			trace("-------------------CornerMouseDown----end----------------");
			CursorManager.setCursor(FlexGlobals.topLevelApplication.imageCursor);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,CornerMouseMove);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,CornerMouseUp);
			e.stopPropagation();
		}
		
		private function CornerMouseUp(e:MouseEvent):void
		{
			bStart=false;
			CursorManager.removeAllCursors();
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,CornerMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,CornerMouseUp);
		}
		private function CornerMouseMove(e:MouseEvent):void
		{
			if(!bStart)
				return;
			CursorManager.setCursor(FlexGlobals.topLevelApplication.imageCursor);
			
			var i:int=Number(cornerNumber);
			MoveCorner(i);
			
			startPoint.x=this.stage.mouseX;
			startPoint.y=this.stage.mouseY;
		}
		
		private function MoveCorner(i:int):void
		{
			var thisWall:Object2D_PartitionWall=(this.parent as Object2D_PartitionWall);
			
			var VMouseMove:Point=new Point((int)(this.stage.mouseX-startPoint.x),int(-this.stage.mouseY+startPoint.y));
			trace("VMouseMove:"+VMouseMove);
			thisWall._vertexVec1[i]+=VMouseMove.x;
			thisWall._vertexVec1[i+1]-=VMouseMove.y;
			thisWall.Update();
			
		}
	}
}