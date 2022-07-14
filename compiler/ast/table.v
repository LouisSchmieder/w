module ast

[heap]
pub struct Table {
pub mut:
	type_syms []&TypeSymbol
	types     map[string]int
}

pub struct Type {
pub:
	name string
	idx  int
}

pub fn create_table() &Table {
	mut table := &Table{}
	table.add_type('void', 'void', BaseClass{
		size: 0
		access: .publ
	}) or { return table }
	return table
}

pub fn (table &Table) get_type_symbol(typ Type) &TypeSymbol {
	return table.type_syms[typ.idx]
}

pub fn (table &Table) contains_type(name string) bool {
	return name in table.types
}

pub fn (table &Table) get_type(name string) Type {
	if name in table.types {
		return Type{name, table.types[name]}
	}
	return Type{name, -1}
}

pub fn (mut table Table) add_type(name string, bname string, info TypeInfo) ?Type {
	if !table.contains_type(name) {
		table.type_syms << &TypeSymbol{
			name: name
			bname: bname
			info: info
		}
		table.types[name] = table.type_syms.len - 1
		return Type{
			name: name
			idx: table.type_syms.len - 1
		}
	}
	return none
}

pub fn (mut table Table) update_symbols() {
	for idx in table.types.values() {
		table.update_symbol(idx)
	}
}

pub fn merge_tables(mut tables []&Table) &Table {
	mut global := create_table()
	for i, table in tables {
		mut deleted := []string{}
		for key, value in table.types {
			sym := table.get_type_symbol(idx: value)
			if table.get_access_type(sym.info) == .publ {
				global.add_type(sym.name, sym.bname, sym.info) or {
					continue
				}
				deleted << key
			}
		}
		tables[i].type_syms = table.type_syms.filter(it.name !in deleted)
		for key in deleted {
			tables[i].types.delete(key)
		}
		names := table.type_syms.map(it.name)
		for key, _ in table.types {
			idx := names.index(key)
			tables[i].types[key] = idx
		}
		tables[i].update_symbols()
 	}

	global.update_symbols()

	return global
}
