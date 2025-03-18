///|
type Date Int

///|
type Time Int64

///|
extern "wasm" fn date_in(str : String) -> Int =
  #| (func (import "env" "date_in")
  #|  (param (ref extern)) (result i32))

///|
extern "wasm" fn date_out(date : Int) -> String =
  #| (func (import "env" "date_out")
  #|  (param i32) (result (ref extern)))

///|
extern "wasm" fn time_in(str : String) -> Int64 =
  #| (func (import "env" "time_in")
  #|  (param (ref extern)) (result i64))

///|
extern "wasm" fn time_out(time : Int64) -> String =
  #| (func (import "env" "time_out")
  #|  (param i64) (result (ref extern)))

///|
pub impl FromStr for Date with from_string(str) { date_in(str) }

///|
pub impl FromStr for Time with from_string(str) { time_in(str) }

///|
pub fn Date::to_string(self : Date) -> String {
  date_out(self._)
}

///|
pub fn Time::to_string(self : Time) -> String {
  time_out(self._)
}

///|
impl Obj for Date with typname() { "date" }

///|
impl Obj for Time with typname() { "time" }

///|
pub impl Show for Date with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Time with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl FromJson for Date with from_json(json, path) {
  date_in(String::from_json!(json, path))
}

///|
pub impl FromJson for Time with from_json(json, path) {
  time_in(String::from_json!(json, path))
}

///|
pub impl ToJson for Date with to_json(self) { String(self.to_string()) }

///|
pub impl ToJson for Time with to_json(self) { String(self.to_string()) }
