# repro-pg-behavior-out-parameters
Repository holding code to reproduce unexpected behavior found with user defined functions with out parameters

I've found that in postgresql 9.3.10, when a user defined function has
out parameters, it is invoked once per out parameter if invoked with the
syntax:

`SELECT (udf()).*`

This syntax is desireable because it is the only way I've found so far to
get the postgresql engine to return all of the out parameters together
as a row, together with the parameters type information, instead of
returning the out parameters together as the text representation of
the composite type that they form together.

To demonstrate, take the function as follows:
```
CREATE FUNCTION demo(
  OUT param1 text,
  OUT param2 text,
  OUT param3 text
) AS $$
BEGIN
  param1 := 'foo';
  param2 := 'bar';
  param3 := 'baz';
END;
$$ LANGUAGE plpgsql
```

The query `SELECT demo();` produces the result
```
testdb=# SELECT demo();
     demo      
---------------
 (foo,bar,baz)
(1 row)
```
Whereas the query `SELECT (demo()).*` produce the result
```
testdb=# SELECT (demo()).*;
 param1 | param2 | param3 
--------+--------+--------
 foo    | bar    | baz
(1 row)
```

I've yet to find another means to get postgresql to produce the result
in such a form.

Unfortunately, I've found that the `SELECT (udf()).*` form executes the
udf once per out parameter.  This is undesireable for both performance
reasons and unacceptable for functions that cause side effects.  To
demonstrate that this is happening I've created another function in
reproduceBehavior.sql

Behavior occurs on:
PostgreSQL 9.3.10 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3, 64-bit

and

 PostgreSQL 9.4.5 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3, 64-bit


Bug has been posted to pg-bugs on 12/5/15 and assigned #13799

