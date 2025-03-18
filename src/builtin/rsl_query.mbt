///|
extern "wasm" fn env_execute_statement(idx : Int) -> Int =
  #| (func (import "env" "execute_statement")
  #|  (param i32)
  #|  (result i32))

///|
extern "wasm" fn env_tid_to_oid(tid : UUID) -> Int =
  #| (func (import "env" "tid_to_oid")
  #|  (param (ref extern)) (result i32))

///|
pub(all) struct Query[ARGS, RET] {
  idx : Int?
  sql : Bytes
  args_oids : Array[Int]
  mut args : ARGS?
  ret : Array[RET]?
  args_tids : Array[UUID]?
}

///|
pub fn Query::new[ARGS, RET](
  sql : Bytes,
  args_tids~ : Array[UUID]? = None
) -> Query[ARGS, RET] {
  { sql, args_oids: [], args: None, ret: None, idx: None, args_tids }
}

///|
pub fn query_all[ARGS, RET](self : Query[ARGS, RET], args : ARGS) -> Array[RET] {
  self.args = Some(args)
  env_execute_statement(self.idx.unwrap()) |> ignore
  self.ret.unwrap()
}

///|
pub fn query_one[ARGS, RET](self : Query[ARGS, RET], args : ARGS) -> RET? {
  self.args = Some(args)
  env_execute_statement(self.idx.unwrap()) |> ignore
  let ret = self.ret.unwrap()
  match ret.length() {
    0 => None
    1 => Some(ret[0])
    x => abort("expected 1 result, got \{x}")
  }
}

///|
pub fn execute[ARGS](self : Query[ARGS, Unit], args : ARGS) -> Unit {
  self.args = Some(args)
  env_execute_statement(self.idx.unwrap()) |> ignore
}

///|
pub fn populate_args_oids[ARGS, RET](self : Query[ARGS, RET]) -> Unit {
  guard let Some(tids) = self.args_tids else { None => () }
  self.args_oids.clear()
  for tid in tids {
    self.args_oids.push(env_tid_to_oid(tid))
  }
}
