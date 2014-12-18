package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.XMLLoader;
	import com.greensock.plugins.ScrollRectPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import fl.transitions.easing.None;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class fatBirds extends Sprite
	{
		public static var STAGE:Stage;
		private var WORLD_STAGE:Stage;
		
		private static var pivots:Vector.<Pivot> = new Vector.<Pivot>();
		private static var allPivots:Vector.<Pivot>;
		private static var allRods:Vector.<Rod>;
		private static var allTerrains:Vector.<Terrain>;
		private static var allBirds:Vector.<Bird>;
		
		static private var startPoint:Point;
		static private var endPoint:Point;
		static private var startPiv:Pivot;
		static private var endPiv:Pivot;
		
		private var logsLeft:int = 0;
		private var debug_sprite:Sprite;
		private var mode:int = 0;							// 0 = Normal, 1 = Delete
		private static var gravMode:Boolean;
		public static var rodMode:uint;
		private var xmlLoader:XMLLoader;
		public static var worldWidth:int;
		public static var worldHeight:int;
		private var originX:int = 0;
		private var timekeeper:Timer;
		
		private var second:int = 0;
		private var minute:int = 0;
		private var ms:int = 0;
		
		public static var money:int;
		public static var baseRodCost:int;
		public static var pillarCost:int;
		private var gridSpacing:int = 25;
		private var gr:Grid;
		private static var mn:TextField;
		static private var pivotCount = 0;
		private var shouldDraw:Boolean;
		private var gameMen:gameMenu;
		private var isRunning:Boolean;
		private var helper:Sprite;
		public static var winLimit:int = 0;
		public static var endFlag:Boolean = false;
		public static var successFlag:Boolean = false;
		private var uid:String;
		private var chances:int = 0;
		private var clearedLite:levelCl;
		private var failLite:failure;
		private var range1:Number;
		private var range2:Number;
		private var range3:Number;
		
		public function fatBirds(stg:Stage, level:String) 
		{
			isRunning = false;
			shouldDraw = false;
			WORLD_STAGE = stg;
			xmlLoader = new XMLLoader(level, { name:"levelXML", onComplete:xmlLoaded, onError:errorHandler } );
			xmlLoader.load();
			//this.chances = chances;
			//trace("grav", GenConstants.fatWorld.GetGravity().x, GenConstants.fatWorld.GetGravity().y);
		}
		
		private function scrollRight(e:MouseEvent):void 
		{
			trace("check width:", worldWidth);
			
			if ((originX + STAGE.stageWidth) < worldWidth) {
				TweenLite.to(this, 1, { ease:None.easeNone, scrollRect: { x: originX + 60, y:this.y, width:STAGE.stageWidth, height:STAGE.stageHeight }} );
				//TweenLite.to(helper, 1, {x:originX + 50, y:this.y});
				originX += 60;
			}
			WORLD_STAGE.focus = this;
			fatBirds.STAGE.focus = fatBirds.STAGE;
			
			trace(this.x);
		}
		
		private function errorHandler(e:Event):void 
		{
			trace("Error loading XML");
		}
		
		private function xmlLoaded(ev:LoaderEvent):void 
		{
			
			GenConstants.fatWorld = new b2World(new b2Vec2(0, 0), false);
			STAGE = this.stage;
			fatBirds.STAGE.focus = fatBirds.STAGE;
			gravMode = false;
			rodMode = GenConstants.CATEGORY_BASE;
			
			allPivots = new Vector.<Pivot>();
			allRods = new Vector.<Rod>();
			allTerrains = new Vector.<Terrain>();
			allBirds = new Vector.<Bird>();
			
			TweenPlugin.activate([ScrollRectPlugin]);
			var goR:goRight = new goRight();
			//STAGE.addChild(goR);
			goR.x = WORLD_STAGE.stageWidth - 30;
			goR.y = WORLD_STAGE.stageHeight / 2-200;
			
			goR.addEventListener(MouseEvent.MOUSE_DOWN, scrollRight);
			
			var goL:goRight = new goRight();
			//STAGE.addChild(goL);
			goL.x = 30;
			goL.rotation = 180;
			goL.y = WORLD_STAGE.stageHeight / 2-200;
			
			goL.addEventListener(MouseEvent.MOUSE_DOWN, scrollLeft);
			
			var xml:XML = new XML(LoaderMax.getContent("levelXML"));
			
			for each(var pr in xml.params) {
				worldWidth = parseInt(pr.@width);
				worldHeight = parseInt(pr.@height);
				GenConstants.maxForce = parseFloat(pr.@maxForceTemp);
				pillarCost = parseInt(pr.@pillarCost);
				baseRodCost = parseInt(pr.@baseRodCost);
				money = parseInt(pr.@money);
				GenConstants.maxRodLength = parseInt(pr.@maxRodLength);
				winLimit = pr.@winlimit;
				range1 = parseInt(pr.@range1);
				range2 = parseInt(pr.@range2);
				range3 = parseInt(pr.@range3);
				
				gridSpacing = parseInt(pr.@gridSpacing);
				gr = new Grid(gridSpacing, worldWidth, worldHeight);
				this.addChild(gr);
				//gr.alpha = 0.1;
				//trace("width:", worldWidth);
			}
			
			var debug_draw:b2DebugDraw = new b2DebugDraw();
			debug_sprite = new Sprite();
			this.addChild(debug_sprite);
			debug_draw.SetSprite(debug_sprite);
			debug_draw.SetDrawScale(30);
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit);
			debug_draw.SetLineThickness(1);
			debug_draw.SetAlpha(0.8);
			debug_draw.SetFillAlpha(0.3);
			GenConstants.fatWorld.SetDebugDraw(debug_draw);
			
			for each(var pv in xml.pivot) {
				trace("pivot detected");
				allPivots.push(new Pivot(this, parseFloat(pv.@maxforce), new Point(parseInt(pv.@x)*gridSpacing, parseInt(pv.@y)*gridSpacing), getNextPivotId()));
			}
			
			/*allPivots.push(new Pivot(50, new Point(500, 350), getNextPivotId()));
			allPivots.push(new Pivot(50, new Point(200, 400), getNextPivotId()));
			allPivots.push(new Pivot(50, new Point(700, 350), getNextPivotId()));*/
			
			for each(var tr in xml.terrain) {
				trace("terrain detected");
				allTerrains.push(new Terrain(this, new Point(parseInt(tr.@x)*gridSpacing, parseInt(tr.@y)*gridSpacing), parseInt(tr.@width)*gridSpacing, parseInt(tr.@height)*gridSpacing, parseFloat(tr.@leftPivot), parseFloat(tr.@rightPivot)));
			}
			
			/*allTerrains.push(new Terrain(new Point(0, 650), 100, 150));
			allTerrains.push(new Terrain(new Point(300, 650), 100, 150));
			allTerrains.push(new Terrain(new Point(900, 650), 100, 150));*/
			
			for each(var br in xml.bird) {
				trace("bird detected");
				allBirds.push(new Bird(this, parseInt(br.@width)*gridSpacing, parseInt(br.@height)*gridSpacing, parseInt(br.@density), new Point(parseInt(br.@x)*gridSpacing, parseInt(br.@y)*gridSpacing)));
			}
			
			/*allBirds.push(new Bird(20, 20, 0.8, new Point(20, 450)));
			allBirds.push(new Bird(20, 20, 3.5, new Point(20, 400)));*/
			STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
			
			//STAGE.addEventListener(KeyboardEvent.KEY_DOWN, toggleMode);
			this.addEventListener(Event.ENTER_FRAME, redraw);
			
			timekeeper = new Timer(100);
			timekeeper.addEventListener(TimerEvent.TIMER, ticktick);
			timekeeper.start();
			
			TweenLite.to(this, 0, { scrollRect: { x: originX, y:this.y, width:STAGE.stageWidth, height:STAGE.stageHeight }} );
			
		/*	mn = new TextField();
			mn.x = 600;
			mn.y = 200;
			mn.height = 20;
			mn.wordWrap = false;
			mn.autoSize = TextFieldAutoSize.LEFT;
			mn.setTextFormat(new TextFormat("Segoe UI" , 20));
			mn.text = String(money);
			STAGE.addChild(mn);*/
			
			gameMen = new gameMenu();
			STAGE.addChild(gameMen);
			gameMen.x = 32;
			gameMen.y = 15;
			gameMen.addPlatform.addEventListener(MouseEvent.CLICK, setBase);
			gameMen.addPillar.addEventListener(MouseEvent.CLICK, setPillar);
			gameMen.RunIt.addEventListener(MouseEvent.CLICK, runGame);
			gameMen.Restart.addEventListener(MouseEvent.CLICK, restartGame);
			gameMen.Delete.addEventListener(MouseEvent.CLICK, toggleDelete);
			gameMen.goLeft.addEventListener(MouseEvent.CLICK, scrollLeft);
			gameMen.goRight.addEventListener(MouseEvent.CLICK, scrollRight);
			
			gameMen.MoneyLeft.text = (String)(money);
			//GenConstants.fatWorld.RayCast(rayCastCallback, new b2Vec2(), new b2Vec2());
			helper = new Sprite();
			STAGE.addChild(helper);
			
			clearedLite = new levelCl();
			STAGE.addChild(clearedLite);
			clearedLite.x = STAGE.stageWidth / 2;
			clearedLite.y = STAGE.stageHeight / 2;
			clearedLite.visible = false;
			
			failLite = new failure();
			STAGE.addChild(failLite);
			failLite.x = STAGE.stageWidth / 2;
			failLite.y = STAGE.stageHeight / 2;
			failLite.visible = false;
		}
		
		private function restartGame(e:MouseEvent):void 
		{
			trace("restarting");
			endFlag = true;
			endGame();
		}
		
		private function setBase(e:MouseEvent):void {
			fatBirds.rodMode = GenConstants.CATEGORY_BASE;
			mode = 0;
				STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
				STAGE.removeEventListener(MouseEvent.CLICK, delObject);
				trace("Delete mode off");
		}

		private function setPillar(e:MouseEvent):void {
			fatBirds.rodMode = GenConstants.CATEGORY_PILLAR;
			mode = 0;
				STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
				STAGE.removeEventListener(MouseEvent.CLICK, delObject);
				trace("Delete mode off");
		}
		public function updateMoney(mon:int):void {
			if (gameMen != null) {
				fatBirds.money = mon;
				gameMen.MoneyLeft.text = (String)(mon);
			}
		}
		public static function hasMoney(amt:int):Boolean {
			if (amt <= money) {
				return true;
			}
			else {
				return false;
			}
		}
		
		private function scrollLeft(e:MouseEvent):void 
		{
			if (originX > 0) {
				TweenLite.to(this, 0.5, { ease:None.easeNone, scrollRect: { x: originX - 60, y:this.y, width:STAGE.stageWidth, height:STAGE.stageHeight }} );
				originX -= 60;
			}
			WORLD_STAGE.focus = this;
			fatBirds.STAGE.focus = fatBirds.STAGE;
		}
		
		private function ticktick(e:TimerEvent):void 
		{
			ms += 100;
			if (ms == 1000) {
				second++;
				ms = 0;
			}
			if (second == 60) {
				second = 0;
				minute++;
			}
			
			gameMen.min.text = String(minute);
			gameMen.sec.text = String(second);
			gameMen.millis.text = String(ms);
		}
		
		private function rayCastCallback(fix:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):void 
		{
			if (fix.GetBody().GetUserData() is Bird) {
				
			}
		}
		
		private function toggleDelete(e:MouseEvent):void {
			if (!isRunning) {
			if (mode == 0) {
				mode = 1;
				STAGE.removeEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
				STAGE.removeEventListener(MouseEvent.MOUSE_UP, stopPiece);
				STAGE.addEventListener(MouseEvent.CLICK, delObject);
				trace("Delete mode on");
			} else {
				mode = 0;
				STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
				STAGE.removeEventListener(MouseEvent.CLICK, delObject);
				trace("Delete mode off");
			}
			}
		}
		
		private function toggleMode(e:KeyboardEvent):void 
		{
			if (e.keyCode == 68) {
				if (mode == 0) {
					mode = 1;
					STAGE.removeEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
					STAGE.removeEventListener(MouseEvent.MOUSE_UP, stopPiece);
					STAGE.addEventListener(MouseEvent.CLICK, delObject);
					trace("Delete mode on");
				} else {
					mode = 0;
					STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
					STAGE.removeEventListener(MouseEvent.CLICK, delObject);
					trace("Delete mode off");
				}
			}
			if (e.keyCode == 65) {
				if (gravMode == false) {
					GenConstants.fatWorld.SetGravity(new b2Vec2(0, 10));
					for each (var pv:Pivot in allPivots) {
						pv.allowRotation();
						if (pv is Pivot2) {
							(Pivot2)(pv).makeDynamic();
						}
					}
					gravMode = true;
					this.removeChild(gr);
				}
				else {
					GenConstants.fatWorld.SetGravity(new b2Vec2(0, 0));
					gravMode = false;
				}
			}
		}
		
		private function runGame(e:MouseEvent) {
			if (!isRunning) {
				if (gravMode == false) {
					GenConstants.fatWorld.SetGravity(new b2Vec2(0, 10));
					for each (var pv:Pivot in allPivots) {
						pv.allowRotation();
						if (pv is Pivot2) {
							(Pivot2)(pv).makeDynamic();
						}
					}
					gravMode = true;
					timekeeper.stop();
					this.removeChild(gr);
				}
				isRunning = true;
			}
		}
		
		private function delObject(e:MouseEvent):void 
		{
			if (!isRunning) {
				trace(e.target.name);
				var s:String = e.target.name;
				var curRod:Rod, curPiv:Pivot, ind:int;
				
				if (s.substr(0, 3) == "Rod") {
					ind = parseInt(s.substr(3, s.length - 3));
					curRod = allRods[ind];
					curRod.destruct(this);
				}
				else if (s.substr(0, 3) == "Piv") {
					ind = parseInt(s.substr(3, s.length - 3));
					curPiv = allPivots[ind];
					if (curPiv is Pivot2)
						curPiv.destruct(this);
				}
			}
		}
		
		public function startNewPiece(e:MouseEvent):void 
		{
			if (!isRunning) {
				if ((rodMode == GenConstants.CATEGORY_BASE && hasMoney(baseRodCost)) || (rodMode == GenConstants.CATEGORY_PILLAR && hasMoney(pillarCost))) {
				var s:String = e.target.name;
				trace(" starting new piece from:", s, STAGE.mouseX);
				
				if (s!=null) {
					if (s.substr(0,3) == "Piv") {
						var ind:int = parseInt(s.substr(3, s.length-3));
						startPiv = allPivots[ind];
						
						if (startPiv.getJointCount() < GenConstants.maxJoints) {
							//trace("you can go on");
							startPoint = new Point((startPiv.getPivotBody().GetWorldCenter().x * GenConstants.RATIO), (startPiv.getPivotBody().GetWorldCenter().y * GenConstants.RATIO));	
							STAGE.removeEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
							STAGE.addEventListener(MouseEvent.MOUSE_MOVE, keepDrawing);
							STAGE.addEventListener(MouseEvent.MOUSE_UP, stopPiece);
							trace("start point: ", startPoint.x, startPoint.y);
						}
						else {
							startPoint = null;
						}
					}
				}
			}
			}
		}
		
		private function keepDrawing(e:MouseEvent):void {
			if (!isRunning) {
				//trace("go on mate");
				var len:Number = Math.sqrt(Math.pow((STAGE.mouseX+originX - startPoint.x), 2) + Math.pow((STAGE.mouseY - startPoint.y), 2));
				trace(len);
				if (len < GenConstants.maxRodLength) {
					helper.graphics.clear();
					helper.graphics.lineStyle(1, 0xFFFFFF, 1);
					helper.graphics.moveTo(startPoint.x-originX, startPoint.y);
					var endX:Number = gridSpacing * Math.round(STAGE.mouseX / gridSpacing); 
					var endY:Number = gridSpacing * Math.round(STAGE.mouseY / gridSpacing);
					//trace(endX, endY);
					helper.graphics.lineTo(endX, endY);
					
					endPoint = new Point(endX + originX, endY);
					//trace(endPoint.x, endPoint.y);
					shouldDraw = true;
				}
				else {
					shouldDraw = false;
				}
			}
			//helper.graphics.clear();
		}
		
		private function stopPiece(e:MouseEvent):void 
		{
			helper.graphics.clear();
			if (!isRunning) {
				trace(money+"rupees", hasMoney(500));
				trace("Ends at: ", STAGE.mouseX, STAGE.mouseY);
				
				STAGE.addEventListener(MouseEvent.MOUSE_DOWN, startNewPiece);
				STAGE.removeEventListener(MouseEvent.MOUSE_UP, stopPiece);
				STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, keepDrawing);
				
				if (shouldDraw) {
					trace("should draw");
					var s:String = e.target.name;
					endPiv = null;
					trace(s, startPoint.x, startPoint.y);
					if (s!=null) {
						if (s.substr(0, 3) == "Piv") {
							trace("String:", s, s.substr(3, s.length - 3));
							var ind:int = parseInt(s.substr(3, s.length-3));
							endPiv = allPivots[ind];
							endPoint = new Point(endPiv.getPivotBody().GetPosition().x * GenConstants.RATIO, endPiv.getPivotBody().GetPosition().y * GenConstants.RATIO);	
							
						}
						/*else {
							endPoint = new Point(STAGE.mouseX, STAGE.mouseY);	
						}*/
					}
					/*else {
						endPoint = new Point(STAGE.mouseX, STAGE.mouseY);	
					}*/
					trace(endPoint.x, endPoint.y);
					trace("Pillarmode is", rodMode == GenConstants.CATEGORY_PILLAR); 
					if (startPiv != endPiv) {
						if (endPiv != null && (endPiv.getJointCount() < GenConstants.maxJoints)) {
							var newRod:Rod = new Rod(this, startPoint, endPoint, startPiv, getNextRodId(), rodMode, endPiv);
							allRods.push(newRod);
						}
						else if (endPiv == null) {
							var newRod:Rod = new Rod(this, startPoint, endPoint, startPiv, getNextRodId(), rodMode, null);
							allRods.push(newRod);
						}
					}else {
						trace("can't build rod");
					}
					}
				}
			
		}
		
		public static function addPivot(pv:Pivot):void {
			allPivots.push(pv);
			//trace("pivot added @ pos: ", allPivots.length);
		}
		
		public function delPivot():void {
			
		}
		
		public function debugDraw():void {
			trace("dbg");
			var debug_draw:b2DebugDraw = new b2DebugDraw();
			debug_sprite = new Sprite();
			this.addChild(debug_sprite);
			
			debug_draw.SetSprite(debug_sprite);
			debug_draw.SetDrawScale(30);
			debug_draw.SetFlags(b2DebugDraw.e_shapeBit);
			debug_draw.SetLineThickness(1);
			debug_draw.SetAlpha(0.8);
			debug_draw.SetFillAlpha(0.3);
			GenConstants.fatWorld.SetDebugDraw(debug_draw);
		}
		
		private function keepFocus(e:Event) {
			fatBirds.STAGE.focus = fatBirds.STAGE;
		}
		
		private function redraw(ev:Event) {
			
			if (!endFlag) {
			//GenConstants.fatWorld.DrawDebugData();
			GenConstants.fatWorld.Step(1 / GenConstants.RATIO, 10, 10);
			
			for each(var pv:Pivot in allPivots) {
				pv.updateNow();
				try {
					if (pv.getSkin() != null) {
						this.setChildIndex(pv.getSkin(), this.numChildren - 1);
					}
				}
				catch (e:Error) {
					
				}
			}
			
			for each(var rd in allRods) {
				rd.updateNow();
			}
			
			for each(var br in allBirds) {
				br.updateNow();
			}
			}
			else {
				if (successFlag) {
					showSuccess();
				}
				else {
					showFailure();
				}
			}
			
		}
		
		private function showSuccess():void {
			clearedLite.visible = true;
			failLite.visible = false;
			clearedLite.scoreTF.text = String(generateScore());
			clearedLite.goButton.addEventListener(MouseEvent.CLICK, endGameCaller);
		}
		
		private function endGameCaller(e:MouseEvent):void 
		{
			clearedLite.goButton.removeEventListener(MouseEvent.CLICK, endGameCaller);
			endGame();
		}
		
		private function showFailure():void {
			clearedLite.visible = false;
			failLite.visible = true;
			failLite.goButton.addEventListener(MouseEvent.CLICK, endGameCaller);
		}
		
		private function endGame():void 
		{
			var sc:int = 0;
			
			if (successFlag) {
				trace("you won!");
				sc = generateScore();
				
				var loader:URLLoader = new URLLoader;
				var urlreq:URLRequest = new URLRequest("http://bits-apogee.org/archetype_cliffhanger/levelComp.php");
				var urlvars:URLVariables = new URLVariables;
				loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				urlreq.method = URLRequestMethod.POST;
				//urlvars.uname = uid;
				urlvars.score = sc;
				//urlvars.chances = chances;
				urlreq.data = urlvars;
				//loader.addEventListener(Event.COMPLETE, completed);
				loader.load(urlreq);
				//loader.addEventListener(Event.COMPLETE, phpLoaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR, eee);
				TweenLite.delayedCall(1, phpLoaded);
				// I DONT KNOW WHAT TO DO WITH THIS
				/*urlvars.apellido = aptxt.text;
				urlvars.email = emtxt.text;
				urlvars.cedula = cctxt.text;*/
				/*var urlReq:URLRequest = new URLRequest("http://bits-apogee.org/archetype_cliffhanger/page2.html");		
				navigateToURL(urlReq, '_self');*/
			}
			else {
				chances++;
				sc = -1;
				trace("you lost");
				var urlReq:URLRequest = new URLRequest("http://bits-apogee.org/archetype_cliffhanger/page2.html");		
				navigateToURL(urlReq, '_self');
			}
			
			// Note: I am sending score -1 if user lost
			// Note: I am incrementing the chances if user lost and sending u
			// Note: If the score is not -1, you need to send me the new level and set the chances in backend to 0
			
				
		}
		
		private function eee(e:IOErrorEvent):void 
		{
			trace(e.target.data);
		}
		
		private function phpLoaded():void 
		{
			var urlReq:URLRequest = new URLRequest("http://bits-apogee.org/archetype_cliffhanger/page2.html");		
			navigateToURL(urlReq, '_self');
		}
		private function generateScore():int {
			var temp = (100 + money / 10) - chances;
			
			if (minute > range1 && minute < range2) { //0 to 5
				temp = temp - (0.10 * temp);
			}
			else if (minute > range2 && minute < range3) {
				temp = temp - (0.2 * temp);
			}
			else if (minute > range3) {
				temp = temp - (0.3 * temp);
			}
			return int(temp);
		}
		
		public static function getNextPivotId():int {
			return allPivots.length;
		}
		
		public static function getNextRodId():int {
			return allRods.length;
		}
		
		public static function isGravityOn():Boolean {
			return gravMode;
		}
		
		public static function destroyPivot(pv:b2Body):void {
			for each(var rd:Rod in allRods) {
				if (rd.getBasePivot() == pv) {
					rd.setBasePivot(null);
				}
				else if (rd.getEndPivot() == pv) {
					rd.setEndPivot(null);
				}
			}
		}
		
		static public function removePivot(pivot:Pivot):void 
		{
			var ind:int = allPivots.indexOf(pivot);
			allPivots.splice(ind, 1);
			for (var i:int = 0; i < allPivots.length;i++) {
				Pivot(allPivots[i]).getSkin().name = "Piv" + i;
			}
		}
		
		/*static public function updateMoney():void 
		{
			mn.text = String(money);
		}*/
		
	}

}