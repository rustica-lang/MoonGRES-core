wasm_path = target/wasm-gc/release/build/builtin/builtin.wasm
wat_path = target/wasm-gc/release/build/builtin/builtin.wat
src = $(wildcard src/builtin/*.mbt)
core = $(filter-out src/builtin/rsl_main.mbt, $(src))

$(wasm_path): $(src)
	moon build

$(wat_path): $(src)
	moon build --output-wat

.ONESHELL: deploy
.PHONY: deploy
deploy: $(wasm_path)
	@psql -h /tmp -d "V2f20388d40_main" <<EOF
		BEGIN;
#		select pg_sleep(5);
		delete from rustica.queries where module = 'main';
		delete from rustica.modules where name = 'main';
		WITH
		  wasm AS (
			SELECT '\x$(shell xxd -p $(wasm_path) | tr -d '\n')'::bytea AS code
		  ),
		  tid_map AS (
			SELECT ROW(id,backend_id)::rustica.tid_oid
			FROM edgedb."_SchemaType"
			WHERE backend_id is not NULL
		  ),
		  compiled AS (
			  SELECT rustica.compile_wasm(code, ARRAY(SELECT * FROM tid_map)) AS result FROM wasm
		  ),
		  module_insert AS (
			INSERT INTO rustica.modules
			  SELECT 'main', code, (result).bin_code, (result).heap_types
			  FROM wasm, compiled
			  RETURNING name
		  )
		INSERT INTO rustica.queries
		  SELECT
			module_insert.name,
			q.index,
			q.sql,
			q.arg_type,
			q.arg_oids,
			q.arg_field_types,
			q.arg_field_fn,
			q.ret_type,
			q.ret_oids,
			q.ret_field_types,
			q.ret_field_fn
		  FROM
			(select (result).queries AS q FROM compiled) AS queries_expanded
		  JOIN
			module_insert ON true
		  CROSS JOIN
			LATERAL unnest(queries_expanded.q) AS q;
		COMMIT;
	EOF

.PHONY: clean
clean:
	rm -f core.mbt
	moon clean

.PHONY: wat
wat: $(wat_path)

core.mbt: $(core)
	cat $(core) | \
		grep -v '^// ' | \
		grep -v '^//$$' | \
		grep -v '^///[^ ]' | \
		grep -v '^/// \?$$' | \
		grep -v '^/// [^@]' > core.mbt
	moonfmt -i core.mbt

.PHONY: wasm
wasm: $(wasm_path)
