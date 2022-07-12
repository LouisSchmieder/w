module ast

pub type TypeInfo = Alias | Array | BaseClass | Class | Pointer

pub type RootClass = BaseClass | Class

pub enum AccessType {
	prot
	priv
	publ
}

pub struct TypeSymbol {
pub:
	info  TypeInfo
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
pub:
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
pub:
	typ Type
}

pub struct Pointer {
pub:
	base Type
}

pub fn (t Table) root(info TypeInfo) RootClass {
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
