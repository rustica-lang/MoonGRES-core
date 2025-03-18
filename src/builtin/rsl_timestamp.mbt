///|
type Timestamp Int64 derive(Eq, Compare)

///|
type Timestamptz Int64 derive(Eq, Compare)

///|
type Interval

///|
extern "wasm" fn timestamp_in(str : String, tz : Bool) -> Int64 =
  #| (func (import "env" "timestamp_in")
  #|  (param (ref extern)) (param i32) (result i64))

///|
extern "wasm" fn timestamp_out(timestamp : Int64, tz : Bool) -> String =
  #| (func (import "env" "timestamp_out")
  #|  (param i64) (param i32) (result (ref extern)))

///|
extern "wasm" fn timestamp_pl_interval(
  timestamp : Int64,
  interval : Interval
) -> Int64 =
  #| (func (import "env" "timestamp_pl_interval")
  #|  (param i64) (param (ref extern)) (result i64))

///|
extern "wasm" fn timestamp_mi_interval(
  timestamp : Int64,
  interval : Interval
) -> Int64 =
  #| (func (import "env" "timestamp_mi_interval")
  #|  (param i64) (param (ref extern)) (result i64))

///|
extern "wasm" fn interval_in(str : String) -> Interval =
  #| (func (import "env" "interval_in")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn interval_make(
  years : Int,
  months : Int,
  weeks : Int,
  days : Int,
  hours : Int,
  minutes : Int,
  seconds : Double
) -> Interval =
  #| (func (import "env" "interval_make")
  #|  (param i32) (param i32) (param i32) (param i32)
  #|  (param i32) (param i32) (param f64) (result (ref extern)))

///|
extern "wasm" fn interval_out(interval : Interval) -> String =
  #| (func (import "env" "interval_out")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn interval_pl(
  interval1 : Interval,
  interval2 : Interval
) -> Interval =
  #| (func (import "env" "interval_pl")
  #|  (param (ref extern)) (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn interval_mi(
  interval1 : Interval,
  interval2 : Interval
) -> Interval =
  #| (func (import "env" "interval_mi")
  #|  (param (ref extern)) (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn interval_mul(interval : Interval, factor : Double) -> Interval =
  #| (func (import "env" "interval_mul")
  #|  (param (ref extern)) (param f64) (result (ref extern)))

///|
extern "wasm" fn interval_div(
  interval : Interval,
  divisor : Double
) -> Interval =
  #| (func (import "env" "interval_div")
  #|  (param (ref extern)) (param f64) (result (ref extern)))

///|
pub impl FromStr for Timestamp with from_string(str) {
  timestamp_in(str, false)
}

///|
pub impl FromStr for Timestamptz with from_string(str) {
  timestamp_in(str, true)
}

///|
pub impl FromStr for Interval with from_string(str) { interval_in(str) }

///|
pub fn Timestamp::to_string(self : Timestamp) -> String {
  timestamp_out(self._, false)
}

///|
pub fn Timestamptz::to_string(self : Timestamptz) -> String {
  timestamp_out(self._, true)
}

///|
pub fn Interval::to_string(self : Interval) -> String {
  interval_out(self)
}

///|
impl Obj for Timestamp with typname() { "timestamp" }

///|
impl Obj for Timestamptz with typname() { "timestamptz" }

///|
impl Obj for Interval with typname() { "interval" }

///|
pub impl Show for Timestamp with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Timestamptz with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Interval with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub fn Timestamp::plus(self : Timestamp, other : Interval) -> Timestamp {
  timestamp_pl_interval(self._, other)
}

///|
pub fn Timestamp::minus(self : Timestamp, other : Interval) -> Timestamp {
  timestamp_mi_interval(self._, other)
}

///|
pub fn Interval::make(
  years~ : Int = 0,
  months~ : Int = 0,
  weeks~ : Int = 0,
  days~ : Int = 0,
  hours~ : Int = 0,
  minutes~ : Int = 0,
  seconds~ : Double = 0.0
) -> Interval {
  interval_make(years, months, weeks, days, hours, minutes, seconds)
}

///|
pub fn Interval::op_add(self : Interval, other : Interval) -> Interval {
  interval_pl(self, other)
}

///|
pub fn Interval::op_sub(self : Interval, other : Interval) -> Interval {
  interval_mi(self, other)
}

///|
pub fn Interval::mul(self : Interval, other : Double) -> Interval {
  interval_mul(self, other)
}

///|
pub fn Interval::div(self : Interval, other : Double) -> Interval {
  interval_div(self, other)
}

///|
pub impl FromJson for Timestamp with from_json(json, path) {
  timestamp_in(String::from_json!(json, path), false)
}

///|
pub impl FromJson for Timestamptz with from_json(json, path) {
  timestamp_in(String::from_json!(json, path), true)
}

///|
pub impl FromJson for Interval with from_json(json, path) {
  interval_in(String::from_json!(json, path))
}

///|
pub impl ToJson for Timestamp with to_json(self) { String(self.to_string()) }

///|
pub impl ToJson for Timestamptz with to_json(self) { String(self.to_string()) }

///|
pub impl ToJson for Interval with to_json(self) { String(self.to_string()) }
