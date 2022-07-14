module checker

import token
import ast
import util

pub struct Checker {
mut:
	scope &ast.Scope
	file &ast.File
	global_table &ast.Table

	current_pos token.Position
	inside_base_class bool
}

pub fn create_checker(file &ast.File, global_table &ast.Table) &Checker {
	return &Checker{
		scope: file.scope
		file: file
		global_table: global_table
	}
}

pub fn (mut c Checker) check_file() {
	c.file.clear_infos()
	for stmt in c.file.stmts {
		c.stmt(stmt)
	}
}

pub fn (mut c Checker) stmt(node_ ast.Stmt) {
	mut node := node_
	c.current_pos = node.pos
	match mut node {
		ast.ClassStmt {
			c.class_stmt(mut node)
		}
		ast.MethodStmt {
			c.method_stmt(mut node)
		}
		ast.AssignStmt {
			// c.assign_stmt(mut node)
		}
		ast.BlockStmt {
			c.block_stmt(mut node)
		}
		else {}
	}
}

fn (mut c Checker) error(msg string, pos token.Position) {
	c.file.infos << util.error(msg, token.Token{pos: pos})
}

fn (mut c Checker) block_stmt(mut node ast.BlockStmt) {
	c.scope = node.scope

	for stmt in node.stmts {
		c.stmt(stmt)
	}

	c.scope = c.scope.parent
}

fn (mut c Checker) class_stmt(mut node ast.ClassStmt) {
	c.typ(mut node.typ)
	sym := c.type_symbol(node.typ)
	mut table := c.get_table(node.typ) or {
		return
	}

	root := table.root(sym.info)
	is_base_class := root is ast.BaseClass

	if !is_base_class {
		mut class := root as ast.Class
		for mut parent in class.parents {
			c.typ(mut parent)
		}
	}

	tmp_base_class := c.inside_base_class
	c.inside_base_class = is_base_class
	c.stmt(node.block)
	c.inside_base_class = tmp_base_class
}

fn (mut c Checker) method_stmt(mut node ast.MethodStmt) {
	c.typ(mut node.ret_typ)
	
	for mut parameter in node.parameters {
		c.current_pos =parameter.pos
		c.typ(mut parameter.typ)
	}

	c.stmt(node.block)
}
