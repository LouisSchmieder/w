module checker

import ast

fn (mut c Checker) expr(expr_ ast.Expr) ast.Type {
	mut expr := expr_
	c.current_pos = expr.pos
	c.current_str = expr.str()

	match mut expr {
		ast.IdentExpr {
			return c.ident_expr(mut expr)
		}
		ast.StringExpr {
			return c.global_table.get_type('string')
		}
		ast.NumberExpr {
			return c.global_table.get_type('int')
		}
		ast.InfixExpr {
			return c.infix_expr(mut expr)
		}
		ast.CallExpr {
			return c.call_expr(mut expr)
		}
		ast.NewExpr {
			return c.new_expr(mut expr)
		}
		ast.CastExpr {
			return c.cast_expr(mut expr)
		}
		ast.BracketExpr {
			return c.expr(expr.expr)
		}
		ast.NegateExpr {
			typ := c.expr(expr.expr)
			return if typ == c.global_table.get_type('bool') {
				typ
			} else {
				c.void_type
			}
		}
		ast.CompareExpr {
			return c.comp_expr(mut expr)
		}
		else {
			c.error('Unknown expression `$expr`', c.current_pos)
		}
	}
	return ast.invalid
}

fn (mut c Checker) get_var(expr ast.Expr) ?&ast.Var {
	match expr {
		ast.IdentExpr {
			return c.scope.get_var(expr.name)
		}
		ast.InfixExpr {
			scope := c.get_expr_scope(expr.left)?
			return scope.get_explicit_var(expr.name)
		}
		else {
			return none
		}
	}
}

fn (mut c Checker) get_method(expr ast.Expr) ?&ast.Method {
	match expr {
		ast.IdentExpr {
			scope := c.get_expr_scope(expr)?
			mut m := scope.get_method(expr.name)?
			c.typ(mut m.return_type)
			return m
		}
		ast.InfixExpr, ast.CallExpr {
			scope := c.get_expr_scope(expr.left)?
			mut m := scope.get_explicit_method(expr.name)?
			c.typ(mut m.return_type)
			return m
		}
		ast.NewExpr {
			scope := c.get_expr_scope(expr)?
			mut m := scope.get_explicit_method('constuctor')?
			c.typ(mut m.return_type)
			return m
		}
		else {
			return none
		}
	}
}

fn (mut c Checker) get_expr_scope(expr ast.Expr) ?&ast.Scope {
	match expr {
		ast.IdentExpr {
			mut var := c.get_var(expr)?
			c.typ(mut var.typ)
			table := c.get_table(var.typ)?
			sym := c.type_symbol(var.typ)
			return table.root(sym.info).scope
		}
		ast.InfixExpr {
			mut var := c.get_var(expr)?
			c.typ(mut var.typ)
			table := c.get_table(var.typ)?
			sym := c.type_symbol(var.typ)
			return table.root(sym.info).scope
		}
		ast.NewExpr {
			table := c.get_table(expr.typ)?
			sym := c.type_symbol(expr.typ)
			return table.root(sym.info).scope
		}
		else {
			return none
		}
	}
}

fn (mut c Checker) set_ident_type(node ast.IdentExpr, typ ast.Type) {
	mut var := c.get_var(node) or { return }
	var.typ = typ
}

fn (mut c Checker) ident_expr(mut node ast.IdentExpr) ast.Type {
	mut var := c.get_var(node) or {
		c.error('Unknown ident `$node.name`', c.current_pos)
		return ast.invalid
	}
	if !var.eic && !c.add_into_content {
		c.error('Ident `$node.name` is not known in context or is not known yet', c.current_pos)
		return ast.invalid
	}
	var.eic = true
	mut typ := var.typ

	c.typ(mut typ)
	var.typ = typ
	return typ
}

fn (mut c Checker) infix_expr(mut node ast.InfixExpr) ast.Type {
	c.expr(node.left)
	mut var := c.get_var(node) or {
		c.current_str = '${node.left}.$node.name'
		c.error('Unknown field `${node.left}.$node.name`', c.current_pos)
		return ast.invalid
	}

	mut typ := var.typ
	c.typ(mut typ)
	var.typ = typ
	return typ
}

fn (mut c Checker) check_parameters(got []ast.Expr, expected []ast.MethodParameter) ? {
	if got.len != expected.len {
		c.error('Expected arguments `$expected.len` but got `$got.len`', c.current_pos)
	}

	for i, param in got {
		typ := c.expr(param)
		mut mp := expected[i]
		c.typ(mut mp.typ)
		if typ != mp.typ {
			c.error('Invalid argument `$i`, expected type is `$mp.typ.name` but got `$typ.name`',
				c.current_pos)
		}
	}
}

fn (mut c Checker) call_expr(mut node ast.CallExpr) ast.Type {
	c.expr(node.left)
	mut method := c.get_method(node) or { return c.void_type }
	c.typ(mut method.return_type)

	node.return_type = method.return_type

	c.check_parameters(node.parameters, method.parameters) or { return c.void_type }
	if node.return_type.idx == -1 {
		return c.void_type
	}
	return node.return_type
}

fn (mut c Checker) new_expr(mut node ast.NewExpr) ast.Type {
	c.typ(mut node.typ)

	mut method := c.get_method(node) or { return c.void_type }

	c.typ(mut method.return_type)

	c.check_parameters(node.parameters, method.parameters) or { return c.void_type }
	return node.typ
}

fn (mut c Checker) cast_expr(mut node ast.CastExpr) ast.Type {
	c.typ(mut node.to)
	c.expr(node.expr)

	if node.to.idx == -1 {
		return c.void_type
	}
	return node.to
}

fn (mut c Checker) comp_expr(mut node ast.CompareExpr) ast.Type {
	b := c.global_table.get_type('bool')
	if node.kind == .unknown {
		c.error('Unknown compare type', c.current_pos)
		return b
	}

	left := c.expr(node.left)
	right := c.expr(node.right)

	if left != right {
		c.error('Right has to be the same type as left', c.current_pos)
		return b
	}

	return b
}
