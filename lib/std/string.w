import "byte.w"

pub class String extends Byte {

    priv mut bytes: []Byte

    constructor(bytes: []Byte) {
        this.bytes = bytes
    }

} alias string