#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include "crypt_blowfish-1.3/ow-crypt.h"
#include <fcntl.h>
#include "utils/array.h"
#include "catalog/pg_type.h"
#include <string.h>

PG_MODULE_MAGIC;
Datum password_in(PG_FUNCTION_ARGS);
Datum password_out(PG_FUNCTION_ARGS);
Datum password_equal(PG_FUNCTION_ARGS);

#define BCRYPT_HASHSIZE	(64)
#define RANDBYTES (16)

#define BF_INT 1
#define BF_NAME "bf"
#define BF_PREFIX "$2a$"

int encode_typmod(char algo[], int rounds)
{
	int algorithm;
	if (strcmp(algo, BF_NAME) == 0) {
		algorithm = 1;
	} else {
		ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE), errmsg("algorithm unknown")));
	}

	if (rounds < 4 || rounds > 31 || rounds == -1)
		rounds = 12; //Default

	return (algorithm << 16) | rounds;
}

void decode_typmod(int encoded, char **algorithm, int *rounds) {
	int a  = encoded >> 16;
	*rounds = encoded & 0xFFFF;

	if (a == BF_INT) {
		*algorithm = BF_NAME;
	} else {
		ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE), errmsg("algorithm unknown")));
	}
}

int random_bytes(char input[RANDBYTES])
{
	FILE *f = fopen("/dev/urandom", "r");
	if (f == NULL)
		return 1;

	size_t r = fread(input, sizeof(char), RANDBYTES, f);

	if (r < RANDBYTES)
		return 2;

	if (fclose(f) != 0)
		return 3;

	return 0;
}
int blowfish_hash(char* password, int rounds, char** output)
{
	int ret;
	char random[RANDBYTES];
	char salt[BCRYPT_HASHSIZE];
	char hash[BCRYPT_HASHSIZE];

	if(strncmp(BF_PREFIX, password, strlen(BF_PREFIX)) != 0){
		ret = random_bytes(random);
		ret = crypt_gensalt_rn(BF_PREFIX, rounds, random, RANDBYTES, salt, BCRYPT_HASHSIZE);
		ret = crypt_rn(password, salt, hash, BCRYPT_HASHSIZE);
		*output = hash;
	} else {
		*output = password;
	}

	return 0;
}
PG_FUNCTION_INFO_V1(password_in);
Datum
password_in(PG_FUNCTION_ARGS)
{
	char  *password = PG_GETARG_CSTRING(0);
	int32 typmod    = PG_GETARG_INT32(2);

	char  *hash, *algorithm;
	int ret, *rounds;

	elog(NOTICE, "TYPMOD %d", typmod);
	if (typmod == -1) {
		rounds = 12;
		algorithm = "bf";
	} else {
		decode_typmod(typmod, &algorithm, &rounds);
	}
	if (strncmp(algorithm, BF_NAME, strlen(algorithm)) == 0) {
		ret = blowfish_hash(password, rounds, &hash);
	}
	PG_RETURN_TEXT_P(cstring_to_text(hash));
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
	Datum	stored_hash	     = TextDatumGetCString(PG_GETARG_DATUM(0));
	Datum	entered_password = TextDatumGetCString(PG_GETARG_DATUM(1));

	int ret;
	char new_hash[BCRYPT_HASHSIZE];

	if(strncmp(BF_PREFIX, entered_password, strlen(BF_PREFIX)) != 0){
		ret = crypt_rn(entered_password, stored_hash, new_hash, BCRYPT_HASHSIZE);
	} else {
		memcpy(new_hash, entered_password, sizeof(entered_password));
	}
	PG_RETURN_BOOL(strcmp(stored_hash, new_hash) == 0);
}
PG_FUNCTION_INFO_V1(password_typmod_in);
Datum
password_typmod_in(PG_FUNCTION_ARGS)
{
	ArrayType *mod_arr = PG_GETARG_ARRAYTYPE_P(0);
	int32     typmod   = PG_GETARG_INT32(0);
	Datum     *values;
	int       n;

	if (ARR_ELEMTYPE(mod_arr) != CSTRINGOID)
		ereport(ERROR, (errcode(ERRCODE_ARRAY_ELEMENT_ERROR), errmsg("typmod array must be type cstring[]")));

	if (ARR_NDIM(mod_arr) != 1)
		ereport(ERROR, (errcode(ERRCODE_ARRAY_SUBSCRIPT_ERROR), errmsg("typmod array must be one-dimensional")));

	if (array_contains_nulls(mod_arr))
		ereport(ERROR, (errcode(ERRCODE_NULL_VALUE_NOT_ALLOWED), errmsg("typmod array must not contain nulls")));

	/* hardwired knowledge about cstring's representation details here */
	deconstruct_array(mod_arr, CSTRINGOID, -2, false, 'c', &values, NULL, &n);

	if (n != 2)
		ereport(ERROR, (errcode(ERRCODE_INVALID_PARAMETER_VALUE), errmsg("typmod array must contain 0 or 2 values")));

	PG_RETURN_INT32(encode_typmod(DatumGetCString(values[0]), atoi(DatumGetCString(values[1]))));
}
PG_FUNCTION_INFO_V1(password_typmod_out);
Datum
password_typmod_out(PG_FUNCTION_ARGS)
{
	int32	typmod = PG_GETARG_INT32(0);
	char output[100];
	int *rounds;
	char *algorithm;

	decode_typmod(typmod, &algorithm, &rounds);
	snprintf(output, sizeof(output), "(%s,%d)", algorithm, rounds);

	PG_RETURN_CSTRING(output);
}
