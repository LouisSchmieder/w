module c

import ast

fn (mut g CGen) stmt(stmt ast.Stmt) {
	match stmt {
		ast.ClassStmt {
			g.class_stmt(stmt)
		}
		else {}
	}
}

fn (mut g CGen) class_stmt(node ast.ClassStmt) {
	g.stmt(node.block)
}
