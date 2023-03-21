create table sucursal
   (idsucursal		varchar(5),
    nombresucursal	varchar(15)	not null,
    ciudadsucursal     varchar(15)	not null,
    activos 		number		not null,
    region	           NUMBER   not null,
    primary key(idsucursal));
    

   create table prestamo
   (noprestamo 	varchar(15)	not null,
    idsucursal	varchar(5),
    cantidad 	number		not null,
    primary key(noprestamo));
    
   
insert into sucursal	values ('S0001', 'Downtown',		'Brooklyn',	 	900000,1);
insert into sucursal	values ('S0002', 'Redwood',		'Palo Alto',	2100000, 1);
insert into sucursal	values ('S0003', 'Perryridge',	'Horseneck',	1700000, 1);
insert into sucursal	values ('S0004', 'Mianus',		'Horseneck',	 400200, 1);
insert into sucursal	values ('S0005', 'Round Hill',	'Horseneck',	8000000, 1);


insert into prestamo	values ('L-17',		'S0001',	1000);
insert into prestamo	values ('L-23',		'S0002',	2000);
insert into prestamo	values ('L-15',		'S0003',	1500);
insert into prestamo	values ('L-14',		'S0001',	1500);
insert into prestamo	values ('L-93',		'S0004',	500);
insert into prestamo	values ('L-11',		'S0005',	900);
insert into prestamo	values ('L-16',		'S0003',	1300);

SELECT  * FROM prestamo;
SELECT  * FROM SUCURSAL;

//Creo el sinonimo de sucursales
DROP  SYNONYM sucursalB;

CREATE PUBLIC SYNONYM sucursalB FOR sucursal@conexionAB;


SELECT * FROM sucursalB;


//Creo la vista GLOBAL de sucursales


CREATE VIEW sucursalGlobal AS
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region
FROM sucursal
UNION ALL
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region
FROM sucursalB;

SELECT * FROM sucursalGlobal;

//Creo el sinonimo de prestamos
DROP  SYNONYM prestamoB;

CREATE PUBLIC SYNONYM prestamoB FOR prestamo@conexionAB;


SELECT * FROM prestamoB;


//Creo la vista GLOBAL de prestamos


CREATE VIEW prestamoGlobal AS
SELECT noprestamo, idsucursal, cantidad
FROM Prestamo
UNION ALL
SELECT noprestamo, idsucursal, cantidad
FROM prestamoB;


SELECT * FROM prestamoGlobal;



//Procediminento almacenado para sucursales 

CREATE OR REPLACE PROCEDURE AltaSucursal(
  p_idSucursal IN VARCHAR2,
  p_nombreSucursal IN VARCHAR2,
  p_ciudadSucursal IN VARCHAR2,
  p_activos IN NUMBER,
  p_region IN NUMBER
) AS
BEGIN
  IF p_region = 1 THEN
    INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region)
    VALUES (p_idSucursal, p_nombreSucursal, p_ciudadSucursal, p_activos, p_region);
  ELSIF p_region = 2 THEN
    INSERT INTO sucursal@conexionAB (idsucursal, nombresucursal, ciudadsucursal, activos, region)
    VALUES (p_idSucursal, p_nombreSucursal, p_ciudadSucursal, p_activos, p_region);
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'La región especificada no es válida');
  END IF;
END;



BEGIN
  AltaSucursal('0010', 'SucursalES', 'Ciudad Dos', 1000, 2);
END;


//Procediminento almacenado para prestamos 

CREATE OR REPLACE PROCEDURE AltaPrestamo (
    p_noPrestamo IN VARCHAR2,
    p_idSucursal IN VARCHAR2,
    p_cantidad IN NUMBER
) AS
    v_region NUMBER;
BEGIN
     BEGIN
        SELECT region INTO v_region FROM sucursal WHERE idsucursal = p_idSucursal;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT region INTO v_region FROM sucursalB WHERE idsucursal = p_idSucursal;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe en ninguna tabla');
            END;
    END;


    IF v_region = 1 THEN
        INSERT INTO prestamo (noprestamo, idsucursal, cantidad) VALUES (p_noPrestamo, p_idSucursal, p_cantidad);
    ELSIF v_region = 2 THEN
        INSERT INTO prestamo@conexionAB (noprestamo, idsucursal, cantidad) VALUES (p_noPrestamo, p_idSucursal, p_cantidad);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
    END IF;
END;



SELECT *
FROM ALL_PROCEDURES
WHERE owner = 'USER1A';


BEGIN
  AltaPrestamo('PR002', 'S0001', 1000);
END;


BEGIN
   AltaPrestamo('PR010', 'S0007', 8856);
END;


SELECT * FROM PRESTAMO;
SELECT * FROM PRESTAMOB;

//Trigger almacenado para sucursal 


create table replicaSucursalB
   (idsucursal		varchar(5),
    nombresucursal	varchar(15)	not null,
    ciudadsucursal     varchar(15)	not null,
    activos 		number		not null,
    region	           NUMBER   not NULL);

SELECT * FROM replicaSucursalB;


CREATE OR REPLACE TRIGGER replicaSucursal
AFTER INSERT ON sucursal
FOR EACH ROW
BEGIN
  INSERT INTO replicaSucursalA@conexionAB (idsucursal, nombresucursal, ciudadsucursal, activos, region)
  VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region);
END;


//Trigger almacenado para prestamo 

DROP TABLE replicaPrestamoB;

   create table replicaPrestamoB
   (noprestamo 	varchar(15)	not null,
    idsucursal	varchar(5),
    cantidad 	number		not null);

SELECT * FROM replicaPrestamoB;


CREATE OR REPLACE TRIGGER replicaPrestamo
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    INSERT INTO replicaPrestamoA@conexionAB (noprestamo, idsucursal, cantidad)
    VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad);
END;


BEGIN
  AltaPrestamo('PR00258', 'S0001', 8585);
END;


BEGIN
   AltaPrestamo('PR01025', 'S0007', 777);
END;

//  Vista materializada de sucursales

create materialized view sucursalesGlobales
refresh complete
as
select idsucursal, nombresucursal, ciudadsucursal, activos, region
from sucursalGlobal
group by idsucursal, nombresucursal, ciudadsucursal, activos, region;


SELECT * FROM sucursalesGlobales;




// Vista para el total de prestamos


CREATE OR REPLACE VIEW prestamosPorSucursal AS
SELECT sg.idsucursal, SUM(pg.cantidad) AS totalPrestamos
FROM sucursalGlobal sg
JOIN prestamoGlobal pg ON sg.idsucursal = pg.idsucursal
GROUP BY sg.idsucursal;



SELECT * FROM  prestamosPorSucursal;


// Optimizacion Backend

CREATE OR  REPLACE PROCEDURE USER1A.ActualizarPrestamo (
    p_noPrestamo IN VARCHAR2,
    p_idSucursal IN VARCHAR2,
    p_cantidad IN NUMBER
) AS
    v_region NUMBER;
BEGIN
     BEGIN
        SELECT region INTO v_region FROM sucursal WHERE idsucursal = p_idSucursal;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT region INTO v_region FROM sucursalA WHERE idsucursal = p_idSucursal;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe en ninguna tabla');
            END;
    END;


    IF v_region = 1 THEN
        UPDATE prestamo SET cantidad = p_cantidad WHERE noprestamo = p_noPrestamo AND idsucursal = p_idSucursal;
    ELSIF v_region = 2 THEN
        UPDATE prestamo@conexionAB SET cantidad = p_cantidad WHERE noprestamo = p_noPrestamo AND idsucursal = p_idSucursal;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
    END IF;
END;



CREATE OR REPLACE PROCEDURE BorrarPrestamo (
  p_noPrestamo IN VARCHAR2,
  p_idSucursal IN VARCHAR2
) AS
  v_region NUMBER;
BEGIN
  BEGIN
    SELECT region INTO v_region FROM sucursal WHERE idsucursal = p_idSucursal;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      BEGIN
        SELECT region INTO v_region FROM sucursalB WHERE idsucursal = p_idSucursal;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe en ninguna tabla');
      END;
  END;

  IF v_region = 1 THEN
    DELETE FROM prestamo WHERE noprestamo = p_noPrestamo;
  ELSIF v_region = 2 THEN
    DELETE FROM prestamo@conexionAB WHERE noprestamo = p_noPrestamo;
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
  END IF;
  DBMS_OUTPUT.PUT_LINE('El préstamo ' || p_noPrestamo || ' ha sido borrado correctamente.');
END;




SELECT * FROM  PRESTAMOGLOBAL;

BEGIN 
	BorrarPrestamo('8888', 'S0002'); 
END;






CREATE OR  REPLACE PROCEDURE USER1A.ActualizarSucursal (
  p_idSucursal IN VARCHAR2,
  p_nombreSucursal IN VARCHAR2,
  p_ciudadSucursal IN VARCHAR2,
  p_activos IN NUMBER,
  p_region IN NUMBER
    
) AS
BEGIN
    
    IF p_region = 1 THEN
        UPDATE sucursal SET nombresucursal = p_nombreSucursal, ciudadsucursal = p_ciudadSucursal, activos = p_activos, region = p_region WHERE idsucursal = p_idSucursal;

    ELSIF p_region = 2 THEN
        UPDATE sucursal@conexionAB  SET nombresucursal = p_nombreSucursal, ciudadsucursal = p_ciudadSucursal, activos = p_activos, region = p_region WHERE idsucursal = p_idSucursal;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
    END IF;
END;



CREATE OR REPLACE PROCEDURE BorrarSucursal (
  p_idSucursal IN VARCHAR2,
  p_region IN NUMBER
) AS
BEGIN
  

  IF p_region = 1 THEN
    DELETE FROM sucursal WHERE idsucursal = p_idSucursal;
  ELSIF p_region = 2 THEN
    DELETE FROM sucursal@conexionAB WHERE idsucursal = p_idSucursal;
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
  END IF;
  DBMS_OUTPUT.PUT_LINE('La sucursal ha sido eliminada correctamente.');
END;

BEGIN 
	BorrarSucursal('S0010', 1); 
END;

SELECT * FROM SUCURSAL;



