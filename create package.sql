
DROP PACKAGE tpackage;
CREATE OR REPLACE PACKAGE DEV_SCHEMA.tpackage AS
    test_dev_package_var NUMBER := 0;
    PROCEDURE test_dev_package_PROCEDURE;
END tpackage;

CREATE OR REPLACE
PACKAGE BODY DEV_SHEMA.tpackage AS
    PROCEDURE
    test_dev_package_PROCEDURE
    IS
        N BOOLEAN;
    BEGIN
        N := TRUE;
    END test_dev_package_PROCEDURE;
END tpackage;


CREATE OR REPLACE PACKAGE PROD_SCHEMA.test_dev_package AS
    test_dev_package_var NUMBER := 0;
    PROCEDURE test_dev_package_PROCEDURE;
    PROCEDURE test_name_PROD(PAR1 VARCHAR2, PAR2 NUMBER);
END test_dev_package;

CREATE OR REPLACE PACKAGE BODY PROD_SCHEMA.test_dev_package AS
    PROCEDURE
    test_dev_package_PROCEDURE
    IS
        N BOOLEAN;
    BEGIN
        N := TRUE;
    END test_dev_package_PROCEDURE;

    PROCEDURE test_name_PROD(PAR1 VARCHAR2, PAR2 NUMBER)
    IS
        N BOOLEAN;
    BEGIN
        N := TRUE;
    END test_name_PROD;

    FUNCTION qwe RETURN BOOLEAN IS
    BEGIN
        NULL;
    END qwe;
END test_dev_package;