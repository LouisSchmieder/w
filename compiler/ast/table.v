module ast

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
	return &Table{}
}

pub fn (table Table) get_type_symbol(typ Type) &TypeSymbol {
	return table.type_syms[typ.idx]
}

pub fn (table Table) contains_type(name string) bool {
	return table.type_syms.filter(it.name == name).len > 0
}

pub fn (table Table) get_type(name string) Type {
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
		return Type{
			name: name
			idx: table.type_syms.len - 1
		}
	}
	return none
}
