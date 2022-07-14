module ast

pub type TypeInfo = Alias | Array | BaseClass | Class | Pointer

pub type RootClass = BaseClass | Class

pub enum AccessType {
	prot
	priv
	publ
}

pub struct TypeSymbol {
pub mut:
	info  TypeInfo
pub:
	name  string
	bname string // backend name
}

pub fn (ts TypeSymbol) alias() Alias {
	return ts.info as Alias
}

pub fn (ts TypeSymbol) base_class() BaseClass {
	return ts.info as BaseClass
}

pub fn (ts TypeSymbol) class() Class {
	return ts.info as Class
}

pub fn (ts TypeSymbol) array() Array {
	return ts.info as Array
}

pub fn (ts TypeSymbol) pointer() Pointer {
	return ts.info as Pointer
}

pub fn (ts TypeSymbol) type_name() string {
	return ts.name
}

pub struct Alias {
pub mut:
	base Type
}

pub struct Class {
pub mut:
	parents []Type
	access  AccessType
}

pub struct BaseClass {
pub:
	size   int
	access AccessType
}

pub struct Array {
pub mut:
	typ Type
}

pub struct Pointer {
pub mut:
	base Type
}

fn (mut alias Alias) update(table &Table) {
	if alias.base.idx != -1 {
		alias.base = table.get_type(alias.base.name)
	}
}

fn (mut class Class) update(table &Table) {
	for i, parent in class.parents {
		if parent.idx != -1 {
			class.parents[i] = table.get_type(parent.name)
		}
	}
}

fn (mut bs BaseClass) update(table &Table) {
}

fn (mut arr Array) update(table &Table) {
	if arr.typ.idx != -1 {
		arr.typ = table.get_type(arr.typ.name)
	}
}

fn (mut p Pointer) update(table &Table) {
	if p.base.idx != -1 {
		p.base = table.get_type(p.base.name)
	}
}

pub fn (t &Table) get_access_type(info TypeInfo) AccessType {
	return t.root(info).access
}

pub fn (t &Table) root(info TypeInfo) RootClass {
	match info {
		Alias {
			return t.root(t.get_type_symbol(info.base).info)
		}
		Class, BaseClass {
			return info
		}
		Array {
			return t.root(t.get_type_symbol(info.typ).info)
		}
		Pointer {
			return t.root(t.get_type_symbol(info.base).info)
		}
	}
}

pub fn (mut t Table) update_symbol(idx int) {
	mut sym := t.type_syms[idx]
	match mut sym.info {
		Alias {
			sym.info.update(t)
		}
		Class {
			sym.info.update(t)
		}
		BaseClass {
			sym.info.update(t)
		}
		Array {
			sym.info.update(t)
		}
		Pointer {
			sym.info.update(t)
		}
	}
}
