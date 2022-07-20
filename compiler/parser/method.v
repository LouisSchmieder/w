module parser

import ast

fn (mut p Parser) parse_constructor() ast.MethodStmt {
	pos := p.tok.pos
	p.next()

	mut parameters := []ast.MethodParameter{}

	if p.inside_base_class {
		p.check(.lbr)
		p.next()
		p.check(.rbr)
		p.next()
	} else {
		parameters = p.parse_parameters()
	}

	p.open_scope()
	block := p.parse_block(false)
	p.close_scope()

	p.scope.add_method(ast.create_method('constructor', p.access, p.class_type, parameters))

	return ast.MethodStmt{
		name: 'constructor'
		pos: pos
		ret_typ: p.class_type
		parameters: parameters
		block: block
	}
}

fn (mut p Parser) parse_destructor() ast.MethodStmt {
	pos := p.tok.pos
	p.next()

	p.check(.lbr)
	p.next()
	p.check(.rbr)
	p.next()

	typ := p.typ()

	p.open_scope()
	block := p.parse_block(false)
	p.close_scope()

	p.scope.add_method(ast.create_method('destructor', p.access, p.class_type, []))

	return ast.MethodStmt{
		name: 'destructor'
		pos: pos
		block: block
		ret_typ: typ
	}
}

fn (mut p Parser) parse_method() ast.MethodStmt {
	pos := p.tok.pos
	name := p.name()

	parameters := p.parse_parameters()

	typ := p.typ()

	p.open_scope()

	for para in parameters {
		mut var := ast.create_var(para.name, para.typ, .publ, false, false)
		var.eic = true
		p.scope.add_var(var)
	}

	block := p.parse_block(false)
	p.close_scope()

	p.scope.add_method(ast.create_method(name, p.access, typ, parameters))

	return ast.MethodStmt{
		name: name
		pos: pos
		ret_typ: typ
		block: block
		parameters: parameters
	}
}

fn (mut p Parser) parse_parameters() []ast.MethodParameter {
	p.check(.lbr)
	p.next()

	mut parameters := []ast.MethodParameter{}

	for {
		if p.tok.kind != .name {
			break
		}
		pos := p.tok.pos
		name := p.name()
		p.check(.ddot)
		p.next()
		typ := p.typ()
		parameters << ast.MethodParameter{
			pos: pos
			name: name
			typ: typ
		}
		if p.tok.kind != .comma {
			break
		}
		p.next()
	}

	p.check(.rbr)
	p.next()

	return parameters
}

fn (mut p Parser) parse_call_parameters() []ast.Expr {
	mut exprs := []ast.Expr{}
	for p.tok.kind != .rbr {
		exprs << p.expr()
		if p.tok.kind != .comma {
			break
		}
		p.next()
	}
	p.check(.rbr)
	p.next()
	return exprs
}
