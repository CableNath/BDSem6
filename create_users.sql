alter session set "_ORACLE_SCRIPT"=true;
create user DEV_SCHEMA identified by qweiop;
create user prod_schema identified by qweiop;

grant create session to dev_schema;
grant create table to dev_schema;
grant create procedure to dev_schema;
grant create trigger to dev_schema;
grant create view to dev_schema;
grant create sequence to dev_schema;
grant alter any table to dev_schema;
grant alter any procedure to dev_schema;
grant alter any trigger to dev_schema;
grant alter profile to dev_schema;
grant delete any table to dev_schema;
grant drop any table to dev_schema;
grant drop any procedure to dev_schema;
grant drop any trigger to dev_schema;
grant drop any view to dev_schema;
grant drop profile to dev_schema;

grant select on sys.v_$session to dev_schema;
grant select on sys.v_$sesstat to dev_schema;
grant select on sys.v_$statname to dev_schema;
grant SELECT ANY DICTIONARY to dev_schema;

grant create session to prod_schema;
grant create table to prod_schema;
grant create procedure to prod_schema;
grant create trigger to prod_schema;
grant create view to prod_schema;
grant create sequence to prod_schema;
grant alter any table to prod_schema;
grant alter any procedure to prod_schema;
grant alter any trigger to prod_schema;
grant alter profile to prod_schema;
grant delete any table to prod_schema;
grant drop any table to prod_schema;
grant drop any procedure to prod_schema;
grant drop any trigger to prod_schema;
grant drop any view to prod_schema;
grant drop profile to prod_schema;

grant select on sys.v_$session to prod_schema;
grant select on sys.v_$sesstat to prod_schema;
grant select on sys.v_$statname to prod_schema;
grant SELECT ANY DICTIONARY to prod_schema;