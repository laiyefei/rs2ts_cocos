/**
 * @Author : laiyefei
 * @Create : 2025-06-05
 * @Desc : bevy框架的使用
 * @Version : v1.0.0
 * @Blog : http://laiyefei.com
 * @Github : http://github.com/laiyefei
 */
use bevy_ecs::world::World;
use once_cell::sync::Lazy;
use std::sync::Mutex;


// 全局 World 单例
static GLOBAL_WORLD: Lazy<Mutex<World>> = Lazy::new(|| {
    let mut world = World::new();
    Mutex::new(world)
});

// 注册资源
pub fn register_resource<T: Resource + Send + Sync + 'static>(resource: T) {
    let mut world = GLOBAL_WORLD.lock().unwrap();
    world.insert_resource(resource);
}

// 获取资源的不可变引用
pub fn get_resource<T: Resource + Send + Sync + 'static>() -> Option<T> 
where
    T: Clone,
{
    let world = GLOBAL_WORLD.lock().unwrap();
    world.get_resource::<T>().cloned()
}

// 取消注册资源
pub fn remove_resource<T: Resource + Send + Sync + 'static>() -> Option<T> {
    let mut world = GLOBAL_WORLD.lock().unwrap();
    world.remove_resource::<T>()
}