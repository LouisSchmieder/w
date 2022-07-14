module main

import os
import parser
import checker
import ast

fn main() {
	mut parser := parser.create_parser_manager()
	parser.add_parser(os.args[1])
	parser.write_errors()
	mut tables := parser.files.map(it.table)
	global := ast.merge_tables(mut tables)
	for file in parser.files {
		mut checker := checker.create_checker(file, global)
		checker.check_file()
		file.write_errors()
	}
}
