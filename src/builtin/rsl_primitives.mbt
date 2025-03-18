///|
pub extern "wasm" fn parse_bool(str : String) -> Bool =
  #| (func (import "env" "parse_bool")
  #|  (param (ref extern)) (result i32))

///|
pub impl FromStr for Bool with from_string(str) { parse_bool(str) }

///|
pub fn Bool::to_string(self : Bool) -> String {
  if self {
    "true"
  } else {
    "false"
  }
}

///|
pub extern "wasm" fn int4in(str : String) -> Int =
  #| (func (import "env" "int4in")
  #|  (param (ref extern)) (result i32))

///|
pub impl FromStr for Int with from_string(str) { int4in(str) }

///|
pub extern "wasm" fn int4out(val : Int) -> String =
  #| (func (import "env" "int4out")
  #|  (param i32) (result (ref extern)))

///|
pub fn Int::to_string(self : Int) -> String {
  int4out(self)
}

///|
pub extern "wasm" fn int8in(str : String) -> Int64 =
  #| (func (import "env" "int8in")
  #|  (param (ref extern)) (result i64))

///|
pub impl FromStr for Int64 with from_string(str) { int8in(str) }

///|
pub extern "wasm" fn int8out(val : Int64) -> String =
  #| (func (import "env" "int8out")
  #|  (param i64) (result (ref extern)))

///|
pub fn Int64::to_string(self : Int64) -> String {
  int8out(self)
}

///|
pub extern "wasm" fn float4in(str : String) -> Float =
  #| (func (import "env" "float4in")
  #|  (param (ref extern)) (result f32))

///|
pub impl FromStr for Float with from_string(str) { float4in(str) }

///|
pub extern "wasm" fn float4out(val : Float) -> String =
  #| (func (import "env" "float4out")
  #|  (param f32) (result (ref extern)))

///|
pub fn Float::to_string(self : Float) -> String {
  float4out(self)
}

///|
pub impl Show for Float with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl FromJson for Float with from_json(json, path) {
  match json {
    Number(n) => n.to_float()
    _ => decode_error!(path, "Float::from_json: expected number")
  }
}

///|
pub extern "wasm" fn float8in(str : String) -> Double =
  #| (func (import "env" "float8in")
  #|  (param (ref extern)) (result f64))

///|
pub impl FromStr for Double with from_string(str) { float8in(str) }

///|
pub extern "wasm" fn float8out(val : Double) -> String =
  #| (func (import "env" "float8out")
  #|  (param f64) (result (ref extern)))

///|
pub fn Double::to_string(self : Double) -> String {
  float8out(self)
}

///|
pub impl Show for Double with output(self, logger) {
  logger.write_string(self.to_string())
}
