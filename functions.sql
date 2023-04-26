create or replace function dev_schema.dev_function(dev_arg1 number, dev_arg2 number) return number is
begin
    return 1;
end;

create or replace function prod_schema.prod_function(prod_arg1 number, prod_arg2 number) return number is
begin
    return 1;
end;

create or replace function dev_schema.test_function(dev_arg1 number, dev_arg2 number) return number is
begin
    return 1;
end;

create or replace function prod_schema.test_function(prod_arg1 number, prod_arg2 number) return number is
begin
    return 1;
end;

create or replace function prod_schema.only_prod(arg1 number, arg2 number) return number is
begin
    return 1;
end;

create or replace function prod_schema.buf_function(arg number) return number is
begin
    return 1;
end;

create or replace function dev_schema.buf_function(arg number) return number is
begin
    return 2;
end;

DECLARE
  l_sql VARCHAR2(1000);
BEGIN
  FOR f IN (SELECT object_name
            FROM all_objects
            WHERE owner = 'PROD_SCHEMA'
            AND object_type = 'FUNCTION')
  LOOP
    l_sql := 'DROP FUNCTION ' || 'prod_schema.'|| f.object_name;
    EXECUTE IMMEDIATE l_sql;
  END LOOP;
END;

DECLARE
  l_sql VARCHAR2(1000);
BEGIN
  FOR f IN (SELECT object_name
            FROM all_objects
            WHERE owner = 'DEV_SCHEMA'
            AND object_type = 'FUNCTION')
  LOOP
    l_sql := 'DROP FUNCTION ' || 'dev_schema.'|| f.object_name;
    EXECUTE IMMEDIATE l_sql;
  END LOOP;
END;

SELECT ARGUMENT_NAME, DATA_TYPE, OBJECT_NAME
            FROM ALL_ARGUMENTS
            WHERE OWNER = 'PROD_SCHEMA';

SELECT ARGUMENT_NAME, DATA_TYPE, OBJECT_NAME
            FROM ALL_ARGUMENTS
            WHERE OWNER = 'DEV_SCHEMA';