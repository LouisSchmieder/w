module c

import ast

fn (mut g CGen) stmt(stmt ast.Stmt) {
	match stmt {
		ast.ClassStmt {
			g.class_stmt(stmt)
		}
		ast.BlockStmt {
			g.block_stmt(stmt)
		}
		ast.MethodStmt {
			g.method_stmt(stmt)
		}
		ast.AssignStmt {
			g.assign_stmt(stmt)
		}
		ast.ExprStmt {
			g.expr(stmt.expr)
			g.writeln(';')
		}
		ast.IfStmt {
			g.if_stmt(stmt)
		}
	}
}

fn (mut g CGen) class_stmt(node ast.ClassStmt) {
	tmp_inside_class := g.inside_class
	tmp_class_type := g.class_type
	tmp_is_base_class := g.is_base_class
	g.methods.writeln('')
	g.methods.writeln('// -- Methods of class $node.typ.name --')
	g.inside_class = true
	g.is_base_class = node.base_class
	g.class_type = node.typ
	g.stmt(node.block)
	g.is_base_class = tmp_is_base_class
	g.inside_class = tmp_inside_class
	g.class_type = tmp_class_type
}

fn (mut g CGen) block_stmt(node ast.BlockStmt) {
	g.scope = node.scope
	g.scope.set_not_known_in_context()

	for stmt in node.stmts {
		g.stmt(stmt)
	}

	g.scope = g.scope.parent
}

fn (mut g CGen) method_stmt(node ast.MethodStmt) {
	ret_type := g.typ(node.ret_typ)
	mut params := []ast.MethodParameter{}
	name := '${g.typ(g.class_type)}__$node.name'
	constructor := node.name == 'constructor'
	if !constructor {
		table := g.get_table(g.class_type)
		params << ast.MethodParameter{
			name: 'this'
			typ: table.get_pointer(g.class_type)
		}
	}
	params << node.parameters
	mut parameters := params.map('${g.typ(it.typ)} $it.name')
	if constructor && g.is_base_class {
		parameters << 'char* data_$ret_type'
	}
	method := '$ret_type ${name}(${parameters.join(', ')})'

	g.methods.writeln('$method;')

	g.writeln('$method {')
	g.inc_indent()

	if constructor {
		g.writeln('${g.typ(g.class_type)} this = {};')
		if g.is_base_class {
			class := g.get_table(node.ret_typ).get_type_symbol(node.ret_typ).base_class()
			g.writeln('memcpy(this.data_$ret_type, data_$ret_type, $class.size);')
		}
	}

	tmp_inside_class := g.inside_class
	g.inside_class = false

	g.stmt(node.block)

	g.inside_class = tmp_inside_class
	if constructor {
		g.writeln('return this;')
	}
	g.dec_indent()
	g.writeln('}')
	g.writeln('')
}

fn (mut g CGen) assign_stmt(node ast.AssignStmt) {
	if g.inside_class {
		return
	}

	if node.left is ast.IdentExpr {
		mut var := g.scope.get_var((node.left as ast.IdentExpr).name) or { &ast.Var{} }
		if var.global {
			g.constants.writeln('${g.typ(var.typ)} $var.name = {};')
			tmp_current := g.current
			g.current = &g.main
			defer {
				g.current = tmp_current
			}
		}
		if !var.eic && !var.global {
			g.write('${g.typ(var.typ)} ')
			var.eic = true
		}
	}

	if !node.define {
		g.expr(node.left)
		g.writeln(';')
		return
	}
	g.expr(node.left)
	g.write(' = ')
	g.expr(node.right)
	g.writeln(';')
}

fn (mut g CGen) if_stmt(node ast.IfStmt) {
	for i, branch in node.branches {
		g.if_branch(branch)
		if node.branches.len > 1 && i < node.branches.len - 1 {
			g.write(' else ')
		}
	}
	g.writeln('')
}

fn (mut g CGen) if_branch(branch ast.IfBranch) {
	if !branch.is_else {
		g.write('if ')
	}
	g.write('(')
	g.expr(branch.cond)
	g.writeln(') {')
	g.inc_indent()
	g.stmt(branch.block)
	g.dec_indent()
	g.write('}')
}
