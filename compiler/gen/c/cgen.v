module c

import ast
import strings

struct Builder {
mut:
	builder  strings.Builder
	indent   int
	new_line bool
}

fn (mut builder Builder) write(msg string) {
	if builder.new_line {
		builder.new_line = false
		builder.builder.write_string('\t'.repeat(builder.indent))
	}
	builder.builder.write_string(msg)
}

fn (mut builder Builder) writeln(msg string) {
	if builder.new_line {
		builder.builder.write_string('\t'.repeat(builder.indent))
	}
	builder.builder.writeln(msg)
	builder.new_line = true
}

fn (builder Builder) free_builder() {
	unsafe {
		builder.builder.free()
	}
}

fn (mut builder Builder) str() string {
	return builder.builder.str()
}

pub struct CGen {
	global_table &ast.Table
mut:
	headers      Builder
	types        Builder
	declarations Builder
	methods      Builder
	constants    Builder
	main         Builder
	src          Builder

	current &Builder

	scope &ast.Scope
	table &ast.Table
	file  &ast.File

	generated_classes []string

	set_neic_global_scope bool

	inside_class  bool
	is_base_class bool

	class_type ast.Type

	init string
}

pub fn create_cgen(global_table &ast.Table, init string) &CGen {
	return &CGen{
		global_table: global_table
		init: init
		scope: 0
		table: 0
		current: 0
		file: 0
	}
}

pub fn (mut g CGen) gen_file(files_ []&ast.File) string {
	mut files := unsafe { files_ }
	g.gen_types(g.global_table)
	g.default_headers()
	g.current = &g.src
	g.constants.writeln('// Constants')

	// Main header
	g.main.writeln('int main(const char* args) {')
	g.main.indent++

	for i, _ in files {
		g.handle_file(mut files[i])
	}

	g.main.writeln('${g.typ(g.global_table.get_type(g.init))}__constructor();')

	g.main.indent--
	g.main.writeln('}')
	g.main.writeln('// The end')

	defer {
		g.headers.free_builder()
		g.types.free_builder()
		g.declarations.free_builder()
		g.constants.free_builder()
		g.main.free_builder()
		g.src.free_builder()
	}
	return [
		g.headers.str(),
		g.types.str(),
		g.declarations.str(),
		g.methods.str(),
		g.constants.str(),
		g.src.str(),
		g.main.str(),
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
	g.current.write(data)
}

fn (mut g CGen) writeln(data string) {
	g.current.writeln(data)
}

fn (mut g CGen) inc_indent() {
	g.current.indent++
}

fn (mut g CGen) dec_indent() {
	g.current.indent--
}
