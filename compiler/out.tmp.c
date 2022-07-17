
typedef struct System System;
typedef System* pointer_System;
typedef System alias_system;
typedef struct Int Int;
typedef Int* pointer_Int;
typedef Int alias_int;
typedef struct Bool Bool;
typedef Bool* pointer_Bool;
typedef Bool alias_bool;
typedef struct Byte Byte;
typedef Byte* pointer_Byte;
typedef Byte alias_byte;
typedef struct Void Void;
typedef Void* pointer_Void;
typedef Void alias_void;
typedef struct Array Array;
typedef Array* pointer_Array;
typedef Array alias_array;
typedef struct String String;
typedef String* pointer_String;
typedef String alias_string;
typedef struct Main Main;
typedef Main* pointer_Main;
typedef struct Program Program;
typedef Program* pointer_Program;

struct System {
	pointer_System this;
	alias_string newLine;
};

struct Int {
	char data_Int[4];
	pointer_System this;
};

struct Bool {
	char data_Bool[1];
	pointer_System this;
};

struct Byte {
	char data_Byte[1];
	pointer_System this;
};

struct Void {
	char data_Void[0];
	pointer_System this;
};

struct Array {
	pointer_System this;
	alias_int length;
	alias_void data;
};

struct String {
	pointer_System this;
	Array bytes;
};

struct Main {
	pointer_Main this;
	Program program;
};

struct Program {
	pointer_Int this;
};



