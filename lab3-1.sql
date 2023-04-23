
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
                where OWNER = 'DEV_SCHEMA'
                and compare_table(t.TABLE_NAME, dev_schema_name, prod_schema_name) = 1
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