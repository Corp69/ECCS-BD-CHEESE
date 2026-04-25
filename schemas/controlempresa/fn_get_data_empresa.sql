create function "controlempresa".fn_get_data_empresa() returns json
    stable
    language sql
as
$$
    --==================================================================================================================
    -- Autor: Elizandro
    -- Fecha: 13/04/2026
    -- Observación: Esta Funcion devuelve la busqueda de los productos.
    --==================================================================================================================
    select
        json_build_object(
            'rfc',eccs_empresa.RFC,
            'nombreComercial',eccs_empresa.nombrecomercial,
            'estatus',eccs_estatus.descripcion,
            'avisoPrivacidad',eccs_empresa.aviso_privacidad
        )
    from eccs_empresa
        inner join eccs_estatus on eccs_estatus.id = eccs_empresa.id_estatus
        where
            eccs_empresa.activa is true
            and eccs_empresa.id = 1;
$$;