clear all 
close all

lon = ncread('cpverano.nc','longitude'); %longitud 
lat = ncread('cpverano.nc','latitude'); % latitud

%datos desde 1994 a 2024 de precipitación por convección de verano
cpv = ncread('cpverano.nc','cp');
t_verano = ncread('cpverano.nc','time');

%Precipitación total en brasil
total = ncread('todo.nc','tp');
t_anual = ncread('todo.nc','time');

%presion super
psv = ncread('PSV.nc','sp');

%preci por convección en invierno
cpi = ncread('cpinvierno.nc','cp');
t_inv = ncread('cpinvierno.nc','time');

%presion super inv
psi = ncread('PSI.nc','sp');

%expver de longitud 2, versión experimental de ERA5, aquella longitud que 
%tiene los datos es la 1

for i = 1:length(t_verano)
    CPV(:,:,:,i) = cpv(:,:,:,1,i); 
    PSV(:,:,:,i) = psv(:,:,:,1,i);
    
end


%number inidica precisión de los datos, la promediamos para obtener la
%mejor estimación

CPV = mean(CPV,3); %así nos queda number con tamaño 1
CPV = squeeze(CPV);

PSV = mean(PSV,3); %así nos queda number con tamaño 1
PSV = squeeze(PSV);

TOTAL = mean(total,3); %así nos queda number con tamaño 1
TOTAL = squeeze(TOTAL);

CPI = mean(cpi,3);
CPI = squeeze(CPI);

PSI = mean(psi,3);
PSI = squeeze(PSI);

%Trabajamos la matriz tiempo
fecha= datetime('1900-01-01 00:00:0.0', 'InputFormat', 'yyyy-MM-dd HH:mm:ss.S');

%año completo
year = fecha + hours(t_anual);
date_year = datevec(year);

%verano
verano = fecha + hours(t_verano);
verano = verano(1:180,:);
date_ver = datevec(verano);

%invierno
winter = fecha + hours(t_inv);
date_inv = datevec(winter);

clear t_anual t_inv t_verano fecha i cpi cpv psi psv total
%% Años completos

%Y separamos por meses, pero tenemos ojo con los años bisiestos
c = 1;
bisiestos = zeros(8,1);
for i = 1996:4:2023
    fb = find(date_year(:,1) == i & date_year(:,2) == 2);
    bisiestos(c,:) = fb;
    c = c +1;
end

clear c

bisiestos = bisiestos(1:7,:);

TOTAL(:,:,bisiestos)  = TOTAL(:,:,bisiestos) * 1000 * 29; 


%enero marzo mayo julio agosto oct dic tienen 31 días
emmjaod = [];
mimpar = [1, 3, 5, 7, 8, 10, 12];
for i = 1:length(mimpar)
    impar = find(date_year(:,2) == mimpar(i));
    emmjaod = [emmjaod;impar];
end

emmjaod = sort(emmjaod,'ascend');

TOTAL(:,:,emmjaod)  = TOTAL(:,:,emmjaod) * 1000 * 31;
 

%abril junio sept nov
ajsn = [];
par = [4, 6, 9, 11];
for i = 1:length(par)
    pares = find(date_year(:,2) == par(i));
    ajsn = [ajsn;pares];
end

ajsn = sort(ajsn,'ascend');

TOTAL(:,:,ajsn)  = TOTAL(:,:,ajsn) * 1000 * 30;


%el resto de los febreros
feb = find(date_year(:,2) == 2);
todosf = ismember(feb,bisiestos);

%queremos los no repetidos
febrero = feb(~todosf);

TOTAL(:,:,febrero)  = TOTAL(:,:,febrero) * 1000 * 28;

%Con ello ya tenemos todos los días en mm

%%
%solo verano

%enero marz  may dec
emmd = [];
solover = [1, 3, 5, 12];
for i = 1:length(solover)
    summer= find(date_ver(:,2) == solover(i));
    emmd = [emmd;summer];
end

emmd = sort(emmd,'ascend');
CPV(:,:,emmd)  = CPV(:,:,emmd) * 1000 * 31; %ahora está en mm

%abril
abril = find(date_ver(:,2) == 4);
CPV(:,:,abril)  = CPV(:,:,abril) * 1000 * 30;


%febrero bisiesto
c = 1;
bisiestos2 = zeros(8,1);
for i = 1996:4:2023
    fb2 = find(date_ver(:,1) == i & date_ver(:,2) == 2);
    bisiestos2(c,:) = fb2;
    c = c +1;
end
bisiestos2 = bisiestos2(1:7,:);
CPV(:,:,bisiestos2) = CPV(:,:,bisiestos2) *1000 *29;

%el resto de los febreros
feb2 = find(date_ver(:,2) == 2);
todosf2 = ismember(feb2,bisiestos2);

%queremos los no repetidos
febrero2 = feb2(~todosf2);

CPV(:,:,febrero2)  = CPV(:,:,febrero2) * 1000 * 28;

%% invierno

%junio sep nov
jsn = [];
tres = [6, 9, 11];
for i = 1:length(tres)
    three= find(date_inv(:,2) == tres(i));
    jsn= [jsn;three];
end

jsn = sort(jsn,'ascend');
CPI(:,:,jsn) = CPI(:,:,jsn) * 1000 * 30;

%julio agost oct
jao = [];
tresyuno = [7, 8, 10];
for i = 1:length(tresyuno)
    threeone= find(date_inv(:,2) == tresyuno(i));
    jao= [jao;threeone];
end

jao = sort(jao,'ascend');
CPI(:,:,jao) = CPI(:,:,jao) * 1000 * 31;

%%
CPV = CPV(:,:,1:180);

cpv_data = reshape(CPV,97*81,180);
cpi_data = reshape(CPI,97*81,180);
pt_data = reshape(TOTAL,97*81,360);

%%
cpv_prom = mean(cpv_data(:,6:179)); %promedia las precipitaciones de cada mes de diciembre a mayo
cpi_prom = mean(cpi_data); %invierno
pt_prom = mean(pt_data);

year = 1994:2023;

%año completo
for i=1:30 %años

    inicio2 = (i-1)*12 + 1;
    fin2 = inicio2 +11;

    tomamos3 = pt_prom(inicio2:fin2);

    sum_year = sum(tomamos3);
 
    acum_year(i) = sum_year;
end

promediototal = mean(acum_year);

figure
bar(year,acum_year,'cyan')
hold on
yline(promediototal,'b', 'LineWidth', 2.5)
xlabel('Años')
ylabel('Precipitación [mm]')
axis tight
grid minor
legend('','Media')
ylim([0 2000])
sgtitle('\bf{Precipitación total acumulada}')

year2 = 1995:2023;

%verano, e invierno p. convectiva
for i=1:29

    inicio = (i-1)*6 + 1;
    fin = inicio +5;

    tomamos = cpv_prom(inicio:fin);
    tomamos2 = cpi_prom(inicio:fin);

    sum_ver = sum(tomamos);
    sum_inv = sum(tomamos2);

    acum_ver(i) = sum_ver;
    acum_inv(i) = sum_inv;
end

promver = mean(acum_ver);
prominv = mean(acum_inv);

%precipitació n total de enero a mayo 
figure
subplot 211
bar(year2,acum_ver,'cyan')
hold on
yline(promver,'b', 'LineWidth', 2.5)
xlabel('Años')
ylabel('Precipitación [mm]')
title('Diciembre a Mayo')
axis tight
grid minor
legend('','Media')
ylim([0 1000])

subplot 212
bar(year2,acum_inv,'cyan')
hold on
yline(prominv,'b', 'LineWidth', 2.5)
xlabel('Años')
ylabel('Precipitación [mm]')
title('Junio a Noviembre')
axis tight
grid minor
legend('','Media')
ylim([0 1000])

sgtitle('\bf{Precipitación convectiva}')



%%
%Trabajamos con la presión superficial (verano)
PSV = PSV(:,:,1:180);
% Inicializamos la matriz para almacenar las correlaciones

% Recorremos cada punto en las dos primeras dimensiones
for i = 1:length(lon) % longitud
    for j = 1:length(lat) % latitud
        % Utilizamos squeeze para convertir los puntos en un vector
        series_CPV = squeeze(CPV(i, j, :));
        series_PSV = squeeze(PSV(i, j, :));
        
        % Calculamos la correlación entre las dos series temporales
        correlacion(i,j) = corr(series_CPV, series_PSV);
    end
end

% Graficar la matriz de correlaciones
figure
m_proj('miller', 'lon', [-75 -27], 'lat', [-34 6]);
m_pcolor(lon, lat, correlacion');
shading interp;
a = colorbar('Location', 'EastOutside','Limits',[-0.8,0.8]);
a.Label.String = 'Correlación';
m_grid('LineStyle', '--', 'Box', 'fancy', 'tickdir', 'in', 'FontSize', 9);
m_gshhs_i('Color', 'k', 'LineWidth', 2);
colormap('cool');
xlabel('Longitud');
ylabel('Latitud');
sgtitle('\bf{Precipitación convectiva y presión superficial}')



%invierno

% Recorremos cada punto en las dos primeras dimensiones
for i = 1:length(lon) % longitud
    for j = 1:length(lat) % latitud
        % Utilizamos squeeze para convertir los puntos en un vector
        series_CPI = squeeze(CPI(i, j, :));
        series_PSI = squeeze(PSI(i, j, :));
        
        % Calculamos la correlación entre las dos series temporales
         correlacion2(i,j) = corr(series_CPI, series_PSI);
    end
end

figure
m_proj('miller', 'lon', [-75 -27], 'lat', [-34 6]);
m_pcolor(lon, lat, correlacion2');
shading interp;
a = colorbar('Location', 'EastOutside');
a.Label.String = 'Correlación';
m_grid('LineStyle', '--', 'Box', 'fancy', 'tickdir', 'in', 'FontSize', 9);
m_gshhs_i('Color', 'k', 'LineWidth', 2);
colormap('cool');
xlabel('Longitud');
ylabel('Latitud');
sgtitle('\bf{Precipitación convectiva y presión superficial}')




%% direccion y velocidad promedio anual
ucom = ncread('u_completo.nc','u10');
vcom = ncread('v_completo.nc','v10');

timec = ncread('u_completo.nc','time');

fecha= datetime('1900-01-01 00:00:0.0', 'InputFormat', 'yyyy-MM-dd HH:mm:ss.S');

%año completo
anios = fecha + hours(timec);
anios = anios(1:360,:);

%trabajamos la dimension number
ubc = mean(ucom,3); %así nos queda number con tamaño 1
ubc= squeeze(ubc);

vbc= mean(vcom,3); %así nos queda number con tamaño 1
vbc= squeeze(vbc);

%trabajamos dimen expver
for i = 1:length(anios)
%La tercera dimensión es expver de longitud 2, que corresponde a una versión experimental
%de ERA5, aquella longitud que tiene los datos es la 1

    UBC(:,:,i) = ubc(:,:,1,i); %guardamos los datos en una nueva matriz
    VBC(:,:,i) = vbc(:,:,1,i);

end

%calculamos la velocidad
velocidad = sqrt(UBC.^2 + VBC.^2);

%direccion
direccion_c = atan2(-UBC,-VBC) .* (180/pi);
direccion_c = mod(direccion_c + 360, 360);

%calculamos las medias de cada componente
%Calculamos las medias
for i=1:size(lon) %longitud
    for j=1:size(lat) %latitud
        v_media(i,j,:) = nanmean(squeeze(velocidad(i, j, :))); %media de la velocidad
        dx_media(i,j,:) = nanmean(squeeze(UBC(i, j, :))); %media componente x
        dy_media(i,j,:) = nanmean(squeeze(VBC(i, j, :))); %media componente y
    end
end

dirC_media = atan2(-dx_media,-dy_media) .* (180/pi); %media de la dirección

%En ángulos meteorológicos
dirC_media = mod(dirC_media+360, 360);

figure
contourf(lon,lat,v_media')  % Visualizar áreas donde la diferencia es significativa
h = colorbar; 
h.Label.String = 'Velocidad [m/s]'; 
title('Velocidad y dirección promedio anual')
xlabel('Longitud')
ylabel('Latitud')
hold on 
scale_factor = 7;
quiver(lon, lat, dx_media', dy_media',scale_factor, 'k', 'LineWidth', 1.5);
xlim([-75 -27])
ylim([-34 6])

%% ahora para el verano

busca = ismember(anios, verano);
filas = find(busca==1);

%partimos en diciembre de 1994 y terminamos en mayo de 2023
filas = filas(6:179,:);

UBV = UBC(:,:,filas);
VBV = VBC(:,:,filas);

%calculamos la velocidad
velocidadv = sqrt(UBV.^2 + VBV.^2);

%direccion
direccion_v = atan2(-UBV,-VBV) .* (180/pi);
direccion_v = mod(direccion_v + 360, 360);

%calculamos las medias de cada componente
%Calculamos las medias
for i=1:size(lon) %longitud
    for j=1:size(lat) %latitud
        v_mediav(i,j,:) = nanmean(squeeze(velocidadv(i, j, :))); %media de la velocidad
        dx_mediav(i,j,:) = nanmean(squeeze(UBV(i, j, :))); %media componente x
        dy_mediav(i,j,:) = nanmean(squeeze(VBV(i, j, :))); %media componente y
    end
end

dirV_media = atan2(-dx_mediav,-dy_mediav) .* (180/pi); %media de la dirección

%En ángulos meteorológicos
dirV_media = mod(dirV_media+360, 360);

figure
contourf(lon,lat,v_mediav')  % Visualizar áreas donde la diferencia es significativa
h = colorbar; 
h.Label.String = 'Velocidad [m/s]'; 
title('Velocidad y dirección promedio (1° período)')
xlabel('Longitud')
ylabel('Latitud')
hold on 
scale_factor = 1.5;
quiver(lon, lat, dx_mediav', dy_mediav',scale_factor, 'k', 'LineWidth', 1.5);
xlim([-75 -27])
ylim([-34 6])

%% invierno
busca2 = ismember(anios, winter);
filas2 = find(busca2==1);

%partimos en diciembre de 1994 y terminamos en mayo de 2023
UBI = UBC(:,:,filas2);
VBI = VBC(:,:,filas2);

%calculamos la velocidad
velocidadi = sqrt(UBI.^2 + VBI.^2);

%direccion
direccion_i = atan2(-UBI,-VBI) .* (180/pi);
direccion_i = mod(direccion_i + 360, 360);

%calculamos las medias de cada componente
%Calculamos las medias
for i=1:size(lon) %longitud
    for j=1:size(lat) %latitud
        v_mediai(i,j,:) = nanmean(squeeze(velocidadi(i, j, :))); %media de la velocidad
        dx_mediai(i,j,:) = nanmean(squeeze(UBI(i, j, :))); %media componente x
        dy_mediai(i,j,:) = nanmean(squeeze(VBI(i, j, :))); %media componente y
    end
end

dirI_media = atan2(-dx_mediai,-dy_mediai) .* (180/pi); %media de la dirección

%En ángulos meteorológicos
dirI_media = mod(dirI_media+360, 360);

figure
contourf(lon,lat,v_mediai')  % Visualizar áreas donde la diferencia es significativa
h = colorbar; 
h.Label.String = 'Velocidad [m/s]'; 
title('Velocidad y dirección promedio (2° período)')
xlabel('Longitud')
ylabel('Latitud')
hold on 
scale_factor = 1.5;
quiver(lon, lat, dx_mediai', dy_mediai',scale_factor, 'k', 'LineWidth', 1.5);
xlim([-75 -27])
ylim([-34 6])




