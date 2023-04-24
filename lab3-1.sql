
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
        WHERE t.owner = prod_schema_name
            AND (c.owner = prod_schema_name or c.owner is null)
            AND t.table_name in (
                select d_t.TABLE_NAME
                from ALL_TABLES d_t
                where d_t.OWNER = dev_schema_name
                and compare_table(d_t.TABLE_NAME, dev_schema_name, prod_schema_name) = 1
                )
        GROUP BY t.table_name;

    cursor sorted_tables_cur_only_dev is
        SELECT t.table_name, COUNT(*) as fk_count
        FROM all_tables t
        LEFT JOIN all_constraints c ON t.table_name = c.table_name AND t.owner = c.owner AND c.constraint_type = 'R'
        LEFT JOIN all_constraints rc ON c.r_owner = rc.owner AND c.r_constraint_name = rc.constraint_name
        WHERE t.owner = dev_schema_name
            AND (c.owner = dev_schema_name or c.owner is null)
            AND t.table_name not in (
                select table_name
                from all_tables d_c
                where OWNER = 'PROD_SCHEMA'
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
            result := 'Table ' || sorted_table.table_name || 'exists in dev schema but not in prod schema or has a different structure, also has circular references';
             -- DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        ELSE
            result := 'Table ' || sorted_table.table_name || ' exists in dev schema but not in prod schema or has a different structure';
             -- DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        END IF;

        DBMS_OUTPUT.PUT_LINE(result);
    END LOOP;

    FOR sorted_table IN sorted_tables_cur_only_dev LOOP
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

call GET_TABLES('DEV_SCHEMA', 'PROD_SCHEMA');
CREATE OR REPLACE PROCEDURE GET_TABLES(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2) AS
    tab_amount NUMBER;
    constr_amount NUMBER;

    CURSOR dev_schema_tables IS
        SELECT * FROM ALL_TABLES
        WHERE OWNER = dev_schema_name;
BEGIN
    FOR dev_schema_table IN dev_schema_tables
    LOOP
        SELECT COUNT(*) INTO tab_amount FROM
        (
            (SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = dev_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = prod_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME)
            UNION
            (SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = prod_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, NULLABLE
            FROM ALL_TAB_COLUMNS
            WHERE OWNER = dev_schema_name AND TABLE_NAME = dev_schema_table.TABLE_NAME)
        );

        SELECT COUNT(*) INTO constr_amount FROM
        (
            (SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME)
            UNION ALL
            (SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = prod_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME
            MINUS
            SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONS_COLUMNS.CONSTRAINT_NAME,
                    ALL_CONSTRAINTS.CONSTRAINT_TYPE
            FROM ALL_CONS_COLUMNS
            JOIN ALL_CONSTRAINTS
            ON ALL_CONSTRAINTS.TABLE_NAME = ALL_CONS_COLUMNS.TABLE_NAME
            WHERE ALL_CONSTRAINTS.OWNER = dev_schema_name
                AND NOT REGEXP_LIKE (ALL_CONS_COLUMNS.CONSTRAINT_NAME, '^SYS_|^BIN_')
                AND ALL_CONS_COLUMNS.TABLE_NAME = dev_schema_table.TABLE_NAME)
        );

        IF tab_amount <> 0 OR constr_amount <> 0 THEN
            dbms_output.put_line('TABLE: ' || dev_schema_table.TABLE_NAME);
            -- DDL_TABLES(dev_schema_table.TABLE_NAME, dev_schema_name, prod_schema_name);
        END IF;
    END LOOP;
END;