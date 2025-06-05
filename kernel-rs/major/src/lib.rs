/**
 * @Author : laiyefei
 * @Create : 2025-06-05
 * @Desc : 业务逻辑：主场景 Major
 * @Version : v1.0.0
 * @Blog : http://laiyefei.com
 * @Github : http://github.com/laiyefei
 */
use bevy_ecs::prelude::*;
use wasm_bindgen::prelude::*;


#[derive(Component, Debug)]
struct Status(String);

#[derive(Resource, Default)]
struct NotificationQueue(Vec<String>);

fn update_status(mut query: Query<(&Status, Entity), Changed<Status>>, mut queue: ResMut<NotificationQueue>) {
    for (status, entity) in &mut query {
        queue.0.push(format!("Entity {:?} changed status to {}", entity, status.0));
    }
}

fn dispatch_notifications(mut queue: ResMut<NotificationQueue>) {
    for msg in queue.0.drain(..) {
        println!("🔔 {}", msg);
    }
}

#[wasm_bindgen]
pub struct Person {
    name: String,
    age: u32,
}

#[wasm_bindgen]
impl Person {
    #[wasm_bindgen(constructor)]
    pub fn new(name: String, age: u32) -> Person {
        Person { name, age }
    }

    pub fn greet(&self) -> String {
        format!("Hi, I'm {} and {} years old", self.name, self.age)
    }

    pub fn test(){
        let mut world = World::new();
        world.insert_resource(NotificationQueue::default());
    
        let mut schedule = Schedule::default();
        schedule.add_systems((update_status, dispatch_notifications));
    
        let id = world.spawn(Status("Idle".into())).id();
        schedule.run(&mut world); // 没有变化，不触发
    
        world.entity_mut(id).insert(Status("Working".into()));
        schedule.run(&mut world); // 触发通知
    
        world.entity_mut(id).insert(Status("Done".into()));
        schedule.run(&mut world); // 再次触发通知
    }
}