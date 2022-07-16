module token

pub struct Position {
pub mut:
	before &Token = unsafe { nil }
	line   int
	idx    int
	pos    int
}

pub fn new_pos(line int, pos int) Position {
	return Position{
		line: line
		pos: pos
	}
}
