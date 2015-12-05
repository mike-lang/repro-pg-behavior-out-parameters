CREATE TABLE test (
  i integer
);

INSERT into test (i) VALUES (0);

CREATE FUNCTION reproduceBehavior(
  OUT message1 text,
  OUT message2 text,
  OUT message3 text,
  OUT message4 text
)
AS $$
DECLARE t integer;
BEGIN
  SELECT i INTO t FROM test limit 1;
  IF t = 0 THEN
    update test set i=1;
    message1 := 'The value of i is now 1';
  END IF;
  IF t = 1 THEN
    update test set i=2;
    message2 := 'The value of i is now 2';
  END IF;
  IF t = 2 THEN
    update test set i=3;
    message3 := 'The value of i is now 3';
  END IF;
  IF t = 3 THEN
    update test set i=4;
    message4 := 'The value of i is now 4';
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql
