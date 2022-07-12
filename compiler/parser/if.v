module parser

import ast

fn (mut p Parser) parse_if() ast.IfStmt {
	tpos := p.tok.pos
	mut branches := []ast.IfBranch{}

	mut is_else := false

	for {
		pos := p.tok.pos
		mut expr := ast.Expr(ast.EmptyExpr{})
		if !is_else {
			p.next()
			expr = p.expr()
		}
		p.open_scope()
		block := p.parse_block(false)
		p.close_scope()
		branches << ast.IfBranch{
			pos: pos
			cond: expr
			is_else: is_else
			block: block
		}
		if p.tok.kind != .key_else || is_else {
			break
		}
		p.next()
		if p.tok.kind != .key_if {
			is_else = true
		}
	}
	return ast.IfStmt{
		pos: tpos
		branches: branches
	}
}
