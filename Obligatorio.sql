-- Tipos de restricciones: dominio, referencia, negocio y clave -> como las implementamos -> capturas de pantalla

-- NOTA pa la segunda parte: para saber en que estado estan los procedimientos va guardando en una tabla y si arranca de nuevo chequea
DROP PROCEDURE REVISARRESPUESTAGENERICA;
DROP PROCEDURE RESPUESTASGENERICAS;
DROP PROCEDURE GenerarIncidentes;
DROP TRIGGER INCIDENTE_NO_LO_ES;
DROP TRIGGER INCIDENTE_YA_RESUELTO;
DROP TABLE INCIDENTE;
DROP TABLE CONSULTA_PRODUCTO;
DROP TRIGGER RESPUESTA_INCIDENTE;
DROP TRIGGER FECHA_CREACION_CONSULTA;
DROP TRIGGER FECHA_RESPUESTA_CONSULTA;
DROP TRIGGER consulta_id;
DROP SEQUENCE consulta_id_seq;
DROP TABLE CONSULTA;
DROP TABLE PALABRA_CLAVE_RESPUESTA;
DROP TRIGGER palabra_clave_id;
DROP SEQUENCE palabra_clave_id_seq;
DROP TABLE PALABRAS_CLAVE_PARA_GENERICA;
DROP SEQUENCE PALABRAS_PROC_ID_SEQ;
DROP TABLE PALABRAS_CLAVE_PROCEDIMIENTO;
DROP TABLE PALABRA_CLAVE;
DROP TRIGGER respuesta_id;
DROP SEQUENCE respuesta_id_seq;
DROP TABLE RESPUESTA;
DROP TABLE FUNCIONARIO_ESPECIALIDAD;
DROP TABLE TELEFONO_FUNCIONARIO;
DROP TABLE FUNCIONARIO;
DROP TRIGGER tipo_consulta_id;
DROP SEQUENCE tipo_consulta_id_seq;
DROP TABLE TIPO_CONSULTA;
DROP TRIGGER especialidad_id;
DROP SEQUENCE especialidad_id_seq;
DROP TABLE ESPECIALIDAD;
DROP TABLE EMPRESA_PRODUCTO;
DROP TABLE PRODUCTO;
DROP TABLE EMPRESA;

-- TABLA EMPRESA

CREATE TABLE EMPRESA (
  RUT             INTEGER       NOT NULL PRIMARY KEY,
  NOMBRE_FANTASIA VARCHAR2(100) NOT NULL UNIQUE,
  EMAIL           VARCHAR2(50)  NOT NULL UNIQUE,
  DIRECCION       VARCHAR2(100) NOT NULL,
  NOMBRE_CONTACTO VARCHAR2(50),
  TELEFONO        VARCHAR2(10)
);

-- TABLA PRODUCTO

CREATE TABLE PRODUCTO (
  CODIGO      INTEGER      NOT NULL PRIMARY KEY,
  NOMBRE      VARCHAR2(50) NOT NULL UNIQUE,
  DESCRIPCION VARCHAR2(100)
);

-- N-N EMPRESA-PRODUCTO

CREATE TABLE EMPRESA_PRODUCTO (
  RUT_EMPRESA     INTEGER NOT NULL CONSTRAINT EMP_PROD_TO_EMPRESA_FK REFERENCES EMPRESA,
  CODIGO_PRODUCTO INTEGER NOT NULL CONSTRAINT EMP_PROD_TO_PRODUCTO_FK REFERENCES PRODUCTO,
  CONSTRAINT EMPRESA_PRODUCTO_PK PRIMARY KEY (RUT_EMPRESA, CODIGO_PRODUCTO)
);

-- ESPECIALIDAD DE FUNCIONARIO

CREATE TABLE ESPECIALIDAD (
  ID          NUMBER(10)   NOT NULL PRIMARY KEY,
  DESCRIPCION VARCHAR2(50) NOT NULL UNIQUE  CONSTRAINT ESPECIALIDAD_DESCRIPCION CHECK (DESCRIPCION IN
                                                                                       ('Tecnica', 'Investigacion', 'Funcional'))
);

CREATE SEQUENCE especialidad_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER especialidad_id
BEFORE INSERT ON ESPECIALIDAD
FOR EACH ROW

  BEGIN
    SELECT especialidad_id_seq.NEXTVAL
    INTO :new.id
    FROM dual;
  END;

-- TIPO DE CONSULTA

CREATE TABLE TIPO_CONSULTA (
  ID              NUMBER(10)   NOT NULL PRIMARY KEY,
  DESCRIPCION     VARCHAR2(50) NOT NULL UNIQUE,
  ID_ESPECIALIDAD NUMBER(10)   NOT NULL CONSTRAINT TIPO_CONS_TO_ESP_FK REFERENCES ESPECIALIDAD
);

CREATE SEQUENCE tipo_consulta_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER tipo_consulta_id
BEFORE INSERT ON TIPO_CONSULTA
FOR EACH ROW

  BEGIN
    SELECT tipo_consulta_id_seq.NEXTVAL
    INTO :new.id
    FROM dual;
  END;

-- FUNCIONARIO

CREATE TABLE FUNCIONARIO (
  DOCUMENTO        INTEGER      NOT NULL PRIMARY KEY,
  TIPO             VARCHAR2(50) NOT NULL,
  PAIS             VARCHAR2(50) NOT NULL,
  DIRECCION        VARCHAR2(50) NOT NULL,
  NOMBRE           VARCHAR2(50) NOT NULL,
  FECHA_NACIMIENTO DATE         NOT NULL,
  FECHA_INGRESO    DATE         NOT NULL
);

-- TELEFONOS DE UN FUNCIONARIO

CREATE TABLE TELEFONO_FUNCIONARIO (
  DOCUMENTO_FUNCIONARIO INTEGER      NOT NULL CONSTRAINT TEL_FUNC_TO_FUNCIONARIO_FK REFERENCES FUNCIONARIO PRIMARY KEY,
  TELEFONO              VARCHAR2(10) NOT NULL
);

-- N-N ESPECIALIDADES DE UN FUNCIONARIO

CREATE TABLE FUNCIONARIO_ESPECIALIDAD (
  DOCUMENTO_FUNCIONARIO INTEGER    NOT NULL CONSTRAINT FUNC_ESP_TO_FUNCIONARIO_FK REFERENCES FUNCIONARIO,
  ID_ESPECIALIDAD       NUMBER(10) NOT NULL CONSTRAINT FUNC_ESP_TO_ESP_FK REFERENCES ESPECIALIDAD,
  CONSTRAINT FUNCIONARIO_ESPECIALIDAD_PK PRIMARY KEY (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD)
);

-- RESPUESTA
-- Tiene estado si es respuesta simple
-- Tiene id_especialidad si es respuesta estandar/generica
CREATE TABLE RESPUESTA (
  ID                    NUMBER(10)   NOT NULL PRIMARY KEY,
  DOCUMENTO_FUNCIONARIO INTEGER      NOT NULL CONSTRAINT RESPUESTA_TO_FUNCIONARIO_FK REFERENCES FUNCIONARIO,
  TEXTO                 VARCHAR2(50) NOT NULL,
  ESTADO                VARCHAR2(50) CONSTRAINT RESPUESTA_SIMPLE_ESTADO CHECK (ESTADO IN
                                                                               ('Pendiente de revision', 'Rechazada', 'Revisada Ok'))

);

CREATE SEQUENCE respuesta_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER respuesta_id
BEFORE INSERT ON RESPUESTA
FOR EACH ROW

  BEGIN
    SELECT respuesta_id_seq.NEXTVAL
    INTO :new.id
    FROM dual;
  END;

-- PALABRAS CLAVE RESPUESTA
CREATE TABLE PALABRA_CLAVE (
  ID      NUMBER(10) PRIMARY KEY,
  PALABRA VARCHAR(50) NOT NULL
);

CREATE SEQUENCE palabra_clave_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER palabra_clave_id
BEFORE INSERT ON PALABRA_CLAVE
FOR EACH ROW

  BEGIN
    SELECT palabra_clave_id_seq.NEXTVAL
    INTO :new.id
    FROM dual;
  END;

-- N-N palabras clave de una respuesta

CREATE TABLE PALABRA_CLAVE_RESPUESTA (
  ID_RESPUESTA     NUMBER(10) NOT NULL CONSTRAINT P_CLAVE_RESP_TO_RESP_FK REFERENCES RESPUESTA,
  ID_PALABRA_CLAVE NUMBER(10) NOT NULL CONSTRAINT P_CLAVE_RESP_TO_P_CLAVE_FK REFERENCES PALABRA_CLAVE,
  CONSTRAINT PALABRA_CLAVE_RESPUESTA_PK PRIMARY KEY (ID_RESPUESTA, ID_PALABRA_CLAVE)
);

-- CONSULTA

CREATE TABLE CONSULTA (
  ID                             NUMBER(10)    NOT NULL PRIMARY KEY,
  ID_TIPO_CONSULTA               NUMBER(10)    NOT NULL CONSTRAINT CONS_TO_TIPO_CONS_FK REFERENCES TIPO_CONSULTA,
  RUT_EMPRESA                    INTEGER       NOT NULL CONSTRAINT CONSULTA_TO_EMPRESA_FK REFERENCES EMPRESA,
  DETALLE                        VARCHAR2(100) NOT NULL,
  VIA_DE_CONTACTO                VARCHAR2(50) CONSTRAINT CONSULTA_CONTACTO CHECK (VIA_DE_CONTACTO IN
                                                                                  ('Telefonica', 'Correo electronico', 'Personal')),
  ID_RESPUESTA                   NUMBER(10) CONSTRAINT CONSULTA_TO_RESP_FK REFERENCES RESPUESTA,
  FECHA_CREACION                 TIMESTAMP     NOT NULL,
  FECHA_RESOLUCION               TIMESTAMP,
  TIEMPO_DE_COMUNICACION_MINUTOS NUMBER
);

CREATE SEQUENCE consulta_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER consulta_id
BEFORE INSERT ON CONSULTA
FOR EACH ROW

  BEGIN
    SELECT consulta_id_seq.NEXTVAL
    INTO :new.id
    FROM dual;
  END;

CREATE OR REPLACE TRIGGER FECHA_CREACION_CONSULTA
BEFORE INSERT ON CONSULTA
FOR EACH ROW
  BEGIN
    :NEW.FECHA_CREACION := sys_extract_utc(systimestamp);
  END;

CREATE OR REPLACE TRIGGER FECHA_RESPUESTA_CONSULTA
BEFORE UPDATE ON CONSULTA
FOR EACH ROW
  BEGIN
    IF :NEW.ID_RESPUESTA IS NOT NULL
    THEN
      :NEW.FECHA_RESOLUCION := sys_extract_utc(systimestamp);
    END IF;
  END;

CREATE OR REPLACE TRIGGER RESPUESTA_INCIDENTE
BEFORE UPDATE ON CONSULTA
FOR EACH ROW
  BEGIN
    IF :NEW.ID_RESPUESTA IS NOT NULL
    THEN
      UPDATE INCIDENTE
      SET ESTADO = 'Resuelto'
      WHERE ID_CONSULTA = :NEW.ID;
    END IF;
  END;

-- N-N CONSULTA - PRODUCTO

CREATE TABLE CONSULTA_PRODUCTO (
  ID_CONSULTA     NUMBER  NOT NULL CONSTRAINT CONS_PROD_TO_CONS_FK REFERENCES CONSULTA,
  CODIGO_PRODUCTO INTEGER NOT NULL CONSTRAINT CONS_PROD_TO_PROD_FK REFERENCES PRODUCTO,
  CONSTRAINT CONSULTA_PRODUCTO_PK PRIMARY KEY (ID_CONSULTA, CODIGO_PRODUCTO)
);

-- INCIDENTES

CREATE TABLE INCIDENTE (
  ID_CONSULTA NUMBER       NOT NULL CONSTRAINT INCIDENTE_TO_CONS_FK REFERENCES CONSULTA PRIMARY KEY,
  ESTADO      VARCHAR2(10) NOT NULL CONSTRAINT INCIDENTE_ESTADO CHECK (ESTADO IN ('Resuelto', 'Pendiente'))
);

CREATE OR REPLACE TRIGGER INCIDENTE_YA_RESUELTO
BEFORE INSERT ON INCIDENTE
FOR EACH ROW
  DECLARE
    id_respuesta NUMBER(10);
  BEGIN
    SELECT ID_RESPUESTA
    INTO id_respuesta
    FROM CONSULTA
    WHERE ID = :NEW.ID_CONSULTA;

    IF id_respuesta IS NOT NULL
    THEN
      raise_application_error(-20001, 'Incidentes no pueden ser creados con consultas ya resueltas.');
    END IF;
  END;

CREATE OR REPLACE TRIGGER INCIDENTE_NO_LO_ES
BEFORE INSERT ON INCIDENTE
FOR EACH ROW
  DECLARE
    fecha_consulta TIMESTAMP;
  BEGIN
    SELECT FECHA_CREACION
    INTO fecha_consulta
    FROM CONSULTA
    WHERE ID = :NEW.ID_CONSULTA;

    IF EXTRACT(DAY FROM (sys_extract_utc(systimestamp) - fecha_consulta)) < 1
    THEN
      raise_application_error(-20001, 'Incidentes deben ser consultas con mas de 24 horas de antigüedad.');
    END IF;
  END;
  
  
CREATE OR REPLACE TRIGGER RESPUESTA_ESPECIALIDAD_UNICA
BEFORE INSERT OR UPDATE ON CONSULTA
FOR EACH ROW
  DECLARE
    respuesta_especialidad NUMBER(10);
    consulta_especialidad  NUMBER(10);
    num                    NUMBER;
  BEGIN
    IF :NEW.ID_RESPUESTA IS NOT NULL
    THEN
      SELECT COUNT(DISTINCT ID_ESPECIALIDAD)
      INTO num
      FROM (SELECT id_especialidad
            FROM TIPO_CONSULTA
            WHERE :new.ID_TIPO_CONSULTA = TIPO_CONSULTA.ID
            UNION SELECT TIPO_CONSULTA.ID_ESPECIALIDAD
                  FROM RESPUESTA
                    JOIN CONSULTA ON RESPUESTA.ID = CONSULTA.ID_RESPUESTA
                    JOIN TIPO_CONSULTA ON CONSULTA.ID_TIPO_CONSULTA = TIPO_CONSULTA.ID
                  WHERE RESPUESTA.ID = :NEW.ID_RESPUESTA);
      IF num > 1
      THEN
        raise_application_error(-20001, 'Respuestas deben tener la misma especialidad');
      END IF;
    END IF;
  END;

--  DATOS DE PRUEBA

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD/MM/YYYY';
INSERT INTO EMPRESA VALUES ('1234567891011', 'Conaprole', 'info@conaprole.com', 'Av. Italia 1245', 'Jeremias', NULL);
INSERT INTO PRODUCTO VALUES (555, 'Caja de Carton', '10x20x50 - Interior de aluminio.');
INSERT INTO EMPRESA_PRODUCTO VALUES ('1234567891011', 555);
INSERT INTO ESPECIALIDAD (DESCRIPCION) VALUES ('Funcional');
INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Generica', (SELECT MAX(ID)
                                                                              FROM ESPECIALIDAD));

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567891011', '¿Cuanto salen 50 cajas de carton?');
INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (47442944, 'Operario', 'Uruguay', '-', 'Juan', '02/09/1996', '08/08/2016');
INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47442944, '50 pe');
UPDATE CONSULTA
SET ID_RESPUESTA = (SELECT MAX(ID)
                    FROM RESPUESTA)
WHERE ID = (SELECT MAX(ID)
            FROM CONSULTA);

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567891011', '¿Cuanto salen 50 MANZANAS?');
INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47442944, 'Mucho dinero');
UPDATE CONSULTA
SET ID_RESPUESTA = (SELECT MAX(ID)
                    FROM RESPUESTA)
WHERE ID = (SELECT MAX(ID)
            FROM CONSULTA);

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567891011', '¿En donde esta el baño?');
UPDATE CONSULTA
SET FECHA_CREACION = '15-10-2017'
WHERE ID = (SELECT MAX(ID)
            FROM CONSULTA);
INSERT INTO INCIDENTE (ID_CONSULTA, ESTADO) VALUES ((SELECT MAX(ID)
                                                     FROM CONSULTA), 'Pendiente');
INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (47442944, 'Al fondo a la derecha');
UPDATE CONSULTA
SET ID_RESPUESTA = (SELECT MAX(ID)
                    FROM RESPUESTA)
WHERE ID = (SELECT MAX(ID)
            FROM CONSULTA);

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567891011', '¿De que color es la pared?');
UPDATE CONSULTA
SET FECHA_CREACION = '14-10-2017'
WHERE ID = (SELECT MAX(ID)
            FROM CONSULTA);
INSERT INTO INCIDENTE (ID_CONSULTA, ESTADO) VALUES ((SELECT MAX(ID)
                                                     FROM CONSULTA), 'Pendiente');

INSERT INTO PALABRA_CLAVE (PALABRA) VALUES ('Baño');

INSERT INTO TIPO_CONSULTA (DESCRIPCION, ID_ESPECIALIDAD) VALUES ('Funcionamiento local', (SELECT MAX(ID)
                                                                                          FROM ESPECIALIDAD));

UPDATE CONSULTA
SET ID_TIPO_CONSULTA = (SELECT MAX(ID)
                        FROM TIPO_CONSULTA)
WHERE ID_RESPUESTA = (SELECT MAX(ID)
                      FROM RESPUESTA)

INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (47442944, (SELECT MAX(ID)
                                                                                                 FROM ESPECIALIDAD));

--- PROCEDIMIENTOS

-- UNO

DROP TABLE IDS_PRODUCTOS_RESP_GEN;
CREATE TABLE IDS_PRODUCTOS_RESP_GEN (
  ID_PRODUCTO NUMBER(10) CONSTRAINT ID_PRODUCTO_FK REFERENCES PRODUCTO
);

INSERT INTO PRODUCTO (CODIGO, NOMBRE, DESCRIPCION) VALUES (111, 'A', 'Producto A');
INSERT INTO PRODUCTO (CODIGO, NOMBRE, DESCRIPCION) VALUES (222, 'B', 'Producto B');

INSERT INTO IDS_PRODUCTOS_RESP_GEN (ID_PRODUCTO) VALUES (111);
INSERT INTO IDS_PRODUCTOS_RESP_GEN (ID_PRODUCTO) VALUES (222);

CREATE OR REPLACE PROCEDURE GenerarRespuestaGenerica(id_tipo_cons IN NUMBER, -- 1
                                                     detalle_consulta in VARCHAR,
                                                     respuesta_ofrecida IN VARCHAR,
                                                     doc_funcionario IN NUMBER, -- 47442944
                                                     rut_cliente IN NUMBER, -- '1234567891011'
                                                     via_comunicacion in VARCHAR, -- Personal
                                                     tiempo_de_comunicacion in NUMBER) -- 20
IS
  id_nueva_consulta NUMBER;
  id_nueva_respuesta NUMBER;
  BEGIN
    DECLARE CURSOR cursor_productos IS
      SELECT ID_PRODUCTO
      FROM IDS_PRODUCTOS_RESP_GEN;

    BEGIN
      INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO, ESTADO)
      VALUES (doc_funcionario, respuesta_ofrecida, 'Pendiente de revision')
      RETURNING ID into id_nueva_respuesta;

      INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, VIA_DE_CONTACTO, ID_RESPUESTA, FECHA_CREACION, FECHA_RESOLUCION, TIEMPO_DE_COMUNICACION_MINUTOS)
      VALUES (id_tipo_cons, rut_cliente, detalle_consulta, via_comunicacion, id_nueva_respuesta, sysdate, sysdate, tiempo_de_comunicacion)
      RETURNING ID into id_nueva_consulta;

      FOR producto IN cursor_productos
      LOOP
        INSERT INTO CONSULTA_PRODUCTO (ID_CONSULTA, CODIGO_PRODUCTO) VALUES (id_nueva_consulta, producto.ID_PRODUCTO);
      END LOOP;

      COMMIT;
    END;
  END;

--- NAMBER CHU
CREATE OR REPLACE PROCEDURE GenerarIncidentes
IS
  BEGIN
    DECLARE CURSOR c1 IS
      SELECT ID
      FROM CONSULTA
      WHERE ID_RESPUESTA IS NULL AND
            EXTRACT(DAY FROM (sys_extract_utc(systimestamp) - FECHA_CREACION)) >= 1;

    BEGIN
      FOR id_consulta_t IN c1
      LOOP
        INSERT INTO INCIDENTE (ID_CONSULTA, ESTADO) VALUES (id_consulta_t.ID, 'Pendiente');
      END LOOP;

      COMMIT;
    END;
  END;

-- Tres

DROP TABLE PALABRAS_CLAVE_PARA_GENERICA;
CREATE TABLE PALABRAS_CLAVE_PARA_GENERICA (
  ID_PALABRA_CLAVE NUMBER(10) CONSTRAINT ID_PALABRA_CLAVE_FK REFERENCES PALABRA_CLAVE
);

CREATE OR REPLACE PROCEDURE RevisarRespuestaGenerica(id_respuesta_in IN NUMBER, estado_deseado IN VARCHAR) IS
  palabras_clave_query VARCHAR(100);
  BEGIN
    DECLARE CURSOR c1 IS
      SELECT ID_PALABRA_CLAVE
      FROM PALABRAS_CLAVE_PARA_GENERICA;
    BEGIN
      UPDATE RESPUESTA
      SET RESPUESTA.ESTADO = estado_deseado
      WHERE RESPUESTA.ID = id_respuesta_in AND RESPUESTA.ESTADO IS NOT NULL;

      DELETE FROM PALABRA_CLAVE_RESPUESTA
      WHERE ID_RESPUESTA = id_respuesta_in;
      IF estado_deseado = 'Revisada Ok'
      THEN
        FOR palabra_clave_t IN c1
        LOOP
          INSERT INTO PALABRA_CLAVE_RESPUESTA (ID_RESPUESTA, ID_PALABRA_CLAVE)
          VALUES (id_respuesta_in, palabra_clave_t.ID_PALABRA_CLAVE);
        END LOOP;
      END IF;
      DELETE FROM PALABRAS_CLAVE_PARA_GENERICA;

      COMMIT;
    END;
  END;

-- cuatro
-- taria bueno usar esto (no me anda): https://stackoverflow.com/questions/242771/oracle-stored-procedure-with-parameters-for-in-clause
-- DATOS DE PRUEBA:


UPDATE RESPUESTA
SET ESTADO = 'Revisada Ok'
WHERE ID = (SELECT MAX(ID)
            FROM RESPUESTA
            WHERE ESTADO IS NULL);


INSERT INTO PALABRA_CLAVE_RESPUESTA (ID_RESPUESTA, ID_PALABRA_CLAVE) VALUES ((SELECT MAX(ID)
                                                                              FROM RESPUESTA
                                                                              WHERE ESTADO = 'Revisada Ok'),
                                                                             (SELECT MAX(ID)
                                                                              FROM PALABRA_CLAVE));

UPDATE CONSULTA
SET ID_TIPO_CONSULTA = (SELECT MAX(ID)
                        FROM TIPO_CONSULTA)
WHERE ID_RESPUESTA = (SELECT MAX(ID)
                      FROM RESPUESTA);


-- CREACION DE TABLAS
CREATE TABLE PALABRA_CLAVE_PROCEDIMIENTO (
  ID_PALABRA_CLAVE NUMBER(10) CONSTRAINT PALABRA_CLAVE_PROCEDIMIENTO_FK REFERENCES PALABRA_CLAVE
);

INSERT INTO PALABRA_CLAVE_PROCEDIMIENTO VALUES((SELECT MAX(ID) FROM PALABRA_CLAVE));

-- PROCEDIMIENTO 4
CREATE OR REPLACE PROCEDURE RESPUESTASGENERICAS(tipo_de_consulta IN VARCHAR2)
IS
  BEGIN
    DECLARE
      CURSOR RESPUESTAS IS
        SELECT R.TEXTO
        FROM CONSULTA C
          JOIN RESPUESTA R ON C.ID_RESPUESTA = R.ID
          JOIN TIPO_CONSULTA TC ON C.ID_TIPO_CONSULTA = TC.ID
          JOIN ESPECIALIDAD E ON TC.ID_ESPECIALIDAD = E.ID
          JOIN PALABRA_CLAVE_RESPUESTA PCR ON R.ID = PCR.ID_RESPUESTA
          JOIN PALABRA_CLAVE PC ON PCR.ID_PALABRA_CLAVE = PC.ID
        WHERE TC.DESCRIPCION = tipo_de_consulta
				AND R.ESTADO = 'Revisada Ok'
              AND PC.PALABRA IN (SELECT PALABRA
                                 FROM PALABRA_CLAVE_PROCEDIMIENTO
                                   JOIN PALABRA_CLAVE
                                     ON PALABRA_CLAVE_PROCEDIMIENTO.ID_PALABRA_CLAVE = PALABRA_CLAVE.ID);

      CURSOR FUNCIONARIOS IS
        SELECT F.NOMBRE
        FROM TIPO_CONSULTA TC
          JOIN ESPECIALIDAD E ON TC.ID_ESPECIALIDAD = E.ID
          JOIN FUNCIONARIO_ESPECIALIDAD FE ON E.ID = FE.ID_ESPECIALIDAD
          JOIN FUNCIONARIO F ON FE.DOCUMENTO_FUNCIONARIO = F.DOCUMENTO
        WHERE TC.DESCRIPCION = tipo_de_consulta;

    BEGIN
      DBMS_OUTPUT.PUT_LINE('RESPUESTAS: ');
      FOR respuesta_cursor IN RESPUESTAS
      LOOP
        DBMS_OUTPUT.PUT_LINE(respuesta_cursor.TEXTO);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
      END LOOP;

      DBMS_OUTPUT.PUT_LINE('FUNCIONARIOS: ');
      FOR funcionario_cursor IN FUNCIONARIOS
      LOOP
        DBMS_OUTPUT.PUT_LINE(funcionario_cursor.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
      END LOOP;
    END;
  END;
-- test
-- execute RESPUESTASGENERICAS('Funcionamiento local');
-- deberia dar al fondo a la derecha y juan

-- coso 5
CREATE OR REPLACE PROCEDURE ACTUALIZAR_ESPECIALIDADES (mes NUMBER default EXTRACT(MONTH FROM (sys_extract_utc(systimestamp))), anio number default EXTRACT(YEAR FROM (sys_extract_utc(systimestamp))))
IS
  count_especialidades NUMBER;
  BEGIN
    DECLARE CURSOR c1 IS
      SELECT
        R.DOCUMENTO_FUNCIONARIO,
        COUNT(R.ID) RESPUESTAS,
        E.ID        ESPECIALIDAD
      FROM RESPUESTA R
        JOIN CONSULTA C ON R.ID = C.ID_RESPUESTA
        JOIN TIPO_CONSULTA TC ON C.ID_TIPO_CONSULTA = TC.ID
        JOIN ESPECIALIDAD E ON TC.ID_ESPECIALIDAD = E.ID
      WHERE EXTRACT(MONTH FROM C.FECHA_RESOLUCION) = mes
            AND EXTRACT(YEAR FROM C.FECHA_RESOLUCION) = anio
      HAVING COUNT(R.ID) > 20
      GROUP BY R.DOCUMENTO_FUNCIONARIO, C.ID_TIPO_CONSULTA, E.ID;

    BEGIN
      FOR row IN c1
      LOOP
        SELECT COUNT(ID_ESPECIALIDAD)
        INTO count_especialidades
        FROM FUNCIONARIO_ESPECIALIDAD
        WHERE ID_ESPECIALIDAD = row.ESPECIALIDAD
              AND DOCUMENTO_FUNCIONARIO = row.DOCUMENTO_FUNCIONARIO;
        IF count_especialidades < 20
        THEN
          INSERT INTO FUNCIONARIO_ESPECIALIDAD VALUES (row.DOCUMENTO_FUNCIONARIO, row.ESPECIALIDAD);
        END IF;
      END LOOP;
      COMMIT;
    END;
  END;

DROP TABLE CACHE_INFO_FUNCIONARIOS;
CREATE TABLE CACHE_INFO_FUNCIONARIOS (
  MES       NUMBER NOT NULL,
  ANO       NUMBER NOT NULL,
  RESULTADO VARCHAR(2500),
  PRIMARY KEY (MES, ANO)
);

DROP TABLE ULTIMO_FUNCIONARIO;
CREATE TABLE ULTIMO_FUNCIONARIO (
  DOCUMENTO_FUNCIONARIO NUMBER NOT NULL CONSTRAINT DOCUMENTO_FUN_ULTIMO_FUN REFERENCES FUNCIONARIO,
  MES                   NUMBER NOT NULL,
  ANO                   NUMBER NOT NULL,
  PRIMARY KEY (DOCUMENTO_FUNCIONARIO, MES, ANO)
);

SELECT *
FROM CACHE_INFO_FUNCIONARIOS;

CREATE OR REPLACE PROCEDURE InfoFuncionarios(mes_param NUMBER DEFAULT NULL, ano_param NUMBER DEFAULT NULL) IS
  mes_comprobado         NUMBER;
  ano_comprobado         NUMBER;
  texto_resultado        VARCHAR(2500);
  hay_cache              NUMBER;
  ultimo_funcionario_doc NUMBER;
  BEGIN
    IF mes_param IS NULL OR ano_param IS NULL
    THEN
      mes_comprobado := EXTRACT(MONTH FROM add_months(sysdate, -1));
      ano_comprobado := EXTRACT(YEAR FROM add_months(sysdate, -1));
    ELSE
      mes_comprobado := mes_param;
      ano_comprobado := ano_param;
    END IF;

    SELECT COUNT(*)
    INTO hay_cache
    FROM
      CACHE_INFO_FUNCIONARIOS
    WHERE CACHE_INFO_FUNCIONARIOS.MES = mes_comprobado AND CACHE_INFO_FUNCIONARIOS.ANO = ano_comprobado;
    SELECT COALESCE(MAX(ULTIMO_FUNCIONARIO.DOCUMENTO_FUNCIONARIO), 0)
    INTO ultimo_funcionario_doc
    FROM ULTIMO_FUNCIONARIO
    WHERE ULTIMO_FUNCIONARIO.MES = mes_comprobado AND ULTIMO_FUNCIONARIO.ANO = ano_comprobado;
    IF hay_cache = 0 OR ultimo_funcionario_doc != 0
    THEN
      IF ultimo_funcionario_doc = 0
      THEN
        ActualizarCacheFuncionarios(mes_comprobado, ano_comprobado, mes_comprobado || '/' || ano_comprobado);
      END IF;
      ImprimirFuncionarios(mes_comprobado, ano_comprobado, ultimo_funcionario_doc);
    END IF;
    SELECT RESULTADO
    INTO texto_resultado
    FROM CACHE_INFO_FUNCIONARIOS
    WHERE CACHE_INFO_FUNCIONARIOS.MES = mes_comprobado AND CACHE_INFO_FUNCIONARIOS.ANO = ano_comprobado;
    DBMS_OUTPUT.PUT_LINE(texto_resultado);
    DELETE FROM ULTIMO_FUNCIONARIO
    WHERE ULTIMO_FUNCIONARIO.MES = mes_comprobado AND ULTIMO_FUNCIONARIO.ANO = ano_comprobado;
    COMMIT;
  END;

CREATE OR REPLACE PROCEDURE ImprimirFuncionarios(mes_param       NUMBER, ano_param NUMBER,
                                                 documento_desde NUMBER DEFAULT 0) IS
  cantidad_respuestas NUMBER;
  promedio_resolucion NUMBER;
  BEGIN
    DECLARE CURSOR c_funcionarios IS SELECT
                                       FUNCIONARIO.DOCUMENTO,
                                       FUNCIONARIO.NOMBRE,
                                       FUNCIONARIO.FECHA_INGRESO,
                                       LISTAGG(ESPECIALIDAD.DESCRIPCION, ', ')
                                       WITHIN GROUP (
                                         ORDER BY ESPECIALIDAD.DESCRIPCION) "ESPECIALIDADES_TEXTO"
                                     FROM FUNCIONARIO
                                       JOIN FUNCIONARIO_ESPECIALIDAD
                                         ON FUNCIONARIO.DOCUMENTO = FUNCIONARIO_ESPECIALIDAD.DOCUMENTO_FUNCIONARIO
                                       JOIN ESPECIALIDAD ON FUNCIONARIO_ESPECIALIDAD.ID_ESPECIALIDAD = ESPECIALIDAD.ID
                                     WHERE FUNCIONARIO.DOCUMENTO > documento_desde
                                     GROUP BY DOCUMENTO, FUNCIONARIO.NOMBRE, FUNCIONARIO.FECHA_INGRESO
                                     ORDER BY FUNCIONARIO.DOCUMENTO;
    BEGIN
      FOR row_funcionario IN c_funcionarios
      LOOP

        ActualizarCacheFuncionarios(mes_param, ano_param,
                                    'Funcionario: ' || row_funcionario.NOMBRE || ' Fecha de ingreso: ' ||
                                    row_funcionario.FECHA_INGRESO ||
                                    ' Especialidades: ' || row_funcionario.ESPECIALIDADES_TEXTO);
        ActualizarCacheFuncionarios(mes_param, ano_param,
                                    '-----------------------------------------------------------------------');

        DECLARE CURSOR c_tipos_de_consulta IS SELECT
                                                TIPO_CONSULTA.ID,
                                                TIPO_CONSULTA.DESCRIPCION
                                              FROM TIPO_CONSULTA
                                                JOIN CONSULTA ON TIPO_CONSULTA.ID = CONSULTA.ID_TIPO_CONSULTA
                                                JOIN RESPUESTA ON CONSULTA.ID_RESPUESTA = RESPUESTA.ID
                                              WHERE RESPUESTA.DOCUMENTO_FUNCIONARIO = row_funcionario.DOCUMENTO
                                                    AND CONSULTA.FECHA_RESOLUCION IS NOT NULL
                                                    AND EXTRACT(MONTH FROM CONSULTA.FECHA_RESOLUCION) = mes_param AND
                                                    EXTRACT(YEAR FROM CONSULTA.FECHA_RESOLUCION) = ano_param
                                              GROUP BY TIPO_CONSULTA.ID, TIPO_CONSULTA.DESCRIPCION;
        BEGIN
          FOR row_tipo_consulta IN c_tipos_de_consulta
          LOOP
            ActualizarCacheFuncionarios(mes_param, ano_param, 'Tipo de Consulta: ' || row_tipo_consulta.DESCRIPCION);
            DECLARE CURSOR c_clientes IS SELECT
                                           EMPRESA.NOMBRE_FANTASIA,
                                           SUM(EXTRACT(MINUTE FROM (CONSULTA.FECHA_RESOLUCION -
                                                                    CONSULTA.FECHA_CREACION))) "TIEMPO_RESOLUCION"
                                         FROM EMPRESA
                                           JOIN CONSULTA ON EMPRESA.RUT = CONSULTA.RUT_EMPRESA
                                           JOIN RESPUESTA ON CONSULTA.ID_RESPUESTA = RESPUESTA.ID
                                         WHERE CONSULTA.ID_TIPO_CONSULTA = row_tipo_consulta.ID AND
                                               RESPUESTA.DOCUMENTO_FUNCIONARIO = row_funcionario.DOCUMENTO
                                               AND CONSULTA.FECHA_RESOLUCION IS NOT NULL
                                               AND EXTRACT(MONTH FROM CONSULTA.FECHA_RESOLUCION) = mes_param AND
                                               EXTRACT(YEAR FROM CONSULTA.FECHA_RESOLUCION) = ano_param
                                         GROUP BY EMPRESA.NOMBRE_FANTASIA;
            BEGIN
              FOR row_cliente IN c_clientes
              LOOP
                ActualizarCacheFuncionarios(mes_param, ano_param,
                                            row_cliente.NOMBRE_FANTASIA || '                 ' ||
                                            row_cliente.TIEMPO_RESOLUCION);
              END LOOP;
              SELECT COUNT(RESPUESTA.ID)
              INTO cantidad_respuestas
              FROM RESPUESTA
                JOIN CONSULTA ON RESPUESTA.ID = CONSULTA.ID_RESPUESTA
              WHERE RESPUESTA.DOCUMENTO_FUNCIONARIO = row_funcionario.DOCUMENTO AND
                    CONSULTA.ID_TIPO_CONSULTA = row_tipo_consulta.ID
                    AND CONSULTA.FECHA_RESOLUCION IS NOT NULL
                    AND EXTRACT(MONTH FROM CONSULTA.FECHA_RESOLUCION) = mes_param AND
                    EXTRACT(YEAR FROM CONSULTA.FECHA_RESOLUCION) = ano_param;
              ActualizarCacheFuncionarios(mes_param, ano_param, 'Cantidad:        ' || cantidad_respuestas);
              SELECT AVG(EXTRACT(MINUTE FROM (CONSULTA.FECHA_RESOLUCION -
                                              CONSULTA.FECHA_CREACION)))
              INTO promedio_resolucion
              FROM CONSULTA
                JOIN RESPUESTA ON CONSULTA.ID_RESPUESTA = RESPUESTA.ID
              WHERE RESPUESTA.DOCUMENTO_FUNCIONARIO = row_funcionario.DOCUMENTO AND
                    CONSULTA.ID_TIPO_CONSULTA = row_tipo_consulta.ID
                    AND CONSULTA.FECHA_RESOLUCION IS NOT NULL
                    AND EXTRACT(MONTH FROM CONSULTA.FECHA_RESOLUCION) = mes_param AND
                    EXTRACT(YEAR FROM CONSULTA.FECHA_RESOLUCION) = ano_param;
              ActualizarCacheFuncionarios(mes_param, ano_param, 'Tiempo promedio: ' || promedio_resolucion);
              ActualizarCacheFuncionarios(mes_param, ano_param, '----------------------------');
            END;
          END LOOP;
        END;
        INSERT INTO ULTIMO_FUNCIONARIO (DOCUMENTO_FUNCIONARIO, ANO, MES)
        VALUES (row_funcionario.DOCUMENTO, ano, mes_param);
        COMMIT;
      END LOOP;
    END;
  END;

CREATE OR REPLACE PROCEDURE ActualizarCacheFuncionarios(mes_param NUMBER, ano_param NUMBER, texto VARCHAR) IS
  existe_cache NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO existe_cache
    FROM CACHE_INFO_FUNCIONARIOS
    WHERE CACHE_INFO_FUNCIONARIOS.ANO = ano_param AND CACHE_INFO_FUNCIONARIOS.MES = mes_param;

    IF existe_cache = 0
    THEN
      INSERT INTO CACHE_INFO_FUNCIONARIOS (MES, ANO, RESULTADO)
      VALUES (mes_param, ano_param, texto || CHR(13) || CHR(10)); -- \r\n
    ELSE
      UPDATE CACHE_INFO_FUNCIONARIOS
      SET CACHE_INFO_FUNCIONARIOS.RESULTADO = CONCAT(CACHE_INFO_FUNCIONARIOS.RESULTADO, texto || CHR(13) || CHR(10))
      WHERE CACHE_INFO_FUNCIONARIOS.ANO = ano_param AND CACHE_INFO_FUNCIONARIOS.MES = mes_param;
    END IF;
  END;

SELECT *
FROM CACHE_INFO_FUNCIONARIOS;
SELECT *
FROM ULTIMO_FUNCIONARIO;

DELETE FROM CACHE_INFO_FUNCIONARIOS;
DELETE FROM ULTIMO_FUNCIONARIO;


INSERT INTO FUNCIONARIO (DOCUMENTO, TIPO, PAIS, DIRECCION, NOMBRE, FECHA_NACIMIENTO, FECHA_INGRESO)
VALUES (48015536, 'Operario', 'Uruguay', '-', 'Bruno', sysdate, sysdate);

INSERT INTO RESPUESTA (DOCUMENTO_FUNCIONARIO, TEXTO) VALUES (48015536, 'coso coso');
SELECT *
FROM RESPUESTA;

INSERT INTO FUNCIONARIO_ESPECIALIDAD (DOCUMENTO_FUNCIONARIO, ID_ESPECIALIDAD) VALUES (48015536, 2)
SELECT *
FROM ESPECIALIDAD;

INSERT INTO CONSULTA (ID_TIPO_CONSULTA, RUT_EMPRESA, DETALLE, ID_RESPUESTA)
VALUES ((SELECT MAX(ID)
         FROM TIPO_CONSULTA), '1234567891011', '¿COSO?', 4);