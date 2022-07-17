module ast

import util
import token

[heap]
pub struct Scope {
pub mut:
	parent  &Scope
	vars    []&Var
	methods []&Method
mut:
	has_parent bool
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

fn (mut scope Scope) set_parent(parent &Scope) {
	scope.has_parent = true
	scope.parent = parent
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

pub fn (scope Scope) has_var(name string) bool {
	return scope.vars.filter(it.name == name).len == 1
}

pub fn (mut scope Scope) set_not_known_in_context() {
	for mut var in scope.vars {
		var.eic = false
	}
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

pub fn (scope Scope) has_method(name string) bool {
	return scope.methods.filter(it.name == name).len == 1
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

pub fn create_global_scope(mut scopes []&Scope) []util.Info {
	mut gscope := create_top_scope()
	mut infos := []util.Info{}
	for mut scope in scopes {
		scope.set_parent(gscope)
		public_vars := scope.vars.filter(it.access == .publ)
		public_methods := scope.methods.filter(it.access == .publ)
		scope.vars = scope.vars.filter(it.access != .publ)
		scope.methods = scope.methods.filter(it.access != .publ)
		for var in public_vars {
			if gscope.has_var(var.name) {
				infos << util.error('Duplicate variable $var.name', token.Token{})
				continue
			}
			gscope.add_var(var)
		}
		for method in public_methods {
			if gscope.has_method(method.name) {
				infos << util.error('Duplicate method $method.name', token.Token{})
				continue
			}
			gscope.add_method(method)
		}
	}
	return infos
}
