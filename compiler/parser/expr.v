module parser

import ast

fn (mut p Parser) expr() ast.Expr {
	pos := p.tok.pos
	match p.tok.kind {
		.name {
			mut expr := ast.Expr(ast.IdentExpr{
				pos: p.tok.pos
				name: p.tok.lit
			})
			p.next()
			for {
				match p.tok.kind {
					.dot {
						p.next()
						expr = ast.InfixExpr{
							pos: p.tok.pos
							left: expr
							name: p.name()
						}
					}
					.lbr {
						p.next()
						parameters := p.parse_call_parameters()
						if mut expr is ast.IdentExpr {
							expr = ast.CallExpr{
								pos: expr.pos
								name: expr.name
								parameters: parameters
							}
						} else if mut expr is ast.InfixExpr {
							expr = ast.CallExpr{
								pos: expr.pos
								left: expr.left
								name: expr.name
								parameters: parameters
							}
						}
					}
					else {
						break
					}
				}
			}
			if p.tok.kind in [.ceq, .gt, .lt, .exclam] {
				return p.parse_comp(expr)
			}
			return expr
		}
		.lbr {
			p.next()
			expr := p.expr()
			p.check(.rbr)
			p.next()
			return ast.BracketExpr{
				pos: pos
				expr: expr
			}
		}
		.exclam {
			p.next()
			return ast.NegateExpr{
				pos: pos
				expr: p.expr()
			}
		}
		.lt {
			p.next()
			typ := p.typ()
			p.check(.gt)
			p.next()
			expr := p.expr()
			return ast.CastExpr{
				pos: pos
				to: typ
				expr: expr
			}
		}
		.str {
			defer {
				p.next()
			}
			return ast.StringExpr{
				pos: p.tok.pos
				lit: p.tok.lit
			}
		}
		.key_new {
			p.next()
			typ := p.typ()
			p.check(.lbr)
			p.next()
			params := p.parse_call_parameters()
			return ast.NewExpr{
				pos: pos
				typ: typ
				parameters: params
			}
		}
		.num {
			defer {
				p.next()
			}
			return ast.NumberExpr{
				pos: p.tok.pos
				num: p.tok.lit
			}
		}
		else {
			p.error('Unexpected symbol $p.tok.kind')
			p.next()
		}
	}
	return ast.EmptyExpr{
		pos: pos
	}
}

fn (mut p Parser) parse_comp(left ast.Expr) ast.CompareExpr {
	pos := p.tok.pos
	kind := p.tok.kind
	p.next()
	comp_kind := if kind == .gt && p.tok.kind == .eq {
		ast.CompareKind.geq
	} else if kind == .lt && p.tok.kind == .eq {
		ast.CompareKind.leq
	} else if kind == .exclam && p.tok.kind == .eq {
		ast.CompareKind.neq
	} else if kind == .ceq {
		ast.CompareKind.eq
	} else if kind == .gt {
		ast.CompareKind.gt
	} else if kind == .lt {
		ast.CompareKind.lt
	} else {
		ast.CompareKind.unknown
	}
	if comp_kind == .unknown {
		p.error('Unexpected compare kind')
		return ast.CompareExpr{}
	}
	if comp_kind in [.geq, .leq, .neq] {
		p.next()
	}
	right := p.expr()

	return ast.CompareExpr{
		pos: pos
		left: left
		right: right
		kind: comp_kind
	}
}
