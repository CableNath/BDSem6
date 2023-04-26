create table dev_schema.t1_dev_prod (
    id number,
    val number
);

create table dev_schema.t2_only_dev (
    id number,
    val number
);

-- create table dev_schema.t3_dev_ref (
--     id number primary key,
--     t4_id number
-- );

-- create table dev_schema.t4_dev_ref (
--     id number primary key,
--     t3_id number,
--     name varchar2(10),
--     constraint fk_t4_t3 foreign key (t3_id) references dev_schema.t3_dev_ref(id)
-- );
--
-- alter table dev_schema.t3_dev_ref
-- add constraint fk_t3_t4 foreign key (t4_id) references dev_schema.t4_dev_ref(id);
--
create table dev_schema.t5_dev_prod_dif_struct (
    id number,
    age varchar2(10)
);

create table dev_schema.t6_dev_prod_dif_struct (
    id number,
    age varchar2(10),
    high number
);

create table prod_schema.t1_dev_prod (
    id number,
    val number
);

create table prod_schema.t2_only_prod (
    id number,
    val number
);


-- create table prod_schema.t3_dev_ref (
--     id number primary key,
--     t4_id number,
--     weight number
-- );
--
-- create table prod_schema.t4_dev_ref (
--     id number primary key,
--     t3_id number,
--     constraint fk_t4_t3 foreign key (t3_id) references prod_schema.t3_dev_ref(id)
-- );

-- alter table prod_schema.t3_dev_ref
-- add constraint fk_t3_t4 foreign key (t4_id) references prod_schema.t4_dev_ref(id);

create table prod_schema.t5_dev_prod_dif_struct (
    id number,
    sex varchar2(10)
);

create table prod_schema.t6_dev_prod_dif_struct (
    id number,
    age varchar2(10)
);


create table dev_schema.t1(
    id number primary key,
    age number
);

create table dev_schema.t2(
    id number primary key ,
    age number
);

create table dev_schema.t3(
    id number primary key ,
    age number
);

alter table dev_schema.t2
add t1_id number;

alter table dev_schema.t2
add constraint fk_t2_t1 foreign key (t1_id) references dev_schema.t1(id);

alter table dev_schema.t1
add t3_id number;

alter table dev_schema.t1
add constraint fk_t1_t3 foreign key (t3_id) references dev_schema.t3(id);


---delete
alter table dev_schema.t2
drop constraint fk_t2_t1;

alter table dev_schema.t1
drop constraint fk_t1_t3;

drop table dev_schema.t1;
drop table dev_schema.t2;
drop table dev_schema.t3;


drop table prod_schema.t6_dev_prod_dif_struct;
drop table prod_schema.t5_dev_prod_dif_struct;
-- alter table prod_schema.t3_dev_ref
-- drop constraint fk_t3_t4;
-- drop table prod_schema.t4_dev_ref;
-- drop table prod_schema.t3_dev_ref;
drop table prod_schema.t2_only_prod;
drop table prod_schema.t1_dev_prod;
drop table dev_schema.t6_dev_prod_dif_struct;
drop table dev_schema.t5_dev_prod_dif_struct;
-- alter table dev_schema.t3_dev_ref
-- drop constraint fk_t3_t4;
-- drop table dev_schema.t4_dev_ref;
-- drop table dev_schema.t3_dev_ref;
drop table dev_schema.t2_only_dev;
drop table dev_schema.t1_dev_prod;

