package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class GenConstants 
	{
		public static const RATIO = 30;
		public static var grav:b2Vec2 = new b2Vec2(0, 5);
		public static var fatWorld:b2World;
		public static const pivotRad:Number = 0.2;
		public static var maxRodLength:Number = 250;
		public static const maxJoints:Number = 8;
		public static var maxForce:Number = 0.6;
		public static const CATEGORY_BASE:uint = 0x0001;
		public static const CATEGORY_PILLAR:uint = 0x0002;
		public static const tempPivotMaxForce:Number = 0.8;
		
		public static const MASK_BIRD:uint = CATEGORY_BASE;
		public static const MASK_ROD:uint = CATEGORY_BASE | CATEGORY_PILLAR;
		public static const MASK_PILLAR:uint = CATEGORY_PILLAR;
		
		public function GenConstants() 
		{
			
			
		}
		
		
	}

}