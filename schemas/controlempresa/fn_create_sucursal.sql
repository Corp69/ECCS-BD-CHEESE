create or replace function "controlempresa".fn_create_sucursal(
    _sucursal varchar
) returns json
    language plpgsql
as
$$
    --=================================================================
    -- Autor: Elizandro
    -- Fecha: 13/04/2026
    -- Descripción: agrega una nueva sucursal
    --=================================================================
    declare
          _id_nuevo  integer;  -- id del registro insertado
    begin

    INSERT INTO public.eccs_sucursal(
        descripcion,
        fecha
    )
    VALUES (
        _sucursal,
        now()
    )returning id into _id_nuevo;

    --=============================================================
    -- Respuesta: Retornar resultado exitoso con ID generado
    --=============================================================
    return json_build_object(
            'success', true,
            'id',      _id_nuevo,
            'titulo' ,'control empresa - sucursal - crear nueva sucursal.',
            'mensaje', 'se a creado con exito la nueva sucursal'
           );
end;
$$;