BEGIN
Timing is on.
CREATE EXTENSION
Time: 3.199 ms
CREATE EXTENSION
Time: 3.405 ms
CREATE TABLE
Time: 2.119 ms
psql:test.sql:12: NOTICE:  TYPMOD -1
LINE 2:     ('user1', 'secret1', 'secret1'),
                                 ^
psql:test.sql:12: NOTICE:  TYPMOD -1
LINE 3:     ('user2', 'secret1', 'secret1'),
                                 ^
psql:test.sql:12: NOTICE:  TYPMOD -1
INSERT 0 3
Time: 484.470 ms
psql:test.sql:22: NOTICE:  TYPMOD -1
psql:test.sql:22: NOTICE:  TYPMOD -1
INSERT 0 2
Time: 488.069 ms
psql:test.sql:29: NOTICE:  TYPMOD -1
psql:test.sql:29: NOTICE:  TYPMOD -1
INSERT 0 2
Time: 481.364 ms
psql:test.sql:38: NOTICE:  TYPMOD -1
LINE 6:     encrypted                    = 'something wrong' AS expe...
                                           ^
 username | clear_text | pgcrypt_compatible | password_equal | expected_fail |                          encrypted                           
----------+------------+--------------------+----------------+---------------+--------------------------------------------------------------
 user1    | secret1    | t                  | t              | f             | $2a$12$QYwWJA0JjLWg0OrD2ia.UeexyZRDpfqiYCFE/YffeKnnv3tvIkZAe
 user2    | secret1    | t                  | t              | f             | $2a$12$/4pV50GCRqPRvDJi1cRjde/Ilco8S2zTHVzPdlYLzyJZAggZBJGem
 user3    | secret2    | t                  | t              | f             | $2a$06$0teRYqZEWiBZAzyo21sZrudI5AXr9VKc68TI6l2b/84StZXRXfeku
 user4    | password   | t                  | t              | f             | $2a$12$cbLqLaLzjxtc6yI0xbtMF.BM0XAASDKWoqwBUoKxh1xFCG.pJGtKm
 user5    | password   | t                  | t              | f             | $2a$12$yJnBejcU.aaG/BMnXDCUpex1I4uQu/OygDFkFPMjsrzcZODxhrUiS
 user6    | password   | t                  | t              | f             | $2a$12$BbdEePmwXanIwKU4fRUwCOegT96gYYKDkZ9xoMcQmGCLwMSP427Ui
 user7    | password   | t                  | t              | f             | $2a$12$VyOdxs1DA0k.pWM2m2u74O1ctUTK2Lfr0JZ4EyukMYc9qoR1wklM6
(7 rows)

Time: 3105.451 ms
                                 List of casts
    Source type    | Target type |      Function      | Implicit? | Description 
-------------------+-------------+--------------------+-----------+-------------
 character varying | password    | (binary coercible) | yes       | 
 password          | text        | (binary coercible) | yes       | 
 text              | password    | (binary coercible) | yes       | 
(3 rows)

                               Table "public.users"
   Column   |      Type       | Modifiers | Storage  | Stats target | Description 
------------+-----------------+-----------+----------+--------------+-------------
 username   | text            |           | extended |              | 
 clear_text | text            |           | extended |              | 
 encrypted  | password(bf,14) |           | plain    |              | 

ROLLBACK
Time: 1.495 ms
