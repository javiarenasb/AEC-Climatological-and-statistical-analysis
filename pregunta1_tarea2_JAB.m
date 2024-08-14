clear all
close all

%%%%%%%%%%%%%%%%
%  Pregunta 1
%%%%%%%%%%%%%%%%

% Temperatura del aire a 2 m de altura desde la superficie
lat = ncread('air.2m.mon.mean.nc','lat'); 
lon = ncread('air.2m.mon.mean.nc','lon'); 
aux = ncread('air.2m.mon.mean.nc','air');

%específicamos las latitudes y longitudes que queremos
lats = lat>=-30 & lat<=14;
longs = lon>=279 & lon<=330;

%vemos las posiciones donde se cumple nuestra condición
idx1=find(lats==1);
idx2=find(longs==1);

%nos quedamos con los datos que nos interesan
aire = aux(idx2,idx1,:);

%datos de precipitación
aux2 = ncread('prate.sfc.mon.mean.nc','prate');

aux2(aux2<0) = 0; %eliminamos los valores negativos de precipitación

precipitacion = aux2(idx2,idx1,:);

%Para que sea más fácil encontrar los meses que nos piden cambiamos el
%formato del tiempo que son las horas desde el 1 de enero de 1800 a las 00:00:00

tiempo = ncread('air.2m.mon.mean.nc','time');

fecha_inicio = datetime('1800-01-01 00:00:0.0', 'InputFormat', 'yyyy-MM-dd HH:mm:s.S');

fechas = fecha_inicio + hours(tiempo); %01-Jan-1948

fecha = datestr(fechas, 'dd/mm/yy'); %01/01/48

%nos quedamos solo con los meses
meses = str2num(fecha(:,4:5));

%buscamos las posiciones que contengan los meses de otoño
march = find(meses == 3);
april = find(meses == 4);
may = find(meses == 5);

time = [march;april;may];

%variable de temperatura de aire en otoño
fall_aire = aire(:,:,time);

%variable de precipitación en otoño
fall_pp = precipitacion(:,:,time);

clear march april may

%calculamos la correlación

for i=1:size(idx2) %longitud
    for j=1:size(idx1) %latitud
        %ocupamos squeeze para convertir los puntos en un vector
        correlacion(i, j, :) = corr(squeeze(fall_aire(i, j, :)), squeeze(fall_pp(i, j, :)));
    end
end

figure()
% Definimos la proyección y creamos los ejes
m_proj('miller','lon',[279 330],'lat',[-30 13]);
m_pcolor(lon(idx2),lat(idx1),(correlacion)');
shading interp;
a=colorbar('Location','EastOutside');
a.Label.String = 'Correlación';
m_grid('LineStyle','--','Box','fancy','tickdir','in','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Temperatura del aire a 2 m y tasa de precipitación en otoño','FontSize',11.5);
colormap('jet');
