module c

import ast
import strings

fn (mut g CGen) get_table(typ ast.Type) &ast.Table {
	return if g.global_table.contains_type(typ.name) {
		g.global_table
	} else {
		g.table
	}
}

fn (mut g CGen) typ(typ ast.Type) string {
	mut sym := g.get_table(typ).get_type_symbol(typ)
	return match mut sym.info {
		ast.Alias {
			g.typ(sym.info.base)
		}
		ast.Pointer {
			'${g.typ(sym.info.base)}*'
		}
		ast.BaseClass, ast.Class, ast.Array {
			sym.bname
		}
	}
}

fn (mut g CGen) get_base_name(typ ast.Type) (&ast.TypeSymbol, string) {
	table := g.get_table(typ)
	sym := table.get_type_symbol(typ)
	match sym.info {
		ast.Class, ast.BaseClass {
			return sym, sym.bname
		}
		ast.Pointer, ast.Alias {
			return g.get_base_name(sym.info.base)
		}
		ast.Array {
			t := g.get_table(name: 'Array')
			tt := t.get_type('Array')
			return t.get_type_symbol(tt), 'Array'
		}
	}
}

fn (mut g CGen) gen_types(table &ast.Table) {
	for s in table.type_syms {
		mut sym := unsafe { s }
		match mut sym.info {
			ast.Class, ast.BaseClass {
				g.gen_class(sym)
			}
			else {}
		}
	}
}

fn (mut g CGen) gen_class(sym ast.TypeSymbol) {
	name := sym.bname
	if name == 'void' {
		return
	}
	if name in g.generated_classes {
		return
	}
	g.types.writeln('typedef struct $name $name;')

	mut info := unsafe { sym.info }

	mut scope := &ast.Scope(0)

	mut buffer := strings.new_builder(0)

	buffer.writeln('struct $name {')
	if mut info is ast.BaseClass {
		buffer.writeln('\tchar data_$name[$info.size];')
		scope = info.scope
	} else if mut info is ast.Class {
		for i, parent in info.parents {
			buffer.writeln('\t${g.typ(parent)} parent_$i;')
		}
		scope = info.scope
	}

	for var in scope.vars {
		if var.name == 'this' {
			continue
		}
		base_sym, base_name := g.get_base_name(var.typ)
		if base_name !in g.generated_classes && base_name != '' {
			g.gen_class(base_sym)
		}
		buffer.writeln('\t${g.typ(var.typ)} $var.name;')
	}

	buffer.writeln('};')
	buffer.writeln('')

	g.declarations.write(buffer.str())
	g.generated_classes << name
	unsafe {
		buffer.free()
	}
}
