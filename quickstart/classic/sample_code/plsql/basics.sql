--
-- Copyright (c) 1999, 2017, Oracle and/or its affiliates. All rights reserved.
--
-- Licensed under the Universal Permissive License v 1.0 as shown
-- at http://oss.oracle.com/licenses/upl
--

Rem
Rem sample.sql
Rem
Rem    NAME
Rem      sample.sql - A simple demo of using PL/SQL from ttIsql
Rem
Rem    NOTES
Rem      This can be run from inside ttIsql:
Rem        cd <this directory>
Rem        ttIsql yourdsn
Rem        @sample.sql;
Rem
Rem      -or-
Rem
Rem        cd <this directory>
Rem        ttIsql -f sample.sql yourdsn
Rem PL/SQL can be used from ttIsql.  Normally, ttIsql expects that statements
Rem end with a semicolon; when it finds such a statement it sends it to 
Rem the TimesTen database.  However, PL/SQL blocks consist of many statements,
Rem all ending with a semicolon.  When entering PL/SQL, a "/" on a line by 
Rem itself signals the end of the block, and causes ttIsql to send the block
Rem to the TimesTen database.
Rem
Rem This example creates a stored procedure in the database, then
Rem executes the procedure via an anonymous block.  
Rem

set serveroutput on

create or replace procedure hello_world as
  begin
    dbms_output.put_line('Hello World!');
  end;
/

begin
  hello_world;
end;
/

Rem Note the "set serveroutput on" statement.  This tells ttIsql to fetch
Rem and display any output that might have been generated by PL/SQL blocks.
Rem By default output from dbms_output is not displayed.

set serveroutput off

begin
  hello_world;
end;
/

Rem (Note that no output was displayed.)

set serveroutput on

Rem When creating a stored procedure, function or package that has compile
Rem errors you may see "Warning: Procedure created with compilation errors".
Rem To see the actual errors, use the ttIsql "show errors" command.

create or replace procedure broken_procedure as
 x pls_integer;
begin
 x = 3;                       -- Should have been x := 3 
end;
/

show errors

Rem Data may be passed to PL/SQL at runtime via "binds".  When a PL/SQL block
Rem contains an input bind, ttIsql will automatically prompt for the value
Rem to be used.

declare
  x varchar(255);
begin
  x := :bindvalue;
  dbms_output.put_line('The value is ' || x);
end;
/
'Hello World'

Rem Data may also be passed back to applications from PL/SQL via OUT binds.
Rem This can be used with ttIsql to test procedures that return such binds.
Rem To illustrate this, here is a procedure that returns information about
Rem how full a TimesTen data store is.  (This is also an example showing 
Rem how to use SQL against TimesTen from PL/SQL.)

create or replace procedure tt_space_info
  (permPct    out pls_integer,
   permMaxPct out pls_integer,
   tempPct    out pls_integer,
   tempMaxPct out pls_integer) as
   monitor    sys.monitor%rowtype;
begin
  select * into monitor from sys.monitor;
  
  permPct := monitor.perm_in_use_size * 100 / monitor.perm_allocated_size;
  permMaxPct := monitor.perm_in_use_high_water * 100 / 
    monitor.perm_allocated_size;
  
  tempPct := monitor.temp_in_use_size * 100 / monitor.temp_allocated_size;
  tempMaxPct := monitor.temp_in_use_high_water * 100 / 
    monitor.temp_allocated_size;
end;
/

Rem This procedure can be used both with traditional PL/SQL variables and
Rem with out binds.  Here we will pass the results back into PL/SQL variables:

declare
 permPct    pls_integer;
 permMaxPct pls_integer;
 tempPct    pls_integer;
 tempMaxPct pls_integer;
begin
  tt_space_info(permPct, permMaxPct, tempPct, tempMaxPct);  

  dbms_output.put_line('TimesTen space utilization report');
  dbms_output.put_line('PERM space is ' || permPct || '% full');
  dbms_output.put_line('PERM space high water mark was ' || permMaxPct || 
    '% full');
  dbms_output.put_line('TEMP space is ' || tempPct || '% full');
  dbms_output.put_line('TEMP space high water mark was ' || tempMaxPct || 
    '% full');
  
end;
/

Rem Here we will call the same procedure, but pass the output values back
Rem to the application (ttIsql) as out binds:

var permpct    number
var permpctmax number
var temppct    number
var temppctmax number

begin
  tt_space_info(:permpct, :permpctmax, :temppct, :temppctmax);
end;
/

print permpct
print permpctmax
print temppct
print temppctmax

Rem You can also use ttIsql facilities to display information about your
Rem stored PL/SQL procedures, functions and packages.  

Rem For example, to list the procedures you have created:

procedures;

Rem To get information about the parameters expected by a PL/SQL block:

describe tt_space_info;

Rem You may also query this metadata via many of the same 
Rem catalog views that are provided in the Oracle Database.
Rem Example: 

select object_name from user_objects order by object_name;

Rem End of Demo
