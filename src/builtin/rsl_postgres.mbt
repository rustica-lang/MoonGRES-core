///|
trait Obj {
  typname() -> String
}

///|
fn output_with_typname[T : Show + Obj](val : T, logger : &Logger) -> Unit {
  logger.write_string(T::typname())
  logger.write_char('<')
  logger.write_string(val.to_string())
  logger.write_char('>')
}
