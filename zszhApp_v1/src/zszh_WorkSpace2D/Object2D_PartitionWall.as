package zszh_WorkSpace2D
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	import zszh_Core.CommandManager;


	public class Object2D_PartitionWall extends UIComponent
	{
		public  var _vertexVec1:Vector.<Number>;
				
		private  var _vertexVec2:Vector.<Number>;
		private  var _vertexVec3:Vector.<Number>;
		
		public  var _vertexVec:Vector.<Number>;


		private var _selected:Boolean;
		private var _wallType:String;//0横,1竖着
		
		private var _lineColor:uint;
		private var _wallColor:uint;
		private var _wallColorSelected:uint;
		
		private var _wallCornerVec:Vector.<Wall_2DCorner>;
		

		public function Object2D_PartitionWall(type:String,vec:Vector.<Number>=null)
		{
			super();
			_vertexVec1=new Vector.<Number>();
			_vertexVec2=new Vector.<Number>();
			_vertexVec3=new Vector.<Number>();
			_vertexVec=new Vector.<Number>();
			
			if(vec!=null)
				_vertexVec1=vec;
			
			addEventListener(FlexEvent.CREATION_COMPLETE,OnCreation_Complete);
			if(type=="1" || type =="2")
				_wallType=type;
			else trace("ERROR:Wall_2D have wrong wall type "+ type );
			_selected=true;
			
			_lineColor=0xffffff;
			_wallColor=0x7c7e89;
			_wallColorSelected=0xff6666;
			
			addEventListener(MouseEvent.MOUSE_DOWN,MouseDown);
			
			addEventListener(MouseEvent.MOUSE_OVER,MouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,MouseOut);
		}
		
		public function SetAllNoSelected():void
		{
			for(var i:int=0;i<_wallCornerVec.length;i++)
				_wallCornerVec[i].SetSelected(false);
		}
		
		public function SetSelected(b:Boolean):void
		{
			SetAllNoSelected();
			_selected=b;
			Update();
		}
		public function GetSelected():Boolean
		{
			return _selected;
		}
		
		//--------------mouse event----------------------------------------
		private function MouseOver(e:MouseEvent):void
		{
			CursorManager.setCursor(FlexGlobals.topLevelApplication.imageCursor);
		}
		private function MouseOut(e:MouseEvent):void
		{
			CursorManager.removeAllCursors();
		}
		
		private var _oldPos:Point;
		private function MouseDown(e:MouseEvent):void
		{
			SetSelected(false);
			startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP,MouseUp);
			_oldPos=new Point(x,y);
			e.stopPropagation();
		}
		
		private function MouseUp(e:MouseEvent):void
		{
			stopDrag();
			if(_oldPos.x!=x || _oldPos.y!=y)
			{
				CommandManager.Instance.Move(this,_oldPos,new Point(x,y));
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP,MouseUp);
			SetSelected(true);
			e.stopPropagation();
		}
		
		
		

		public function Update():void
		{
			UpdateData();
			UpdateWallCorner();
		}
				
		private function OnCreation_Complete(e:FlexEvent):void
		{
			
			
			
			if(_wallType=="1")
			{
				_vertexVec1.push(0,0,100,0);
			}
			else if(_wallType=="2")
			{
				_vertexVec1.push(0,0,0,100);
			}
			
			
			UpdateData();
			
			
			//wall corners 
			_wallCornerVec=new Vector.<Wall_2DCorner>;
			
			for(var i:int=0;i<_vertexVec1.length;i+=2)
			{
				var wallCorner:Wall_2DCorner=new Wall_2DCorner();
				wallCorner.name="wallCorner"+i;
			
				addChild(wallCorner);
				_wallCornerVec.push(wallCorner);
			}
			
			UpdateWallCorner();
		}
		
		// not fixed
		private function UpdateData():void
		{

				var P1:Point=new Point(_vertexVec1[0],_vertexVec1[1]);
				var P2:Point=new Point(_vertexVec1[2],_vertexVec1[3]);
				
				var disP1P2:Number=Math.sqrt((P2.x-P1.x)*(P2.x-P1.x)+(P2.y-P1.y)*(P2.y-P1.y));

				var sinx:Number=(P2.y-P1.y)/disP1P2;
				var cosx:Number=(P2.x-P1.x)/disP1P2;
				
				_vertexVec2[0]=_vertexVec1[0]+10*sinx;
				_vertexVec2[1]=_vertexVec1[1]+10*cosx;
				
				_vertexVec2[2]=_vertexVec1[2]+10*sinx;
				_vertexVec2[3]=_vertexVec1[3]+10*cosx;
				
				_vertexVec3[0]=_vertexVec1[0]-10*sinx;
				_vertexVec3[1]=_vertexVec1[1]-10*cosx;
				
				_vertexVec3[2]=_vertexVec1[2]-10*sinx;
				_vertexVec3[3]=_vertexVec1[3]-10*cosx;
				
				_vertexVec[0]=_vertexVec2[0];
				_vertexVec[1]=_vertexVec2[1];
				_vertexVec[2]=_vertexVec2[2];
				_vertexVec[3]=_vertexVec2[3];
				_vertexVec[4]=_vertexVec3[2];
				_vertexVec[5]=_vertexVec3[3];
				_vertexVec[6]=_vertexVec3[0];
				_vertexVec[7]=_vertexVec3[1];
			 
		}
		
		private function UpdateWallCorner():void
		{
			//wall
			graphics.clear();
			graphics.lineStyle(1,_lineColor);//白线
			
			if(_selected)
				graphics.beginFill(_wallColorSelected,0.8);
			else
				graphics.beginFill(_wallColor,0.8);
			
			graphics.moveTo(_vertexVec2[0],_vertexVec2[1]);
			graphics.lineTo(_vertexVec2[2],_vertexVec2[3]);
			graphics.lineTo(_vertexVec3[2],_vertexVec3[3]);
			graphics.lineTo(_vertexVec3[0],_vertexVec3[1]);
			graphics.endFill();
			
			//corners
			var len:int=_vertexVec1.length;
			for(var i:int=0;i<len;i+=2)
			{
				_wallCornerVec[i/2].Draw(_vertexVec1[i],_vertexVec1[i+1]);
			}
		}
		
	}
}