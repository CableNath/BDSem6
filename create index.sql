CREATE INDEX dev_schema.TEST_INDEX1 on dev_schema.t1_dev_prod(id);

CREATE INDEX dev_schema.TEST_INDEX2 on dev_schema.t5_dev_prod_dif_struct(id);

CREATE INDEX dev_schema.TEST_INDEX3 on dev_schema.t6_dev_prod_dif_struct(high);


CREATE INDEX prod_schema.TEST_INDEX1 on prod_schema.t1_dev_prod(id);
CREATE INDEX prod_schema.TEST_INDEX2 on prod_schema.t5_dev_prod_dif_struct(sex);
CREATE INDEX prod_schema.TEST_INDEX3 on prod_schema.t6_dev_prod_dif_struct(age);



drop index prod_schema.TEST_INDEX1;
drop index prod_schema.TEST_INDEX2;
drop index prod_schema.TEST_INDEX3;
drop index dev_schema.TEST_INDEX1;
drop index dev_schema.TEST_INDEX2;
drop index dev_schema.TEST_INDEX3;