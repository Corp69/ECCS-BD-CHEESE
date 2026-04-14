/*
=============================================================================
SISTEMA DE GESTIÓN COMERCIAL (ECCS) - ESQUEMA DE BASE DE DATOS
=============================================================================
Descripción: Definición de tablas para catálogos SAT, gestión de empresas,
             clientes, productos y facturación (comprobantes).
Versión: 1.0
-----------------------------------------------------------------------------
*/

-- =========================================================
-- 1. CATÁLOGOS BASE (GENERALES Y SAT)
-- =========================================================

-- Tipos de cliente (ej. Mayoreo, Menudeo, Frecuente)
CREATE TABLE eccs_tipo_cliente (
    id            BIGSERIAL PRIMARY KEY,
    descripcion   VARCHAR,
    observaciones VARCHAR,
    icon          TEXT,
    activo        BOOLEAN DEFAULT TRUE
);

-- Estatus generales para diferentes módulos del sistema
CREATE TABLE eccs_estatus (
    id            BIGSERIAL PRIMARY KEY,
    descripcion   VARCHAR(50) NOT NULL,
    icon          TEXT,
    modulo        VARCHAR(50),
    orden         VARCHAR(50),
    activo        BOOLEAN DEFAULT TRUE
);

-- Catálogo SAT: Regímenes Fiscales (CFDI 4.0)
CREATE TABLE sat_regimenfiscalcfdi (
    id          BIGINT NOT NULL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR,
    fisica      BOOLEAN DEFAULT FALSE,
    moral       BOOLEAN DEFAULT FALSE
);

-- Catálogo SAT: Uso de CFDI
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

-- Catálogo SAT: Claves de Productos y Servicios
CREATE TABLE sat_claveprodserv (
    id          BIGSERIAL PRIMARY KEY,
    codigo      VARCHAR,
    descripcion VARCHAR,
    activo      BOOLEAN DEFAULT TRUE
);

-- Catálogo SAT: Unidades de Aduana
CREATE TABLE sat_unidad_aduana (
    id          BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR,
    activo      BOOLEAN DEFAULT TRUE
);

-- Catálogo SAT: Objetos de Impuesto
CREATE TABLE sat_objetoimp (
    id          SERIAL PRIMARY KEY,
    descripcion VARCHAR,
    codigo      VARCHAR
);

-- =========================================================
-- 2. ESTRUCTURA OPERATIVA (EMPRESA, SUCURSALES, EMPLEADOS)
-- =========================================================

-- Datos generales de la empresa
CREATE TABLE eccs_empresa (
    id               SERIAL PRIMARY KEY,
    rfc              VARCHAR(13),
    observaciones    VARCHAR,
    nombrecomercial  VARCHAR,
    aviso_privacidad TEXT,
    id_estatus       INTEGER DEFAULT 1 CONSTRAINT fk_id_estatus REFERENCES eccs_estatus,
    activa           BOOLEAN DEFAULT TRUE
);

-- Datos de empleados y credenciales de acceso
CREATE TABLE eccs_empleado (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellidop       VARCHAR(100),
    apellidom       VARCHAR(100),
    correo_personal VARCHAR(45),
    nss             BIGINT,
    rfc             VARCHAR(25),
    usuario         VARCHAR(45),
    pass            VARCHAR(45),
    fecharegistro   TIMESTAMP DEFAULT NOW(),
    nivelacceso     INTEGER DEFAULT 1,
    activo          BOOLEAN DEFAULT TRUE, 

    id_eccs_estatus  integer default 1 not null
        constraint id_eccs_estatus_fkey
            references eccs_estatus,
    
    id_eccs_sucursal  integer default 1 not null
            constraint id_eccs_sucursal_fkey
                references eccs_sucursal,

    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado
);

-- Definición de aplicaciones dentro del ecosistema
CREATE TABLE eccs_aplicacion (
    id          BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR
);

-- Módulos pertenecientes a cada aplicación
CREATE TABLE eccs_modulo (
    id                 BIGSERIAL PRIMARY KEY,
    id_eccs_aplicacion BIGINT NOT NULL CONSTRAINT eccs_aplicacion_fkey REFERENCES eccs_aplicacion,
    descripcion        VARCHAR,
    icon               VARCHAR,
    activo             BOOLEAN DEFAULT TRUE
);

-- Configuración de tipos de comprobantes por sucursal/módulo (Serie, Folios, Sellos)
CREATE TABLE eccs_tipo_comprobante (
    id                       SERIAL PRIMARY KEY,
    id_eccs_modulo           INTEGER CONSTRAINT eccs_modulo_fkey REFERENCES eccs_modulo,
    id_eccs_estatus          INTEGER DEFAULT 1 NOT NULL CONSTRAINT id_eccs_estatus_fkey REFERENCES eccs_estatus,
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
     id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado, 
     id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal
);

-- =========================================================
-- 3. ENTIDAD CLIENTE
-- =========================================================

-- Maestro de clientes con configuración fiscal
CREATE TABLE eccs_cliente (
    id                       BIGSERIAL CONSTRAINT id_cliente_pkey PRIMARY KEY,
    fecharegistro            TIMESTAMP DEFAULT NOW(),
    nombre                   VARCHAR(50) NOT NULL,
    rfc                      VARCHAR(15) NOT NULL,
    correo                   VARCHAR(100),
    id_sat_usocfdi           INTEGER DEFAULT 3 CONSTRAINT fk_id_sat_usocfdi REFERENCES sat_usocfdi,
    id_sat_regimenfiscalcfdi INTEGER DEFAULT 11 REFERENCES sat_regimenfiscalcfdi,
    id_estatus               INTEGER DEFAULT 1 CONSTRAINT id_eccs_estatus_fkey REFERENCES eccs_estatus,
    id_tipo_cliente          INTEGER DEFAULT 1 CONSTRAINT id_tipo_fkey REFERENCES eccs_tipo_cliente,
    activo                   BOOLEAN DEFAULT TRUE,
    telefono                 BIGINT,
    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal,
    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado,

    CONSTRAINT fk_cliente_campos_son_unicos UNIQUE (id, nombre, rfc)
);

-- Direcciones asociadas a los clientes
CREATE TABLE eccs_cliente_domicilio (
    id              BIGSERIAL PRIMARY KEY,
    id_eccs_cliente INTEGER NOT NULL CONSTRAINT eccs_cliente_fk REFERENCES eccs_cliente,
    lada            VARCHAR DEFAULT '+ 52',
    telefono        BIGINT,
    calle           VARCHAR NOT NULL,
    num_ext         VARCHAR,
    num_int         VARCHAR,
    cp              VARCHAR,
    id_estatus      INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    predeterminado  BOOLEAN DEFAULT FALSE,
    activo          BOOLEAN DEFAULT TRUE,

    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado,

    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal

);

-- =========================================================
-- 4. INVENTARIOS (PRODUCTOS Y SERVICIOS)
-- =========================================================

-- Tipos de productos (ej. Servicio, Bien Material)
CREATE TABLE eccs_tipo_producto_servicio (
    id              BIGSERIAL PRIMARY KEY,
    descripcion     VARCHAR,
    fecha_creacion  TIMESTAMP DEFAULT NOW(),
    activa          BOOLEAN DEFAULT TRUE,
    id_eccs_estatus INTEGER DEFAULT 1 REFERENCES eccs_estatus, 

    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado,
    
    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal




);

-- Clasificación secundaria de productos
CREATE TABLE eccs_clasificacion_producto_servicio (
    id              BIGSERIAL PRIMARY KEY,
    descripcion     VARCHAR,
    fecha_creacion  DATE DEFAULT NOW(),
    id_eccs_tipo    INTEGER DEFAULT 1 CONSTRAINT id_eccs_tipo_producto_servicio_fkey REFERENCES eccs_tipo_producto_servicio,
    id_eccs_estatus INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    activa          BOOLEAN DEFAULT TRUE, 

    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado,
    
    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal
);

-- Maestro de Productos y Servicios
CREATE TABLE eccs_producto_servicio (
    id                         BIGSERIAL PRIMARY KEY,
    descripcion                VARCHAR,
    codigo                     VARCHAR,
    id_eccs_tipo               INTEGER DEFAULT 1 REFERENCES eccs_tipo_producto_servicio,
    id_eccs_clasificacion      INTEGER DEFAULT 1 REFERENCES eccs_clasificacion_producto_servicio,
    id_sat_claveprodserv       INTEGER DEFAULT 51885 REFERENCES sat_claveprodserv,
    id_sat_unidad_aduana       INTEGER DEFAULT 6 REFERENCES sat_unidad_aduana,
    codigo_barras              TEXT,
    imagen                     BYTEA,
    id_eccs_estatus            INTEGER DEFAULT 1 REFERENCES eccs_estatus,
    id_sat_claveunidad         BIGINT DEFAULT 678 REFERENCES sat_claveunidad,
    id_sat_objetoimp           INTEGER DEFAULT 2 NOT NULL REFERENCES sat_objetoimp,
    activo                     BOOLEAN DEFAULT TRUE,

    id_eccs_empleado  integer
        constraint id_eccs_empleado_fkey
            references eccs_empleado,
    
    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal



);

-- Precios de venta asignados a productos
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

-- Costos de adquisición de productos
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

-- =========================================================
-- 5. IMPUESTOS
-- =========================================================

CREATE TABLE sat_tipo_factor (
    id         SERIAL PRIMARY KEY,
    descipcion VARCHAR(20),
    activo     BOOLEAN DEFAULT TRUE
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

-- Relación N a N entre productos e impuestos
CREATE TABLE eccs_producto_servicio_impuesto (
    id                        SERIAL PRIMARY KEY,
    id_eccs_producto_servicio INTEGER NOT NULL REFERENCES eccs_producto_servicio,
    id_sat_impuesto           INTEGER NOT NULL REFERENCES sat_impuesto,
    activo                    BOOLEAN DEFAULT TRUE NOT NULL,
    id_eccs_empleado          INTEGER REFERENCES eccs_empleado,
    CONSTRAINT eccs_producto_servicio_impuesto_key UNIQUE (id_eccs_producto_servicio, id_sat_impuesto)
);

-- =========================================================
-- 6. VENTAS Y COMPROBANTES (PUNTO DE VENTA)
-- =========================================================


create table eccs_tipo_comprobante
(
    id                       serial
        primary key,
    id_eccs_modulo           integer
        constraint eccs_modulo_fkey
            references eccs_modulo,
    id_eccs_estatus          integer default 1     not null
        constraint id_eccs_estatus_fkey
            references eccs_estatus,
    descripcion              varchar,
    serie                    varchar,
    folio_inicial            integer default 1     not null,
    folio_anterior           integer default 0     not null,
    folio_final              integer default 99999 not null,
    razonsocial              varchar,
    rfc                      varchar,
    cp                       varchar,
    numerocertificado        varchar,
    id_sat_regimenfiscalcfdi integer
        references sat_regimenfiscalcfdi
        constraint sat_regimenfiscalcfdi_fkey1
            references sat_regimenfiscalcfdi,
    id_sat_usocfdi           integer
        references sat_usocfdi
        constraint sat_usocfdi_fkey1
            references sat_usocfdi,
    passkey                  varchar,
    archivokey               text,
    certificadocert          text,
    produccion               boolean default true,
    activo                   boolean default true, 

    id_eccs_empleado  integer
    constraint id_eccs_empleado_fkey
        references eccs_empleado, 
    
    id_eccs_sucursal  integer
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal


);




-- Cabecera del comprobante de venta
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
    id_sucursal_domicilio     INTEGER DEFAULT 1 REFERENCES eccs_sucursal_domicilio,
    id_sat_exportacion        INTEGER DEFAULT 1 REFERENCES sat_exportacion,
    sellocfd                  VARCHAR,
    sellosat                  VARCHAR,
    cadena_certificado_sat    VARCHAR,
    activo                    BOOLEAN DEFAULT TRUE
);

-- Detalle de los artículos vendidos en el comprobante
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
--- validar el historial de la venta encabezado
create table eccs_comprobante_venta_historial
(
    id   bigserial primary key,
    id_eccs_comprobante_venta  integer   default 1
        constraint id_eccs_comprobante_venta_fkey
            references eccs_comprobante_venta,
    id_eccs_sucursal          integer   default 1
        constraint id_eccs_sucursal_fkey
            references eccs_sucursal,
    id_eccs_tipo_comprobante  integer             not null
        constraint eccs_tipo_comprobante_fkey
            references eccs_tipo_comprobante,
    id_eccs_cliente           integer   default 1 not null
        constraint id_eccs_cliente_fkey
            references eccs_cliente,
    fecha_creacion            timestamp default now(),
    folio                     bigint              not null,
    uuid                      varchar,
    fecha_timbrado            timestamp,
    id_eccs_estatus           integer   default 1 not null
        constraint id_eccs_estatus_fkey
            references eccs_estatus,
    id_eccs_moneda            integer   default 1 not null
        constraint id_eccs_moneda_venta_fkey
            references eccs_moneda,
    id_eccs_empleado          integer             not null
        constraint id_eccs_empleado_fkey
            references eccs_empleado,
    id_sat_comprobantes       integer   default 1 not null
        constraint id_sat_comprobantes_fkey
            references sat_comprobantes,
    id_sat_forma_pago         integer   default 1 not null
        constraint id_sat_forma_pago_fkey
            references sat_forma_pago,
    id_sat_metodo_pago        integer   default 1
        constraint id_sat_metodo_pago_fkey
            references sat_metodo_pago,
    id_eccs_aplicacion        integer   default 1
        constraint id_eccs_aplicacion_fkey
            references eccs_aplicacion,
    id_eccs_cliente_domicilio integer
        constraint id_eccs_empleado_domicilio_fkey
            references eccs_cliente_domicilio,
    id_sucursal_domicilio     integer   default 1
        constraint fk_eccs_sucursal_domicilio
            references eccs_sucursal_domicilio,
    id_sat_exportacion        integer   default 1
        constraint fk_sat_exportacion
            references sat_exportacion,
    sellocfd                  varchar,
    sellosat                  varchar,
    cadena_certificado_sat    varchar,
    activo                    boolean   default true
);
