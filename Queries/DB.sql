/*
=============================================================================
SISTEMA DE GESTIÓN COMERCIAL (ECCS) - ESQUEMA DE BASE DE DATOS
=============================================================================
Descripción: Esquema completo que incluye Catálogos SAT, Estructura Operativa,
             Gestión de Sucursales, Inventarios y Punto de Venta (Cortes/Cajas).
Versión: 1.1
-----------------------------------------------------------------------------
*/

-- =========================================================
-- 1. CATÁLOGOS BASE Y SAT (TABLAS INDEPENDIENTES)
-- =========================================================

CREATE TABLE eccs_estatus (
    id            BIGSERIAL PRIMARY KEY,
    descripcion   VARCHAR(50) NOT NULL,
    icon          TEXT,
    modulo        VARCHAR(50),
    orden         VARCHAR(50),
    activo        BOOLEAN DEFAULT TRUE
);

CREATE TABLE eccs_tipo_cliente (
    id            BIGSERIAL PRIMARY KEY,
    descripcion   VARCHAR,
    observaciones VARCHAR,
    icon          TEXT,
    activo        BOOLEAN DEFAULT TRUE
);

CREATE TABLE sat_regimenfiscalcfdi (
    id          BIGINT NOT NULL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR,
    fisica      BOOLEAN DEFAULT FALSE,
    moral       BOOLEAN DEFAULT FALSE
);

CREATE TABLE sat_usocfdi (
    id          BIGINT NOT NULL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR,
    compra      BOOLEAN DEFAULT TRUE NOT NULL,
    gasto       BOOLEAN DEFAULT TRUE NOT NULL,
    fisica      BOOLEAN DEFAULT FALSE,
    moral       BOOLEAN DEFAULT FALSE,
    receptores  VARCHAR
);

CREATE TABLE sat_claveprodserv (
    id          BIGSERIAL PRIMARY KEY,
    codigo      VARCHAR,
    descripcion VARCHAR,
    activo      BOOLEAN DEFAULT TRUE
);

CREATE TABLE sat_unidad_aduana (
    id          BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR,
    activo      BOOLEAN DEFAULT TRUE
);

CREATE TABLE sat_objetoimp (
    id          SERIAL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR
);

CREATE TABLE sat_tipo_factor (
    id         SERIAL PRIMARY KEY,
    descipcion VARCHAR(20),
    activo     BOOLEAN DEFAULT TRUE
);

-- =========================================================
-- 2. ESTRUCTURA OPERATIVA (EMPRESA Y SUCURSALES)
-- =========================================================

CREATE TABLE eccs_empresa (
    id               SERIAL PRIMARY KEY,
    rfc              VARCHAR(13),
    observaciones    VARCHAR,
    nombrecomercial  VARCHAR,
    aviso_privacidad TEXT,
    id_estatus       INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    activa           BOOLEAN DEFAULT TRUE
);

CREATE TABLE eccs_sucursal (
    id          BIGSERIAL PRIMARY KEY,
    id_empresa  INTEGER DEFAULT 1 REFERENCES eccs_empresa,
    id_estatus  INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    descripcion VARCHAR,
    activo      BOOLEAN DEFAULT TRUE,
    fecha       TIMESTAMP DEFAULT NOW()
);

-- Los empleados dependen de una sucursal y un estatus
CREATE TABLE eccs_empleado (
    id               SERIAL PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    apellidop        VARCHAR(100),
    apellidom        VARCHAR(100),
    correo_personal  VARCHAR(45),
    nss              BIGINT,
    rfc              VARCHAR(25),
    usuario          VARCHAR(45),
    pass             VARCHAR(45),
    fecharegistro    TIMESTAMP DEFAULT NOW(),
    nivelacceso      INTEGER DEFAULT 1,
    activo           BOOLEAN DEFAULT TRUE,
    id_eccs_estatus  INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    id_eccs_sucursal INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_sucursal,
    id_eccs_empleado INTEGER REFERENCES eccs_empleado -- Auto-referencia para jefes/supervisores
);

CREATE TABLE eccs_sucursal_domicilio (
    id               BIGSERIAL PRIMARY KEY,
    id_sucursal      INTEGER NOT NULL REFERENCES eccs_sucursal,
    lada             VARCHAR DEFAULT '+ 52',
    telefono         BIGINT,
    calle            VARCHAR NOT NULL,
    num_ext          VARCHAR,
    num_int          VARCHAR,
    cp               VARCHAR,
    id_estatus       INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    predeterminado   BOOLEAN DEFAULT FALSE,
    activo           BOOLEAN DEFAULT TRUE,
    id_eccs_empleado INTEGER REFERENCES eccs_empleado
);

CREATE TABLE eccs_aplicacion (
    id          BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR
);

CREATE TABLE eccs_modulo (
    id                 BIGSERIAL PRIMARY KEY,
    id_eccs_aplicacion BIGINT NOT NULL REFERENCES eccs_aplicacion,
    descripcion        VARCHAR,
    icon               VARCHAR,
    activo             BOOLEAN DEFAULT TRUE
);

-- =========================================================
-- 3. CLIENTES
-- =========================================================

CREATE TABLE eccs_cliente (
    id                       BIGSERIAL PRIMARY KEY,
    fecharegistro            TIMESTAMP DEFAULT NOW(),
    nombre                   VARCHAR(50) NOT NULL,
    rfc                      VARCHAR(15) NOT NULL,
    correo                   VARCHAR(100),
    id_sat_usocfdi           INTEGER DEFAULT 3 REFERENCES sat_usocfdi,
    id_sat_regimenfiscalcfdi INTEGER DEFAULT 11 REFERENCES sat_regimenfiscalcfdi,
    id_estatus               INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    id_tipo_cliente          INTEGER DEFAULT 1 REFERENCES eccs_tipo_cliente,
    activo                   BOOLEAN DEFAULT TRUE,
    telefono                 BIGINT,
    id_eccs_sucursal         INTEGER REFERENCES eccs_sucursal,
    id_eccs_empleado         INTEGER REFERENCES eccs_empleado,
    CONSTRAINT fk_cliente_campos_son_unicos UNIQUE (id, nombre, rfc)
);

CREATE TABLE eccs_cliente_domicilio (
    id               BIGSERIAL PRIMARY KEY,
    id_eccs_cliente  INTEGER NOT NULL REFERENCES eccs_cliente,
    lada             VARCHAR DEFAULT '+ 52',
    telefono         BIGINT,
    calle            VARCHAR NOT NULL,
    num_ext          VARCHAR,
    num_int          VARCHAR,
    cp               VARCHAR,
    id_estatus       INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    predeterminado   BOOLEAN DEFAULT FALSE,
    activo           BOOLEAN DEFAULT TRUE,
    id_eccs_empleado INTEGER REFERENCES eccs_empleado,
    id_eccs_sucursal INTEGER REFERENCES eccs_sucursal
);

-- =========================================================
-- 4. INVENTARIOS Y PRODUCTOS
-- =========================================================

CREATE TABLE eccs_tipo_producto_servicio (
    id               BIGSERIAL PRIMARY KEY,
    descripcion      VARCHAR,
    fecha_creacion   TIMESTAMP DEFAULT NOW(),
    activa           BOOLEAN DEFAULT TRUE,
    id_eccs_estatus  INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    id_eccs_empleado INTEGER REFERENCES eccs_empleado,
    id_eccs_sucursal INTEGER REFERENCES eccs_sucursal
);

CREATE TABLE eccs_clasificacion_producto_servicio (
    id               BIGSERIAL PRIMARY KEY,
    descripcion      VARCHAR,
    fecha_creacion   DATE DEFAULT NOW(),
    id_eccs_tipo     INTEGER DEFAULT 1 REFERENCES eccs_tipo_producto_servicio,
    id_eccs_estatus  INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    activa           BOOLEAN DEFAULT TRUE,
    id_eccs_empleado INTEGER REFERENCES eccs_empleado,
    id_eccs_sucursal INTEGER REFERENCES eccs_sucursal
);

CREATE TABLE eccs_producto_servicio (
    id                    BIGSERIAL PRIMARY KEY,
    descripcion           VARCHAR,
    codigo                VARCHAR,
    id_eccs_tipo          INTEGER DEFAULT 1 REFERENCES eccs_tipo_producto_servicio,
    id_eccs_clasificacion INTEGER DEFAULT 1 REFERENCES eccs_clasificacion_producto_servicio,
    id_sat_claveprodserv  INTEGER DEFAULT 51885 REFERENCES sat_claveprodserv,
    id_sat_unidad_aduana  INTEGER DEFAULT 6 REFERENCES sat_unidad_aduana,
    codigo_barras         TEXT,
    imagen                BYTEA,
    id_eccs_estatus       INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    id_sat_claveunidad    BIGINT DEFAULT 678 REFERENCES sat_claveunidad,
    id_sat_objetoimp      INTEGER DEFAULT 2 NOT NULL REFERENCES sat_objetoimp,
    activo                BOOLEAN DEFAULT TRUE,
    id_eccs_empleado      INTEGER REFERENCES eccs_empleado,
    id_eccs_sucursal      INTEGER REFERENCES eccs_sucursal
);

-- Precios, Costos e Impuestos de Productos
CREATE TABLE eccs_producto_servicio_precios (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_producto_servicio INTEGER REFERENCES eccs_producto_servicio,
    fecha_registro            TIMESTAMP DEFAULT NOW(),
    id_eccs_estatus           INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    descripcion               VARCHAR,
    descuento                 NUMERIC DEFAULT 0.0000,
    precio                    NUMERIC DEFAULT 0.0000,
    id_eccs_sucursal          INTEGER REFERENCES eccs_sucursal,
    id_eccs_empleado          INTEGER REFERENCES eccs_empleado,
    predeterminado            BOOLEAN DEFAULT FALSE,
    activo                    BOOLEAN DEFAULT TRUE,
    id_eccs_moneda            INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_moneda
);

CREATE TABLE eccs_producto_servicio_costos (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_producto_servicio INTEGER REFERENCES eccs_producto_servicio,
    fecha_registro            TIMESTAMP DEFAULT NOW(),
    id_eccs_estatus           INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    descripcion               VARCHAR,
    descuento                 NUMERIC DEFAULT 0.0000,
    precio                    NUMERIC DEFAULT 0.0000,
    id_eccs_sucursal          INTEGER REFERENCES eccs_sucursal,
    predeterminado            BOOLEAN DEFAULT FALSE,
    id_eccs_empleado          INTEGER REFERENCES eccs_empleado,
    id_eccs_moneda            INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_moneda,
    activo                    BOOLEAN DEFAULT TRUE
);

CREATE TABLE sat_impuesto (
    id                    SERIAL PRIMARY KEY,
    fijo                  BOOLEAN NOT NULL,
    id_sat_tipo_factor    INTEGER DEFAULT 1 NOT NULL REFERENCES sat_tipo_factor,
    codigo                VARCHAR(4),
    descripcion           VARCHAR(15),
    valor_minimo          NUMERIC(8, 6) DEFAULT 0.0 NOT NULL,
    valor                 NUMERIC(8, 6) DEFAULT 0.0 NOT NULL,
    valor_maximo          NUMERIC(8, 6) DEFAULT 0.0 NOT NULL,
    retencion             BOOLEAN,
    traslado              BOOLEAN,
    local                 BOOLEAN,
    federal               BOOLEAN,
    fecha_inicio_vigencia DATE DEFAULT '2022-01-01',
    fecha_fin_vigencia    DATE,
    activo                BOOLEAN DEFAULT TRUE,
    observaciones         VARCHAR,
    c_impuesto            VARCHAR
);

CREATE TABLE eccs_producto_servicio_impuesto (
    id                        SERIAL PRIMARY KEY,
    id_eccs_producto_servicio INTEGER NOT NULL REFERENCES eccs_producto_servicio,
    id_sat_impuesto           INTEGER NOT NULL REFERENCES sat_impuesto,
    activo                    BOOLEAN DEFAULT TRUE NOT NULL,
    id_eccs_empleado          INTEGER REFERENCES eccs_empleado,
    CONSTRAINT eccs_producto_servicio_impuesto_key UNIQUE (id_eccs_producto_servicio, id_sat_impuesto)
);

-- =========================================================
-- 5. VENTAS Y COMPROBANTES
-- =========================================================

CREATE TABLE eccs_tipo_comprobante (
    id                       SERIAL PRIMARY KEY,
    id_eccs_modulo           INTEGER REFERENCES eccs_modulo,
    id_eccs_estatus          INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    descripcion              VARCHAR,
    serie                    VARCHAR,
    folio_inicial            INTEGER DEFAULT 1 NOT NULL,
    folio_anterior           INTEGER DEFAULT 0 NOT NULL,
    folio_final              INTEGER DEFAULT 99999 NOT NULL,
    razonsocial              VARCHAR,
    rfc                      VARCHAR,
    cp                       VARCHAR,
    numerocertificado        VARCHAR,
    id_sat_regimenfiscalcfdi INTEGER REFERENCES sat_regimenfiscalcfdi,
    id_sat_usocfdi           INTEGER REFERENCES sat_usocfdi,
    passkey                  VARCHAR,
    archivokey               TEXT,
    certificadocert          TEXT,
    produccion               BOOLEAN DEFAULT TRUE,
    activo                   BOOLEAN DEFAULT TRUE,
    id_eccs_empleado         INTEGER REFERENCES eccs_empleado,
    id_eccs_sucursal         INTEGER REFERENCES eccs_sucursal
);

CREATE TABLE eccs_comprobante_venta (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_sucursal          INTEGER DEFAULT 1 REFERENCES eccs_sucursal,
    id_eccs_tipo_comprobante  INTEGER NOT NULL REFERENCES eccs_tipo_comprobante,
    id_eccs_cliente           INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_cliente,
    fecha_creacion            TIMESTAMP DEFAULT NOW(),
    folio                     BIGINT NOT NULL,
    uuid                      VARCHAR,
    fecha_timbrado            TIMESTAMP,
    id_eccs_estatus           INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    id_eccs_moneda            INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_moneda,
    id_eccs_empleado          INTEGER NOT NULL REFERENCES eccs_empleado,
    id_sat_comprobantes       INTEGER DEFAULT 1 NOT NULL REFERENCES sat_comprobantes,
    id_sat_forma_pago         INTEGER DEFAULT 1 NOT NULL REFERENCES sat_forma_pago,
    id_sat_metodo_pago        INTEGER DEFAULT 1 REFERENCES sat_metodo_pago,
    id_eccs_aplicacion        INTEGER DEFAULT 1 REFERENCES eccs_aplicacion,
    id_eccs_cliente_domicilio INTEGER REFERENCES eccs_cliente_domicilio,
    id_sat_exportacion        INTEGER DEFAULT 1 REFERENCES sat_exportacion,
    sellocfd                  VARCHAR,
    sellosat                  VARCHAR,
    cadena_certificado_sat    VARCHAR,
    activo                    BOOLEAN DEFAULT TRUE
);

CREATE TABLE eccs_comprobante_venta_info (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_comprobante_venta BIGINT NOT NULL REFERENCES eccs_comprobante_venta,
    id_eccs_empleado          INTEGER NOT NULL REFERENCES eccs_empleado,
    fecha_agrego              TIMESTAMP DEFAULT NOW(),
    id_eccs_producto_servicio INTEGER NOT NULL REFERENCES eccs_producto_servicio,
    id_sat_claveprodserv      INTEGER NOT NULL REFERENCES sat_claveprodserv,
    id_sat_claveunidad        INTEGER NOT NULL REFERENCES sat_claveunidad,
    cantidad                  INTEGER DEFAULT 1 NOT NULL,
    valor_unitario            NUMERIC DEFAULT 0.00 NOT NULL,
    descuento                 NUMERIC(8, 4) DEFAULT 0.00 NOT NULL,
    observaciones             VARCHAR,
    activo                    BOOLEAN DEFAULT TRUE
);

-- =========================================================
-- 6. CAJAS, CORTES E HISTÓRICOS (DEPENDENCIAS FINALES)
-- =========================================================

CREATE TABLE eccs_sucursal_caja (
    id               BIGSERIAL PRIMARY KEY,
    id_eccs_sucursal INTEGER NOT NULL REFERENCES eccs_sucursal,
    id_eccs_estatus  INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    id_eccs_empleado INTEGER NOT NULL REFERENCES eccs_empleado,
    fecha_creacion   TIMESTAMP DEFAULT NOW() NOT NULL,
    descripcion      VARCHAR,
    activa           BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE eccs_sucursal_cortes (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_sucursal          INTEGER NOT NULL REFERENCES eccs_sucursal,
    id_eccs_estatus           INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    id_eccs_empleado          INTEGER NOT NULL REFERENCES eccs_empleado,
    id_eccs_comprobante_venta INTEGER NOT NULL REFERENCES eccs_comprobante_venta,
    id_eccs_sucursal_caja     INTEGER NOT NULL REFERENCES eccs_sucursal_caja,
    fecha_creacion            TIMESTAMP DEFAULT NOW() NOT NULL,
    fecha_apertura            TIMESTAMP DEFAULT NOW() NOT NULL,
    fecha_cierre              TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE TABLE eccs_comprobante_venta_historial (
    id                        BIGSERIAL PRIMARY KEY,
    id_eccs_comprobante_venta INTEGER DEFAULT 1 REFERENCES eccs_comprobante_venta,
    id_eccs_sucursal          INTEGER DEFAULT 1 REFERENCES eccs_sucursal,
    id_eccs_tipo_comprobante  INTEGER NOT NULL REFERENCES eccs_tipo_comprobante,
    id_eccs_cliente           INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_cliente,
    fecha_creacion            TIMESTAMP DEFAULT NOW(),
    folio                     BIGINT NOT NULL,
    uuid                      VARCHAR,
    fecha_timbrado            TIMESTAMP,
    id_eccs_estatus           INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_estatus,
    id_eccs_moneda            INTEGER DEFAULT 1 NOT NULL REFERENCES eccs_moneda,
    id_eccs_empleado          INTEGER NOT NULL REFERENCES eccs_empleado,
    id_sat_comprobantes       INTEGER DEFAULT 1 NOT NULL REFERENCES sat_comprobantes,
    id_sat_forma_pago         INTEGER DEFAULT 1 NOT NULL REFERENCES sat_forma_pago,
    id_sat_metodo_pago        INTEGER DEFAULT 1 REFERENCES sat_metodo_pago,
    id_eccs_aplicacion        INTEGER DEFAULT 1 REFERENCES eccs_aplicacion,
    id_eccs_cliente_domicilio INTEGER REFERENCES eccs_cliente_domicilio,
    id_sat_exportacion        INTEGER DEFAULT 1 REFERENCES sat_exportacion,
    sellocfd                  VARCHAR,
    sellosat                  VARCHAR,
    cadena_certificado_sat    VARCHAR,
    activo                    BOOLEAN DEFAULT TRUE
);