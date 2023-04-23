create table dev_schema.t1_dev_prod (
    id number,
    val number
);

create table dev_schema.t2_only_dev (
    id number,
    val number
);

create table dev_schema.t3_dev_ref (
    id number primary key,
    t4_id number
);

create table dev_schema.t4_dev_ref (
    id number primary key,
    t3_id number,
    name varchar2(10),
    constraint fk_t4_t3 foreign key (t3_id) references dev_schema.t3_dev_ref(id)
);

alter table dev_schema.t3_dev_ref
add constraint fk_t3_t4 foreign key (t4_id) references dev_schema.t4_dev_ref(id);

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

create table prod_schema.t3_dev_ref (
    id number primary key ,
    t4_id number,
    weight number
);


create table prod_schema.t4_dev_ref (
    id number primary key,
    t3_id number,
    constraint fk_t4_t3 foreign key (t3_id) references prod_schema.t3_dev_ref(id)
);

alter table prod_schema.t3_dev_ref
add constraint fk_t3_t4 foreign key (t4_id) references prod_schema.t4_dev_ref(id);

create table prod_schema.t5_dev_prod_dif_struct (
    id number,
    sex varchar2(10)
);

create table prod_schema.t6_dev_prod_dif_struct (
    id number,
    age varchar2(10)
)