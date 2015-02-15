CREATE TYPE password;

CREATE FUNCTION password_in(cstring)
RETURNS password
AS 'MODULE_PATHNAME'
LANGUAGE C VOLATILE STRICT;

CREATE FUNCTION password_out(password)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION password_equal(password, text)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION password_equal(password, varchar)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION password_equal(password, password)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE password (
    INPUT          = password_in,
    OUTPUT         = password_out
);

CREATE OPERATOR = (
    leftarg   = password,
    rightarg  = text,
    procedure = password_equal
);
CREATE OPERATOR = (
    leftarg   = password,
    rightarg  = varchar,
    procedure = password_equal
);
CREATE OPERATOR = (
    leftarg   = password,
    rightarg  = password,
    procedure = password_equal
);

CREATE CAST (password AS text) WITH INOUT AS IMPLICIT;
CREATE CAST (text AS password) WITH INOUT AS IMPLICIT;
CREATE CAST (varchar AS password) WITH INOUT AS IMPLICIT;
