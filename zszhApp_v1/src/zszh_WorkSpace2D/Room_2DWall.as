package zszh_WorkSpace2D
{

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	
	import zszh_WorkSpace2D.PopupMenu_Room2D_Wall;
	
	public class Room_2DWall extends Object2D_Base
	{
		private var _popupWindowMenu:PopupMenu_Room2D_Wall;
		private var _lineColor:uint;
		private var _wallColor:uint;
		private var _wallColorSelected:uint;
		
		private var _wallPos:Vector.<Number>;
		
		public  var _postionInRoom:int;
		public  var _rotation:Number;
		
		[Bindable]
		[Embed(source="../embeds/rooms/cursor_wall.png")]
		public var _cursorWall:Class;
		private var _cursorSprite:Sprite;
		
		
		public function Room_2DWall()
		{
			super();
		
			_lineColor=0xffffff;
			_wallColor=0x7c7e89;
			_wallColorSelected=0xff6666;
			_wallPos=new Vector.<Number>;
			_selected=true;
			
			_cursorSprite=new Sprite();
			var img:Bitmap=new _cursorWall();
			_cursorSprite.addChild(img);
			img.x=-img.width/2;
			img.y=-img.height/2;
			
			addChild(_cursorSprite);
			_cursorSprite.visible=false;
			
			addEventListener(MouseEvent.RIGHT_CLICK,WallCLICK);
			addEventListener(MouseEvent.MOUSE_OVER,WallMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,WallMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN,WallMouseDown);
		}
		
		public function UpdateVertex(p1x:Number,p1y:Number,p2x:Number,p2y:Number,p3x:Number,p3y:Number,p4x:Number,p4y:Number):void
		{

			_wallPos[0]=p1x;_wallPos[1]=p1y;
			_wallPos[2]=p2x;_wallPos[3]=p2y;
			_wallPos[4]=p3x;_wallPos[5]=p3y;
			_wallPos[6]=p4x;_wallPos[7]=p4y;
			
			Update();
		}
		
 
		
	
		private function ShowCursorCorner(postion:Point,rotation:Number):void
		{
			CursorManager.hideCursor();
			
			_cursorSprite.rotation=rotation+90;
			_cursorSprite.visible=true;
			_cursorSprite.x=postion.x;
			_cursorSprite.y=postion.y;
		}
		
		private function HideCursorCorner():void
		{
			CursorManager.showCursor();
			_cursorSprite.visible=false;
		}
		
		
		private function OnDeleteWall(e:Event):void
		{
			trace("OnDeleteWall");
			this.visible=false;
		}
		
		private function OnSplitWall(e:Event):void
		{
			trace("OnSplitWall");
		}
		
		private function OnHoleWall(e:Event):void
		{
			trace("OnHoleWall");
		}
		
		private function Update():void
		{
			graphics.clear();
			graphics.lineStyle(1,_lineColor);//白线
			
			if(_selected)
				graphics.beginFill(_wallColorSelected,0.8);
			else
				graphics.beginFill(_wallColor,0.8);
			
			graphics.moveTo(_wallPos[0],-_wallPos[1]);
			graphics.lineTo(_wallPos[2],-_wallPos[3]);
			graphics.lineTo(_wallPos[6],-_wallPos[7]);
			graphics.lineTo(_wallPos[4],-_wallPos[5]);
			graphics.endFill();
			
			if(_popupWindowMenu)
			{
				PopUpManager.removePopUp(_popupWindowMenu);
				_popupWindowMenu=null;
			}
			
			var p1:Point=new Point(_wallPos[2]-_wallPos[0],_wallPos[3]-_wallPos[1]);
			var p2:Point=new Point(1,0);
			var d:Number=p1.x*p2.x+p1.y*p2.y;
			var d1:Number=Math.sqrt(p1.x*p1.x+p1.y*p1.y) * Math.sqrt(p2.x*p2.x+p2.y*p2.y);
			_rotation= Math.acos(d/d1)/Math.PI *180;
			
			var sind:Number=p1.x*p2.y-p1.y*p2.x;
			if(sind<0)
				_rotation=360-_rotation;
		}
		
		
		//----------------wall mouse move event ---------------------------------------
		
		private function WallMouseOver(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			ShowCursorCorner(new Point(this.mouseX,this.mouseY),_rotation);
			e.stopPropagation();
		}
		private function WallMouseOut(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			HideCursorCorner();
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
			_popupWindowMenu.addEventListener(PopupMenu_Room2D_Wall.DELETE_WALL,OnDeleteWall,false,0,true);
			_popupWindowMenu.addEventListener(PopupMenu_Room2D_Wall.SPLIT_WALL,OnSplitWall,false,0,true);
			_popupWindowMenu.addEventListener(PopupMenu_Room2D_Wall.HOLE_WALL,OnHoleWall,false,0,true);
			PopUpManager.addPopUp(_popupWindowMenu,this,false);
		
			var pt:Point = new Point(e.localX, e.localY);
			pt = e.target.localToGlobal(pt);
			_popupWindowMenu.move(pt.x,pt.y);
			e.stopPropagation();
			
		}
		
	
		private var startPoint:Point=new Point;
		private var bStart:Boolean=false;
		
		override public function Draw():void
		{}

		private function WallMouseDown(e:MouseEvent):void
		{
			if(!_selected)
				return;
		  
			bStart=true;
			startPoint.x=this.mouseX;
			startPoint.y=this.mouseY;
	
			ShowCursorCorner(new Point(this.mouseX,this.mouseY),_rotation);
			
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE,WallMouseMove);
			this.stage.addEventListener(MouseEvent.MOUSE_UP,WallMouseUp);
			e.stopPropagation();
		}
		
		private function WallMouseUp(e:MouseEvent):void
		{
		  	SetSelected(true);
			bStart=false;
			HideCursorCorner();
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,WallMouseMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,WallMouseUp);
		}
		private function WallMouseMove(e:MouseEvent):void
		{
			if(!_selected)
				return;
			
			if(!bStart)
				return;
			ShowCursorCorner(new Point(this.mouseX,this.mouseY),_rotation);
			if(MoveWall(_postionInRoom))
			{
				startPoint.x=this.mouseX;
				startPoint.y=this.mouseY;
			}
		}
		
		
		private function MoveWall(i:int):Boolean
		{
			var thisRoom:Object2D_Room=(this.parent as Object2D_Room);
			
			var vecLen:int=thisRoom._vertexVec1.length;
			
			var P0:Point=new Point(thisRoom._vertexVec1[(i+0)%vecLen],-thisRoom._vertexVec1[(i+1)%vecLen]);
			
			var P1:Point=new Point(thisRoom._vertexVec1[(i+2)%vecLen],-thisRoom._vertexVec1[(i+3)%vecLen]);
			
			var P2:Point=new Point(thisRoom._vertexVec1[(i+4)%vecLen],-thisRoom._vertexVec1[(i+5)%vecLen]);
			
			var P3:Point=new Point(thisRoom._vertexVec1[(i+6)%vecLen],-thisRoom._vertexVec1[(i+7)%vecLen]);    
			trace("P0123:"+P0+P1+P2+P3);
			
			
			//1.求鼠标移动的向量
	
			var VMouseMove:Point=new Point((int)(this.mouseX-startPoint.x),int(this.mouseY-startPoint.y));
			trace("VMouseMove:"+VMouseMove);
			
			
			//1.求移动的P1P2线段
			
			var VP1P2:Point=new Point(P2.x-P1.x,P2.y-P1.y);
			
			trace("VP1P2:"+VP1P2);
			
			//1.求P1P2线段逆时针方向法线向量
			
			var VP1P2_Normal:Point= new Point(-VP1P2.y,VP1P2.x);
			
			trace("VP1P2_Normal:"+VP1P2_Normal);
			
			
			
			//1求夹角，P1P2_Normal和 MouseMove。
			
			var d:Number=VP1P2_Normal.x*VMouseMove.x+VP1P2_Normal.y*VMouseMove.y;
			
			var d1:Number=Math.sqrt(VP1P2_Normal.x*VP1P2_Normal.x+VP1P2_Normal.y*VP1P2_Normal.y) * Math.sqrt(VMouseMove.x*VMouseMove.x+VMouseMove.y*VMouseMove.y);
			
			var VMouseMove_arg:Number= Math.acos(d/d1);
			
			
			trace("mouse_move to normal arg:"+VMouseMove_arg);
			
			trace("mouse_move to normal ang:"+VMouseMove_arg*180/Math.PI);
			
			
			
			//2 P1P2 直线方程  Ax+By+c=0的表达式
			
			var A:Number=(P2.y-P1.y);
			
			var B:Number=(P1.x-P2.x);
			
			var C:Number = P2.x*P1.y-P1.x*P2.y;
			
			trace("ABC:"+A+B+C);
			
			//2求平移后的直线  |C1-C0|/sqrt（A*A+B*B）=DIS
			
			var aabb:Number=Math.sqrt(A*A+B*B);
			
			var dis:Number=Math.sqrt( VMouseMove .x*  VMouseMove .x+  VMouseMove .y*  VMouseMove .y)*Math.cos(VMouseMove_arg);
			
			
			var s:Number=dis*aabb;
			
			var C2:Number=C+s;
			trace("C2:"+C2);
			
			
			
			//求POP1，P3P2和  AX+BY+C2 两个交点
			var i1:Point=Object2D_Utility.Intersection2(P0,P1,A,B,C2);
			
			var i2:Point=Object2D_Utility.Intersection2(P3,P2,A,B,C2);
			
		
			
			if(i1.x!=Number.POSITIVE_INFINITY && i2.x!=Number.POSITIVE_INFINITY)
			{
				var vertex:Vector.<Number>=new Vector.<Number>;
				for(var j:int=0;j<thisRoom._vertexVec1.length;j++)
					vertex.push(thisRoom._vertexVec1[j]);
				
				vertex[(i+2)%vecLen]=(int)(i1.x);
				
				vertex[(i+3)%vecLen]=(int)(-i1.y);
				
				vertex[(i+4)%vecLen]=(int)(i2.x);
				
				vertex[(i+5)%vecLen]=(int)(-i2.y);
				
				for(j=0;j<vertex.length;j+=2)
				{
					var isInter:Boolean=Object2D_Utility.SelfIntersection(vertex,j);
					if(isInter)
						return false;
				}
								
				thisRoom._vertexVec1[(i+2)%vecLen]=(int)(i1.x);
				
				thisRoom._vertexVec1[(i+3)%vecLen]=(int)(-i1.y);
				
				thisRoom._vertexVec1[(i+4)%vecLen]=(int)(i2.x);
				
				thisRoom._vertexVec1[(i+5)%vecLen]=(int)(-i2.y);
				
				thisRoom.Object2DUpdate();
				
				return true;
				
			}
			
			return false;
		}
		

		
		
	}
}