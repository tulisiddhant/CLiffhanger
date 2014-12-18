package  
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class Pivot2 extends Pivot
	{
		
		public function Pivot2(x:Number, y:Number) 
		{
			super(x, y);
			
		}
		override protected function createBody():void {
			body2Def.type = b2Body.b2_dynamicBody;
			pivot = test3.b2w.CreateBody(body2Def);
			pivot.CreateFixture(body2FixDef);
		}
	}

}