# LAB3-Instrumentación
# Cálculo ambulatorio del índice pletismográfico quirúrgico (SPI)


# Fotopletismografía (PPG) y Cálculo del SPI



##  DESCRIPCIÓN

Este proyecto presenta el desarrollo de un sistema para la adquisición y procesamiento de señales de fotopletismografía (PPG), con el objetivo de analizar variaciones del volumen sanguíneo periférico y calcular el Índice Pletismográfico Quirúrgico (SPI).

El análisis se realiza bajo condiciones de reposo y durante la aplicación del Cold Pressor Test (CPT), permitiendo observar la respuesta fisiológica del sistema cardiovascular, así como se reslta la importancia de la extracción y cálculo de ciertas características de la onda para estimar el balance nocicepción-analgesia.

---

##  OBJETIVOS

Objetivo General: Desarrollar un sistema de medición continua del índice
pletismográfico quirúrgico (SPI) en condiciones ambulatorias.

Objetivos Específicos

• Reconocer las características fundamentales de la onda de pulso a partir de
las cuales se obtiene el SPI.

• Construir un sistema que calcule el SPI en tiempo real y bajo condiciones
ambulatorias.

• Validar el funcionamiento del sistema desarrollado mediante un método que
induzca una respuesta fisiológica similar a la que produce el dolor agudo.

---
##  MARCO TEÓRICO

###  Fotopletismografía (PPG)

La fotopletismografía (PPG) es una técnica óptica no invasiva utilizada para medir las variaciones del volumen sanguíneo en los tejidos periféricos. Se basa en la emisión de luz hacia la piel y la detección de la luz reflejada o transmitida, la cual varía en función de los cambios pulsátiles del flujo sanguíneo asociados al ciclo cardíaco.

La señal PPG está compuesta por dos componentes principales:

- Componente DC: asociada a tejidos, sangre no pulsátil y absorción constante.
- Componente AC: relacionada con la variación pulsátil del volumen sanguíneo.

Esta técnica es ampliamente utilizada en dispositivos biomédicos como oxímetros de pulso y sistemas de monitoreo cardiovascular.

---

###  Índice Pletismográfico Quirúrgico (SPI)

El Índice Pletismográfico Quirúrgico (SPI) es un parámetro derivado de la señal PPG que permite evaluar el equilibrio entre la actividad del sistema nervioso simpático y parasimpático, siendo especialmente útil en entornos clínicos para monitorear el nivel de estrés o nocicepción en pacientes.

El SPI se basa en la relación entre la amplitud pulsátil (componente AC) y el nivel basal de la señal (componente DC), lo que permite inferir cambios en la vasoconstricción periférica. Durante estados de activación simpática, como el dolor o el estrés, se produce una disminución en la amplitud de la señal PPG debido a la vasoconstricción.

Este se calcula de la forma  SPI= 100 - (0.33 X PPGAnorm + 0.67 X HBInorm), en donde PPGAnorm es la amplitud normalizada del pulso y HBInorm es el intervalo entre latidos normalizado.

---

###  Cold Pressor Test (CPT)

El Cold Pressor Test (CPT) es una prueba fisiológica utilizada para evaluar la respuesta del sistema nervioso autónomo ante un estímulo de estrés. Consiste en la inmersión de una extremidad (generalmente la mano) en agua fría (0–5 °C) durante un tiempo determinado.

Esta prueba induce la activación del sistema nervioso simpático, el incremento de la presión arterial, la vasoconstricción periférica y por ende permite notar los cambios en señales fisiológicas como la PPG. El CPT es ampliamente utilizado en investigación cardiovascular y estudios de regulación autonómica.

###  Protocolo experimental (CPT)

| Fase            | Tiempo        | Descripción                  |
|-----------------|-------------|-----------------------------|
| Reposo inicial  | 0 – 40 s    | Condición basal             |
| CPT             | 40 – 80 s   | Estímulo frío               |
| Recuperación    | 80 – 120 s  | Retorno a estado basal      |

---

##  Procedimiento 

 Se buscó inicialmente realizar en proto-board el circuito de la siguiente figura:
 
   <img width="456" height="256" alt="image" src="https://github.com/user-attachments/assets/0cda07be-5403-4c85-b6ce-f337ccd13114" />

La cual es extraida de la guía de laboratorio (Figura 1. Circuito para capturar las variaciones del volumen sanguíneo periférico).
De este modo utilizando un acoplador óptico modificado se pretendía convertir en yn sensor de reflectacia, sin embargo en la continuidad de la práctica se realizó un cambio para utilizar únicamente el sensor óptico MAX30102, esto para garantizar mejores resultados ya que del modo anterior no eran nada óptimos.

<img width="873" height="1280" alt="image" src="https://github.com/user-attachments/assets/3e1bb678-2ec0-4b4f-abdd-7dd0d973245a" />

Circuito resultante con el uso del MAX30102.

## Código Matlab

Se diseñó un código en MATLAB que captura la señal con el propósito de calcular el SPI de cada pulsación. Posteriormente se realiza la captura de 2 minutos mientras se utiliza la maniobra CPT. Paralelamente un integrante tomó los datos visualizados durante el uso de la maniobra.


###  Protocolo experimental (CPT)

| Fase            | Tiempo        | Descripción                  |
|-----------------|-------------|-----------------------------|
| Reposo inicial  | 0 – 40 s    | Condición basal             |
| CPT             | 40 – 80 s   | Estímulo frío               |
| Recuperación    | 80 – 120 s  | Retorno a estado basal      |


<img width="1148" height="1351" alt="image" src="https://github.com/user-attachments/assets/c29cedf3-9070-49d7-9453-e5d241199864" />

A su vez se espera obtener y visualizar la evolución del SPI en función del tiempo.

```matlab
clear; clc; close all;

%% CONFIGURACIÓN
puerto = "COM3";
baud = 115200;
fs = 100;

T = input("Ingrese tiempo de captura (segundos): ");
window_sec = input("Ventana visible (segundos): ");

window_samples = fs * window_sec;

%% SERIAL
s = serialport(puerto, baud);

%% BUFFER
max_samples = fs*T*2;
data = zeros(max_samples,1);

disp("Capturando señal...");

%% FIGURAS
figure('Position',[100 100 1000 600]);

subplot(2,1,1)
h_ppg = plot(nan,nan,'b','LineWidth',1.5); hold on;
h_peaks = plot(nan,nan,'ro');
h_valleys = plot(nan,nan,'go');
title('PPG en tiempo real');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

subplot(2,1,2)
h_spi = plot(nan,nan,'LineWidth',2);
title('SPI en tiempo real');
xlabel('Tiempo (s)');
ylabel('SPI');
grid on;

%% VARIABLES SPI
SPI = [];
t_spi = [];

tic;
i = 1;

while toc < T
    
    val = str2double(readline(s));
    
    if isnan(val)
        if i > 1
            val = data(i-1);
        else
            val = 0;
        end
    end
    
    data(i) = val;
    
    %% PROCESAMIENTO EN VIVO
    ppg = detrend(data(1:i));
    ppg = movmean(ppg,8);
    ppg = ppg - mean(ppg);
    
    if length(ppg) > fs*2
        ppg2 = ppg(fs*2:end);
    else
        i = i + 1;
        continue;
    end
    
    time = (0:length(ppg2)-1)/fs;
    
    %% DETECCIÓN DE PICOS (MÉTODO ALPINISTA)
    media = mean(ppg2);
    sigma = std(ppg2);
    
    umbral = media + 0.8*sigma;
    umbral_v = media - 0.8*sigma;
    
    peaks = [];
    locs_p = [];
    valleys = [];
    locs_v = [];
    
    for k = 2:length(ppg2)-1
        
        if ppg2(k) > ppg2(k-1) && ppg2(k) > ppg2(k+1) && ppg2(k) > umbral
            peaks(end+1) = ppg2(k);
            locs_p(end+1) = k;
        end
        
        if ppg2(k) < ppg2(k-1) && ppg2(k) < ppg2(k+1) && ppg2(k) < umbral_v
            valleys(end+1) = ppg2(k);
            locs_v(end+1) = k;
        end
    end
    
    %% SPI CORRECTO (ESCALADO FISIOLÓGICO)

if length(locs_p) > 3 && length(locs_v) > 3
    
    % PPGA
    n = min(length(peaks), length(valleys));
    PPGA = peaks(1:n) - valleys(1:n);
    
    % HBI
    HBI = diff(locs_p)/fs;
    
    m = min(length(PPGA)-1, length(HBI));
    PPGA = PPGA(1:m);
    HBI = HBI(1:m);
    
    %% NORMALIZACIÓN CORRECTA
    
    % PPGA (relativa)
    PPGA_norm = PPGA / mean(PPGA);
    
    % HBI (escala fisiológica)
    HBI_min = 0.6;   % latido rápido
    HBI_max = 1.2;   % latido lento
    
    HBI_norm = (HBI - HBI_min) / (HBI_max - HBI_min);
    
    % limitar entre 0 y 1
    HBI_norm = max(0, min(1, HBI_norm));
    
    % también limitar PPGA
    PPGA_norm = max(0, min(2, PPGA_norm));
    
    %% SPI REAL
    SPI = 100 - (0.33*PPGA_norm + 0.67*HBI_norm)*100;
    
    t_spi = locs_p(2:m+1)/fs;
end
    
    %% ACTUALIZAR GRÁFICAS
    
    % PPG
    set(h_ppg,'XData',time,'YData',ppg2);
    set(h_peaks,'XData',locs_p/fs,'YData',peaks);
    set(h_valleys,'XData',locs_v/fs,'YData',valleys);
    
    % SPI
    set(h_spi,'XData',t_spi,'YData',SPI);
    
    drawnow;
    
    i = i + 1;
end

disp("Captura finalizada");
```

## RESULTADOS

<img width="1245" height="846" alt="image" src="https://github.com/user-attachments/assets/a757823e-7142-44f3-bbf9-2bea30e055c6" />


###  Adquisición de señal REVISAR

- Sensor óptico de reflectancia (MAX30102)
- ESP32 como sistema de adquisición
- Comunicación serial con MATLAB
- Circuito
 

```matlab
#include <Wire.h>
#include "MAX30105.h"

MAX30105 sensor;

long irValue;
float dc = 0;

void setup() {
  Serial.begin(115200);
  Wire.begin();

  if (!sensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("MAX30102 no encontrado");
    while (1);
  }

  sensor.setup(
    50,    // brillo LED (30–60)
    4,     // promedio
    2,     // modo (Red + IR)
    100,   // sample rate
    411,   // pulse width
    4096   // rango ADC
  );

  Serial.println("Sensor listo");
}

void loop() {

  irValue = sensor.getIR();

  dc = 0.95 * dc + 0.05 * irValue;
  float ac = irValue - dc;

  float signal = -ac; 

  Serial.println(signal);

  delay(10); 
}
```
---

<img width="945" height="640" alt="image" src="https://github.com/user-attachments/assets/31295f3a-66f2-4289-bd79-aee9e4619b5f" />


###  Procesamiento de señal en MATLAB

1. **Captura de datos**
   - Duración: 120 segundos
   - Frecuencia de muestreo: 50 Hz

2. **Filtrado**
   - Filtro pasa banda: 0.5 – 5 Hz
  
```matlab
senal_filtrada = bandpass(senal, [0.5 5], fs);
```

3. **Detección de latidos**
   - Algoritmo `findpeaks`
   - Identificación de picos y valles

```matlab
[pks, locs] = findpeaks(senal_filtrada, ...
    'MinPeakDistance', round(0.5*fs), ...
    'MinPeakHeight', mean(senal_filtrada));
```

4. **Cálculo del SPI**

\[
SPI = \frac{AC}{DC}
\]

Donde:

- **AC**: amplitud del pulso (pico - valle)  
- **DC**: valor medio de la señal  
```matlab
SPI = [];

for i = 1:length(locs)-1
    idx = locs(i):locs(i+1);
    segmento = senal_filtrada(idx);

    AC = max(segmento) - min(segmento);
    DC = mean(segmento);

    SPI = [SPI AC/DC];
end
```
---


---


##  ANÁLISIS COMPLETAAAAAAR

2. Contrastar el funcionamiento del sistema desarrollado con lo que hace un
monitor de signos vitales comercial.

4. Obtener cuantitativamente el índice pletismográfico quirúrgico (SPI).
5. Plantear hipótesis o explicaciones posibles de los resultados obtenidos desde
la fisiología.

• 1. Compare los valores del SPI obtenidos durante la práctica con
los que frecuentemente se observan durante una cirugía para proporcionar
el nivel óptimo de anestesia.
# 2. Evalúe el alcance y las posibles limitaciones de emplear el
sistema desarrollado para cuantificar el dolor que percibe una persona.


## PREGUNTAS PARA LA DISCUSIÓN

• ¿Cómo se relacionan las variaciones del volumen sanguíneo
periférico con el balance autonómico?

• ¿Cómo se compara el SPI con otros índices comúnmente
empleados en cirugía, como el índice nocicepción-analgesia (ANI) y el
índice de perfusión?

El volumen sanguíneo periférico está directamente regulado por el equilibrio entre el sistema simpático y el parasimpático, el sistema simpático está directamente relacionado con el estrés y dolor y este predomina en la vasoconstricción periférica cuando baja el volumen sanguíneo en la piel y la amplitud de la señal pletismográfica, mientras que la fracuancia cardíaca aumenta. Por otra parte el sistema parasimpático realacionado con el reposo y la analgesia muestra su predominio en la vasodilatación cuandoel volumen   sanguíneo periférico aumenta, así como la amplitud, mientras que la frecuencia cardíaca baja.

Los índices SPI, ANI e Índice de perfusión permiten evaluar el dolor, estres y balance autonómico. El SPI está basado en la amplitud pletismográfica que es el volumen periférico como es mensionado antes, a su vez, se basa en el intervalo de pulso y frecuencia cardíaca y refleja la respuesta simpática al dolor, tiene una escala de 0 a 100, entre más SPI hay, significa más dolor o estrés, este es muy utilizado en anestesia general.

La ANI (Analgesia Nociception Index) esta basada en la variabilidad de la frecuencia cardíaca (HRV), específicamente en la modulación parasimpática, este también va de 0 a 100, sin embargo en este la subida del ANI significa buena analgesia.

Finalmente el Índice de perfusión (PI) es derivado del pulsioxímetro, mide la relación entre flujo pulsátil y flujo no pulsátil. Este refleja perfusión periférica y no es tan específico del dolor.

Todos estos se relacionan en cuanto a que el SPI detecta activación simpática, por ejemplo dolor, ANI detecta la supresión parasimpática y PI refleja una consecuencia vascular ya sea vasoconstricción y/o dilatación. Es decir que estos índices miden el efecto del dolor sobre el sistema autónomo pero cada con sus leves diferencuias en sus bases.


## CONCLUSIONES

En esta práctica se logró captar y analizar la señal PPG, evidenciando correctamente las variaciones del volumen sanguíneo y su respuesta ante estímulos como el estrés con cold pressor test (frío). Aunque no se consiguió calcular el SPI en tiempo real, sí se cumplieron los objetivos principales relacionados con la adquisición y procesamiento de la señal.
En la vida real, este tipo de sistemas es muy útil porque permite monitorear de forma no invasiva el estado fisiológico de una persona, lo que puede ayudar a mejorar la evaluación del dolor y la toma de decisiones médicas, incluso en entornos fuera del hospital.


## Referencias

[1] J. Allen, “Photoplethysmography and its application in clinical physiological measurement,” *Physiological Measurement*, vol. 28, no. 3, pp. R1–R39, 2007.

[2] M. Huiku et al., “Assessment of surgical stress during general anaesthesia,” *British Journal of Anaesthesia*, vol. 98, no. 4, pp. 447–455, 2007.

[3] Y. C. Fung, *Biomechanics: Circulation*, 2nd ed. New York, NY, USA: Springer, 1997.

[4] W. Verkruysse, L. O. Svaasand, and J. S. Nelson, “Remote plethysmographic imaging using ambient light,” *Optics Express*, vol. 16, no. 26, pp. 21434–21445, 2008.

[5] V. Jambrik et al., “Usefulness of the cold pressor test in cardiovascular research,” *Heart*, vol. 90, no. 7, pp. 727–728, 2004.
