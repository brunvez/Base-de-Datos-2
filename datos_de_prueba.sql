ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY';

-- PROCEDIMIENTO 1

INSERT INTO EMPRESA VALUES ('123456', 'Mi Empresa SA', 'miempresa@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');

INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Funcional');

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo F', (SELECT ID FROM ESPECIALIDAD WHERE ESPECIALIDAD.DESCRIPCION = 'Funcional'));

INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (47338517, 'Operario', 'Uruguay', 'Cuareim 1122', 'Juan Rodriguez', '02/09/1996', '08/08/2016');

INSERT INTO PRODUCTO (CODIGO, NOMBRE, DESCRIPCION) VALUES (111, 'A', 'Producto A');
INSERT INTO PRODUCTO (CODIGO, NOMBRE, DESCRIPCION) VALUES (222, 'B', 'Producto B');

INSERT INTO IDS_PRODUCTOS_RESP_GEN (ID_PRODUCTO) VALUES (111);
INSERT INTO IDS_PRODUCTOS_RESP_GEN (ID_PRODUCTO) VALUES (222);

-- PROCEDIMIENTO 2

INSERT INTO EMPRESA VALUES ('123456', 'Mi Empresa SA', 'miempresa@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');

INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Funcional');

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo F', (SELECT ID FROM ESPECIALIDAD WHERE ESPECIALIDAD.DESCRIPCION = 'Funcional'));

INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (47338517, 'Operario', 'Uruguay', 'Cuareim 1122', 'Juan Rodriguez', '02/09/1996', '08/08/2016');

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE) VALUES ((SELECT ID FROM TIPO_CONSULTA WHERE DESCRIPCION = 'Tipo F'), '123456', 'Mi consulta');

UPDATE CONSULTA SET FECHA_CREACION = '28/11/2017' WHERE ID = (SELECT MAX(ID) FROM CONSULTA);


-- PROCEDIMIENTO 6
-- Sin parametros
INSERT INTO EMPRESA
VALUES ('123456', 'Mi Empresa SA', 'miempresa@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');
INSERT INTO EMPRESA
VALUES ('1234567', 'Mi Empresa 2 SA', 'miempresa2@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');

INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Funcional');
INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Investigacion');

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo F', (SELECT ID
                                                                            FROM ESPECIALIDAD
                                                                            WHERE
                                                                              ESPECIALIDAD.DESCRIPCION = 'Funcional'));

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo I', (SELECT ID
                                                                            FROM ESPECIALIDAD
                                                                            WHERE
                                                                              ESPECIALIDAD.DESCRIPCION =
                                                                              'Investigacion'));

INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (47338517, 'Operario', 'Uruguay', 'Cuareim 1122', 'Juan Rodriguez', '02/09/1996', '08/08/2016');

INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (47338517, (SELECT ID
                                                                                                 FROM ESPECIALIDAD
                                                                                                 WHERE
                                                                                                   ESPECIALIDAD.DESCRIPCION
                                                                                                   = 'Funcional'));
INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (47338517, (SELECT ID
                                                                                                 FROM ESPECIALIDAD
                                                                                                 WHERE
                                                                                                   ESPECIALIDAD.DESCRIPCION
                                                                                                   = 'Investigacion'));

INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47338517, 'Respuesta 1');

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, ID_RESPUESTA)
VALUES ((SELECT MIN(ID)
         FROM TIPO_CONSULTA), '123456', '¿Pregunta 1?', (SELECT MAX(ID)
                                                         FROM RESPUESTA));

INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47338517, 'Respuesta 2');

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, ID_RESPUESTA)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567', '¿Pregunta 2?', (SELECT MAX(ID)
                                                          FROM RESPUESTA));

UPDATE CONSULTA
SET FECHA_RESOLUCION = (ADD_MONTHS(FECHA_RESOLUCION, -2) + (1 / 24 * 5)),
  FECHA_CREACION     = (ADD_MONTHS(FECHA_CREACION, -2) + (1 / 24 * 3));



-- Prueba recupera

INSERT INTO EMPRESA
VALUES ('123456', 'Mi Empresa SA', 'miempresa@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');
INSERT INTO EMPRESA
VALUES ('1234567', 'Mi Empresa 2 SA', 'miempresa2@gmail.com', 'Avda Italia 1234', 'Juan Perez', '099334455');

INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Funcional');
INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Investigacion');

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo F', (SELECT ID
                                                                            FROM ESPECIALIDAD
                                                                            WHERE
                                                                              ESPECIALIDAD.DESCRIPCION = 'Funcional'));

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Tipo I', (SELECT ID
                                                                            FROM ESPECIALIDAD
                                                                            WHERE
                                                                              ESPECIALIDAD.DESCRIPCION =
                                                                              'Investigacion'));

INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (47338517, 'Operario', 'Uruguay', 'Cuareim 1122', 'Juan Rodriguez', '02/09/1996', '08/08/2016');


INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (48015536, 'Operario', 'Uruguay', 'Cuareim 1122', 'Rodolfo Perez', '02/09/1997', '08/08/2018');


INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (47338517, (SELECT ID
                                                                                                 FROM ESPECIALIDAD
                                                                                                 WHERE
                                                                                                   ESPECIALIDAD.DESCRIPCION
                                                                                                   = 'Funcional'));
INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (48015536, (SELECT ID
                                                                                                 FROM ESPECIALIDAD
                                                                                                 WHERE
                                                                                                   ESPECIALIDAD.DESCRIPCION
                                                                                                   = 'Investigacion'));

INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47338517, 'Respuesta 1');

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, ID_RESPUESTA)
VALUES ((SELECT MIN(ID)
         FROM TIPO_CONSULTA), '123456', '¿Pregunta 1?', (SELECT MAX(ID)
                                                         FROM RESPUESTA));

INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (48015536, 'Respuesta 2');

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, ID_RESPUESTA)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567', '¿Pregunta 2?', (SELECT MAX(ID)
                                                          FROM RESPUESTA));

UPDATE CONSULTA
SET FECHA_RESOLUCION = (ADD_MONTHS(FECHA_RESOLUCION, -2) + (1 / 24 * 5)),
  FECHA_CREACION     = (ADD_MONTHS(FECHA_CREACION, -2) + (1 / 24 * 3));
