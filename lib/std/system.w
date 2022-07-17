pub class System {

    pub newLine: string

    constructor() {
        this.newLine = '\n'
    }

    print(msg: string) {

    }

    println(msg: string) {
        this.print(msg)
        this.print(this.newLine)
    }

} alias system

pub system = new System()
