create  or replace function "controlventas".fn_get_catalogo_clientes() returns json
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
            'nombre',eccs_cliente.nombre,
            'rfc', eccs_cliente.rfc,
            'telefono',eccs_cliente.telefono,
            'correo', eccs_cliente.correo,
            'estatus',eccs_estatus.descripcion
            -- 'tipoCliente', eccs_tipo_cliente.descripcion
            )
        )
    from eccs_cliente
        inner join eccs_estatus on eccs_estatus.id = eccs_cliente.id_estatus
        inner join eccs_tipo_cliente on eccs_tipo_cliente.id = eccs_cliente.id_tipo_cliente
    where
        eccs_cliente.activo is true
$$;

alter function fn_get_catalogo_clientes() owner to eccsadmin;

