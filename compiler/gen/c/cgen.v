module c

import ast
import strings

pub struct CGen {
	global_table &ast.Table
mut:
	headers      strings.Builder
	types        strings.Builder
	declarations strings.Builder
	methods      strings.Builder
	main         strings.Builder
	src          strings.Builder

	scope &ast.Scope
	table &ast.Table
	file  &ast.File

	generated_classes []string

	set_neic_global_scope bool
	indent int
	new_line bool

	inside_class  bool
	is_base_class bool

	class_type   ast.Type
}

pub fn create_cgen(global_table &ast.Table) &CGen {
	return &CGen{
		global_table: global_table
		scope: 0
		table: 0
		file: 0
	}
}

pub fn (mut g CGen) gen_file(files_ []&ast.File) string {
	mut files := unsafe { files_ }
	g.gen_types(g.global_table)
	g.default_headers()
	for i, _ in files {
		g.handle_file(mut files[i])
	}

	defer {
		unsafe {
			g.headers.free()
			g.types.free()
			g.declarations.free()
			g.main.free()
			g.src.free()
		}
	}
	return [
		g.headers.str(),
		g.types.str(),
		g.declarations.str(),
		g.methods.str(),
		g.src.str(),
		g.main.str()
	].join('\n')
}

fn (mut g CGen) default_headers() {
	g.headers.writeln('#include <string.h>')

	g.headers.writeln('#define _STR(str, len) String__constructor(Array__constructor(str, Int__constructor((char*)(long)len)))')
}

fn (mut g CGen) handle_file(mut file ast.File) {
	g.scope = file.scope
	if !g.set_neic_global_scope {
		g.set_neic_global_scope = true
		mut scope := g.scope.parent
		scope.set_not_known_in_context()
	}
	g.scope.set_not_known_in_context()
	g.table = file.table
	g.file = file
	g.gen_types(g.table)
	file.clear_infos()
	for stmt in file.stmts {
		g.stmt(stmt)
	}
}

fn (mut g CGen) write(data string) {
	if g.new_line {
		g.new_line = false
		g.src.write_string('\t'.repeat(g.indent))
	}
	g.src.write_string(data)
}

fn (mut g CGen) writeln(data string) {
	if g.new_line {
		g.new_line = false
		g.src.write_string('\t'.repeat(g.indent))
	}
	g.src.writeln(data)
	g.new_line = true
}
