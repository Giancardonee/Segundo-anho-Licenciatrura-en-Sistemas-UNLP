{se deberá informar en un archivo de texto: nombre de producto,
descripción, stock disponible y precio de aquellos productos que tengan stock disponible por
debajo del stock mínimo.
 Pensar alternativas sobre realizar el informe en el mismo procedimiento de actualización, 
 o realizarlo en un procedimiento separado (analizarventajas/desventajas en cada caso).}

// Respuesta aca abajo paaa: 
{Para exportar el archivoTxt, conviene hacerlo en el mismo proceso donde actualizamos el maestro porque: 
* - ya tenemos el registro actualizado, de esta manera nos evitamos recorrer devuelta en otro modulo el archivo maestro
* - al tener el registro actualizado, directamente lo evaluamos y si cumple la condicion lo agregamos al archivoTxt
* - Una desventaja es que queda mas cargado el proceso actualizarMaestro. Si se separaria quedaria mas modularizado
* -Opté por esta alternativa, porque me pareció mas eficiente en cuanto a tiempos de ejecucion.}

program eje5; 
const
	valorAlto = 9999;
	cantDetalles = 30; 
type
	str20 = string[20]; 
	rMaestro = record
		codigo : integer; 
		nombre : str20; 
		descripcion : str20; 
		stockDisponible : integer; 
		stockMinimo : integer; 
		precio : real;
	end; 
	
	rDetalle = record
		codigo : integer;
		cantVendida : integer; 
	end; 
	
	archivoMaestro = file of rMaestro; 
	archivoDetalle = file of rDetalle;
	{array de 30 archivos detalles}
	arrayDetalles = array [1..cantDetalles] of archivoDetalle; 
	{array de 30 registro del archivo detalle. Este array es para leer cada detalle} 
	arrayRegistroDetalles = array [1..cantDetalles] of rDetalle; 
	
	
{====================================================}
{modulos para debugg}
procedure cargarMaestro (var maestro : archivoMaestro); 
var 
	rMae : rMaestro;
	i: integer;
	iString : str20; 
begin
	rewrite(maestro); 
	for i:= 1 to cantDetalles do 
		begin
			rMae.codigo:= i;
			Str ( i, iString);  
			rMae.nombre:= 'producto '+iString;
			rMae.descripcion:= 'Descripcion '+iString; 
			if (i < 28) then
				rMae.stockDisponible:= 100
			else rMae.stockDisponible:= 5;
			rMae.stockMinimo:= 1; 
			write(maestro,rMae); 
		end; 
	close(maestro); 
end;	
	
procedure cargarDetalle (var vD : arrayDetalles); 
var
	i,j : integer; 
	iString : str20;
	rDet : rDetalle;
begin
	for i:= 1 to cantDetalles do 
		begin
			Str (i, iString); 
			assign(vD[i],'detalle'+iString); 
			rewrite(vD[i]); 
			for j:= 1 to 3 do 
				begin
					rDet.codigo:= i; 
					rDet.cantVendida:= 20 ; {ajustar esto si se quiere ver los cambios}
					write(vD[i],rDet); 
				end;
			close(vD[i]); 
		end; 
end; 
procedure imprimirMaestro (var maestro : archivoMaestro); 
var
	rMae : rMaestro; 
begin
	reset(maestro); 
	while (not eof (maestro)) do 
		begin
			read(maestro,rMae); 
			Writeln (rMae.nombre, ' Stock disponible: ',rMae.stockDisponible, ' Stock minimo ',rMae.stockMinimo ); 
		end; 
	close(maestro); 
end; 	
{====================================================}
procedure leer (var detalle : archivoDetalle; var dato : rDetalle); 
begin
	if (not eof(detalle)) then 
		read (detalle,dato)
	else dato.codigo:= valorAlto; 
end; 
procedure inicializarDetalles (var vecArchDetalles : arrayDetalles; var vecRegDet: arrayRegistroDetalles); 
var
	i : integer; 
	iString : str20; 
begin
	for i:= 1 to cantDetalles do
		begin
			Str(i,iString); 
			{descomentar si se comentan los modulos de cargarMaestro y cargarDetalles}
			//assign(vecArchDetalles[i],'detalle_'+iString); 
			reset(vecArchDetalles[i]); 
			leer(vecArchDetalles[i],vecRegDet[i]); 
		end; 
end; 
procedure closeDetalles (var vecArchDetalles : arrayDetalles); 
var
	i : integer;
begin
	for i:= 1 to cantDetalles do 
		close(vecArchDetalles[i]); 
end; 
{====================================================}
{modulos para actualizar el maestro}
procedure minimo (var vDetalle : arrayDetalles; var vRegDet : arrayRegistroDetalles; var min : rDetalle); 
var
	i,posMin,codigoMin : integer; 
begin
	codigoMin:= 9999; 
	for i:= 1 to cantDetalles do 
		begin
				if (vRegDet[i].codigo < codigoMin) then begin 
					codigoMin:= vRegDet[i].codigo; 
					posMin:= i;
				end; 
		end; 
		min:= vRegDet[posMin]; 
		leer(vDetalle[posMin],vRegDet[posMin]); 
end; 
procedure evaluarStockDisponible (var archivoTxt : Text; rMae : rMaestro); 
begin
	if (rMae.stockDisponible < rMae.stockMinimo) then 
		writeln(archivoTxt, '|| Nombre producto: ',rMae.nombre, ' Descripcion: ',rMae.descripcion, ' Stock disponible: ',rMae.stockDisponible, ' Precio: ',rMae.precio:2:2 ); 
end; 

procedure actualizarMaestro (var maestro : archivoMaestro; var vecDet : arrayDetalles; var vecRegDet : arrayRegistroDetalles);
var
	productoActual,totalVendido : integer; 
	min : rDetalle;
	rMae : rMaestro; 
	archivoTxt : Text; 
begin
	assign (archivoTxt, 'productos_Stock_Menor_Al_Minimo'); 
	rewrite(archivoTxt); 
	reset(maestro);
	read(maestro,rMae); 
	minimo(vecDet,vecRegDet,min); 
	while (min.codigo <> valorAlto) do 
		begin
			productoActual:= min.codigo; 
			totalVendido:=0; 
			{calculamos las ventas del producto}
			while (productoActual = min.codigo) do 
				begin
					totalVendido:= totalVendido + min.cantVendida; 
					minimo(vecDet,vecRegDet,min); 
				end; 
			{buscamos en el maestro, el producto actual}
			while (rMae.codigo <> productoActual) do 
					read(maestro,rMae); 
			{cuando sale es porque encontro en el maestro el producto actual. solo debemos actualizar el stock disponible}
			rMae.stockDisponible:= rMae.stockDisponible - totalVendido; 
			seek(maestro,filePos(maestro)-1); 
			write (maestro,rMae); {actualizamos}
			 evaluarStockDisponible(archivoTxt,rMae); {este proceso agrega en un archivo txt aquellos producto con stock disp < stock actual}
			if (not eof(maestro)) then read(maestro,rMae); 
		end; 
	close(maestro); 
	closeDetalles(vecDet);
	close(archivoTxt);  
end; 
{====================================================}
{programa principal}
var
	maestro : archivoMaestro; 
	vecArchivosDetalle : arrayDetalles; 
	vecRegDetalle : arrayRegistroDetalles; 
begin
	assign(maestro,'maestro'); 
	cargarMaestro(maestro);  {para debugg}
	cargarDetalle(vecArchivosDetalle);  {para debugg}
	inicializarDetalles(vecArchivosDetalle,vecRegDetalle); 
	actualizarMaestro(maestro,vecArchivosDetalle,vecRegDetalle); 
	imprimirMaestro(maestro); 
end.
