module ast

[heap]
pub struct Scope {
pub:
	parent &Scope
mut:
	vars    []&Var
	methods []&Method
}

pub fn create_scope(parent &Scope) &Scope {
	return &Scope{
		parent: parent
	}
}

pub fn (mut scope Scope) add_var(var &Var) {
	scope.vars << var
}

pub fn (mut scope Scope) add_method(method &Method) {
	scope.methods << method
}

pub struct Var {
pub:
	name    string
	typ     Type
	access  AccessType
	mutable bool
pub mut:
	defined bool
}

pub fn create_var(name string, typ Type, access AccessType, mutable bool) &Var {
	return &Var{
		name: name
		typ: typ
		access: access
		mutable: mutable
	}
}

pub struct Method {
pub:
	name        string
	access      AccessType
	return_type Type
}

pub fn create_method(name string, access AccessType, return_type Type) &Method {
	return &Method{
		name: name
		access: access
		return_type: return_type
	}
}
