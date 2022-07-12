module parser

import token
import ast

pub fn (mut p Parser) top_lvl() ?ast.Stmt {
	mut access := ast.AccessType.priv
	mut mutable := false
	if p.tok.kind == .key_pub {
		access = .publ
		p.next()
	} else if p.tok.kind == .key_priv {
		p.next()
	}

	if p.tok.kind == .key_mut {
		p.next()
		mutable = true
	}

	p.access = access
	p.mutable = mutable

	match p.tok.kind {
		.key_base, .key_class {
			mut base := false
			mut base_size := 0
			if p.tok.kind == .key_base {
				base = true
				p.next()
				p.check(.lsbr)
				p.next()
				p.check(.num)
				base_size = p.tok.lit.int()
				p.next()
				p.check(.rsbr)
				p.next()
				p.check(.key_class)
			}
			if p.inside_base_class {
				p.error('Cannot create a sub class in a base class')
				return none
			}
			if p.inside_class && base {
				base = false
				p.error('Cannot create base sub class in class')
			}
			return p.parse_class(base, base_size)
		}
		.name {
			return p.parse_assign()
		}
		.key_constructor {
			return p.parse_constructor()
		}
		else {
			p.error('Unexpected top level statement')
			return none
		}
	}
}

fn (mut p Parser) stmt() ast.Stmt {
	mut mutable := false

	if p.tok.kind == .key_mut {
		p.next()
		mutable = true
	}

	p.mutable = mutable

	match p.tok.kind {
//		.key_for {}
		.key_if {
			return p.parse_if()
		}
//		.key_match {} 
		.lcbr {
			return p.parse_block(false)
		}
		else {
			return p.parse_multi_expr()
		}
	}
}

fn (mut p Parser) parse_block(top_lvl bool) ast.BlockStmt {
	pos := p.tok.pos
	p.check(.lcbr)
	p.next()

	mut stmts := []ast.Stmt{}

	for p.tok.kind != .rcbr {
		if top_lvl {
			stmts << p.top_lvl() or { break }
		} else {
			stmt := p.stmt()
			stmts << stmt
		}
	}
	p.check(.rcbr)
	p.next()

	return ast.BlockStmt{
		pos: pos
		stmts: stmts
		scope: p.scope
	}
}

fn (mut p Parser) parse_multi_expr() ast.Stmt {
	pos := p.tok.pos
	expr := p.expr()

	if p.tok.kind in [.ddot, .eq] {
		return p.parse_assign_with_left(expr, pos)
	}
	return ast.ExprStmt{
		pos: pos
		expr: expr
	}
}

fn (mut p Parser) parse_assign() ast.AssignStmt {
	pos := p.tok.pos
	left := p.expr()

	return p.parse_assign_with_left(left, pos)
}

fn (mut p Parser) parse_assign_with_left(left ast.Expr, pos token.Position) ast.AssignStmt {
	mut left_type := ast.Type{}
	if p.tok.kind == .ddot {
		p.next()
		left_type = p.typ()
	}


	if left is ast.IdentExpr {
		// Declaration
		if p.tok.kind != .eq {
			if left_type != ast.Type{} {
				p.scope.add_var(ast.create_var(left.name, left_type, p.access, p.mutable))
				return ast.AssignStmt{
					pos: pos
					left: left
					left_type: left_type
					define: false
				}
			} else {
				p.error('Require a type, to declare an variable')
				return ast.AssignStmt{}
			}
		}
	}
	
	p.check(.eq)
	p.next()
	right := p.expr()
	return ast.AssignStmt{
		pos: pos
		left: left
		right: right
		define: true
	}
}
