create or replace procedure dev_schema.dev_procedure(dev_arg1 number, dev_arg2 number) as
begin
    DBMS_OUTPUT.PUT_LINE('dev_procedure');
end;

create or replace procedure prod_schema.prod_procedure(prod_arg1 number, prod_arg2 number) as
begin
    DBMS_OUTPUT.PUT_LINE('prod_procedure');
end;

create or replace procedure dev_schema.test_procedure(dev_arg1 number, dev_arg2 number) as
begin
    DBMS_OUTPUT.PUT_LINE('test_procedure');
end;

create or replace procedure prod_schema.test_procedure(prod_arg1 number, prod_arg2 number) as
begin
    DBMS_OUTPUT.PUT_LINE('test_procedure');
end;

create or replace procedure prod_schema.only_prod_procedure(arg1 number, arg2 number) as
begin
     DBMS_OUTPUT.PUT_LINE('only_prod_procedure');
end;


DECLARE
  l_sql VARCHAR2(1000);
BEGIN
  FOR f IN (SELECT object_name
            FROM all_objects
            WHERE owner = 'DEV_SCHEMA'
            AND object_type = 'PROCEDURE')
  LOOP
    l_sql := 'DROP PROCEDURE ' || 'dev_schema.' || f.object_name;
    EXECUTE IMMEDIATE l_sql;
  END LOOP;
END;

DECLARE
  l_sql VARCHAR2(1000);
BEGIN
  FOR f IN (SELECT object_name
            FROM all_objects
            WHERE owner = 'PROD_SCHEMA'
            AND object_type = 'PROCEDURE')
  LOOP
    l_sql := 'DROP PROCEDURE ' || 'prod_schema.' || f.object_name;
    EXECUTE IMMEDIATE l_sql;
  END LOOP;
END;

SELECT ARGUMENT_NAME, DATA_TYPE, OBJECT_NAME
            FROM ALL_ARGUMENTS
            WHERE OWNER = 'PROD_SCHEMA';

SELECT ARGUMENT_NAME, DATA_TYPE, OBJECT_NAME
            FROM ALL_ARGUMENTS
            WHERE OWNER = 'DEV_SCHEMA'

