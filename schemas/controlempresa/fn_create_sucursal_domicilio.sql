create or replace function "controlempresa".fn_create_sucursal_domicilio
(
    _id_sucursal int,
    _telefono varchar,
    _calle varchar,
    _num_exterior varchar,
    _num_interior varchar,
    _codigo_postal varchar
) returns json
    language plpgsql
as
$$
    --=================================================================
    -- Autor: Elizandro
    -- Fecha: 13/04/2026
    -- Descripción: agrega nuevo registro a la tabla eccs_sucursal_domicilio con valores por default
    --=================================================================
    declare
          _id_nuevo  integer;  -- id del registro insertado
    begin
        INSERT INTO public.eccs_sucursal_domicilio (
            id_sucursal, 
            telefono, 
            calle, 
            num_ext, 
            num_int, 
            cp
        ) 
        VALUES (
            _id_sucursal,
            _telefono,
            _calle,
            _num_exterior ,
            _num_interior, 
            _codigo_postal 
        )returning id into _id_nuevo;

    --=============================================================
    -- Respuesta: Retornar resultado exitoso con ID generado
    --=============================================================
    return json_build_object(
            'success', true,
            'id',      _id_nuevo,
            'titulo' ,'control empresa - sucursal - domicilio - nuevo domicilio.',
            'mensaje', 'se a creado con exito el nuevo domicilio'
           );
end;
$$;