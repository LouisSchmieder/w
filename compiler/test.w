pub class Main {

    priv mut program: Program

    constructor(args: []string) {
        this.program = new Program()
    }

    beginProgram() {
        this.program.begin()
    }

}

pub class Program {

    constructor() {

    }

    begin() {
        bitField = <byte> 0x00
        b: string
        a = b
        if !(a == b) {
            system.println()
        }
    }

}