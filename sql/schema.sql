alter session set "_oracle_script"=true;

-- init.sql — создать схему AFADEEV в PDB XEPDB1
whenever sqlerror exit failure rollback
set echo on verify off heading on feedback on serveroutput on

-- ==== параметры (можно поменять перед запуском) ====
define PDB_NAME        = 'XEPDB1'
define SCHEMA_NAME     = 'AFADEEV'
define SCHEMA_PASSWORD = 'AFADEEV#123'  -- задай свой пароль

-- ==== убедимся, что нужная PDB открыта ====
alter session set container = CDB$ROOT;

declare
  v_open_mode varchar2(20);
begin
  select open_mode
  into   v_open_mode
  from   v$pdbs
  where  name = upper('&PDB_NAME');

  if v_open_mode <> 'READ WRITE' then
    execute immediate 'alter pluggable database '||upper('&PDB_NAME')||' open read write';
  end if;

  -- чтобы при рестарте контейнера PDB открывалась автоматически
  execute immediate 'alter pluggable database '||upper('&PDB_NAME')||' save state';
exception
  when no_data_found then
    raise_application_error(-20000, 'PDB '||'&PDB_NAME'||' не найдена');
end;
/

-- ==== переходим в целевую PDB ====
alter session set container = &PDB_NAME;

-- ==== создаём (или обновляем) пользователя ====
declare
  n number;
  p_pwd varchar2(4000) := replace('&SCHEMA_PASSWORD','"','""'); -- экранируем кавычки
begin
  select count(*) into n from dba_users where username = upper('&SCHEMA_NAME');

  if n = 0 then
    execute immediate
      'create user '||upper('&SCHEMA_NAME')||
      ' identified by "'||p_pwd||'" '||
      ' default tablespace USERS temporary tablespace TEMP';
  else
    execute immediate
      'alter user '||upper('&SCHEMA_NAME')||
      ' identified by "'||p_pwd||'"';
  end if;
end;
/

-- ==== выдаём права и квоту ====
begin
  for r in (
    select 'grant '||priv||' to '||upper('&SCHEMA_NAME')||case when priv like 'CREATE%' then '' end stmt
    from (
      select 'create session'  priv from dual union all
      select 'create table'    from dual union all
      select 'create sequence' from dual union all
      select 'create view'     from dual union all
      select 'create procedure'from dual union all
      select 'create trigger'  from dual union all
      select 'create type'     from dual union all
      select 'create synonym'  from dual
    )
  ) loop
    begin
      execute immediate r.stmt;
    exception when others then
      if sqlcode != -1919 then raise; end if; -- ORA-01919: role does not exist (на случай редких конфигураций)
    end;
  end loop;

  -- безлимитная квота на USERS, чтобы можно было создавать объекты
  execute immediate 'alter user '||upper('&SCHEMA_NAME')||' quota unlimited on USERS';
end;
/

-- ==== проверка ====
column username format a20
column account_status format a20
column default_tablespace format a15
prompt
prompt === Проверка созданной схемы ===
select username, account_status, default_tablespace
from   dba_users
where  username=upper('&SCHEMA_NAME');


ALTER SESSION SET CONTAINER = XEPDB1;

CREATE TABLE AFADEEV.USERS (
	id      		INT generated as identity NOT NULL ,
	first_name     VARCHAR2(64) NOT NULL,
	last_name     	VARCHAR2(64) NOT NULL,
	age 			INT NOT NULL,
	city     		VARCHAR2(64) NOT NULL,
	address     	VARCHAR2(256) NOT NULL,
	phone_number    VARCHAR2(64) NOT NULL,
	created_at    	TIMESTAMP(3) NOT NULL,
	updated_at    	TIMESTAMP(3) NOT NULL,
	constraint users_pk PRIMARY KEY(id)
 );

ALTER TABLE AFADEEV.USERS ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

EXIT;