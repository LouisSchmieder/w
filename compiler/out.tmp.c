#include <string.h>
#define _STR(str, len) String__constructor(Array__constructor(str, Int__constructor((char*)(long)len)))

typedef struct System System;
typedef struct String String;
typedef struct Array Array;
typedef struct Int Int;
typedef struct Bool Bool;
typedef struct Byte Byte;
typedef struct Main Main;
typedef struct Program Program;

struct Int {
	char data_Int[4];
};

struct Array {
	Int length;
	void* data;
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
System System__constructor();
void System__print(System* this, String msg);
void System__println(System* this, String msg);

// -- Methods of class Int --
Int Int__constructor(char* data_Int);

// -- Methods of class Bool --
Bool Bool__constructor(char* data_Bool);

// -- Methods of class Byte --

// -- Methods of class void --

// -- Methods of class Array --
Array Array__constructor(void* data, Int length);

// -- Methods of class String --
String String__constructor(Array bytes);

// -- Methods of class Main --
Main Main__constructor(Array args);
void Main__beginProgram(Main* this);

// -- Methods of class Program --
Program Program__constructor();
void Program__begin(Program* this);

System System__constructor() {
	System this = {};
	this.newLine = _STR("\n", 2);
	return this;
}

void System__print(System* this, String msg) {
}

void System__println(System* this, String msg) {
	System__print(this, msg);
	System__print(this, this->newLine);
}

System system = /*new System*/ System__constructor();
Int Int__constructor(char* data_Int) {
	Int this = {};
	memcpy(this.data_Int, data_Int, 4);
	return this;
}

Bool Bool__constructor(char* data_Bool) {
	Bool this = {};
	memcpy(this.data_Bool, data_Bool, 1);
	return this;
}

Array Array__constructor(void* data, Int length) {
	Array this = {};
	this.length = length;
	this.data = data;
	return this;
}

String String__constructor(Array bytes) {
	String this = {};
	this.bytes = bytes;
	return this;
}

Main Main__constructor(Array args) {
	Main this = {};
	this.program = /*new Program*/ Program__constructor();
	return this;
}

void Main__beginProgram(Main* this) {
	Program__begin(&this->program);
}

Program Program__constructor() {
	Program this = {};
	return this;
}

void Program__begin(Program* this) {
	Byte bitField = (Byte) Int__constructor((char*) (long) 0x00);
	String b;
	String a = b;
	if (!(a == b)) {
		System__println(&system, _STR("test", 4));
	}
}


