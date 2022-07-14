module token

pub struct Token {
pub mut:
	pos  Position
pub:
	lit  string
	kind TokenKind
}

pub fn (token Token) str() string {
	return '$token.lit ($token.kind) [$token.pos.line:$token.pos.pos]'
}

pub fn make_token(pos Position, lit string, kind TokenKind) Token {
	return Token{
		pos: pos
		lit: lit
		kind: kind
	}
}

pub enum TokenKind {
	eof
	unknown
	name
	str
	num
	dot // .
	ddot // :
	comma // ,
	quest // ?
	exclam // !
	lbr // (
	rbr // )
	lcbr // {
	rcbr // }
	lsbr // [
	rsbr // ]
	// Conditionals
	cand // &&
	cor // ||
	ceq // ==	
	gt // >
	lt // <
	// Bitwise
	band // &
	bor // |
	xor // ^
	lshift // <<
	rshift // >>
	// Math
	eq // =
	plus // +
	minus // -
	div // /
	mult // *
	mod // %
	// Extra symbols
	dollar // $
	back // \
	hash // #
	// Keys
	// Modifiers
	key_pub // pub
	key_priv
	key_mut // mut
	key_prot // prot
	key_alias // alias
	key_base // base
	key_extends // extends
	// Top Level
	key_class // class
	key_import // import
	// Others
	key_constructor // constructor
	key_destructor // destructor
	key_return // return
	key_if // if
	key_else // else
	key_match // match
	key_for // for
	key_new // new
}

pub const (
	keys = {
		'pub':         TokenKind.key_pub
		'priv':        TokenKind.key_priv
		'prot':        TokenKind.key_prot
		'mut':         TokenKind.key_mut
		'class':       TokenKind.key_class
		'import':      TokenKind.key_import
		'constructor': TokenKind.key_constructor
		'destructor':  TokenKind.key_destructor
		'if':          TokenKind.key_if
		'else':        TokenKind.key_else
		'match':       TokenKind.key_match
		'for':         TokenKind.key_for
		'alias':       TokenKind.key_alias
		'base':        TokenKind.key_base
		'extends':     TokenKind.key_extends
		'new':         TokenKind.key_new
		'return':      TokenKind.key_return
	}
	symbols = {
		'.':  TokenKind.dot
		',':  TokenKind.comma
		'?':  TokenKind.quest
		'!':  TokenKind.exclam
		'(':  TokenKind.lbr
		'{':  TokenKind.lcbr
		'[':  TokenKind.lsbr
		')':  TokenKind.rbr
		'}':  TokenKind.rcbr
		']':  TokenKind.rsbr
		'&&': TokenKind.cand
		'||': TokenKind.cor
		'>':  TokenKind.gt
		'<':  TokenKind.lt
		'&':  TokenKind.band
		'|':  TokenKind.bor
		'^':  TokenKind.xor
		'<<': TokenKind.lshift
		'>>': TokenKind.rshift
		'=':  TokenKind.eq
		'==': TokenKind.ceq
		'+':  TokenKind.plus
		'-':  TokenKind.minus
		'/':  TokenKind.div
		'*':  TokenKind.mult
		'%':  TokenKind.mod
		'$':  TokenKind.dollar
		'\\': TokenKind.back
		'#':  TokenKind.hash
		':':  TokenKind.ddot
	}
)
