package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author
	 */
	public class Pivot extends Builder
	{
		private var joints:int;
		private var max_force:Number = 10;
		private var joints_arr:Vector.<b2RevoluteJoint>;
		private var pos:Point;
		private var id:int
		protected var par:Sprite;
		
		public function Pivot(par:Sprite, maxF:Number, pos:Point, id:int)
		{
			
			this.par = par;	
			joints = 0;
			max_force = maxF;
			//trace(pos.x);
			joints_arr = new Vector.<b2RevoluteJoint>();
			this.pos = pos;
			this.id = id;
			//trace(id);
			//_skin.name = "Piv" + id;
			super(pos, par);
		}
		
		override protected function makeBody(pos:Point):void
		{
			var body2Def:b2BodyDef = new b2BodyDef();
			var body2Shape:b2CircleShape = new b2CircleShape(GenConstants.pivotRad);
			var body2FixDef:b2FixtureDef = new b2FixtureDef();
			
			body2Def.position.Set(pos.x / GenConstants.RATIO, pos.y / GenConstants.RATIO);
			body2Def.type = b2Body.b2_staticBody;
			
			var mat:b2Mat22 = new b2Mat22();
			//var ang:Number = Math.atan((startPoint.y - endPoint.y) / (endPoint.x - startPoint.x));
			mat.Set(Math.PI / 4);
			
			body2FixDef.shape = body2Shape;
			body2FixDef.friction = 0.9;
			body2FixDef.restitution = 0;
			body2FixDef.density = 2;
			
			body2FixDef.filter.categoryBits = GenConstants.CATEGORY_BASE;
			body2FixDef.filter.maskBits = GenConstants.MASK_ROD;
			
			_body = GenConstants.fatWorld.CreateBody(body2Def);
			_body.CreateFixture(body2FixDef);
			//_body.SetTransform(new b2Transform(new b2Vec2(0,4), mat));
			
			super.makeBody(pos);
		}
		
		override protected function makeSkin(par:Sprite):void
		{
			_skin = new pivot_mc();
			par.addChild(_skin);
			_skin.name = "Piv" + id;
			trace(_skin.name);
			//_skin.alpha = 0; 
			super.makeSkin(par);
		}
		
		override protected function childSpecificUpdating():void
		{
			//trace(_skin.name, ":", getJointCount());
			try
			{
				for each (var jt:b2RevoluteJoint in joints_arr)
				{
					var f:b2Vec2 = jt.GetReactionForce(1 / GenConstants.RATIO);
					//trace(Math.sqrt(Math.pow(f.x, 2) + Math.pow(f.y, 2)));
					//trace("t:", jt.GetReactionTorque(1/GenConstants.RATIO), jt.GetReactionForce(1/GenConstants.RATIO).y, jt.GetMotorSpeed(), jt.GetMotorTorque());
					if (Math.sqrt(Math.pow(f.x, 2) + Math.pow(f.y, 2)) > max_force)
					{
						trace("yes");
						destruct(par);
						joints_arr = null;
							//deleteJoint(jt);
					}
				}
				super.childSpecificUpdating();
			}
			catch (e:Error)
			{
				trace("Null");
			}
		}
		
		public function getPivotBody():b2Body
		{
			return _body;
		}
		
		public function getJointCount():int
		{
			return joints_arr.length;
		}
		
		public function getAllJoints():Vector.<b2RevoluteJoint>
		{
			return joints_arr;
		}
		
		public function addJoint(jt:b2RevoluteJoint):void
		{
			joints_arr.push(jt);
			joints++;
		}
		
		public function deleteJoint(joint:b2RevoluteJoint):void
		{
			var ind:int = joints_arr.indexOf(joint);
			trace("joint at index", ind, "deleted of", _skin.name);
			joints_arr.splice(ind, 1);
			
			trace(joints_arr.length);
			if ((joints_arr.length == 0) && (this is Pivot2))
				destruct(par);
		}
		
		override public function destruct(par:Sprite):void
		{
			if (this is Pivot2) {
				for each (var jt:b2RevoluteJoint in joints_arr)
				{
					trace("joint deleted");
					GenConstants.fatWorld.DestroyJoint(jt);
				}
				fatBirds.destroyPivot(_body);
				fatBirds.removePivot(this);
				super.destruct(par);
			}
		}
		
		public function allowRotation():void
		{
			for each (var jt:b2RevoluteJoint in joints_arr)
			{
				jt.EnableLimit(false);
			}
		}
		public function getSkin():Sprite {
			return _skin;
		}
	}

}