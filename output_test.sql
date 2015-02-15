BEGIN
Timing is on.
CREATE EXTENSION
Time: 3.100 ms
CREATE EXTENSION
Time: 3.384 ms
CREATE TABLE
Time: 2.433 ms
INSERT 0 3
Time: 477.648 ms
INSERT 0 2
Time: 472.208 ms
INSERT 0 2
Time: 236.587 ms
 username | clear_text | pgcrypt_compatible | password_equal | expected_fail |                          encrypted                           
----------+------------+--------------------+----------------+---------------+--------------------------------------------------------------
 user1    | secret1    | t                  | f              | f             | $2a$12$gejGaV.hTPm4Y2Sart1uFuI5sF4MFXWuqqs/nZkkZ4A/dG/r5Yq1u
 user2    | secret1    | t                  | f              | f             | $2a$12$h6CmLniXUjr1pa37k.WTXOGdJNKeSGhqsi/rldmTNiIGeHPh0smtO
 user3    | secret2    | t                  | f              | f             | $2a$06$yC/kIxJpWy8d3g6j5VzFB./FGEIxuARcmU9Y9kqEL4W4iTqfMuVVm
 user4    | password   | t                  | f              | f             | $2a$12$YzC2o5aP/.QIymVBzvX7Uetibbx0HhklWzBmj2qJ6sBLC1reOVb6e
 user5    | password   | t                  | f              | f             | $2a$12$504B87PVaikZyJCdAOE/kuEUVC3T6l.RoWu86tFRstjMdkLVZVlhu
 user6    | password   | t                  | f              | f             | $2a$12$ng.tTGeCGcyORjKmwb2KLur/NoH4WC/uWVp41b3cpFoV.vOHaOD8.
 user7    | password   | t                  | f              | f             | $2a$12$ng.tTGeCGcyORjKmwb2KLur/NoH4WC/uWVp41b3cpFoV.vOHaOD8.
(7 rows)

Time: 1652.958 ms
                                 List of casts
    Source type    | Target type |      Function      | Implicit? | Description 
-------------------+-------------+--------------------+-----------+-------------
 character varying | password    | (binary coercible) | yes       | 
 password          | text        | (binary coercible) | yes       | 
 text              | password    | (binary coercible) | yes       | 
(3 rows)

ROLLBACK
Time: 1.529 ms
