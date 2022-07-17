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
		else {}
	}
}

fn (mut g CGen) class_stmt(node ast.ClassStmt) {
	tmp_inside_class := g.inside_class
	tmp_class_type := g.class_type
	g.methods.writeln('')
	g.methods.writeln('// -- Methods of class $node.typ.name --')
	g.inside_class = true
	g.class_type = node.typ
	g.stmt(node.block)
	g.inside_class = tmp_inside_class
	g.class_type = tmp_class_type
}

fn (mut g CGen) block_stmt(node ast.BlockStmt) {
	g.scope = node.scope

	for stmt in node.stmts {
		g.stmt(stmt)
	}

	g.scope = g.scope.parent
}

fn (mut g CGen) method_stmt(node ast.MethodStmt) {
	ret_type := g.typ(node.ret_typ)
	mut params := []ast.MethodParameter{}
	constructor := node.name == 'constructor'
	if constructor {
		table := g.get_table(g.class_type)
		params << ast.MethodParameter{
			name: 'this'
			typ: table.get_pointer(g.class_type)
		}
	}
	params << node.parameters
	parameters := params.map('${g.typ(it.typ)} $it.name').join(', ')
	method := '$ret_type ${node.name}($parameters)'

	g.methods.writeln('$method;')

	g.writeln('$method {')
	g.indent++

	if constructor {	
		g.writeln('${g.typ(g.class_type)} this = {};')
	}

	tmp_inside_class := g.inside_class
	g.inside_class = false

	g.stmt(node.block)

	g.inside_class = tmp_inside_class
	if constructor {
		g.writeln('return this;')
	}
	g.indent--
	g.writeln('}')
	g.writeln('')
}
