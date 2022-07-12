module main

import os
import parser

fn main() {
	mut parser := parser.create_parser(os.args[1])?
	file := parser.parse_file()
	file.write_errors()
//	eprintln(file)
}
