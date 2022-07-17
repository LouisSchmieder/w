module main

import os
import parser
import checker
import ast
import gen.c

fn main() {
	mut parser := parser.create_parser_manager()
	parser.init()
	parser.add_parser(os.args[1])
	parser.write_errors()
	mut tables := parser.files.map(it.table)
	global := ast.merge_tables(mut tables)
	mut scopes := parser.files.map(it.scope)
	ast.create_global_scope(mut scopes)
	for file in parser.files {
		mut checker := checker.create_checker(file, global)
		checker.check_file()
		file.write_errors()
	}

	mut gen := c.create_cgen(global)
	file_str := gen.gen_file(parser.files)
	os.write_file('out.tmp.c', file_str) ?
}
