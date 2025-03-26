///|
enum LogLevel {
  DEBUG5
  DEBUG4
  DEBUG3
  DEBUG2
  DEBUG1
  LOG
  INFO
  NOTICE
  WARNING
  ERROR
  FATAL
}

///|
fn env_ereport(level : Int, msg : String) -> Unit = "env" "ereport"

///|
pub fn ereport(level : LogLevel, msg : String) -> Unit {
  let level = match level {
    DEBUG5 => 10
    DEBUG4 => 11
    DEBUG3 => 12
    DEBUG2 => 13
    DEBUG1 => 14
    LOG => 15
    INFO => 17
    NOTICE => 18
    WARNING => 19
    ERROR => 21
    FATAL => 22
  }
  env_ereport(level, msg)
}

///|
pub fn unreachable[T]() -> T = "%unreachable"

///|
pub fn abort[T](msg : String) -> T {
  ereport(ERROR, msg)
  unreachable()
}

///|
pub fn panic[T]() -> T {
  ereport(FATAL, "panic")
  unreachable()
}

///|
pub fn println[T : Show](input : T) -> Unit {
  ereport(LOG, input.to_string())
}
