module ast

[heap]
pub struct Scope {
	has_parent bool
pub:
	parent &Scope
mut:
	vars    []&Var
	methods []&Method
}

fn create_top_scope() &Scope {
	return &Scope{
		parent: 0
	}
}

pub fn create_scope(parent &Scope) &Scope {
	return &Scope{
		parent: parent
		has_parent: true
	}
}

pub fn (scope Scope) get_explicit_var(name string) ?&Var {
	vars := scope.vars.filter(it.name == name)
	if vars.len == 1 {
		return vars[0]
	}
	return none
}

pub fn (scope Scope) get_var(name string) ?&Var {
	vars := scope.vars.filter(it.name == name)
	if vars.len == 1 {
		return vars[0]
	}
	if scope.has_parent {
		return scope.parent.get_var(name)
	}
	return none
}

pub fn (scope Scope) get_explicit_method(name string) ?&Method {
	methods := scope.methods.filter(it.name == name)
	if methods.len == 1 {
		return methods[0]
	}
	return none
}

pub fn (scope Scope) get_method(name string) ?&Method {
	methods := scope.methods.filter(it.name == name)
	if methods.len == 1 {
		return methods[0]
	}
	if scope.has_parent {
		return scope.parent.get_method(name)
	}
	return none
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
	access  AccessType
	mutable bool
pub mut:
	typ Type
	eic bool // Exists in content
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
	name   string
	access AccessType
pub mut:
	return_type Type
	parameters  []MethodParameter
}

pub fn create_method(name string, access AccessType, return_type Type, parameters []MethodParameter) &Method {
	return &Method{
		name: name
		access: access
		return_type: return_type
		parameters: parameters
	}
}
