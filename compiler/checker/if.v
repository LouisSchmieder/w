module checker

import ast

fn (mut c Checker) if_stmt(mut node ast.IfStmt) {
	for mut branch in node.branches {
		c.check_if_branch(mut branch)
	}
}

fn (mut c Checker) check_if_branch(mut branch ast.IfBranch) {
	c.current_pos = branch.pos
	if !branch.is_else {
		typ := c.expr(branch.cond)
		if typ != c.global_table.get_type('bool') {
			c.error('Condition needs to be a boolean', c.current_pos)
			return
		}
	}
	c.stmt(branch.block)
}
