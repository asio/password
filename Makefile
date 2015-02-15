EXTENSION    = $(shell grep -m 1 '"name":' META.json | \
               sed -e 's/[[:space:]]*"name":[[:space:]]*"\([^"]*\)",/\1/')
EXTVERSION   = $(shell grep -m 1 '[[:space:]]\{8\}"version":' META.json | \
               sed -e 's/[[:space:]]*"version":[[:space:]]*"\([^"]*\)",\{0,1\}/\1/')
MODULE_big   = password
OBJS         = src/password.o src/crypt_blowfish-1.3/x86.o src/crypt_blowfish-1.3/wrapper.o src/crypt_blowfish-1.3/crypt_blowfish.o src/crypt_blowfish-1.3/crypt_gensalt.o
DATA         = sql/password--0.0.1.sql
REGRESS      = password
PG_CONFIG    = pg_config

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
