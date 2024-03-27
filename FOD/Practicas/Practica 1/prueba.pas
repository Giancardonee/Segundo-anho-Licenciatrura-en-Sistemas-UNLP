const valorAlto = 9999; 
procedure leer (var archivoDet: archDetalle; var dato : regDetalle);
begin
    if (not (EOF(archivoDet))) then 
        read (archivoDet,dato)
    else dato.cod = valorAlto; 
end; 
end;

{prog principal}
begin 
    assign(archMae,"Maestro"); 
    assign(archDet,"Detalle"); 
    reset(archMae); reset (archDet); 
    read(archMae,redMae); 
    leer (archDet,regDet);
    {se cuenta la cantidad de ventas con codigo de producto igual 
    en el archivo detalle.}
    while (regDet.cod <> valorAlto) do 
        begin
            productoActual = regDet.cod; 
            total:=0; 
            while (productoActual = regDet.cod) do 
                begin
                    total:= total + regDet.cantVendidas; 
                    leer (archDet,regDet); 
                end;
            {se busca el producto del detalle en el maestro} 
            while (regMae.cod <> productoActual) do 
                read(archMae,regMae); 
            {se modifica el stock actual}
            while ()
        end; 
end. 






