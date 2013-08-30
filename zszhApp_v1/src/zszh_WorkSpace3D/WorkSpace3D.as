package zszh_WorkSpace3D
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.SubMesh;
	import away3d.core.math.MathConsts;
	import away3d.core.math.Plane3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.library.utils.AssetLibraryIterator;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframeCube;
	import away3d.textures.Texture2DBase;
	import away3d.tools.utils.Bounds;
	import away3d.tools.utils.Ray;
	import away3d.utils.Cast;
	
	import zszh_WorkSpace2D.Object2D_PartitionWall;
	
	public class WorkSpace3D extends UIComponent
	{
		public static var gCurrentObj3D:ObjectContainer3D;
		//engine variables
		private var _view3d:View3D;
		private var _camera:Camera3D;
		private var _cameraController:HoverController;
		
		private var _view3d2:View3D;
		private var _camera2:Camera3D;
		private var _cameraController2:HoverController;
		
		//navigation variables
		private var _cameraMove:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		
		private var _directionLight:DirectionalLight;
		private var _pointLight:PointLight;
		public var _lightPicker:StaticLightPicker;
		

		//debug 
		private var _debug:AwayStats;
		//rooms
		private var _roomContainer3D:ObjectContainer3D;
		//wallInside
		private var _wallInsideContainer3D:ObjectContainer3D;
		//models
		public var _modelsContainer3D:ObjectContainer3D;
		
		//Center 
		public var _cameraCenter:ObjectContainer3D;
		public var _centerPos:Vector3D;
		
		private var _meshArray:Array;
		
		public function WorkSpace3D()
		{
			super();  
			
			//3D loader	
			//AssetLibrary.enableParser(AWD2Parser);
			//AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
 			this.addEventListener(DragEvent.DRAG_ENTER,OnDragEnter);
			this.addEventListener(DragEvent.DRAG_DROP,OnDragDrop);
			addEventListener(FlexEvent.CREATION_COMPLETE,OnCreation_Complete);
		}
	
		private function onAssetComplete(event:AssetEvent):void
		{
			trace(event.asset.assetType);
			if(event.asset.assetType=="mesh")
			{
				_modelsContainer3D.addChild(Mesh(event.asset));
				
			//	var model:Model_3D=new Model_3D(resPath,modelName,pos);
				//_modelsContainer3D.addChild(model);
			}
		}
		
		
		//--------punblic functions------------------------------------------
		public function ClearRoom():void
		{
			for(var i:int=_roomContainer3D.numChildren-1;i>=0;i--)
				_roomContainer3D.removeChildAt(i);
			
		}
		public function AddRoom(pos1:Vector.<Number>,pos2:Vector.<Number>,pos3:Vector.<Number>,floorTex:String,roomName:String):void
		{
			var room:Room_3D=new Room_3D(pos1,pos2,pos3,floorTex,_lightPicker);
			room.name=roomName;
			_roomContainer3D.addChild(room);
		}
		
		public function ClearWallInside():void
		{
			for(var i:int=_wallInsideContainer3D.numChildren-1;i>=0;i--)
				_wallInsideContainer3D.removeChildAt(i);
			
		}
		public function AddWallInside(pos1:Vector.<Number>,wallName:String):void
		{
			var wallInside:WallInside_3D=new WallInside_3D(pos1,_lightPicker);
			wallInside.name=wallName;
			_wallInsideContainer3D.addChild(wallInside);
		}
		
		
		public function ClearModels():void
		{
			for(var i:int=_modelsContainer3D.numChildren-1;i>=0;i--)
				_modelsContainer3D.removeChildAt(i);
			
			//AssetLibrary.removeAllAssets();

		}
		
		public function AddModels(resPath:String,modelName:String,pos:Vector3D,name:String):void
		{	
			//var modelFile:String=resPath+modelName+".awd";
			//AssetLibrary.load(new URLRequest(modelFile));
			
			var model:Model_3D=new Model_3D(resPath,modelName,pos,_lightPicker);
			model.name=name;
			_modelsContainer3D.addChild(model);
		}
		
	
		
		//--------------init the workspace3d-------------------------
		private function OnCreation_Complete(e:FlexEvent):void
		{
		
			_view3d=new View3D();
			_view3d.backgroundColor=0x303344;
			_view3d.antiAlias=4;
			addChild(_view3d);
			
			addEventListener(Event.ENTER_FRAME,OnFrameEnter);
						
			//setup debuh info
			//_debug=new AwayStats(_view3d);
			//addChild(_debug);
			
			_camera = new Camera3D();
			_view3d.camera = _camera;

			//setup controller to be used on the camera
			_cameraCenter=new ObjectContainer3D();
			_cameraCenter.addChild(new Trident(50));
			_view3d.scene.addChild(_cameraCenter);
			
			_cameraController = new HoverController(_camera,_cameraCenter, 180,60, 800);
			_cameraController.maxTiltAngle=45;
			_cameraController.minTiltAngle=25;
			
			//setup light
			_directionLight = new DirectionalLight();
			_directionLight.direction = _view3d.camera.forwardVector;
			_directionLight.color = 0xFFFFFF;
			_directionLight.ambient = 0.2;
			_directionLight.diffuse = 0.1;
			
			_pointLight = new PointLight();
			_pointLight.y=500;
			_pointLight.x=500;
			_pointLight.color=0xFFFFFF;
			_pointLight.ambient=0.2;
			_pointLight.diffuse=0.5;
			_pointLight.specular=0.5;
			
			_view3d.scene.addChild(_directionLight);
			_view3d.scene.addChild(_pointLight);
			
			_lightPicker = new StaticLightPicker([_pointLight,_directionLight]);
			
							
			_view3d.addEventListener(MouseEvent.MOUSE_DOWN,MOUSE_DOWN_view3d);
			_view3d.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,MIDDLE_MOUSE_DOWN_view3d);
			_view3d.addEventListener(MouseEvent.MOUSE_WHEEL,MOUSE_WHEEL_view3d);
			
			//setup the scene
			_roomContainer3D = new ObjectContainer3D();
			_wallInsideContainer3D=new ObjectContainer3D();
			_modelsContainer3D= new ObjectContainer3D();
			
			_view3d.scene.addChild(_roomContainer3D);
			_view3d.scene.addChild(_wallInsideContainer3D);
			_view3d.scene.addChild(_modelsContainer3D);
			
			InitView3dSmall();
			
		}
		
		
		private function InitView3dSmall():void
		{
			
			_view3d2=new View3D();
			_view3d2.backgroundAlpha=0;
			_view3d2.backgroundColor=0x303344;
			_view3d2.antiAlias=4;
			_view3d2.width=150;
			_view3d2.height=150;
			addChild(_view3d2);
				
			// cubes
			var cubeGeometry:CubeGeometry = new CubeGeometry(200,200,200, 10, 10, 10);
			var cubeMaterial:ColorMaterial = new ColorMaterial( 0x535564 );
			//cubeMaterial.lightPicker = lightPicker;
			var mesh:Mesh = new Mesh(cubeGeometry, cubeMaterial);
			mesh.showBounds=true;
			mesh.bounds.boundingRenderable.color = 0x449ebe;
			_view3d2.scene.addChild(mesh);
			
			var lens:OrthographicLens = new OrthographicLens();
			_camera2 = new Camera3D(lens);
			_camera2.lens
			_view3d2.camera = _camera2;
			//setup controller to be used on the camera
			_cameraController2 = new HoverController(_camera2, mesh, 180,60, 800);
			_cameraController2.maxTiltAngle=45;
			_cameraController2.minTiltAngle=25;
			
			//setup camera controller
			_view3d2.addEventListener(MouseEvent.MOUSE_DOWN,MOUSE_DOWN_view3d2);

			
		}
		
	
		public function ShowCenter3D():void
		{
			
		}
		
		private function OnFrameEnter(e:Event):void
		{
			
			if(_view3d)
			{
				_view3d.width = unscaledWidth;
				_view3d.height = unscaledHeight ;
			}
			
			if(_view3d2&&_view3d)
			{
				_view3d2.x = unscaledWidth-250;
				_view3d2.y = 100 ;
			}
			
			
			if(_view3d.stage3DProxy)
			{
				_view3d.render();
				_pointLight.position= _view3d.camera.position;
 
				_directionLight.direction = _view3d.camera.forwardVector;
			}
			
			if(_view3d2.stage3DProxy)
			{
				_view3d2.render();
			}
			
			if (_cameraMove) {
				_cameraController2.panAngle = (mouseX - lastMouseX) + lastPanAngle;
				_cameraController2.tiltAngle = (mouseY - lastMouseY) + lastTiltAngle;
				
				_cameraController.panAngle = 	_cameraController2.panAngle;
				_cameraController.tiltAngle =   _cameraController2.tiltAngle;
			}
		}
		
		
		//-----------------mouse event---------------------------------------------
		/**
		 * _view3d listener for mouse interaction
		 */
		//左键
		private var _bMDown_view3d:Boolean=false;
		private var _MDownPos:Point=new Point(0,0);
		private var _MDownCameraPos:Point=new Point(0,0);
		
		private function MOUSE_DOWN_view3d2(ev:MouseEvent) : void
		{
			_bMDown_view3d=true;
			_MDownPos.x=ev.localX;
			_MDownPos.y=ev.localY;
			
			_MDownCameraPos.x=_view3d.camera.x;
			_MDownCameraPos.y=_view3d.camera.z;
			
			lastPanAngle = _cameraController.panAngle;
			lastTiltAngle = _cameraController.tiltAngle;
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			_cameraMove = true;
			addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			addEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d2);
			addEventListener(MouseEvent.MOUSE_UP,MOUSE_UP_view3d2);
			
		}
		private function MOUSE_UP_view3d2(ev:MouseEvent) : void
		{
			_bMDown_view3d=false;			
			_cameraMove = false;
			removeEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d2);
			removeEventListener(MouseEvent.MOUSE_UP,MOUSE_UP_view3d2);
			removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onStageMouseLeave(event:Event):void
		{
			_cameraMove = false;
			removeEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d2);
			removeEventListener(MouseEvent.MOUSE_UP,MOUSE_UP_view3d2);
			removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		//左键
		private var _bMouseDown:Boolean=false;
		private var _bFirstIn:Boolean=true;
		private var _MouseDownPos:Vector3D=new Vector3D;
		
		private var _bMidMouseDown:Boolean=false;
		
		private var _MMDownPos:Point=new Point(0,0);
		private var _MMDownCameraPos:Point=new Point(0,0);
		
		private function MOUSE_DOWN_view3d(event:MouseEvent):void
		{
			_bMouseDown=true;
			gCurrentObj3D=null;
			_bFirstIn=true;
			
			_view3d.addEventListener(MouseEvent.MOUSE_MOVE,MOUSE_MOVE_view3d);
			_view3d.addEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d);
			_view3d.addEventListener(MouseEvent.MOUSE_UP,MOUSE_UP_view3d);

		}
		
		//中键
		
		private function MIDDLE_MOUSE_DOWN_view3d(event:MouseEvent):void
		{
			_bMidMouseDown=true;
			_MMDownPos.x=event.localX;
			_MMDownPos.y=event.localY;
			
			_view3d.addEventListener(MouseEvent.MOUSE_MOVE,MOUSE_MOVE_view3d);
			_view3d.addEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d);
			_view3d.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,MOUSE_UP_view3d);
			
		}
		
		private function MOUSE_MOVE_view3d(event:MouseEvent) : void
		{
			if(_bMouseDown&&gCurrentObj3D)
			{
				var screenX:Number=2*this.mouseX/this.unscaledWidth-1;
				var screenY:Number=2*this.mouseY/this.unscaledHeight-1;
				var cameraRay:Vector3D=_camera.getRay(screenX,screenY,1);
				trace(_camera.scenePosition);
				trace(cameraRay);

				var planeNormal:Vector3D=new Vector3D(0,1,0);
				
				var bound:Bounds=new Bounds;
				Bounds.getObjectContainerBounds(gCurrentObj3D)
				var planePos:Vector3D=new Vector3D(0,gCurrentObj3D.y+Bounds.height,0);
				var t:Number=(planeNormal.dotProduct(planePos)-planeNormal.dotProduct(_camera.scenePosition))/planeNormal.dotProduct(cameraRay);

				var interP:Vector3D=new Vector3D;
				interP.x=_camera.scenePosition.x+cameraRay.x*t;
				interP.y=_camera.scenePosition.y+cameraRay.y*t;
				interP.z=_camera.scenePosition.z+cameraRay.z*t;
				
				if(_bFirstIn)
				{
					_bFirstIn=false;
					_MouseDownPos=interP;
				}
				else 
				{
					gCurrentObj3D.x+=interP.x-_MouseDownPos.x;
					gCurrentObj3D.z+=interP.z-_MouseDownPos.z;
					_MouseDownPos=interP;
				}
				
				//var plane:Plane3D=new Plane3D();
				//plane.fromNormalAndPoint(new Vector3D(0,1,0),new Vector3D(0,gCurrentObj3D.y,0) );
				
				
				
				/*var dest:Vector3D=this._camera.unproject(screenX,screenY,100);
				
				var dest2:Vector3D=new Vector3D(_camera.scenePosition.x+cameraRay.x,_camera.scenePosition.y+cameraRay.y,_camera.scenePosition.z+cameraRay.z);
				
				var plane:Plane3D=new Plane3D();
				plane.fromNormalAndPoint(new Vector3D(0,1,0),new Vector3D(0,gCurrentObj3D.y,0) );
				
				var ray:Ray=new Ray;
				var v0:Vector3D = new Vector3D(1,gCurrentObj3D.y,0);
				var v1:Vector3D = new Vector3D(0,gCurrentObj3D.y,1);
				var v2:Vector3D = new Vector3D(0,gCurrentObj3D.y,0);
				
				
				var intersect:Vector3D = ray.getRayToTriangleIntersection(this._camera.position, dest, v0, v1, v2 );
				trace("intersect ray: "+intersect);
				
				
				var p1:Vector3D=this._camera.project(gCurrentObj3D.scenePosition);
				
				trace(gCurrentObj3D.position);
				trace(gCurrentObj3D.scenePosition);
				
				var p2:Vector3D=this._camera.unproject(p1.x,p1.y,p1.z);
				
				trace(p2);
				
				var intersect2:Vector3D = ray.getRayToTriangleIntersection(this._camera.scenePosition, new Vector3D(0,0,0), v0, v1, v2 );
				
				var v0:Vector3D = new Vector3D(1,0,0);
				var v1:Vector3D = new Vector3D(0,0,1);
				var v2:Vector3D = new Vector3D(0,0,0);
				var intersect2:Vector3D = ray.getRayToTriangleIntersection(this._camera.scenePosition, new Vector3D(0,1,0), v0, v1, v2 );
				//gCurrentObj3D.x=intersect.x;
				//gCurrentObj3D.y=intersection.y;
				//gCurrentObj3D.z=intersect.z;*/
			}
			
			else if(_bMidMouseDown)
			{
				
				_cameraCenter.x-=(event.localX-_MMDownPos.x)*10;
				_cameraCenter.z+=(event.localY-_MMDownPos.y)*10;
				
				_MMDownPos.x=event.localX;
				_MMDownPos.y=event.localY;
			}
		}
		
		
		private function MOUSE_UP_view3d(event:MouseEvent):void
		{
			_bMouseDown=false;
			_bMidMouseDown=false;
			
			_view3d.removeEventListener(MouseEvent.MOUSE_MOVE,MOUSE_MOVE_view3d);
			_view3d.removeEventListener(MouseEvent.MOUSE_OUT,MOUSE_UP_view3d);
			_view3d.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP,MOUSE_UP_view3d);
			_view3d.removeEventListener(MouseEvent.MOUSE_UP,MOUSE_UP_view3d);
		}
		
		
	
			
		private function MOUSE_WHEEL_view3d(ev:MouseEvent) : void
		{
			if(ev.delta<0&&_cameraController.distance<1200)
			{
				_cameraController.distance+=20;
			}
			else if(_cameraController.distance>500)
			{
				_cameraController.distance-=20;
			}				
		}
		
		//----------------D&D-------------------
		private function OnDragEnter(event:DragEvent):void
		{
			DragManager.acceptDragDrop(event.target as UIComponent);
		}
		
		private static var currentMesh:Mesh=null;
		
		private function OnDragDrop(event:DragEvent):void
		{
			var className:String=String(event.dragSource.dataForFormat("className"));
			var classArgument:String=String(event.dragSource.dataForFormat("classArgument"));
			var resourcePath:String=String(event.dragSource.dataForFormat("resourcePath"));
			var objectName:String=String(event.dragSource.dataForFormat("objectName"));
			
			
			if(className=="rujiaoqi")
			{
				 
				var wallTex:String=resourcePath+"texture.jpg";
				
				var wallTexLoader:Loader = new Loader();
				wallTexLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
				wallTexLoader.load(new URLRequest(wallTex));
				
				function onComplete(e:Event):void
				{
					var wallBitmap:Bitmap = Bitmap(wallTexLoader.content);
					var wallMaterial:MaterialBase = new TextureMaterial(Cast.bitmapTexture(wallBitmap));
					
					var wall:Mesh=GetCurrentWallMesh();
					if(wall)
						wall.material=wallMaterial;
				}
				
			}
		}
		
		private function GetCurrentWallMesh():Mesh
		{
			return currentMesh;
		}
		
		public static function SetCurrentWallMesh(mesh:Mesh):void
		{
			currentMesh=mesh;
		}
		
	}
}