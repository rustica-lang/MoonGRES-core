///|
type UUID

///|
extern "wasm" fn uuid(str : String) -> UUID =
  #| (func (import "env" "uuid_in")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn uuid_out(uuid : UUID) -> String =
  #| (func (import "env" "uuid_out")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn uuid_cmp(left : UUID, right : UUID) -> Int =
  #| (func (import "env" "uuid_cmp")
  #|  (param (ref extern)) (param (ref extern)) (result i32))

///|
pub impl FromStr for UUID with from_string(str) { uuid(str) }

///|
pub fn UUID::to_string(self : UUID) -> String {
  uuid_out(self)
}

///|
impl Obj for UUID with typname() { "uuid" }

///|
pub impl Show for UUID with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Compare for UUID with compare(self, other) { uuid_cmp(self, other) }

///|
pub impl FromJson for UUID with from_json(json, path) {
  uuid(String::from_json!(json, path))
}

///|
pub impl ToJson for UUID with to_json(self) { String(self.to_string()) }
