module parser

import scanner
import token
import util
import ast
import os

[heap]
pub struct ParserManager {
pub mut:
	parsers map[string]Parser
	files []&ast.File
}

pub fn create_parser_manager() ParserManager {
	return ParserManager{}
}

pub fn (mut pm ParserManager) add_parser(filepath_ string) {
	filepath := os.norm_path(filepath_)
	if filepath in pm.parsers {
		return
	}
	mut parser := create_parser(filepath, &pm) or {
		eprintln(err)
		return
	}
	pm.parsers[filepath] = parser
	parser.parse_file()
	pm.files << parser.get_file()
}

pub fn (pm ParserManager) write_errors() {
	for _, value in pm.files {
		value.write_errors()
	}
}

pub struct Parser {
mut:
	manager &ParserManager
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

pub fn create_parser(filepath string, manager &ParserManager) ?Parser {
	file := ast.create_file(filepath)
	return Parser{
		manager: manager
		scanner: scanner.create_scanner(os.read_bytes(filepath)?)
		file: file
		scope: file.scope
	}
}

fn (mut p Parser) parse_file() {
	p.next()

	p.parse_imports()

	for p.tok.kind != .eof {
		p.file.stmts << p.top_lvl() or { break }
	}
}

pub fn (p Parser) get_file() &ast.File {
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
	last := p.tok
	p.tok = p.scanner.scan_next()
	p.tok.pos.before = &last
}

fn (mut p Parser) check(kind token.TokenKind) {
	if p.tok.kind != kind {
		p.error('Unexpected token, expected `$kind` but got `$p.tok.kind`')
	}
}

fn (mut p Parser) go_before(pos token.Position) {
	p.scanner.pos = pos.before.pos
	p.tok = pos.before
	p.next()
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
	if p.tok.kind !in [.lsbr, .name] {
		return p.file.table.get_type('void')
	}
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
