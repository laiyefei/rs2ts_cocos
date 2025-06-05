use wasm_bindgen::prelude::*;

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
}