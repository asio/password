BEGIN
Timing is on.
CREATE EXTENSION
Time: 3.083 ms
CREATE EXTENSION
Time: 3.319 ms
CREATE TABLE
Time: 2.127 ms
INSERT 0 3
Time: 479.299 ms
INSERT 0 2
Time: 472.811 ms
INSERT 0 2
Time: 237.248 ms
 username | clear_text | pgcrypt_compatible | password_equal | expected_fail |                          encrypted                           
----------+------------+--------------------+----------------+---------------+--------------------------------------------------------------
 user1    | secret1    | t                  | t              | f             | $2a$12$UWQq6.nifud2TCGoSBh4oe/C/jDuQsPAE3lso1kLI9Uoy8Qgq2.6.
 user2    | secret1    | t                  | t              | f             | $2a$12$p3VxQdc/YH.XqTDw2.X7n.xTVpswSyJL69GE4K9zWtTee4f1V.n.K
 user3    | secret2    | t                  | t              | f             | $2a$06$SzS1bfM/MXvaHQqL4avcueKg86gs8Ufe5q9E5fCfYUz7AXDnVCD2O
 user4    | password   | t                  | t              | f             | $2a$12$nBq8v6yvKe6lqFmNAxwMfe8dU7pS0kXx35kSTM9/bbxxZMHA.otEa
 user5    | password   | t                  | t              | f             | $2a$12$5lclLl8MIkfERK3QLa21me6FbmsgcO8N9BCgOqUVYgVajte3khrSa
 user6    | password   | t                  | t              | f             | $2a$12$8rFiPUvIGcJ5lBUyn2PJ5uwKFzqsmXWjLDbDgG2sBolmFrp6FXIMS
 user7    | password   | t                  | t              | f             | $2a$12$8rFiPUvIGcJ5lBUyn2PJ5uwKFzqsmXWjLDbDgG2sBolmFrp6FXIMS
(7 rows)

Time: 3085.346 ms
                                 List of casts
    Source type    | Target type |      Function      | Implicit? | Description 
-------------------+-------------+--------------------+-----------+-------------
 character varying | password    | (binary coercible) | yes       | 
 password          | text        | (binary coercible) | yes       | 
 text              | password    | (binary coercible) | yes       | 
(3 rows)

ROLLBACK
Time: 1.794 ms
