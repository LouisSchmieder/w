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
System System__destructor(System* this);

// -- Methods of class Int --
Int Int__constructor(char* data_Int);
Int Int__destructor(Int* this);

// -- Methods of class Bool --
Bool Bool__constructor(char* data_Bool);
Bool Bool__destructor(Bool* this);

// -- Methods of class Byte --
Byte Byte__constructor(char* data_Byte);
Byte Byte__destructor(Byte* this);

// -- Methods of class void --

// -- Methods of class Array --
Array Array__constructor(void* data, Int length);
Array Array__destructor(Array* this);

// -- Methods of class String --
String String__constructor(Array bytes);
String String__destructor(String* this);

// -- Methods of class Main --
Main Main__constructor();
void Main__beginProgram(Main* this);
Main Main__destructor(Main* this);

// -- Methods of class Program --
Program Program__constructor();
void Program__begin(Program* this);
Program Program__destructor(Program* this);

// Constants
System system = {};

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

System System__destructor(System* this) {
}

Int Int__constructor(char* data_Int) {
	Int this = {};
	memcpy(this.data_Int, data_Int, 4);
	return this;
}

Int Int__destructor(Int* this) {
}

Bool Bool__constructor(char* data_Bool) {
	Bool this = {};
	memcpy(this.data_Bool, data_Bool, 1);
	return this;
}

Bool Bool__destructor(Bool* this) {
}

Byte Byte__constructor(char* data_Byte) {
	Byte this = {};
	memcpy(this.data_Byte, data_Byte, 1);
	return this;
}

Byte Byte__destructor(Byte* this) {
}

Array Array__constructor(void* data, Int length) {
	Array this = {};
	this.length = length;
	this.data = data;
	return this;
}

Array Array__destructor(Array* this) {
}

String String__constructor(Array bytes) {
	String this = {};
	this.bytes = bytes;
	return this;
}

String String__destructor(String* this) {
}

Main Main__constructor() {
	Main this = {};
	this.program = /*new Program*/ Program__constructor();
	return this;
}

void Main__beginProgram(Main* this) {
	Program__begin(&this->program);
}

Main Main__destructor(Main* this) {
}

Program Program__constructor() {
	Program this = {};
	return this;
}

void Program__begin(Program* this) {
	Byte bitField = Byte__constructor((char*) (long) 0x00);
	String b;
	String a = b;
}

Program Program__destructor(Program* this) {
}


int main(const char* args) {
	system = /*new System*/ System__constructor();
	Main__constructor();
}
// The end
