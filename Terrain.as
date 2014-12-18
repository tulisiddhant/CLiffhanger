package  
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Mat22;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Terrain extends Builder
	{
		private var _wid:Number;
		private var _hei:Number;
		private var rightF:Number;
		private var leftF:Number;
		private var par:Sprite;
		
		public function Terrain(par:Sprite, pos:Point, _wid:Number, _hei:Number, leftF:Number, rightF:Number) 
		{
			this.par = par;
			this.rightF = rightF;
			this.leftF = leftF;
			this._wid = _wid;
			this._hei = _hei;
			super(pos, par);
		}
		
		override protected function makeBody(pos:Point):void 
		{
			var body1Def:b2BodyDef = new b2BodyDef();
			var body1Shape:b2PolygonShape = new b2PolygonShape();
			var body1FixDef:b2FixtureDef = new b2FixtureDef();
			
			body1Shape.SetAsBox(_wid/GenConstants.RATIO, _hei/GenConstants.RATIO);
			
			body1Def.position.Set(pos.x/GenConstants.RATIO, pos.y/GenConstants.RATIO);
			body1Def.type = b2Body.b2_staticBody;
			
			body1FixDef.shape = body1Shape;
			body1FixDef.friction = 2;
			body1FixDef.density = 0.5;
			body1FixDef.restitution = 0;
			
			body1FixDef.filter.categoryBits = GenConstants.CATEGORY_BASE;
			body1FixDef.filter.maskBits = GenConstants.MASK_ROD;
			
			_body = GenConstants.fatWorld.CreateBody(body1Def);
			_body.CreateFixture(body1FixDef);
			
			if (rightF != 0) {
				var pv:Pivot = new Pivot(par, rightF, new Point(pos.x + _wid, pos.y - _hei+20), fatBirds.getNextPivotId());
				fatBirds.addPivot(pv);
			}
			
			if (leftF != 0) {
				pv = new Pivot(par, leftF, new Point(pos.x - _wid, pos.y - _hei+20), fatBirds.getNextPivotId());
				fatBirds.addPivot(pv);
			}
			
			super.makeBody(pos);
		}
		
		override protected function makeSkin(par:Sprite):void 
		{
			
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x36371c, 1);
			sp.graphics.drawRect(-_wid, -_hei, _wid*2, _hei*2);
			sp.graphics.endFill();
			
			var gr:grassMc = new grassMc();
			
			/*var maskRect:Sprite = new Sprite();
			maskRect.graphics.beginFill(0x36371c, 0);
			maskRect.graphics.drawRect(0, 0, _wid*2, 45);
			maskRect.graphics.endFill();*/
			
			sp.addChild(gr);
			//sp.addChild(maskRect);
			
			gr.x = -_wid-4;
			gr.y = -_hei-3;
			//maskRect.x = gr.x;
			//maskRect.y = gr.y;
			
			gr.scaleX = ((_wid * 2) / (gr.width-16));
			gr.scaleY = gr.scaleX;
			//gr.mask = maskRect;
			
			_skin = sp;
			par.addChild(_skin);
			super.makeSkin(par);
		}
		
		override protected function childSpecificUpdating():void 
		{
			super.childSpecificUpdating();
		}
	}

}