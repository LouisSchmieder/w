import "byte.w"

pub class String {

    priv mut bytes: []Byte

    constructor(bytes: []Byte) {
        this.bytes = bytes
    }

} alias string