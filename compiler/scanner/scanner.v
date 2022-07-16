module scanner

import token

pub struct Scanner {
mut:
	data []u8
pub mut:
	pos token.Position
}

pub fn create_scanner(data []u8) Scanner {
	return Scanner{
		data: data
	}
}

pub fn (mut s Scanner) scan_next() token.Token {
	defer {
		s.next()
	}
	mut now := s.now_o() or { return token.make_token(s.pos, '', .eof) }

	if s.should_skip(now) && s.pos.idx == 0 {
		s.next()
		now = s.now_o() or { return token.make_token(s.pos, '', .eof) }
	}

	match now {
		`.` {
			return token.make_token(s.pos, '.', token.symbols['.'])
		}
		`,` {
			return token.make_token(s.pos, ',', token.symbols[','])
		}
		`?` {
			return token.make_token(s.pos, '?', token.symbols['?'])
		}
		`!` {
			return token.make_token(s.pos, '!', token.symbols['!'])
		}
		`(` {
			return token.make_token(s.pos, '(', token.symbols['('])
		}
		`)` {
			return token.make_token(s.pos, ')', token.symbols[')'])
		}
		`{` {
			return token.make_token(s.pos, '{', token.symbols['{'])
		}
		`}` {
			return token.make_token(s.pos, '}', token.symbols['}'])
		}
		`[` {
			return token.make_token(s.pos, '[', token.symbols['['])
		}
		`]` {
			return token.make_token(s.pos, ']', token.symbols[']'])
		}
		`^` {
			return token.make_token(s.pos, '^', token.symbols['^'])
		}
		`+` {
			return token.make_token(s.pos, '+', token.symbols['+'])
		}
		`-` {
			return token.make_token(s.pos, '-', token.symbols['-'])
		}
		`/` {
			return token.make_token(s.pos, '/', token.symbols['/'])
		}
		`*` {
			return token.make_token(s.pos, '*', token.symbols['*'])
		}
		`%` {
			return token.make_token(s.pos, '%', token.symbols['%'])
		}
		`$` {
			return token.make_token(s.pos, '$', token.symbols['$'])
		}
		`\\` {
			return token.make_token(s.pos, '\\', token.symbols['\\'])
		}
		`#` {
			return token.make_token(s.pos, '#', token.symbols['#'])
		}
		`:` {
			return token.make_token(s.pos, ':', token.symbols[':'])
		}
		`&`, `|`, `=`, `>`, `<` {
			return s.check_double(now)
		}
		`'`, `"` {
			return s.s_str(now)
		}
		else {
			if s.is_number(now) {
				return s.number(now)
			} else if s.is_name(now) {
				pos := s.pos
				name := s.name(now)
				if name in token.keys {
					return token.make_token(pos, name, token.keys[name])
				}
				return token.make_token(pos, name, .name)
			}
		}
	}

	return token.make_token(s.pos, [now].bytestr(), .unknown)
}

fn (mut s Scanner) s_str(now u8) token.Token {
	pos := s.pos
	mut bytes := []u8{}
	mut last := u8(0)
	for last != now {
		if last != 0 {
			bytes << last
		}
		s.inc()
		last = s.now_o() or { break }
		if last == `\n` {
			s.nl()
		}
	}
	return token.make_token(pos, bytes.bytestr(), .str)
}

fn (mut s Scanner) number(now u8) token.Token {
	pos := s.pos
	mut bytes := [now]
	mut next := s.next_byte_o() or { return token.make_token(pos, bytes.bytestr(), .num) }
	if now == `0` {
		if next in [`x`, `X`, `b`, `B`, `o`, `O`] {
			s.next()
			bytes << next
			next = s.next_byte_o() or { return token.make_token(pos, bytes.bytestr(), .num) }
		}
	}
	for s.is_number(next) {
		s.next()
		bytes << next
		next = s.next_byte_o() or { break }
	}
	return token.make_token(pos, bytes.bytestr(), .num)
}

fn (mut s Scanner) name(now u8) string {
	mut bytes := [now]
	mut next := s.next_byte_o() or { return bytes.bytestr() }
	for s.is_name(next) || s.is_number(next) {
		s.next()
		bytes << next
		next = s.next_byte_o() or { break }
	}
	return bytes.bytestr()
}

fn (mut s Scanner) check_double(current u8) token.Token {
	pos := s.pos

	mut lit := [current].bytestr()

	next := s.next_byte_o() or { return token.make_token(pos, lit, token.symbols[lit]) }

	if next != current {
		return token.make_token(pos, lit, token.symbols[lit])
	}

	s.next()

	lit = lit.repeat(2)

	return token.make_token(pos, lit, token.symbols[lit])
}

fn (s Scanner) is_eof() bool {
	return s.pos.idx >= s.data.len
}

fn (s Scanner) now_o() ?u8 {
	if !s.is_eof() {
		return s.data[s.pos.idx]
	}
	return none
}

fn (s Scanner) now() u8 {
	return s.now_o() or { 0 }
}

fn (mut s Scanner) next() {
	s.inc()
	mut now := s.now_o() or { return }
	for s.should_skip(now) {
		s.inc()
		if now == `\n` {
			s.nl()
		}
		now = s.now_o() or { break }
	}
}

fn (mut s Scanner) inc() {
	s.pos.idx++
	s.pos.pos++
}

fn (mut s Scanner) nl() {
	s.pos.line++
	s.pos.pos = 0
}

fn (mut s Scanner) next_byte_o() ?u8 {
	defer {
		s.pos.idx--
	}
	s.pos.idx++
	return s.now_o()
}

fn (s Scanner) should_skip(now u8) bool {
	return now in [` `, `\t`, `\r`, `\n`]
}

fn (s Scanner) is_name(now u8) bool {
	return (now >= `A` && now <= `Z`) || (now >= `a` && now <= `z`) || now == `_`
}

fn (s Scanner) is_number(now u8) bool {
	return now >= `0` && now <= `9`
}

pub fn (s Scanner) str() string {
	return 'line: $s.pos.line, pos: $s.pos.pos, idx: $s.pos.idx'
}
