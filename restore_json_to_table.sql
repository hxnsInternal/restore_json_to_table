
	-- @autor: Hans Zamora Carrillo - hanszcarrillo@hotmail.com :  Colombia, Bogota

	drop table if exists public.tbl_test;	-- creacion de tabla
	create table public.tbl_test (
		id serial,
		datos jsonb
	);

	insert into public.tbl_test (datos)	-- insert data
	select jsonb_build_object('nombre','Dave','apellido','Florez','edad','35')
	union
	select jsonb_build_object('nombre','Jon','apellido','Perez','edad','23')
	union
	select jsonb_build_object('nombre','bella','apellido','ste','edad','48')
	union
	select jsonb_build_object('nombre','orion','apellido','ckarl','edad','75')
	union
	select jsonb_build_object('nombre','kile','apellido','sten','edad','36')
	union
	select jsonb_build_object('nombre','steve','apellido','ramire','edad','19')
	union
	select jsonb_build_object('nombre','sash','apellido','diaz','edad','20');


	-- visualizar data de public.tbl_test
	select * from public.tbl_test

		id |datos                                                   |
		---|--------------------------------------------------------|
		1  |{"edad": "35", "nombre": "Dave", "apellido": "Florez"}  |
		2  |{"edad": "48", "nombre": "bella", "apellido": "ste"}    |
		3  |{"edad": "20", "nombre": "sash", "apellido": "diaz"}    |
		4  |{"edad": "23", "nombre": "Jon", "apellido": "Perez"}    |
		5  |{"edad": "75", "nombre": "orion", "apellido": "ckarl"}  |
		6  |{"edad": "19", "nombre": "steve", "apellido": "ramire"} |
		7  |{"edad": "36", "nombre": "kile", "apellido": "sten"}    |



	-- creacion de la funcion
	create or replace function public.sp_json_to_table(lsTablaOrigen varchar default 'public.tbl_test', lsCampo varchar default 'datos', lsTablaDestino varchar default 'public.tbl_restore_json') returns void as $$
	declare
		lsSql varchar; -- variable contenedora Script
	begin
			discard temp; 

			-- Crear script de tabla temporal con los keys del json
			lsSql := '	
				create temp table tmp_campos as
					select distinct jsonb_object_keys('|| lsCampo ||') campo
				from '|| lsTablaOrigen ||';
				';

			raise notice 'lsSql: %',lsSql;

			execute lsSql;	-- crear tabla temporal.

			raise notice 'ok: tmp_campos';

			-- crear script de creacion de tabla destino
			lsSQl := chr(10) || 'drop table if exists '|| lsTablaDestino || ';' || chr(10) || 'create table ' || lsTablaDestino || ' as '|| chr(10) || 'select ';
			lsSql := lsSql || (select string_agg( lsCampo || ' ->> ''' || c.campo || ''' ' || c.campo ,',' || chr(10)) from tmp_campos c) || chr(10);	-- concatenar campos
			lsSql := lsSql || 'from '|| lsTablaOrigen || ';' ;	-- definir tabla origen

			raise notice 'lsSql : %', lsSql;	

			execute lsSql;	-- crear tabla destino

	end;
	$$ language plpgsql;


	-- Llamado a funcion de restore:
		select public.sp_json_to_table('public.tbl_test','datos','public.tbl_tabla_prueba_restore')
	-- Consulta a nuestra nueva tabla creada: 

	select * from public.tbl_tabla_prueba_restore;

	edad |nombre |apellido |
	-----|-------|---------|
	35   |Dave   |Florez   |
	48   |bella  |ste      |
	20   |sash   |diaz     |
	23   |Jon    |Perez    |
	75   |orion  |ckarl    |
	19   |steve  |ramire   |
	36   |kile   |sten     |


