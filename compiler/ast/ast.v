module ast

import token

pub type Stmt = AssignStmt | ClassStmt | MethodStmt | ExprStmt | BlockStmt | IfStmt

pub type Expr = IdentExpr | InfixExpr | CallExpr | EmptyExpr | StringExpr | CAndExpr | COrExpr | CompareExpr | NegateExpr | BracketExpr

pub struct ClassStmt {
pub:
	pos token.Position
pub mut:
	typ Type
	block BlockStmt
}

pub struct MethodStmt {
pub:
	pos token.Position
	name string
	parameters []MethodParameter
pub mut:
	ret_typ Type
	block BlockStmt
}

pub struct ExprStmt {
pub:
	pos token.Position
	expr Expr
}

pub struct BlockStmt {
pub:
	pos token.Position
	stmts []Stmt
	scope &Scope
}

pub struct AssignStmt {
pub:
	pos token.Position
	left Expr
	left_type Type
	right Expr
	right_type Type
	define bool
}

pub struct IfStmt {
pub:
	pos token.Position
	branches []IfBranch
}

pub struct IfBranch {
pub:
	pos token.Position
	cond Expr
	is_else bool
	block BlockStmt
}

pub struct CallExpr {
pub:
	pos token.Position
	base Expr
	return_type Type
	parameters []Expr
}

pub struct IdentExpr {
pub:
	pos token.Position
	name string
}

pub struct InfixExpr {
pub:
	pos token.Position
	left Expr
	name string
}

pub struct EmptyExpr {
pub:
	pos token.Position
}

pub struct StringExpr {
pub:
	pos token.Position
	lit string
}

pub struct CAndExpr {
pub:
	pos token.Position
	exprs []Expr
}

pub struct COrExpr {
pub:
	pos token.Position
	exprs []Expr
}

pub enum CompareKind {
	eq // ==
	neq // !=
	gt // >
	lt // <
	leq // <=
	geq // >=
	unknown
}

pub struct CompareExpr {
pub:
	pos token.Position
	kind CompareKind
	left Expr
	right Expr
}

pub struct NegateExpr {
pub:
	pos token.Position
	expr Expr
}

pub struct BracketExpr {
pub:
	pos token.Position
	expr Expr
}

pub struct MethodParameter {
pub:
	pos token.Position
	name string
pub mut:
	typ Type
}
/*
pub fn (class ClassStmt) str() string {
	return 'class $class.typ.name'
}

pub fn (method MethodStmt) str() string {
	parameters := method.parameters.map(it.str()).join(', ')
	return '${method.name}($parameters)'
}

pub fn (para MethodParameter) str() string {
	return '$para.name: $para.typ.name'
}
*/
