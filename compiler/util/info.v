module util

import token

pub enum InfoType {
	info
	warn
	error
}

pub struct Info {
pub:
	msg string
	tok token.Token
	typ InfoType
}

pub fn create_info(msg string, tok token.Token, typ InfoType) Info {
	return Info{
		msg: msg
		tok: tok
		typ: typ
	}
}

pub fn info(msg string, tok token.Token) Info {
	return create_info(msg, tok, .info)
}

pub fn warn(msg string, tok token.Token) Info {
	return create_info(msg, tok, .warn)
}

pub fn error(msg string, tok token.Token) Info {
	return create_info(msg, tok, .error)
}
