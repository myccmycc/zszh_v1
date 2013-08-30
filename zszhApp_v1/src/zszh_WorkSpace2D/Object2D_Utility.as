package zszh_WorkSpace2D
{
	import flash.geom.Point;

	public final class Object2D_Utility
	{
		//多边形自相交检测
		public static function SelfIntersection(vertex:Vector.<Number>,pos:int):Boolean
		{
			
			var len:int=vertex.length;
			var P0:Point=new Point(vertex[(pos)%len],vertex[(pos+1)%len]);
			var P1:Point=new Point(vertex[(pos+2)%len],vertex[(pos+3)%len]);
			
			for(var i:int=4;i<len-2;i+=2)
			{
				var P2:Point=new Point(vertex[(pos+i)%len],vertex[(pos+i+1)%len]);
				var P3:Point=new Point(vertex[(pos+i+2)%len],vertex[(pos+i+3)%len]);
				
				var isInter:Boolean=IsSegmentIntersection(P0,P1,P2,P3);
				if(isInter)
				{
					if(P1.x==P2.x&&P1.y==P2.y&&!OnSegment(P2,P3,P0))
						return false;
					if(P0.x==P3.x&&P0.y==P3.y&&!OnSegment(P2,P3,P1))
						return false;
					return true;
				}
			}
			
			return false;
		}
		
		
		public  static function Intersection( A1:Number, B1:Number, C1:Number , A2:Number, B2:Number, C2:Number ):Point
		{
			if (A1 * B2 == B1 * A2)    {
				if ((A1 + B1) * C2==(A2 + B2) * C1 ) {
					return new Point(Number.POSITIVE_INFINITY,0);
				} else {
					return new Point(Number.POSITIVE_INFINITY,Number.POSITIVE_INFINITY);
				}
			} 
				
			else {
				var result:Point=new Point;
				result.x = (B2 * C1 - B1 * C2) / (A2 * B1 - A1 * B2);
				result.y = (A1 * C2 - A2 * C1) / (A2 * B1 - A1 * B2);
				return result;
			}
		}
		
		public static function Intersection2( a:Point, b:Point, A2:Number, B2:Number, C2:Number ):Point
		{
			var  A1:Number, B1:Number, C1:Number;
			
			A1 = b.y - a.y;
			B1 = a.x - b.x;
			C1 = b.x * a.y - a.x * b.y;
			
			//当两个点为同一个点的时候
			if(a.x==b.x&&a.y==b.y)
			{
				A1 = B2;
				B1 = -A2;
				C1 = -A1*a.x-B1*a.y;
			}
			
			if (A1 * B2 == B1 * A2)    {
				if ((A1 + B1) * C2==(A2 + B2) * C1 ) {
					return new Point(Number.POSITIVE_INFINITY,0);
				} else {
					return new Point(Number.POSITIVE_INFINITY,Number.POSITIVE_INFINITY);
				}
			} 
				
			else {
				var result:Point=new Point;
				result.x = (B2 * C1 - B1 * C2) / (A2 * B1 - A1 * B2);
				result.y = (A1 * C2 - A2 * C1) / (A2 * B1 - A1 * B2);
				return result;
			}
		}
		

		public static function PointinTriangle( A:Point, B:Point, C:Point, P:Point):Boolean
		{
			var  v0:Point =new Point(C.x - A.x,C.y-A.y) ;
			var  v1:Point =new Point(B.x - A.x,B.y-A.y) ;
			var  v2:Point =new Point(P.x - A.x,P.y-A.y) ;
			
			var dot00:Number = v0.x*v0.x+v0.y*v0.y;
			var dot01:Number = v0.x*v1.x+v0.y*v1.y;
			var dot02:Number = v0.x*v2.x+v0.y*v2.y;
			var dot11:Number = v1.x*v1.x+v1.y*v1.y;
			var dot12:Number = v1.x*v2.x+v1.y*v2.y;
			
			var inverDeno:Number = 1 / (dot00 * dot11 - dot01 * dot01) ;
			
			var u:Number = (dot11 * dot02 - dot01 * dot12) * inverDeno ;
			if (u <= 0 || u >=1) // if u out of range, return directly  =0在A点，1在B点
			{
				return false ;
			}
			
			var v:Number = (dot00 * dot12 - dot01 * dot02) * inverDeno ;
			if (v <=0 || v >= 1) // if v out of range, return directly  =0在A点，1在C点
			{
				return false ;
			}
			
			return u + v < 1 ; //u+v ==1 是在线上，在这里不算在三角形内。
		}
		
		public static function GetPolygonArea(points:Vector.<Point>):Number
		{
			if (points.length < 3) {//至少是三角形
				return 0;
			}
			var result:Number = 0;
			for (var i:int = 1; i < points.length - 1; i++) {
				
				var p0:Point = points[0];
				var pi1:Point = points[i];
				var pi2:Point = points[i+1];
				var area:Number=-(pi1.x-p0.x)*(pi2.y-p0.y)+(pi2.x-p0.x)*(pi1.y-p0.y);
				result += area;
			}
			result *= 0.5;
			return result;
		}
		
		
		
		private static function Direction(p0:Point,p1:Point,p2:Point):int
		{
			var p0p1:Point=new Point(p1.x-p0.x,p1.y-p0.y);
			var p0p2:Point=new Point(p2.x-p0.x,p2.y-p0.y);
			
			var cross:int=p0p1.x*p0p2.y-p0p1.y*p0p2.x;
			return cross;
		}
		
		private static function OnSegment(p0:Point,p1:Point,p2:Point):Boolean
		{
			var minx:Number=Math.min(p0.x,p1.x);
			var miny:Number=Math.min(p0.y,p1.y);
			
			var maxx:Number=Math.max(p0.x,p1.x);
			var maxy:Number=Math.max(p0.y,p1.y);
			
			if(p2.x>=minx&&p2.x<=maxx&&p2.y>=miny&&p2.y<=maxy)
				return true;
			return false;
		}
		
		private static function IsSegmentIntersection( p0:Point,p1:Point,p2:Point,p3:Point ):Boolean
		{
			var d1:int=Direction(p0,p1,p2);var d2:int=Direction(p0,p1,p3);
			var t1:int=Direction(p2,p3,p0);var t2:int=Direction(p2,p3,p1);
			if(d1*d2<0&&t1*t2<0) return true;
			
			if(!d1&&OnSegment(p0,p1,p2))
				return true;
			if(!d2&&OnSegment(p0,p1,p3))
				return true;
			if(!t1&&OnSegment(p2,p3,p0))
				return true;
			if(!t2&&OnSegment(p2,p3,p1))
				return true;
			return false;
		}
		
		
	}
}