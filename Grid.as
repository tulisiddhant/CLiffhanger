package  {
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	public class Grid extends Sprite{
		var i:int = 0;
		//var sh1:DropShadowFilter = new DropShadowFilter(1, 45, 0x000000, 1, 2, 2);
		
		public function Grid(size:int, width:Number, height:Number) {
			// constructor code
			this.graphics.beginFill(0x4D34DA);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
			
			for(i=0; i<=width/size; ++i) {
				this.graphics.lineStyle (0.01,0xCCCCCC,0.3);
				this.graphics.moveTo(size*i, 0);
				this.graphics.lineTo(size*i, height);
				//trace(i);
			}
			for(i=0; i<=height/size; ++i) {
				this.graphics.lineStyle (0.01,0xCCCCCC,0.3);
				this.graphics.moveTo(0, size*i);
				this.graphics.lineTo(width, size*i);
				//trace(i);
			}
			//this.filters = [sh1];
		}

	}
	
}