drop table dev_shema.customers CASCADE CONSTRAINTS;
drop table dev_shema.orders CASCADE CONSTRAINTS;
drop table prod_shema.customers CASCADE CONSTRAINTS;
drop table prod_shema.orders CASCADE CONSTRAINTS;

select * from all_tables;
select * from all_users;



CREATE TABLE customers
(
  id          NUMBER(10)   PRIMARY KEY,
  first_name  VARCHAR2(50),
  last_name   VARCHAR2(50),
  email       VARCHAR2(50) UNIQUE,
  created_at  DATE
);

CREATE TABLE dev_shema.customers
(
  id          NUMBER(10)   PRIMARY KEY,
  first_name  VARCHAR2(50),
  last_name   VARCHAR2(50),
  email       VARCHAR2(50) UNIQUE,
  created_at  DATE
);

CREATE TABLE dev_shema.orders
(
  id          NUMBER(10)   PRIMARY KEY,
  customer_id NUMBER(10)   REFERENCES dev_shema.customers(id),
  order_date  DATE,
  amount      NUMBER(10,2)
);

CREATE TABLE prod_shema.customers
(
  id          NUMBER(10)   PRIMARY KEY,
  first_name  VARCHAR2(50),
  last_name   VARCHAR2(50),
  email       VARCHAR2(50) UNIQUE,
  created_at  DATE
);

CREATE TABLE prod_shema.orders
(
  id          NUMBER(10)   PRIMARY KEY,
  customer_id NUMBER(10)   REFERENCES prod_shema.customers(id),
  order_date  DATE,
  amount      NUMBER(10,2)
);

select * from all_tables where OWNER = 'DEV_SHEMA';
select * from all_tables where owner='PROD_SHEMA';
select * from dev_shema.t10;


select * from DEV_SHEMA.T6;
create table prod_shema.t6 (
    id NUMBER(10) PRIMARY KEY,
    val varchar(10),
    time DATE,
    year number
);

select * from ALL_TAB_COLUMNS where OWNER = 'PROD_SHEMA' and TABLE_NAME = 'T1';
alter table prod_shema.t6
add time date;

select * from PROD_SHEMA.T6;

CREATE TABLE dev_shema.t10 (
    id NUMBER(10) PRIMARY KEY,
    go integer
);


alter table dev_shema.t12
add constraint fk_t12_t13_new foreign key (t13_id) references dev_shema.t13(id);


select * from ALL_CONSTRAINTS where owner = 'DEV_SHEMA';

drop table dev_shema.t13;

create table dev_shema.t13 (
    id NUMBER(10) PRIMARY KEY,
    name varchar2(50),
    t12_id number,
    constraint fk_t13_t12 FOREIGN KEY (t12_id) REFERENCES dev_shema.t12(id)
);



SELECT t.table_name, COUNT(*) AS fk_count
        FROM all_tables t
            LEFT JOIN all_constraints c ON t.table_name = c.table_name AND t.owner = c.owner AND c.constraint_type = 'R'
            LEFT JOIN all_constraints rc ON c.r_owner = rc.owner AND c.r_constraint_name = rc.constraint_name
        WHERE t.owner = 'DEV_SHEMA'
            AND (c.owner = 'DEV_SHEMA' or c.owner is null)
            AND t.table_name NOT IN (
                select table_name
                from ALL_TAB_COLUMNS d_c
                where OWNER = 'DEV_SHEMA'
                and compare_table(t.TABLE_NAME, 'DEV_SHEMA', 'PROD_SHEMA') = 1
--                 and column_name not in (
--                     select column_name from all_tab_columns h
--                     where h.owner = 'PROD_SHEMA'
--                     and h.table_name = t.table_name
--                 )
            )
        GROUP BY t.table_name
        ORDER BY fk_count;

SELECT t.table_name
        FROM all_tables t
        WHERE t.owner = 'PROD_SHEMA';

select r_owner from all_constraints where owner='DEV_SHEMA';
select * from all_tables where OWNER = 'PROD_SHEMA';
select * from ALL_TAB_COLUMNS where table_name = 'T10';

select table_name from all_tables where owner = 'PROD_SHEMA';

-- test lab3 - 1
call compare_schemas('DEV_SHEMA', 'PROD_SHEMA');

create or replace function compare_table (name_of_table varchar2, dev_schema_name varchar2, prod_schema_name varchar2)
return number
is
    cursor column_dev_name_cur is
        select column_name
        from ALL_TAB_COLUMNS t
        where t.owner = dev_schema_name
          and t.table_name = name_of_table;

    cursor column_prod_name_cur is
        select column_name
        from ALL_TAB_COLUMNS t
        where t.owner = prod_schema_name
          and t.table_name = name_of_table;

    column_count number;
    dev_cl_count number;
    prod_cl_count number;
begin
    select count(*) into dev_cl_count
        from ALL_TAB_COLUMNS t
        where t.owner = dev_schema_name and t.table_name = name_of_table;

    select count(*) into prod_cl_count
        from ALL_TAB_COLUMNS t
        where t.owner = prod_schema_name and t.table_name = name_of_table;

    case
        when dev_cl_count >= prod_cl_count then
            for column in column_dev_name_cur loop
                column_count := 0;

                select count(*) into column_count
                from ALL_TAB_COLUMNS t
                where t.owner = prod_schema_name and t.table_name = name_of_table and t.column_name = column.column_name;

                if column_count = 0 then
                    return 0;
                end if;

            end loop;

        when dev_cl_count < prod_cl_count then
            for column in column_prod_name_cur loop
                column_count := 0;

                select count(*) into column_count
                from ALL_TAB_COLUMNS t
                where t.owner = dev_schema_name and t.table_name = name_of_table and t.column_name = column.column_name;

                if column_count = 0 then
                    return 0;
                end if;
            end loop;

    end case;

    return 1;
end;


-- lab3 - 1
CREATE OR REPLACE PROCEDURE compare_schemas (
    dev_schema_name VARCHAR2,
    prod_schema_name VARCHAR2
) AS

    CURSOR sorted_tables_cur IS
        SELECT t.table_name, COUNT(*) AS fk_count
        FROM all_tables t
            LEFT JOIN all_constraints c ON t.table_name = c.table_name AND t.owner = c.owner AND c.constraint_type = 'R'
            LEFT JOIN all_constraints rc ON c.r_owner = rc.owner AND c.r_constraint_name = rc.constraint_name
        WHERE t.owner = dev_schema_name
            AND (c.owner = dev_schema_name or c.owner is null)
            AND t.table_name NOT IN (
                select table_name
                from ALL_TAB_COLUMNS d_c
                where OWNER = dev_schema_name
                and compare_table(t.table_name, dev_schema_name, prod_schema_name) = 1
            )
        GROUP BY t.table_name;

    -- Variables for holding table names and results
    table_name VARCHAR2(255);
    result VARCHAR2(4000);
    circular_count number;

BEGIN
    -- Loop through sorted tables and output the results
    FOR sorted_table IN sorted_tables_cur LOOP
        -- Check if the table has circular references
        circular_count := 0;
        SELECT COUNT(*) INTO circular_count
        FROM all_constraints c
        JOIN all_constraints rc ON c.r_owner = rc.owner AND c.r_constraint_name = rc.constraint_name
        JOIN all_tables t ON rc.owner = t.owner AND rc.table_name = t.table_name
        WHERE c.owner = dev_schema_name
        AND c.table_name = sorted_table.TABLE_NAME
        AND c.constraint_type = 'R'
        AND rc.table_name IN (
            SELECT s_c.table_name
            FROM all_constraints s_c
            JOIN all_constraints s_rc ON s_c.r_owner = s_rc.owner AND s_c.r_constraint_name = s_rc.constraint_name
            JOIN all_tables s_t ON s_rc.owner = s_t.owner AND s_rc.table_name = s_t.table_name
            WHERE s_c.owner = dev_schema_name
            AND s_rc.table_name = sorted_table.TABLE_NAME
        );

        IF circular_count > 0 THEN
            result := 'Table ' || sorted_table.table_name || ' has circular references';
        ELSE
            result := 'Table ' || sorted_table.table_name || ' exists in dev schema but not in prod schema or has a different structure';
        END IF;

        DBMS_OUTPUT.PUT_LINE(result);
    END LOOP;
END;