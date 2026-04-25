create or replace function "controlventas".fn_create_comprobante_venta(_id_eccs_cliente integer, _id_eccs_cliente_domicilio integer, _id_eccs_usuarios integer, _id_eccs_tipo_comprobante integer, _id_eccs_sucursal integer, _id_sucursal_domicilio integer, _id_moneda integer, _id_estatus integer) returns json
    language plpgsql
as
$$
--=================================================================
-- Autor: Elizandro
-- Fecha: 13/04/2026
-- Descripción: genera un comprobante de venta nuevo
--=================================================================
declare
    _id_nuevo       integer;  -- id del registro insertado
begin
    --=============================================================
    -- Validación 1: Verificar sucursal y domicilio
    --=============================================================
    select id into _id_eccs_sucursal
    from eccs_sucursal
    where id = _id_eccs_sucursal
    limit 1;

    -- IF: validamos el domicilio
    if _id_eccs_sucursal is null then
        raise exception 'No hay Sucursal seleccionada %', _id_eccs_sucursal;
    end if;
    --=============================================================
    -- Validación 2: Verificar sucursal y domicilio
    --=============================================================
    select id into _id_sucursal_domicilio
    from eccs_sucursal_domicilio
    where id = _id_sucursal_domicilio
    limit 1;

    -- IF: validamos el domicilio
    if _id_sucursal_domicilio is null then
        raise exception 'No hay Sucursal Domicilio %', _id_sucursal_domicilio;
    end if;

    --=============================================================
    -- Validación 3: cliente seleccionado
    --=============================================================
    select id into _id_eccs_cliente
    from eccs_cliente
    where activo is true
        and id_estatus in ( 1)
        and id = _id_eccs_cliente
    limit 1;
    -- IF: validamos
    if _id_eccs_cliente is null then
        raise exception 'No hay cliente seleccionado %', _id_eccs_cliente;
    end if;

    --=============================================================
    -- Validación 4: cliente Domiclio seleccionado
    --=============================================================
    select id into _id_eccs_cliente_domicilio
    from eccs_cliente_domicilio
    where activo is true
        and id_estatus in ( 1)
        and id = _id_eccs_cliente_domicilio
    limit 1;
    -- IF: validamos
    if _id_eccs_cliente is null then
        raise exception 'No hay Domicilio del cliente %', _id_eccs_cliente_domicilio;
    end if;

    --=============================================================
    -- Validación 5: moneda seleccionada
    --=============================================================
    select id into _id_moneda
    from eccs_moneda
    where activa is true
        and id = _id_moneda
    limit 1;
    -- IF: validamos
    if _id_moneda is null then
        raise exception 'No se encontro la moneda seleccionada %', _id_moneda;
    end if;

    --=============================================================
    -- Validación 6: Obtencion de comprobante
    --=============================================================
    select id into _id_eccs_tipo_comprobante
    from eccs_tipo_comprobante
    where activo is true
        and id_eccs_estatus in ( 1 )
        and id = _id_eccs_tipo_comprobante
    limit 1;
    -- IF: validamos
    if _id_eccs_tipo_comprobante is null then
        raise exception 'No se encontro comprobante %', _id_eccs_tipo_comprobante;
    end if;
    --=============================================================
    -- Inserción: Agregar detalle al comprobante
    --=============================================================
    insert into eccs_comprobante_venta (
        id_eccs_cliente,
        folio,
        id_eccs_estatus,
        id_eccs_moneda,
        id_eccs_empleado,
        id_eccs_sucursal,
        id_eccs_tipo_comprobante,
        id_eccs_cliente_domicilio,
        -- activo,
        id_sucursal_domicilio
    ) values (
        _id_eccs_cliente,
        0,
        _id_estatus,
        _id_moneda,
        _id_eccs_usuarios,
        _id_eccs_sucursal,
        _id_eccs_tipo_comprobante,
        _id_eccs_cliente_domicilio,
        -- activo,
        _id_sucursal_domicilio
    ) returning id into _id_nuevo;
     --=============================================================
    -- Insertamos: sacamos un Historial del comprobante antes de actualizar
    -- tabla eccs_comprobante_venta_historial
    --=============================================================
    insert into eccs_comprobante_venta_historial (
        id_eccs_comprobante_venta,
        id_eccs_cliente,
        fecha_creacion,
        folio,
        uuid,
        fecha_timbrado,
        id_eccs_estatus,
        id_eccs_moneda,
        id_eccs_empleado,
        id_sat_comprobantes,
        id_sat_forma_pago,
        id_sat_metodo_pago,
        id_eccs_aplicacion,
        id_eccs_sucursal,
        id_eccs_tipo_comprobante,
        id_eccs_cliente_domicilio,
        activo,
        id_sucursal_domicilio,
        id_sat_exportacion
    )
    select
        id,
        id_eccs_cliente,
        fecha_creacion,
        folio,
        uuid,
        fecha_timbrado,
        id_eccs_estatus,
        id_eccs_moneda,
        id_eccs_empleado,
        id_sat_comprobantes,
        id_sat_forma_pago,
        id_sat_metodo_pago,
        id_eccs_aplicacion,
        id_eccs_sucursal,
        id_eccs_tipo_comprobante,
        id_eccs_cliente_domicilio,
        activo,
        id_sucursal_domicilio,
        id_sat_exportacion
    from eccs_comprobante_venta
    where id = _id_nuevo;
    --=============================================================
    -- Respuesta: Retornar resultado exitoso con ID generado
    --=============================================================
    return json_build_object('success', true, 'id', _id_nuevo);
end;
$$;

alter function fn_create_comprobante_venta(integer, integer, integer, integer, integer, integer, integer, integer) owner to eccsadmin;

