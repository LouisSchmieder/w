module ast

import token

pub type Stmt = AssignStmt | BlockStmt | ClassStmt | ExprStmt | IfStmt | MethodStmt

pub type Expr = BracketExpr
	| CAndExpr
	| COrExpr
	| CallExpr
	| CastExpr
	| CompareExpr
	| EmptyExpr
	| IdentExpr
	| InfixExpr
	| NegateExpr
	| NewExpr
	| NumberExpr
	| StringExpr

pub struct ClassStmt {
pub:
	pos token.Position
pub mut:
	typ   Type
	block BlockStmt
}

pub struct MethodStmt {
pub:
	pos        token.Position
	name       string
	parameters []MethodParameter
pub mut:
	ret_typ Type
	block   BlockStmt
}

pub struct ExprStmt {
pub:
	pos  token.Position
	expr Expr
}

pub struct BlockStmt {
pub:
	pos   token.Position
	stmts []Stmt
	scope &Scope
}

pub struct AssignStmt {
pub:
	pos    token.Position
	define bool
pub mut:
	left       Expr
	left_type  Type
	right      Expr
	right_type Type
}

pub struct IfStmt {
pub:
	pos      token.Position
	branches []IfBranch
}

pub struct IfBranch {
pub:
	pos     token.Position
	cond    Expr
	is_else bool
	block   BlockStmt
}

pub struct CallExpr {
pub mut:
	return_type Type
pub:
	pos        token.Position
	left       Expr
	name       string
	parameters []Expr
}

pub struct CastExpr {
pub mut:
	to Type
pub:
	pos  token.Position
	expr Expr
}

pub struct NewExpr {
pub mut:
	typ Type
pub:
	pos        token.Position
	parameters []Expr
}

pub struct IdentExpr {
pub:
	pos  token.Position
	name string
}

pub struct InfixExpr {
pub:
	pos  token.Position
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

pub struct NumberExpr {
pub:
	pos token.Position
	num string
}

pub struct CAndExpr {
pub:
	pos   token.Position
	exprs []Expr
}

pub struct COrExpr {
pub:
	pos   token.Position
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
	pos   token.Position
	kind  CompareKind
	left  Expr
	right Expr
}

pub struct NegateExpr {
pub:
	pos  token.Position
	expr Expr
}

pub struct BracketExpr {
pub:
	pos  token.Position
	expr Expr
}

pub struct MethodParameter {
pub:
	pos  token.Position
	name string
pub mut:
	typ Type
}

