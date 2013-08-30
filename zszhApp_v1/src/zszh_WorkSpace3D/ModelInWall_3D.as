package zszh_WorkSpace3D
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.data.EntityListItem;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.utils.Cast;
	
	import zszh_WorkSpace3D.WorkSpace3D;
	
	public class ModelInWall_3D extends ObjectContainer3D
	{
		public var _resPath:String;
		public var _modelName:String;
		public var _dirction:Vector3D;
		
		public var _loaderModel:Loader3D;
		//WorkSpace3D _lightPicker
		private var _lightPicker:StaticLightPicker;
		
		private var _mesh:Mesh;
		
		private var _frontTex:String;
		private var _backTex:String;
		private var _frontLoader:Loader;
		private var _backLoader:Loader;
		
		//material objects
		private var _frontMaterial:TextureMaterial;
		private var _backMaterial:TextureMaterial;
		
		public function ModelInWall_3D(path:String,name:String,pos:Vector3D,dir:Vector3D,lightPick:StaticLightPicker)
		{
			super();
			_resPath=path;
			_modelName=name;
			position=pos;
			_dirction=dir;
			_lightPicker=lightPick;
			
			_frontTex=_resPath+"front.png";
			_backTex=_resPath+"back.png";
			
			_frontLoader=new Loader;
			_frontLoader.load(new URLRequest(_frontTex));
			_frontLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteFront);
			
			_backLoader=new Loader;
			_backLoader.load(new URLRequest(_backTex));
			_backLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteBack);
		}
		
		private function onCompleteFront(e:Event):void
		{
			_frontMaterial = new TextureMaterial(Cast.bitmapTexture(_frontLoader.content));
		}
		
		private function onCompleteBack(e:Event):void
		{
			_backMaterial = new TextureMaterial(Cast.bitmapTexture(_backLoader.content));
		}
		
		private function Update():void
		{
			if(_frontMaterial&&_backMaterial)
			{
				var gem:Geometry=new Geometry();
				var subGeom : SubGeometry = new SubGeometry;
				
				var vertex : Vector.<Number> = new Vector.<Number>;
				var index : Vector.<uint> = new Vector.<uint>;
				var uv : Vector.<Number> = new Vector.<Number>;
				
				//p0  pi pi+1 顺时针方向 三角形
				vertex.push(-100,50,0,
					100,50,0,
					100,-50,0,
					-100,-50, 0);
				
				index.push(0,1,2,0,2,3);
				

				
				uv.push(0, 0,
					0, 1,
					1, 0,
					1, 1);
				
				subGeom.updateVertexData(vertex);
				subGeom.updateIndexData(index);
				subGeom.updateUVData(uv);
				gem.addSubGeometry(subGeom);
				
				
				_mesh=new Mesh(gem,_frontMaterial);
				addChild(_mesh);
				
				_mesh.mouseEnabled=true;
				_mesh.pickingCollider=PickingColliderType.AS3_BEST_HIT;
				
				_mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,MeshMouseDown);
				//_mesh.addEventListener(MouseEvent3D.MOUSE_OVER,MeshMouseMove);
				_mesh.addEventListener(MouseEvent3D.MOUSE_OUT,MeshMouseUp);
			}
		}
		
		private var startPoint:Point;
		private var bStart:Boolean=false;
		private function MeshMouseDown(e:MouseEvent3D):void
		{
			e.target.showBounds=true;
			startPoint=new Point;
			bStart=true;
			startPoint.x=e.scenePosition.x;
			startPoint.y=e.scenePosition.z;
			
			//e.target.addEventListener(MouseEvent3D.MOUSE_MOVE, MeshMouseMove);
			
			WorkSpace3D.gCurrentObj3D=this;
			
			trace("MeshMouseDown");
			trace(e.screenX);
			trace(e.screenY);
			/*trace(e.screenX);
			trace(e.screenY);
			trace(e.scenePosition);
			trace(e.localPosition);*/
			
			
			//update ray
			/*var rayPosition:Vector3D = e.view.unproject(e.screenX, e.screenY, 0);
			var rayDirection:Vector3D = e.view.unproject(e.screenX, e.screenY, 1);
			rayDirection = rayDirection.subtract(rayPosition);
			
			trace(rayPosition);
			trace(rayDirection);
			/*if (entity.isVisible && entity.isIntersectingRay(rayPosition, rayDirection))
			{
				
			}	*/
				
		}
		
		private function MeshMouseMove(e:MouseEvent3D):void
		{
			if(bStart)
			{
				
				var dx:Number=e.scenePosition.x-startPoint.x;
				var dz:Number=e.scenePosition.z-startPoint.y;
				
				
				e.target.parent.x+=dx;
				e.target.parent.z+=dz;
				
				startPoint.x=e.scenePosition.x;
				startPoint.y=e.scenePosition.z;
				
			}
		}
		private function MeshMouseUp(e:MouseEvent3D):void
		{
			bStart=false;
			e.target.removeEventListener(MouseEvent3D.MOUSE_MOVE, MeshMouseMove);
		}
		
	}

}