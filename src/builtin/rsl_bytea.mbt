///|
type Bytea

///|
extern "wasm" fn bytea_out(bytea : Bytea) -> String =
  #| (func (import "env" "bytea_out")
  #|  (param (ref extern)) (result (ref extern)))

///|
pub fn Bytea::to_string(self : Bytea) -> String {
  bytea_out(self)
}

///|
impl Obj for Bytea with typname() { "bytea" }

///|
pub impl Show for Bytea with output(self, logger) {
  output_with_typname(self, logger)
}

///|
impl FromJson for Bytea with from_json(json, path) {
  String::from_json!(json, path).encode()
}

///|
impl ToJson for Bytea with to_json(self) { String(self.to_string()) }
