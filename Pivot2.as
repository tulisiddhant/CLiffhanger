package  
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Pivot2 extends Pivot
	{
		
		public function Pivot2(par:Sprite, maxF:Number, pos:Point, id:int) 
		{
			this.par = par;
			super(par, maxF, pos, id);
		}
		
		override protected function makeBody(pos:Point):void {
			var body2Def:b2BodyDef = new b2BodyDef();
			var body2Shape:b2CircleShape = new b2CircleShape(GenConstants.pivotRad);
			var body2FixDef:b2FixtureDef = new b2FixtureDef();
			
			body2Def.position.Set(pos.x/GenConstants.RATIO, pos.y/GenConstants.RATIO);
			body2Def.type = b2Body.b2_staticBody;
			
			body2FixDef.shape = body2Shape;
			body2FixDef.friction = 0.5;
			body2FixDef.restitution = 0;
			body2FixDef.density = 2;
			
			body2FixDef.filter.categoryBits = GenConstants.CATEGORY_PILLAR;
			body2FixDef.filter.maskBits = GenConstants.MASK_ROD;
			
			_body = GenConstants.fatWorld.CreateBody(body2Def);
			_body.CreateFixture(body2FixDef);
			//super.makeBody(pos);
		}
		public function makeDynamic():void {
			_body.SetType(b2Body.b2_dynamicBody);
		}
	}

}