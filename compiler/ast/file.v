module ast

import util
import term
import os

[heap]
pub struct File {
pub mut:
	filepath string
	scope    &Scope
	table    &Table
	stmts    []Stmt
	infos    []util.Info
}

pub fn create_file(filepath string) &File {
	return &File{
		filepath: filepath
		scope: create_top_scope()
		table: create_table()
	}
}

pub fn (mut file File) clear_infos() {
	file.infos.clear()
}

pub fn (file File) write_errors() {
	raw := os.read_file(file.filepath) or { '' }
	lines := raw.split_into_lines()
	for err in file.infos.filter(it.typ == .error) {
		if err.tok.pos.line >= lines.len {
			continue
		}
		tok := err.tok
		line := tok.pos.line
		mut data := []string{}
		data << '${term.gray(file.filepath)}:$line:$tok.pos.pos: ${term.red(term.bold('error:'))} ${term.red(err.msg)}'
		if line > 1 {
			data << '${line - 2:5} | ${lines[line - 2]}'
			data << '${line - 1:5} | ${lines[line - 1]}'
		} else if line == 1 {
			data << '${line - 1:5} | ${lines[line - 1]}'
		}

		ld := lines[line]

		b := ld[..tok.pos.pos]
		r := ld[tok.pos.pos + tok.lit.len..]

		res := b + term.red(tok.lit) + r
		data << '${line:5} | $res'

		data << '      | ' + ' '.repeat(tok.pos.pos) + term.red('~'.repeat(tok.lit.len))

		if line < lines.len - 2 {
			data << '${line + 1:5} | ${lines[line + 1]}'
			data << '${line + 2:5} | ${lines[line + 2]}'
		} else if line < lines.len - 1 {
			data << '${line + 1:5} | ${lines[line + 1]}'
		}
		eprintln(data.join('\n'))
	}
}
