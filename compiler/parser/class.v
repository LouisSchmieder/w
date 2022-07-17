module parser

import ast

fn (mut p Parser) parse_class(base bool, base_size int) ast.ClassStmt {
	pos := p.tok.pos
	p.next()
	name := p.name()

	mut parents := []ast.Type{}
	if !base {
		if p.tok.kind == .key_extends {
			p.next()
			for {
				parents << p.typ()
				if p.tok.kind != .comma {
					break
				}
				p.next()
			}
		}
	}

	p.open_scope()

	mut info := if base {
		ast.TypeInfo(ast.BaseClass{
			size: base_size
			access: p.access
			scope: p.scope
		})
	} else {
		ast.TypeInfo(ast.Class{
			access: p.access
			parents: parents
			scope: p.scope
		})
	}

	typ := p.file.table.add_type(name, name, info) or {
		p.error('Type $name already exists')
		return ast.ClassStmt{}
	}
	ptyp := p.file.table.add_type('&$name', 'pointer_$name', ast.Pointer{typ}) or {
		p.file.table.get_type('&$name')
	}
	p.scope.add_var(ast.create_var('this', ptyp, .priv, false))
	mut this := p.scope.get_var('this') or {
		p.error('Var `this` was not added to scope')
		return ast.ClassStmt{}
	}
	this.eic = true

	tmp_base_class := p.inside_base_class
	tmp_inside_class := p.inside_class
	tmp_class_type := p.class_type

	p.inside_base_class = base
	p.inside_class = true
	p.class_type = typ

	block := p.parse_block(true)

	p.close_scope()

	p.inside_base_class = tmp_base_class
	p.inside_class = tmp_inside_class
	p.class_type = tmp_class_type

	p.parse_alias(typ)

	return ast.ClassStmt{
		pos: pos
		typ: typ
		block: block
	}
}

fn (mut p Parser) parse_alias(typ ast.Type) {
	if p.tok.kind == .key_alias {
		p.next()
		for {
			name := p.name()
			p.file.table.add_type(name, 'alias_$name', ast.Alias{typ}) or {
				p.error('Type $name already exists')
				continue
			}
			if p.tok.kind != .comma {
				break
			}
			p.next()
		}
	}
}
