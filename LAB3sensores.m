clear; clc; close all;


puerto = "COM3";      
baudrate = 9600;

arduino = serialport(puerto, baudrate);

% Parámetros de adquisición
tiempo_total = 120;   % segundos (2 minutos)
fs = 50;              % Hz (frecuencia de muestreo)
dt = 1/fs;
N = tiempo_total * fs;

% Inicialización de variables
senal = zeros(1, N);
tiempo = (0:N-1)*dt;

disp("Iniciando captura...");

%% 2. Captura de señal
for i = 1:N
    dato = readline(arduino);
    senal(i) = str2double(dato);
    pause(dt);
end

disp("Captura finalizada");

%% 3. Filtrado (Pasa banda 0.5 - 5 Hz)
senal_filtrada = bandpass(senal, [0.5 5], fs);

% Visualización
figure;
plot(tiempo, senal, 'Color', [0.7 0.7 0.7]);
hold on;
plot(tiempo, senal_filtrada, 'b');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Señal PPG (Original vs Filtrada)');
legend('Original', 'Filtrada');
grid on;



%% 4. Detección de latidos

% Picos (máximos)
[pks, locs] = findpeaks(senal_filtrada, ...
    'MinPeakDistance', round(0.5*fs), ...
    'MinPeakHeight', mean(senal_filtrada));

% Valles (mínimos)
[mins, locs_min] = findpeaks(-senal_filtrada);
mins = -mins;

% Visualización
figure;
plot(tiempo, senal_filtrada);
hold on;
plot(tiempo(locs), pks, 'ro');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Detección de picos (latidos)');
grid on;


%% 5. Cálculo del SPI por latido

SPI = [];

for i = 1:length(locs)-1
    
    % Segmento entre picos
    idx = locs(i):locs(i+1);
    segmento = senal_filtrada(idx);
    
    % Pico y valle
    pico = max(segmento);
    valle = min(segmento);
    
    % Componentes
    AC = pico - valle;
    DC = mean(segmento);
    
    % SPI
    spi_val = AC / DC;
    
    SPI = [SPI spi_val];
    
    fprintf("Latido %d -> SPI = %.4f\n", i, spi_val);
end

%% 6. Evolución del SPI

tiempo_spi = tiempo(locs(1:length(SPI)));

figure;
plot(tiempo_spi, SPI, '-o');
xlabel('Tiempo (s)');
ylabel('SPI');
title('Evolución del SPI');
grid on;

%% 7. Fases del experimento (CPT)

figure;
plot(tiempo_spi, SPI, '-o');
hold on;

% Líneas de referencia
xline(40, '--r', 'Inicio CPT');
xline(80, '--r', 'Fin CPT');

xlabel('Tiempo (s)');
ylabel('SPI');
title('SPI durante Cold Pressor Test');
grid on;

%% 8. Análisis por fases

% Índices por fase
reposo1 = tiempo_spi < 40;
cpt = (tiempo_spi >= 40) & (tiempo_spi < 80);
reposo2 = tiempo_spi >= 80;

% Promedios
SPI_reposo1 = mean(SPI(reposo1));
SPI_cpt = mean(SPI(cpt));
SPI_reposo2 = mean(SPI(reposo2));

fprintf("\n--- RESULTADOS ---\n");
fprintf("SPI Reposo inicial: %.4f\n", SPI_reposo1);
fprintf("SPI durante CPT: %.4f\n", SPI_cpt);
fprintf("SPI Recuperación: %.4f\n", SPI_reposo2);