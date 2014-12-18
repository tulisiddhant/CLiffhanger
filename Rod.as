package  
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Rod extends Builder
	{
		private var startPoint:Point;
		private var endPoint:Point;
		private var basePivot:Pivot;
		private var endPivot:Pivot;
		private var ropeBody:b2Body;
		private var upperJoint:b2RevoluteJoint;
		private var bottomJoint:b2RevoluteJoint;
		private var id:int;
		private var cat:uint;
		private var par:Sprite;
		private var len:Number;
		
		public function Rod(par:Sprite, startPoint:Point, endPoint:Point, basePivot:Pivot, id:int, cat:uint, endPivot:Pivot = null) 
		{
			this.par = par;
			this.startPoint = startPoint;
			this.endPoint = endPoint;
			this.basePivot = basePivot;
			this.endPivot = endPivot;
			this.id = id;
			this.cat = cat;
			super(new Point((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y) /2),par);
			
		}
		
		override protected function makeBody(_pos:Point):void 
		{
			// MAKING THE ROPE BODY //
			
			var body1Def:b2BodyDef = new b2BodyDef();
			var body1Shape:b2PolygonShape = new b2PolygonShape();
			var body1FixDef:b2FixtureDef = new b2FixtureDef();
			
			len = Math.sqrt(Math.pow((endPoint.y - startPoint.y), 2) + Math.pow((endPoint.x - startPoint.x), 2));
			//len = len > 50 ? 50 : len;
			
			body1Shape.SetAsBox(0.3, len / (2*GenConstants.RATIO));
			
			body1Def.position.Set(startPoint.x/GenConstants.RATIO, startPoint.y/GenConstants.RATIO);
			body1Def.type = b2Body.b2_dynamicBody;
			
			body1FixDef.shape = body1Shape;
			body1FixDef.friction = 0.8;
			body1FixDef.restitution = 0.2;
			body1FixDef.density = 0.1;
			
			body1FixDef.filter.categoryBits = cat;
			body1FixDef.filter.maskBits = GenConstants.MASK_ROD;
			
			var mat:b2Mat22 = new b2Mat22();
			var ang:Number = Math.atan(Math.abs(startPoint.y - endPoint.y) / Math.abs(endPoint.x - startPoint.x));
			
			ropeBody = GenConstants.fatWorld.CreateBody(body1Def);
			ropeBody.CreateFixture(body1FixDef);
			
			_body = ropeBody;
			
			// ------------------------------------------------------------ //
			
			// MAKING THE END PIVOT //
			
			if (endPivot == null) {
				var tempPiv:Pivot2 = new Pivot2(par, GenConstants.tempPivotMaxForce, new Point(endPoint.x, endPoint.y), fatBirds.getNextPivotId());
				fatBirds.addPivot(tempPiv);
				
				endPivot = tempPiv;
			}
			
			revoJointDef = new b2RevoluteJointDef();
			revoJointDef.Initialize(ropeBody, endPivot.getPivotBody(), endPivot.getPivotBody().GetPosition());
			
			revoJointDef.localAnchorB = new b2Vec2(0, 0);
			revoJointDef.localAnchorA = new b2Vec2(0, -len / (2 * GenConstants.RATIO)); 
			
			/*revoJointDef.upperAngle = Math.PI - (getAngle(ang) - Math.PI / 2);
			revoJointDef.lowerAngle = revoJointDef.upperAngle;
			revoJointDef.enableLimit = true;*/
			
			revoJoint = GenConstants.fatWorld.CreateJoint(revoJointDef) as b2RevoluteJoint;
			
			endPivot.addJoint(revoJoint);
			bottomJoint = revoJoint;
			
			// ------------------------------------ LOWER PIVOT CREATED ----------------------------------------- //
			
			// --------------------------------- JOINING TO THE BASE PIVOT ---------------------------------------//
			
			var revoJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revoJointDef.Initialize(ropeBody, basePivot.getPivotBody(), basePivot.getPivotBody().GetPosition());
			
			revoJointDef.localAnchorB = new b2Vec2(0, 0);
			revoJointDef.localAnchorA = new b2Vec2(0, len / (2 * GenConstants.RATIO)); 
			
			revoJointDef.collideConnected = false;
			
			//revoJointDef.upperAngle = getAngle(ang) - Math.PI / 2; /*+ basePivot.getPivotBody().GetAngle()*///revoJointDef.bodyA.GetAngle() - Math.PI / 2;// revoJointDef.bodyB.GetAngle();
			//revoJointDef.lowerAngle = revoJointDef.upperAngle;// revoJointDef.upperAngle;
			//revoJointDef.enableLimit = true;
			
			var revoJoint:b2RevoluteJoint = GenConstants.fatWorld.CreateJoint(revoJointDef) as b2RevoluteJoint;
			upperJoint = revoJoint;
			basePivot.addJoint(revoJoint);
			
			if (cat == GenConstants.CATEGORY_BASE) {
				fatBirds(par).updateMoney(fatBirds.money - fatBirds.baseRodCost);
				//fatBirds.money -= fatBirds.baseRodCost;
			}
			else {
				fatBirds(par).updateMoney(fatBirds.money - fatBirds.pillarCost);
			}
			//fatBirds.updateMoney();
			trace("money left", fatBirds.money);
			super.makeBody(_pos);
		}
		
		private function getAngle(ang:Number):Number 
		{
			if (startPoint.y > endPoint.y && startPoint.x < endPoint.x) {
				return ang;
			}
			else if (startPoint.y > endPoint.y && startPoint.x > endPoint.x) {
				return Math.PI - ang;
			}
			else if (startPoint.y < endPoint.y && startPoint.x > endPoint.x) {
				return Math.PI + ang;
			}
			else if (startPoint.y < endPoint.y && startPoint.x < endPoint.x) {
				return -ang;
			}
			return 0;
		}
		
		override protected function makeSkin(par:Sprite):void 
		{
			if (cat == GenConstants.CATEGORY_BASE) {
				var sp:Sprite = new woodtexture();
				sp.height = len;
				_skin = sp;
			}
			else if (cat == GenConstants.CATEGORY_PILLAR) {
				var sp:Sprite = new pillarTexture();
				sp.height = len;
				_skin = sp;
			}
			
			_skin.name = "Rod" + id;
			par.addChild(_skin);
			super.makeSkin(par);
		}
		
		override protected function childSpecificUpdating():void 
		{
			try {
				if (basePivot != null) {
					basePivot.updateNow();
				}
				if (endPivot != null) {
					endPivot.updateNow();
				}
			}
			catch (e:Error) {
				
			}
			super.childSpecificUpdating();
		}
		
		override public function destruct(par:Sprite):void 
		{
			if(basePivot != null) {
				basePivot.deleteJoint(upperJoint);
				GenConstants.fatWorld.DestroyJoint(upperJoint);
				//if (basePivot is Pivot2)
					//basePivot.destruct(par);
			}
			if (endPivot != null) {
				endPivot.deleteJoint(bottomJoint);
				GenConstants.fatWorld.DestroyJoint(bottomJoint);
				//if (endPivot is Pivot2)
					//endPivot.destruct(par);
			}
			if (cat == GenConstants.CATEGORY_BASE) {
				(fatBirds)(par).updateMoney(fatBirds.money + fatBirds.baseRodCost);
			}
			else if (cat == GenConstants.CATEGORY_PILLAR) {
				(fatBirds)(par).updateMoney(fatBirds.money + fatBirds.pillarCost);
			}
			super.destruct(par);
		}
		
		public function getBasePivot():b2Body {
			if (basePivot != null) {
				return basePivot.getPivotBody();
			}
			else {
				return null;
			}
		}
		
		public function getEndPivot():b2Body {
			if (endPivot != null) {
				return endPivot.getPivotBody();
			}
			else {
				return null;
			}
		}
		
		public function setBasePivot(basePv:Pivot):void {
			basePivot = basePv;
		}
		
		public function setEndPivot(endPv:Pivot):void {
			endPivot = endPv;
		}
		
	}
}