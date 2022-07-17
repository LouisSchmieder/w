
typedef struct System System;
typedef struct String String;
typedef struct Array Array;
typedef struct Int Int;
typedef struct Void Void;
typedef struct Bool Bool;
typedef struct Byte Byte;
typedef struct Main Main;
typedef struct Program Program;

struct Int {
	char data_Int[4];
};

struct Void {
	char data_Void[0];
};

struct Array {
	Int length;
	Void data;
};

struct String {
	Array bytes;
};

struct System {
	String newLine;
};

struct Bool {
	char data_Bool[1];
};

struct Byte {
	char data_Byte[1];
};

struct Program {
};

struct Main {
	Program program;
};



// -- Methods of class System --
System constructor(System* this);
Void print(String msg);
Void println(String msg);

// -- Methods of class Int --

// -- Methods of class Bool --
Bool constructor(Bool* this);

// -- Methods of class Byte --

// -- Methods of class Void --

// -- Methods of class Array --

// -- Methods of class String --
String constructor(String* this, Array bytes);

// -- Methods of class Main --
Main constructor(Main* this, Array args);
Void beginProgram();

// -- Methods of class Program --
Program constructor(Program* this);
Void begin();

System constructor(System* this) {
	System this = {};
	return this;
}

Void print(String msg) {
}

Void println(String msg) {
}

Bool constructor(Bool* this) {
	Bool this = {};
	return this;
}

String constructor(String* this, Array bytes) {
	String this = {};
	return this;
}

Main constructor(Main* this, Array args) {
	Main this = {};
	return this;
}

Void beginProgram() {
}

Program constructor(Program* this) {
	Program this = {};
	return this;
}

Void begin() {
}


