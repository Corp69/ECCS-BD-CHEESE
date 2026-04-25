create  or replace function "controlempresa".fn_get_catalogo_sucursales() returns json
    stable
    language sql
as
$$
    --==================================================================================================================
    -- Autor: Elizandro
    -- Fecha: 13/04/2026.
    --==================================================================================================================
    select
        json_agg(
            json_build_object(
            'id', eccs_sucursal.id,
            'sucursal ', eccs_sucursal.descripcion,
            'estatus', eccs_estatus.descripcion,
            'fecha', TO_CHAR(eccs_sucursal.fecha, 'DD/MM/YYYY')
            )
        )
    from eccs_sucursal
        inner join eccs_estatus on eccs_estatus.id =  eccs_sucursal.id_estatus
    where
        eccs_sucursal.activo is true
$$;