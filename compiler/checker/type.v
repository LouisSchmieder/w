module checker

import ast

fn (mut c Checker) get_table(typ ast.Type) ?&ast.Table {
	return if c.global_table.contains_type(typ.name) {
		c.global_table
	} else if c.file.table.contains_type(typ.name) {
		c.file.table
	} else {
		none
	}
}

fn (mut c Checker) typ(mut typ ast.Type) {
	mut table := c.get_table(typ) or {
		c.error('Type `$typ.name` does not exists', c.current_pos)
		return
	}
	typ = table.get_type(typ.name)
}

fn (mut c Checker) type_symbol(typ ast.Type) &ast.TypeSymbol {
	mut table := c.get_table(typ) or {
		c.error('Type `$typ.name` does not exists', c.current_pos)
		return unsafe { 0 }
	}
	eprintln(table)
	eprintln(typ)
	return table.get_type_symbol(typ)
}
