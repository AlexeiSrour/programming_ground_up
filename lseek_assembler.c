// Testing out how the lseek system call works when compiled using gcc -m32 I hope it works

#include <unistd.h>
#include <fcntl.h>

void main(int argc, char* argv[])
{
		int file = open(argv[1], O_RDWR|O_TRUNC|O_CREAT, S_IRUSR|S_IWUSR);
		off_t offset = lseek(file, 12, SEEK_END);
		_exit(offset);
}
