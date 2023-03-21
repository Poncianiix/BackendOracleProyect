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
    
   
insert into sucursal	values ('S0006', 'Pownal',		'Bennington',	 400000,2);
insert into sucursal	values ('S0007', 'North Town',	'Rye',		3700000, 2);
insert into sucursal	values ('S0008', 'Brighton',		'Brooklyn',		7000000, 2);
insert into sucursal	values ('S0009', 'Central',		'Rye',		 400280, 2);


insert into prestamo	values ('L-20',		'S0007',	7500);
insert into prestamo	values ('L-21',		'S0009',	570);

SELECT  * FROM PRESTAMO;
SELECT  * FROM SUCURSALA;





//Creo el sinonimo de sucursales
DROP  SYNONYM sucursalA;

CREATE PUBLIC SYNONYM sucursalA FOR sucursal@conexionBA;


SELECT * FROM sucursalA;


//Creo la vista GLOBAL de sucursales


CREATE VIEW sucursalGlobal AS
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region
FROM sucursal
UNION ALL
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region
FROM sucursalA;

SELECT * FROM sucursalGlobal;

//Creo el sinonimo de prestamos
DROP  SYNONYM prestamoA;

CREATE PUBLIC SYNONYM prestamoA FOR prestamo@conexionBA;


SELECT * FROM prestamoA;


//Creo la vista GLOBAL de prestamos


CREATE VIEW prestamoGlobal AS
SELECT noprestamo, idsucursal, cantidad
FROM Prestamo
UNION ALL
SELECT noprestamo, idsucursal, cantidad
FROM prestamoA;


SELECT * FROM prestamoGlobal;


DELETE FROM sucursal
WHERE idsucursal = '001';

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
    INSERT INTO sucursal@conexionBA (idsucursal, nombresucursal, ciudadsucursal, activos, region)
    VALUES (p_idSucursal, p_nombreSucursal, p_ciudadSucursal, p_activos, p_region);
  ELSIF p_region = 2 THEN
    INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region)
    VALUES (p_idSucursal, p_nombreSucursal, p_ciudadSucursal, p_activos, p_region);
  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'La región especificada no es válida');
  END IF;
END;



BEGIN
  AltaSucursal('005', 'Sucursal Cuatro', 'Ciudad Cuatro', 1000, 1);
END;


//Procediminento almacenado para prestamos 
CREATE OR  REPLACE PROCEDURE USER1B.AltaPrestamo (
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
        INSERT INTO prestamo@conexionBA  (noprestamo, idsucursal, cantidad) VALUES (p_noPrestamo, p_idSucursal, p_cantidad);
    ELSIF v_region = 2 THEN
        INSERT INTO prestamo (noprestamo, idsucursal, cantidad) VALUES (p_noPrestamo, p_idSucursal, p_cantidad);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'La sucursal especificada no existe o no pertenece a una región válida');
    END IF;
END;



BEGIN
  AltaPrestamo('PR009', 'S0002', 9565);
END;


BEGIN
   AltaPrestamo('PR007', 'S0006', 8756);
END;


SELECT * FROM PRESTAMO;
SELECT * FROM PRESTAMOA;

//Trigger almacenado para sucursal 

DROP TABLE replicaSucursalA;

create table replicaSucursalA
   (idsucursal		varchar(5),
    nombresucursal	varchar(15)	not null,
    ciudadsucursal     varchar(15)	not null,
    activos 		number		not null,
    region	           NUMBER   not null);

   
SELECT * FROM replicaSucursalA;

DELETE FROM sucursal
WHERE idsucursal = '8956';


CREATE OR REPLACE TRIGGER replicaSucursal
AFTER INSERT ON sucursal
FOR EACH ROW
BEGIN
  INSERT INTO replicaSucursalB@conexionBA (idsucursal, nombresucursal, ciudadsucursal, activos, region)
  VALUES (:NEW.idsucursal, :NEW.nombresucursal, :NEW.ciudadsucursal, :NEW.activos, :NEW.region);
END;

//Trigger almacenado para prestamo 



   create table replicaPrestamoA
   (noprestamo 	varchar(15)	not null,
    idsucursal	varchar(5),
    cantidad 	number		not null);

SELECT * FROM replicaPrestamoA;


CREATE OR REPLACE TRIGGER replicaPrestamo
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    INSERT INTO replicaPrestamoB@conexionBA (noprestamo, idsucursal, cantidad)
    VALUES (:NEW.noprestamo, :NEW.idsucursal, :NEW.cantidad);
END;

//  Vista materializada de prestamos




create materialized view prestamosGlobales
refresh complete
as
select noprestamo, idsucursal, cantidad
from prestamoGlobal
group by noprestamo, idsucursal, cantidad;

SELECT * FROM prestamosGlobales;


DELETE FROM REPLICAPRESTAMOA
WHERE NOPRESTAMO = '7777';
SELECT * FROM  REPLICAPRESTAMOA;

SELECT * FROM  REPLICASUCURSALA;

