package  
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class Bird extends Builder
	{
		private var _wid:Number;
		private var _hei:Number;
		private var density:Number;
		private var par:Sprite;
		private var birdsSuccess:int;
		private static var birdC:int = 0;
		private static var birdsFin:int = 0;
		
		public function Bird(par:Sprite, _wid:Number, _hei:Number, density:Number, startPos:Point) 
		{
			birdC++;
			this.par = par;
			this._wid = _wid;
			this._hei = _hei;
			this.density = density;
			birdsSuccess = 0;
			super(startPos, par);
		}
		
		override protected function makeBody(pos:Point):void 
		{
			var body1Def:b2BodyDef = new b2BodyDef();
			var body1Shape:b2PolygonShape = new b2PolygonShape();
			var body1FixDef:b2FixtureDef = new b2FixtureDef();
			
			body1Shape.SetAsBox(_wid/GenConstants.RATIO, _hei/GenConstants.RATIO);
			
			body1Def.position.Set(pos.x/GenConstants.RATIO, pos.y/GenConstants.RATIO);
			body1Def.type = b2Body.b2_dynamicBody;
			
			body1FixDef.shape = body1Shape;
			body1FixDef.friction = 0.8;
			body1FixDef.restitution = 0;
			body1FixDef.density = density;
			
			body1FixDef.filter.categoryBits = GenConstants.CATEGORY_BASE;
			body1FixDef.filter.maskBits = GenConstants.MASK_BIRD;
			
			_body = GenConstants.fatWorld.CreateBody(body1Def);
			_body.CreateFixture(body1FixDef);
			
			var t1:Timer = new Timer(2000);
			t1.addEventListener(TimerEvent.TIMER, hop);
			t1.start();
			
			super.makeBody(pos);
		}
		
		override protected function makeSkin(par:Sprite):void 
		{
			var sp:Sprite = new minion();
			sp.scaleX = (_wid * 2) / sp.width;
			sp.scaleY = sp.scaleX;
			
			_skin = sp;
			par.addChild(_skin);
			
			super.makeSkin(par);
		}
		
		override protected function childSpecificUpdating():void 
		{
			if (_body.GetWorldCenter().y > (fatBirds.worldHeight) / GenConstants.RATIO) {
				if (_body.GetWorldCenter().x < fatBirds.winLimit/GenConstants.RATIO) {
					fatBirds.endFlag = true;
					
					_skin.rotation = 0;
				}
			}
			if (_body.GetWorldCenter().x > fatBirds.winLimit / GenConstants.RATIO) {
				if (birdsSuccess == 0) { 
					birdsSuccess = 1;
					birdsFin++;
				}
				if (birdsFin == birdC) {
					fatBirds.endFlag = true;
					fatBirds.successFlag = true;
				}
			}
			super.childSpecificUpdating();
		}
		
		private function hop(ev:TimerEvent):void {
			//trace("hopping");
			if (fatBirds.isGravityOn()) {
				_body.ApplyImpulse(new b2Vec2(_body.GetMass()*2, -_body.GetMass()*GenConstants.fatWorld.GetGravity().y/2), _body.GetWorldCenter());
			}
		}	
	}
}