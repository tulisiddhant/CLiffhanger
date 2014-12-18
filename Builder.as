package  
{
	import Box2D.Dynamics.b2Body;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class Builder extends EventDispatcher
	{
		protected var _body:b2Body;
		protected var _skin:Sprite;
		
		public function Builder(pos:Point, par:Sprite) 
		{
			makeBody(pos);
			makeSkin(par);
			_body.SetUserData(this);
			
			updateAttribs();
		}
		
		protected function makeSkin(par:Sprite):void 
		{
			//_skin.alpha = 0;
			// overridden in child
		}
		
		protected function makeBody(pos:Point):void 
		{
			// overridden in child
		}
		
		public function updateNow():void {
			
			updateAttribs();
			childSpecificUpdating();
			
		}
		
		public function updateAttribs():void {
			_skin.x = _body.GetPosition().x * GenConstants.RATIO;
			//trace(_body.GetPosition().x, _body.GetPosition().y);
			_skin.y = _body.GetPosition().y * GenConstants.RATIO;
			if (!(this is Bird))
				_skin.rotation = _body.GetAngle() * 180 / Math.PI;
			else 
				_skin.rotation = 0;
			
		}
		
		protected function childSpecificUpdating():void {
			// overridden in child
		}
		
		public function destruct(par:Sprite):void {
			if (_body != null) {
				GenConstants.fatWorld.DestroyBody(_body);
			}
			if (_skin != null) {
				par.removeChild(_skin);
			}
		}
		
	}

}