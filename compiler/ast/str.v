module ast

pub fn (expr Expr) str() string {
	match expr {
		IdentExpr {
			return '$expr.name'
		}
		InfixExpr {
			return '${expr.left}.$expr.name'
		}
		CallExpr {
			return '${expr.left}.${expr.name}(${expr.parameters.map(it.str()).join(', ')})'
		}
		EmptyExpr {
			return ''
		}
		StringExpr {
			return "'$expr.lit'"
		}
		CAndExpr {
			return ''
		}
		COrExpr {
			return ''
		}
		CompareExpr {
			return ''
		}
		NegateExpr {
			return '!$expr.expr'
		}
		BracketExpr {
			return '($expr.expr)'
		}
		NewExpr {
			return 'new ${expr.typ.name}(${expr.parameters.map(it.str()).join(', ')})'
		}
		CastExpr {
			return '<$expr.to.name> $expr.expr'
		}
		NumberExpr {
			return '$expr.num'
		}
	}
}
