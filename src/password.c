#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "crypt_blowfish-1.3/ow-crypt.h"
#include <fcntl.h>

PG_MODULE_MAGIC;
Datum password_in(PG_FUNCTION_ARGS);
Datum password_out(PG_FUNCTION_ARGS);
Datum password_equal(PG_FUNCTION_ARGS);

#define BCRYPT_HASHSIZE	(64)
#define RANDBYTES (16)
#define BF_PREFIX "$2a$"
#define WORK_FACTOR 12

static int try_close(int fd)
{
	int ret;
	for (;;) {
		errno = 0;
		ret = close(fd);
		if (ret == -1 && errno == EINTR)
			continue;
		break;
	}
	return ret;
}

static int try_read(int fd, char *out, size_t count)
{
	size_t total;
	ssize_t partial;

	total = 0;
	while (total < count)
	{
		for (;;) {
			errno = 0;
			partial = read(fd, out + total, count - total);
			if (partial == -1 && errno == EINTR)
				continue;
			break;
		}

		if (partial < 1)
			return -1;

		total += partial;
	}

	return 0;
}

int random_bytes(char input[RANDBYTES])
{
	int fd;
	char *ret;

	if ((fd = open("/dev/urandom", O_RDONLY)) == -1)
		return 1;

	if (try_read(fd, input, RANDBYTES) != 0) {
		if (try_close(fd) != 0)
			return 4;
		return 2;
	}

	if (try_close(fd) != 0)
		return 3;

	return 0;
}

PG_FUNCTION_INFO_V1(password_in);
Datum
password_in(PG_FUNCTION_ARGS)
{
	char	*encrypted;
	char	*password = PG_GETARG_CSTRING(0);

	int ret;
	char salt[BCRYPT_HASHSIZE];
	char hash[BCRYPT_HASHSIZE];
	char random[RANDBYTES];
  
	if(strncmp(BF_PREFIX, password, strlen(BF_PREFIX)) != 0){
		ret = random_bytes(random);
		ret = crypt_gensalt_rn(BF_PREFIX, WORK_FACTOR, random, RANDBYTES, salt, BCRYPT_HASHSIZE);
		ret = crypt_rn(password, salt, hash, BCRYPT_HASHSIZE);
		encrypted = hash; 
	} else {
		encrypted = password;
	}

	PG_RETURN_TEXT_P(cstring_to_text(encrypted));
}

PG_FUNCTION_INFO_V1(password_out);
Datum
password_out(PG_FUNCTION_ARGS)
{
	PG_RETURN_CSTRING(text_to_cstring(PG_GETARG_TEXT_P(0)));
}

PG_FUNCTION_INFO_V1(password_equal);
Datum
password_equal(PG_FUNCTION_ARGS)
{
	Datum	stored_hash	     = PG_GETARG_TEXT_P(0);
	Datum	entered_password = PG_GETARG_TEXT_P(1);

	int ret;
	char new_hash[BCRYPT_HASHSIZE];

	if(strncmp(BF_PREFIX, entered_password, strlen(BF_PREFIX)) != 0){
		ret = crypt_rn(entered_password, stored_hash, new_hash, BCRYPT_HASHSIZE);
	} else {
		memcpy(new_hash, entered_password, sizeof(entered_password));
	}
	PG_RETURN_BOOL(strcmp(stored_hash, new_hash) == 0);
}
