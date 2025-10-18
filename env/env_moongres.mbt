// SPDX-FileCopyrightText: 2025 燕几（北京）科技有限公司
// SPDX-License-Identifier: Apache-2.0 OR MulanPSL-2.0

///|
fn get_cli_args_internal() -> Array[String] {
  []
}

///|
fn realtime_micros_since_unix_epoch() -> UInt64 = "env" "realtime_micros_since_unix_epoch"

///|
fn now_internal() -> UInt64 {
  realtime_micros_since_unix_epoch() / 1000
}

///|
fn current_dir_internal() -> String? {
  None
}
