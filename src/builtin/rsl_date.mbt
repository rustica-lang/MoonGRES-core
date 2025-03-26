///|
type Date Int

///|
type Time Int64

///|
fn date_in(str : String) -> Int = "env" "date_in"

///|
fn date_out(date : Int) -> String = "env" "date_out"

///|
fn time_in(str : String) -> Int64 = "env" "time_in"

///|
fn time_out(time : Int64) -> String = "env" "time_out"

///|
pub impl FromStr for Date with from_string(str) {
  date_in(str)
}

///|
pub impl FromStr for Time with from_string(str) {
  time_in(str)
}

///|
impl Obj for Date with typname() {
  "date"
}

///|
impl Obj for Time with typname() {
  "time"
}

///|
pub impl Show for Date with to_string(self) {
  date_out(self._)
}

///|
pub impl Show for Date with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Time with to_string(self) {
  time_out(self._)
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
pub impl ToJson for Date with to_json(self) {
  String(self.to_string())
}

///|
pub impl ToJson for Time with to_json(self) {
  String(self.to_string())
}
