create function app_menu(_id_usuario integer) returns json
as
$$
begin
    --==================================================================================================================
    -- elizandro: fecha: 01/04/2026
    -- observacion: devuelve el menu. v2
    --==================================================================================================================
    return json_build_object(
        'menu', (    select
                        array_to_json(array_agg(row_to_json(menu)))
                    from
                    (
                        select eccs_menu_modulo.descripcion label,
                            array_to_json(array_agg(row_to_json(datos))) as items
                        from (
                                select eccs_menu_vista.id,
                                        eccs_menu_vista.id_eccs_menu_modulo,
                                        eccs_menu_vista.descripcion as label,
                                        eccs_menu_vista.url,
                                        eccs_menu_vista.icon,
                                        eccs_menu_vista.activa
                                from eccs_menu
                                    inner join eccs_menu_vista on eccs_menu_vista.id = eccs_menu.id_eccs_menu_vista
                                        and eccs_menu_vista.activa is true -- bloquear vista a todos los usuarios
                                    inner join eccs_menu_modulo on eccs_menu_modulo.id = eccs_menu_vista.id_eccs_menu_modulo
                                        and eccs_menu_modulo.activo is true -- bloquear los modulos a todos los usuarios
                                where
                                    eccs_menu.id_eccs_empleado = _id_usuario
                                        and eccs_menu.activa is true -- bloquear la vista a un unico usuario en especifico
                                group by
                                    eccs_menu_vista.id,
                                    eccs_menu_vista.descripcion,
                                    eccs_menu_vista.url,
                                    eccs_menu_vista.icon,
                                    eccs_menu_vista.orden,
                                    eccs_menu_vista.activa
                                order by
                                    eccs_menu_vista.orden
                            ) datos
                            inner join eccs_menu_modulo on eccs_menu_modulo.id = datos.id_eccs_menu_modulo
                        group by eccs_menu_modulo.id
                    ) menu
                 )
    );
end;

$$;

