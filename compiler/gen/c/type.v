module c

import ast

fn (mut g CGen) get_table(typ ast.Type) &ast.Table {
	return if g.global_table.contains_type(typ.name) {
		g.global_table
	} else {
		g.table
	}
}

fn (mut g CGen) typ(typ ast.Type) string {
	return g.get_table(typ).get_type_symbol(typ).bname
}

fn (mut g CGen) gen_types(table &ast.Table) {
	for s in table.type_syms {
		mut sym := unsafe { s }
		match mut sym.info {
			ast.Alias {
				g.gen_alias(sym)
			}
			ast.Class, ast.BaseClass {
				g.gen_class(sym)
			}
			ast.Pointer {
				g.gen_pointer(sym)
			}
			else {}
		}
	}
}

fn (mut g CGen) gen_alias(sym ast.TypeSymbol) {
	g.types.writeln('typedef ${g.typ(sym.alias().base)} $sym.bname;')
}

fn (mut g CGen) gen_pointer(sym ast.TypeSymbol) {
	g.types.writeln('typedef ${g.typ(sym.pointer().base)}* $sym.bname;')
}

fn (mut g CGen) gen_class(sym ast.TypeSymbol) {
	name := sym.bname
	g.types.writeln('typedef struct $name $name;')

	mut info := unsafe { sym.info }

	mut scope := &ast.Scope(0)

	g.declarations.writeln('struct $name {')
	if mut info is ast.BaseClass {
		g.declarations.writeln('\tchar data_$name[$info.size];')
		scope = info.scope
	} else if mut info is ast.Class {
		for i, parent in info.parents {
			g.declarations.writeln('\t${g.typ(parent)} parent_$i;')
		}
		scope = info.scope
	}

	for var in scope.vars {
		g.declarations.writeln('\t${g.typ(var.typ)} $var.name;')
	}

	g.declarations.writeln('};')
	g.declarations.writeln('')
}
