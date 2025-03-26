///|
type Timestamp Int64 derive(Eq, Compare)

///|
type Timestamptz Int64 derive(Eq, Compare)

///|
extern type Interval

///|
fn timestamp_in(str : String, tz : Bool) -> Int64 = "env" "timestamp_in"

///|
fn timestamp_out(timestamp : Int64, tz : Bool) -> String = "env" "timestamp_out"

///|
fn timestamp_pl_interval(timestamp : Int64, interval : Interval) -> Int64 = "env" "timestamp_pl_interval"

///|
fn timestamp_mi_interval(timestamp : Int64, interval : Interval) -> Int64 = "env" "timestamp_mi_interval"

///|
fn interval_in(str : String) -> Interval = "env" "interval_in"

///|
fn interval_make(
  years : Int,
  months : Int,
  weeks : Int,
  days : Int,
  hours : Int,
  minutes : Int,
  seconds : Double
) -> Interval = "env" "interval_make"

///|
fn interval_out(interval : Interval) -> String = "env" "interval_out"

///|
fn interval_pl(interval1 : Interval, interval2 : Interval) -> Interval = "env" "interval_pl"

///|
fn interval_mi(interval1 : Interval, interval2 : Interval) -> Interval = "env" "interval_mi"

///|
fn interval_mul(interval : Interval, factor : Double) -> Interval = "env" "interval_mul"

///|
fn interval_div(interval : Interval, divisor : Double) -> Interval = "env" "interval_div"

///|
pub impl FromStr for Timestamp with from_string(str) {
  timestamp_in(str, false)
}

///|
pub impl FromStr for Timestamptz with from_string(str) {
  timestamp_in(str, true)
}

///|
pub impl FromStr for Interval with from_string(str) {
  interval_in(str)
}

///|
impl Obj for Timestamp with typname() {
  "timestamp"
}

///|
impl Obj for Timestamptz with typname() {
  "timestamptz"
}

///|
impl Obj for Interval with typname() {
  "interval"
}

///|
pub impl Show for Timestamp with to_string(self) {
  timestamp_out(self._, false)
}

///|
pub impl Show for Timestamp with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Timestamptz with to_string(self) {
  timestamp_out(self._, true)
}

///|
pub impl Show for Timestamptz with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Show for Interval with to_string(self) {
  interval_out(self)
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
pub impl ToJson for Timestamp with to_json(self) {
  String(self.to_string())
}

///|
pub impl ToJson for Timestamptz with to_json(self) {
  String(self.to_string())
}

///|
pub impl ToJson for Interval with to_json(self) {
  String(self.to_string())
}
