
select * from all_tables where owner = 'DEV_SCHEMA'
union
select * from all_tables where owner = 'PROD_SCHEMA';
-- test lab3 - 1
call compare_schemas('DEV_SCHEMA', 'PROD_SCHEMA');

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
    dev_cl_count number := 0;
    prod_cl_count number := 0;
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
                    return 1;
                end if;

            end loop;

        when dev_cl_count < prod_cl_count then
            for column in column_prod_name_cur loop
                column_count := 0;

                select count(*) into column_count
                from ALL_TAB_COLUMNS t
                where t.owner = dev_schema_name and t.table_name = name_of_table and t.column_name = column.column_name;


                if column_count = 0 then
                    return 1;
                end if;
            end loop;
    end case;

    return 0;
end;

drop table references_sorted;
create table references_sorted (
    id number generated always as identity primary key,
    table_name varchar2(50),
    owner varchar2(50),
    constraint_name varchar2(50),
    constraint_type varchar2(50),
    r_owner varchar2(50),
    r_constraint_name varchar2(50)
);
select distinct table_name from references_sorted;

CREATE OR REPLACE function traverse_references (name_of_table IN VARCHAR2) return varchar2
is
    next_tab varchar2(50);
    count_r number := 0;
    r_table_name varchar2(50);
    ref_owner varchar2(50);
    ref_constraint_type varchar2(50);
    ref_table_name varchar2(50);
    ref_constraint_name varchar2(50);
    ref_r_constraint_name varchar2(50);
    ref_r_owner varchar2(50);
BEGIN
            select count(*) into count_r
                from (select owner, constraint_type, table_name,  CONSTRAINT_NAME from all_constraints where CONSTRAINT_TYPE = 'R' and OWNER = 'DEV_SCHEMA' and TABLE_NAME = name_of_table);

            if count_r = 0 then
                SELECT owner, constraint_type, table_name,  CONSTRAINT_NAME into ref_owner, ref_constraint_type, ref_table_name, ref_constraint_name
                FROM all_constraints c
                WHERE c.OWNER = 'DEV_SCHEMA'
                AND c.TABLE_NAME = name_of_table and c.CONSTRAINT_TYPE = 'P';
                EXECUTE IMMEDIATE 'INSERT INTO references_sorted (table_name, owner, constraint_name, constraint_type) VALUES (''' || ref_table_name || ''', ''' || ref_owner || ''', ''' || ref_constraint_name || ''', ''' || ref_constraint_type || ''')';
                return '';
            end if;

            SELECT owner, constraint_type, table_name,  CONSTRAINT_NAME, R_CONSTRAINT_NAME, R_OWNER into ref_owner, ref_constraint_type, ref_table_name, ref_constraint_name, ref_r_constraint_name, ref_r_owner
            FROM all_constraints c
            WHERE c.OWNER = 'DEV_SCHEMA'
            AND c.TABLE_NAME = name_of_table and c.CONSTRAINT_TYPE = 'R';

            if ref_constraint_type = 'R' then
                select TABLE_NAME into next_tab
                    from ALL_CONSTRAINTS a_c where a_c.OWNER = 'DEV_SCHEMA' and CONSTRAINT_TYPE = 'P' and CONSTRAINT_NAME = ref_r_constraint_name;

                r_table_name := traverse_references(next_tab);

                EXECUTE IMMEDIATE 'INSERT INTO references_sorted (table_name, owner, constraint_name, constraint_type, r_owner, r_constraint_name) VALUES (''' || ref_table_name || ''', ''' || ref_owner || ''', ''' || ref_constraint_name || ''', ''' || ref_constraint_type || ''', ''' || ref_r_owner || ''', ''' || ref_r_constraint_name || ''')';

                return r_table_name;
            end if;
    return '';
END;

create or replace procedure arrange_order_ref(dev_schema in varchar2) as
    res varchar2(50);
begin
    for ref in (select * from ALL_CONSTRAINTS where OWNER = dev_schema)
        loop
        res := traverse_references(ref.table_name);
    end loop;
end;

CREATE OR REPLACE PROCEDURE CHECK_CYCLE(dev_schema_name VARCHAR2) AS
    amount NUMBER;
    CURSOR tab_all IS
    SELECT DISTINCT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
        ALL_CONSTRAINTS.CONSTRAINT_TYPE, ALL_IND_COLUMNS.TABLE_NAME tab1, ALL_CONSTRAINTS.TABLE_NAME tab2
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            LEFT JOIN ALL_IND_COLUMNS
            ON ALL_CONSTRAINTS.R_CONSTRAINT_NAME = ALL_IND_COLUMNS.INDEX_NAME
            WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN%')
                AND ALL_CONSTRAINTS.CONSTRAINT_TYPE = 'R'
                AND SUBSTR(ALL_CONS_COLUMNS.CONSTRAINT_NAME, 1, 1) = 'F';
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM cycle_check';
    FOR tab IN tab_all
    LOOP
        EXECUTE IMMEDIATE 'INSERT INTO CYCLE_CHECK VALUES(''' || tab.tab1 || ''', ' || '1)';
        EXECUTE IMMEDIATE 'INSERT INTO CYCLE_CHECK VALUES(''' || tab.tab2 || ''', ' || '-1)';
        SELECT COUNT(*) INTO amount FROM
            (SELECT name, sum(num) sum FROM cycle_check
                GROUP BY name)
            WHERE sum <> 0;
        IF amount = 0 THEN
            RAISE_APPLICATION_ERROR(-20343,'CYCLE IN TABLES');
        END IF;
    END LOOP;
END;


-- lab3 - 1
CREATE OR REPLACE PROCEDURE compare_schemas (
    dev_schema_name VARCHAR2,
    prod_schema_name VARCHAR2
) AS

    CURSOR sorted_tables_cur IS
        SELECT distinct t.table_name -- COUNT(*) AS fk_count
        FROM references_sorted c
            RIGHT JOIN all_tables t ON t.table_name = c.table_name AND t.owner = c.owner AND (c.constraint_type = 'R' or c.constraint_type = 'P')
        WHERE t.owner = dev_schema_name
            AND (t.owner = dev_schema_name or t.owner is null)
            AND t.table_name in (
                select d_t.TABLE_NAME
                from ALL_TABLES d_t
                where d_t.OWNER = dev_schema_name
                and compare_table(d_t.TABLE_NAME, dev_schema_name, prod_schema_name) = 1
                );

    -- Variables for holding table names and results
    table_name VARCHAR2(255);
    result VARCHAR2(4000);
    circular_count number;
BEGIN
    check_cycle('DEV_SCHEMA');
    arrange_order_ref('DEV_SCHEMA');
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
            result := 'Table ' || sorted_table.table_name || 'exists in dev schema but not in prod schema or has a different structure, also has circular references';
             -- DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        ELSE
            result := 'Table ' || sorted_table.table_name || ' exists in dev schema but not in prod schema or has a different structure';
             -- DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        END IF;

        DBMS_OUTPUT.PUT_LINE(result);
    END LOOP;

END;
