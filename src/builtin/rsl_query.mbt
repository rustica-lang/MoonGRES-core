///|
extern type Portal

///|
extern type TupleTable

///|
extern type HeapTuple

///|
fn env_execute_statement(idx : Int) -> Int = "env" "execute_statement"

///|
fn env_cursor_open(idx : Int) -> Portal = "env" "cursor_open"

///|
fn env_cursor_fetch(portal : Portal, count : Int) -> TupleTable = "env" "cursor_fetch"

///|
fn env_cursor_fetch_all(portal : Portal) -> TupleTable = "env" "cursor_fetch_all"

///|
fn env_cursor_close(portal : Portal) -> Unit = "env" "cursor_close"

///|
fn env_tuple_table_len(table : TupleTable) -> Int = "env" "tuple_table_len"

///|
fn env_tuple_table_get(table : TupleTable, index : Int) -> HeapTuple = "env" "tuple_table_get"

///|
fn env_tuple_lower(tuple : HeapTuple) -> Unit = "env" "tuple_lower"

///|
fn env_tid_to_oid(tid : UUID) -> Int = "env" "tid_to_oid"

///|
pub(all) struct Query[ARGS, RET] {
  idx : Int?
  sql : Bytes
  args_oids : Array[Int]
  mut args : ARGS?
  rec : Ref[RET?]
  args_tids : Array[UUID]?
}

///|
pub type Tuple[T] (HeapTuple, Ref[T?])

///|
pub fn Tuple::lower[T](self : Tuple[T]) -> T {
  env_tuple_lower(self.0)
  let rv = self.1.val.unwrap()
  self.1.val = None
  rv
}

///|
pub type Cursor[T] (Portal, Ref[T?])

///|
pub fn Cursor::fetch[T](self : Cursor[T], count~: Int = 0) -> Array[Tuple[T]] {
  let table = match count {
    0 => env_cursor_fetch_all(self.0)
    _..<0 => abort("unimplemented")
    count => env_cursor_fetch(self.0, count)
  }
  let len = env_tuple_table_len(table)
  let rv = Array::new(capacity=len)
  for i in 0..<len {
    rv.push(Tuple((env_tuple_table_get(table, i), self.1)))
  }
  rv
}

///|
pub fn Cursor::close[T](self : Cursor[T]) -> Unit {
  env_cursor_close(self.0)
}

///|
pub fn Query::new[ARGS, RET](
  sql : Bytes,
  args_tids~ : Array[UUID]? = None
) -> Query[ARGS, RET] {
  { sql, args_oids: [], args: None, idx: None, args_tids, rec: Ref::new(None) }
}

///|
pub fn Query::bind[ARGS, RET](
  self : Query[ARGS, RET],
  args : ARGS
) -> Cursor[RET] {
  self.args = Some(args)
  let portal = env_cursor_open(self.idx.unwrap())
  Cursor((portal, self.rec))
}

///|
pub fn query_all[ARGS, RET](self : Query[ARGS, RET], args : ARGS) -> Array[RET] {
  let cursor = self.bind(args)
  let rv = cursor.fetch()
  cursor.close()
  rv.map(Tuple::lower)
}

///|
pub fn query_one[ARGS, RET](self : Query[ARGS, RET], args : ARGS) -> RET? {
  let cursor = self.bind(args)
  let rv = cursor.fetch(count=1)
  cursor.close()
  match rv {
    [] => None
    [tuple] => Some(tuple.lower())
    _ => unreachable()
  }
}

///|
pub fn execute[ARGS](self : Query[ARGS, Unit], args : ARGS) -> Unit {
  self.args = Some(args)
  env_execute_statement(self.idx.unwrap()) |> ignore
}

///|
pub fn populate_args_oids[ARGS, RET](self : Query[ARGS, RET]) -> Unit {
  guard self.args_tids is Some(tids) else { () }
  self.args_oids.clear()
  for tid in tids {
    self.args_oids.push(env_tid_to_oid(tid))
  }
}
