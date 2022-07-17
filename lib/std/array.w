pub class Array {

    priv mut length: int
    priv mut data: &void

    constructor(data: &void, length: int) {
        this.length = length
        this.data = data
    }

} alias array