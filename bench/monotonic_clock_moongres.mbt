// SPDX-FileCopyrightText: 2025 燕几（北京）科技有限公司
// SPDX-License-Identifier: Apache-2.0 OR MulanPSL-2.0

///|
#external
type Timestamp

///|
fn monotonic_nanos_since(x : Timestamp) -> UInt64 = "env" "monotonic_nanos_since"

///|
pub fn monotonic_clock_start() -> Timestamp = "env" "monotonic_now"

///|
pub fn monotonic_clock_end(ts : Timestamp) -> Double {
  monotonic_nanos_since(ts).to_double() / 1000.0
}
