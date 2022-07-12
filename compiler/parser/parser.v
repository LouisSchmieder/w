module parser

import scanner
import token
import util
import ast
import os

pub struct Parser {
mut:
	scanner scanner.Scanner
	tok     token.Token
	file    &ast.File
	scope   &ast.Scope

	inside_base_class bool
	inside_class bool
	access ast.AccessType
	mutable bool
	class_type ast.Type
}

pub fn create_parser(filepath string) ?Parser {
	file := ast.create_file(filepath)
	return Parser{
		scanner: scanner.create_scanner(os.read_bytes(filepath)?)
		file: file
		scope: file.scope
	}
}

pub fn (mut p Parser) parse_file() &ast.File {
	p.next()

	for p.tok.kind != .eof {
		p.file.stmts << p.top_lvl() or { break }
	}

	return p.file
}

fn (mut p Parser) error(msg string) {
	p.file.infos << util.error(msg, p.tok)
}

fn (mut p Parser) warn(msg string) {
	p.file.infos << util.warn(msg, p.tok)
}

fn (mut p Parser) info(msg string) {
	p.file.infos << util.info(msg, p.tok)
}

fn (mut p Parser) next() {
	p.tok = p.scanner.scan_next()
}

fn (mut p Parser) check(kind token.TokenKind) {
	if p.tok.kind != kind {
		p.error('Unexpected token, expected `$kind` but got `$p.tok.kind`')
	}
}

fn (mut p Parser) open_scope() {
	scope := ast.create_scope(p.scope)
	p.scope = scope
}

fn (mut p Parser) close_scope() {
	p.scope = p.scope.parent
}

fn (mut p Parser) name() string {
	p.check(.name)
	defer {
		p.next()
	}
	return p.tok.lit
}

fn (mut p Parser) number() string {
	p.check(.num)
	defer {
		p.next()
	}
	return p.tok.lit
}

fn (mut p Parser) typ() ast.Type {
	mut arr := false
	mut len := ''
	if p.tok.kind == .lsbr {
		p.next()
		arr = true
		if p.tok.kind == .num {
			len = p.number()
		}
		p.check(.rsbr)
		p.next()
	}
	mut name := p.name()
	if arr {
		if len.len > 0 {
			name = '[$len]$name'
		} else {
			name = '[]$name'
		}
	}
	return p.file.table.get_type(name)
}
