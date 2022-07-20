module c

import ast

fn (mut g CGen) expr(expr ast.Expr) {
	match expr {
		ast.IdentExpr {
			g.write(expr.name)
		}
		ast.InfixExpr {
			g.expr(expr.left)
			if expr.ptr {
				g.write('->')
			} else {
				g.write('.')
			}
			g.write('$expr.name')
		}
		ast.NewExpr {
			g.new_expr(expr)
		}
		ast.CastExpr {
			g.cast_expr(expr)
		}
		ast.NumberExpr {
			g.write('Int__constructor((char*) (long) $expr.num)')
		}
		ast.CallExpr {
			g.call_expr(expr)
		}
		ast.StringExpr {
			g.write('_STR("$expr.lit", $expr.lit.len)')
		}
		ast.NegateExpr {
			g.write('!')
			g.expr(expr.expr)
		}
		ast.BracketExpr {
			g.write('(')
			g.expr(expr.expr)
			g.write(')')
		}
		ast.CompareExpr {
			g.expr(expr.left)
			str := match expr.kind {
				.eq { '==' }
				.neq { '!=' }
				.gt { '>' }
				.lt { '<' }
				.leq { '<=' }
				.geq { '>=' }
				.unknown { '' }
			}
			g.write(' $str ')
			g.expr(expr.right)
		}
		else {}
	}
}

fn (mut g CGen) new_expr(expr ast.NewExpr) {
	typ := g.typ(expr.typ)
	g.write('/*new $typ*/ ${typ}__constructor(')
	for i, param in expr.parameters {
		g.expr(param)
		if i < expr.parameters.len - 1 {
			g.write(', ')
		}
	}
	g.write(')')
}

fn (mut g CGen) call_expr(expr ast.CallExpr) {
	_, typ := g.get_base_name(expr.left_type)
	sym := g.get_table(expr.left_type).get_type_symbol(expr.left_type)
	g.write('${typ}__${expr.name}(')
	if sym.info !is ast.Pointer {
		g.write('&')
	}
	g.expr(expr.left)
	if expr.parameters.len > 0 {
		g.write(', ')
	}
	for i, param in expr.parameters {
		g.expr(param)
		if i < expr.parameters.len - 1 {
			g.write(', ')
		}
	}
	g.write(')')
}

fn (mut g CGen) cast_expr(expr ast.CastExpr) {
	table := g.get_table(expr.to)
	sym := table.get_type_symbol(expr.to)
	if table.root(sym.info) is ast.BaseClass {
		if expr.expr is ast.NumberExpr {
			num := expr.expr as ast.NumberExpr
			g.write('${g.typ(expr.to)}__constructor((char*) (long) $num.num)')
			return
		} else if expr.expr is ast.StringExpr {
			str := expr.expr as ast.StringExpr
			g.write('${g.typ(expr.to)}__constructor("$str.lit")')
			return
		}
	}

	g.write('(${g.typ(expr.to)}) ')
	g.expr(expr.expr)
}
