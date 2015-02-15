BEGIN;

\timing on

CREATE EXTENSION password;
CREATE EXTENSION pgcrypto; -- used to test compatibility betwen password extension <-> pgcrypto

CREATE TABLE users (username text, clear_text text, encrypted password);
INSERT INTO users (username, clear_text, encrypted) VALUES
    ('user1', 'secret1', 'secret1'),
    ('user2', 'secret1', 'secret1'),
    ('user3', 'secret2', crypt('secret2', gen_salt('bf')));

INSERT INTO users (username, clear_text, encrypted)
    SELECT
        username,
        clear_text,
        password
    FROM (VALUES
        ('user4', 'password', 'password'),
        ('user5', 'password', 'password')
    ) g(username, clear_text, password);

INSERT INTO users (username, clear_text, encrypted)
    SELECT
        'user' || g,
        'password',
        'password'
    FROM generate_series(6, 7) g;

select
    username,
    clear_text,
    crypt(clear_text, encrypted) = encrypted::text   AS pgcrypt_compatible,
    encrypted                    = clear_text        AS password_equal,
    encrypted                    = 'something wrong' AS expected_fail,
    encrypted
from users;

\dC+ *password*
ROLLBACK;
