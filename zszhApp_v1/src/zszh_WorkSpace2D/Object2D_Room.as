package zszh_WorkSpace2D
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import zszh_Core.CommandManager;

	public class Object2D_Room extends Object2D_Base
	{
		public  var _vertexVec1:Vector.<Number>;
		public  var _vertexVec2:Vector.<Number>;
		public  var _vertexVec3:Vector.<Number>;
		
		public  var _floor:Room_2DFloor;
		
		private var _roomType:String;//0小,1大,2L,3room
		
		public function Object2D_Room(roomType:String,_vertexData:Vector.<Number>=null)
		{
			super();
			_vertexVec1=new Vector.<Number>();
			_vertexVec2=new Vector.<Number>();
			_vertexVec3=new Vector.<Number>();
			
			if(_vertexData!=null&&roomType=="0")
				_vertexVec1=_vertexData;
			else if(_vertexData!=null&&roomType!="0")
				trace("error: Object2D_Room if construct _vertexData!=null , roomType should is '0'.");
			
			_roomType=roomType;		
			addEventListener(FlexEvent.CREATION_COMPLETE,OnCreation_Complete);
		}
		
		
		public function DeleteThisRoom():void
		{
			CommandManager.Instance.Delete(this.parent as UIComponent,this);
		}
		
		public function SetAllSelected(b:Boolean):void
		{
			for(var i:int=0;i<numChildren;i++)
				(getChildAt(i) as Object2D_Base).SetSelected(b);

		}
	
		override public function Object2DUpdate():void
		{
			SetAllSelected(_selected);
			Draw();
		}
		
		override public function Draw():void
		{
			
			UpdateVertexData();
			
			for(var i:int=0;i<numChildren;i++)
				(getChildAt(i) as Object2D_Base).Draw();
			
			
			//floor
			//_floor.Draw();
			
			//walls and corners
		/*	var len:int=_vertexVec1.length;
			for(var i:int=0;i<len;i+=2)
			{
				_wallVec[i/2].UpdateVertex(_vertexVec2[i],_vertexVec2[i+1],_vertexVec2[(i+2)%len],_vertexVec2[(i+3)%len],_vertexVec3[i],_vertexVec3[i+1],_vertexVec3[(i+2)%len],_vertexVec3[(i+3)%len]);
				_wallCornerVec[i/2].Draw(_vertexVec1[i],_vertexVec1[i+1]);
			}*/
		}
		
		
		private function OnCreation_Complete(e:FlexEvent):void
		{
		
			if(_roomType=="4")
			{
				_vertexVec1.push(-100,50,100,100,100,-100,-100,-100);
			}
			else if(_roomType=="1")
			{
				_vertexVec1.push(-200,200,200,200,200,-200,-200,-200);
			}
				
			else if(_roomType=="2")
			{
				_vertexVec1.push(0,0, 200,0, 200,-200, -200,-200,  -200,200, 0,200);
			}
				
			else if(_roomType=="3")
			{
				_vertexVec1.push(0,400, 500,400, 500,-300, 0,-300, 0,-500, -500,-500, -500,500, 0,500);
			}
			
			
			UpdateVertexData();
			
			//floor
			_floor=new Room_2DFloor();
			addChild(_floor);
			
			//walls
			//_wallVec=new Vector.<Room_2DWall>;	
			var len:int=_vertexVec1.length;
			for(var i:int=0;i<len;i+=2)
			{
				var wall:Room_2DWall=new Room_2DWall();
				wall._postionInRoom=i;
				addChild(wall);
				//_wallVec.push(wall);
				//wall.UpdateVertex(_vertexVec2[i],_vertexVec2[i+1],_vertexVec2[(i+2)%len],_vertexVec2[(i+3)%len],_vertexVec3[i],_vertexVec3[i+1],_vertexVec3[(i+2)%len],_vertexVec3[(i+3)%len]);
			}
			
			//wall corners 
			//_wallCornerVec=new Vector.<Room_2DCorner>;
			for(i=0;i<_vertexVec1.length;i+=2)
			{
				var wallCorner:Room_2DCorner=new Room_2DCorner();
				wallCorner._posInRoom=i;
			//	wallCorner.Draw(_vertexVec1[i],_vertexVec1[i+1]);
				addChild(wallCorner);
				//_wallCornerVec.push(wallCorner);
			}
		}
		
		
		
		private function UpdateVertexData():void
		{	
			for(var i:int=0;i<_vertexVec1.length;i+=2)
			{
				var P1:Point=new Point(_vertexVec1[i],_vertexVec1[i+1]);
				var P2:Point=new Point(_vertexVec1[(i+2)%_vertexVec1.length],_vertexVec1[(i+3)%_vertexVec1.length]);
				var P3:Point=new Point(_vertexVec1[(i+4)%_vertexVec1.length],_vertexVec1[(i+5)%_vertexVec1.length]);	
				
				//2 P1P2 直线方程  Ax+By+c=0的表达式
			
				var A1:Number=(P2.y-P1.y);
			
				var B1:Number=(P1.x-P2.x);
			
				var C1:Number = P2.x*P1.y-P1.x*P2.y;
			
				//trace("ABC:"+A1+B1+C1);
			
				//2求平移后的直线  |C1-C0|/sqrt（A*A+B*B）=DIS
			
				var aabb:Number=Math.sqrt(A1*A1+B1*B1);
			
				var dis:Number=10;
			
			
				var s:Number=dis*aabb;
			
				var C1_1:Number=C1+s;
				var C1_2:Number=C1-s;
				//trace("C1_1:"+C1_1);
				//trace("C1_2:"+C1_2);
				
				
				//2 P2P3 直线方程  Ax+By+c=0的表达式
			
				var A2:Number=(P3.y-P2.y);
			
				var B2:Number=(P2.x-P3.x);
			
				var C2:Number = P3.x*P2.y-P2.x*P3.y;
			
				//trace("ABC:"+A2+B2+C2);
			
				//2求平移后的直线  |C1-C0|/sqrt（A*A+B*B）=DIS
			
				var aabb2:Number=Math.sqrt(A2*A2+B2*B2);
			
				var dis2:Number=10;
			
			
				var s2:Number=dis2*aabb2;
			
				var C2_1:Number=C2+s2;
				var C2_2:Number=C2-s2;
				//trace("C2_1:"+C2_1);
				//trace("C2_2:"+C2_2);
			
				 //求P1P2平移线 和P2P3平移线 交点
				var p:Point=Object2D_Utility.Intersection(A1,B1,C1_1,A2,B2,C2_1);
				if(p.x!=Number.POSITIVE_INFINITY&& p.y!=Number.POSITIVE_INFINITY)
				{
					_vertexVec3[i]=p.x;
					_vertexVec3[i+1]=p.y;
				}
				
				p=Object2D_Utility.Intersection(A1,B1,C1_2,A2,B2,C2_2);
				if(p.x!=Number.POSITIVE_INFINITY&& p.y!=Number.POSITIVE_INFINITY)
				{
					_vertexVec2[i]=p.x;
					_vertexVec2[i+1]=p.y;
				}
			}
		}
		
	}
}