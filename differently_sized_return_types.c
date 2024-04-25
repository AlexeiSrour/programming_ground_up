// The purpose of this c file is to compile down a list of 3 functions that return differently
// sized return values. The SysV ABI (the C calling convention adhere's to this) states that
// amongst the registers, [e]ax is a return register (amongst other things). To validate this,
// three functions returning a basic int, a struct of 2 ints, and a struct of 5 ints will be
// defined and compiled

int basic_32bit_return(int a)
{
		int return_val;
		return_val = a*5;
		return return_val;
};

typedef struct double_int
{
		int a;
		int b;
} double_int;

double_int basic_64bit_return(int a)
{
		double_int return_val;
		return_val.a = a*5;
		return_val.b = a*5*4;

		return return_val;
}

typedef struct quintuple_int
{
		int a;
		int b;
		int c;
		int d;
		int e;
} quintuple_int;

quintuple_int basic_huge_return(int a)
{
		quintuple_int return_val;
		return_val.a = a*5;
		return_val.b = a*5*4;
		return_val.c = a*5*4*3;
		return_val.d = a*5*4*3*2;
		return_val.e = a*5*4*3*2*1;

		return return_val;
};

int main(int argc, char* argv[])
{
		int a = basic_32bit_return(1);
		double_int b = basic_64bit_return(1);
		quintuple_int c = basic_huge_return(1);

		int output_val = a * b.a * c.a;
		
		return output_val;
}
