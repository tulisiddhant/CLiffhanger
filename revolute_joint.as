package {
    import flash.display.Sprite;
    import flash.events.Event;
    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.Joints.*;
    import flash.events.MouseEvent;
	
    public class revolute_joint extends Sprite {
        var mouseJoint:b2MouseJoint;
        var mousePVec:b2Vec2 = new b2Vec2();
        var bd:b2BodyDef;
        var the_box:b2PolygonDef = new b2PolygonDef();
        var the_pivot:b2CircleDef = new b2CircleDef();
        var the_rev_joint:b2RevoluteJointDef = new b2RevoluteJointDef();
		
        public function revolute_joint() {
            // world setup
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-100.0, -100.0);
            worldAABB.upperBound.Set(100.0, 100.0);
            var gravity:b2Vec2=new b2Vec2(0.0,10.0);
            var doSleep:Boolean=true;
            m_world=new b2World(worldAABB,gravity,doSleep);
            // debug draw
            var m_sprite:Sprite;
            m_sprite = new Sprite();
            addChild(m_sprite);
            var dbgDraw:b2DebugDraw = new b2DebugDraw();
            var dbgSprite:Sprite = new Sprite();
            m_sprite.addChild(dbgSprite);
            dbgDraw.m_sprite=m_sprite;
            dbgDraw.m_drawScale=30;
            dbgDraw.m_alpha = 1;
            dbgDraw.m_fillAlpha=0.5;
            dbgDraw.m_lineThickness=1;
            dbgDraw.m_drawFlags=b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit;
            m_world.SetDebugDraw(dbgDraw);
            // pivot for revolute joint
            the_pivot.radius = 0.5;
            the_pivot.density = 0;
            bd = new b2BodyDef();
            bd.position.Set(8.5,6.5);
            var rev_joint:b2Body = m_world.CreateBody(bd);
            rev_joint.CreateShape(the_pivot)
            rev_joint.SetMassFromShapes();
            // box for the revolute joint
            the_box.SetAsBox(4,0.5);
            the_box.density = 0.01;
            the_box.friction = 1;
            the_box.restitution = 0.1;
            bd = new b2BodyDef();
            bd.position.Set(6.5,6.5);
            var rev_box:b2Body = m_world.CreateBody(bd);
            rev_box.CreateShape(the_box)
            rev_box.SetMassFromShapes();
            the_rev_joint.Initialize(rev_joint, rev_box, new b2Vec2(8.5,6.5));
            var joint_added:b2RevoluteJoint = m_world.CreateJoint(the_rev_joint) as b2RevoluteJoint;
            // listeners
            stage.addEventListener(MouseEvent.MOUSE_DOWN, createMouse);
            stage.addEventListener(MouseEvent.MOUSE_UP, destroyMouse);
            addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
        }
        
		public function createMouse(evt:MouseEvent):void {
            var body:b2Body=GetBodyAtMouse();
            if (body) {
                var mouseJointDef:b2MouseJointDef=new b2MouseJointDef;
                mouseJointDef.body1=m_world.GetGroundBody();
                mouseJointDef.body2=body;
                mouseJointDef.target.Set(mouseX/30, mouseY/30);
                mouseJointDef.maxForce=30000;
                mouseJointDef.timeStep=m_timeStep;
                mouseJoint=m_world.CreateJoint(mouseJointDef) as b2MouseJoint;
            }
        }
        
		public function destroyMouse(evt:MouseEvent):void {
            if (mouseJoint) {
                m_world.DestroyJoint(mouseJoint);
                mouseJoint=null;
            }
        }
        
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body {
            var mouseXWorldPhys = (mouseX)/30;
            var mouseYWorldPhys = (mouseY)/30;
            mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
            var aabb:b2AABB = new b2AABB();
            aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
            aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
            var k_maxCount:int=10;
            var shapes:Array = new Array();
            var count:int=m_world.Query(aabb,shapes,k_maxCount);
            var body:b2Body=null;
            for (var i:int = 0; i < count; ++i) {
                if (shapes[i].GetBody().IsStatic()==false||includeStatic) {
                    var tShape:b2Shape=shapes[i] as b2Shape;
                    var inside:Boolean=tShape.TestPoint(tShape.GetBody().GetXForm(),mousePVec);
                    if (inside) {
                        body=tShape.GetBody();
                        break;
                    }
                }
            }
            return body;
        }
        
		public function Update(e:Event):void {
            m_world.Step(m_timeStep, m_iterations);
            if (mouseJoint) {
                var mouseXWorldPhys=mouseX/30;
                var mouseYWorldPhys=mouseY/30;
                var p2:b2Vec2=new b2Vec2(mouseXWorldPhys,mouseYWorldPhys);
                mouseJoint.SetTarget(p2);
            }
        }
        
		public var m_world:b2World;
        public var m_iterations:int=10;
        public var m_timeStep:Number=1.0/30.0;
    }
}