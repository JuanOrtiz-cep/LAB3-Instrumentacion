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

1. Se buscó realizar en proto-board el circuito de la siguiente figura:
2. 
   <img width="456" height="256" alt="image" src="https://github.com/user-attachments/assets/0cda07be-5403-4c85-b6ce-f337ccd13114" />

La cual es extraida de la guía de laboratorio (Figura 1. Circuito para capturar las variaciones del volumen sanguíneo periférico).
De este modo utilizando un acoplador óptico modificado se pretendía convertir en yn sensor de reflectacia, sin embargo en la continuidad de la práctica se realizó un cambio para utilizar únicamente el sensor óptico MAX30102, esto para garantizar mejores resultados ya que del modo anterior no eran nada óptimos.

<img width="873" height="1280" alt="image" src="https://github.com/user-attachments/assets/3e1bb678-2ec0-4b4f-abdd-7dd0d973245a" />

Circuito resultante con el uso del MAX30102.

## Código REVISAAAAAAAAAAAAAR

Se diseñó un código en MATLAB que captura la señal con el propósito de calcular el SPI de cada pulsación. Posteriormente se realiza la captura de 2 minutos mientras se utiliza la maniobra CPT. Paralelamente un integrante tomó los datos visualizados durante el uso de la maniobra.

###  Protocolo experimental (CPT)

| Fase            | Tiempo        | Descripción                  |
|-----------------|-------------|-----------------------------|
| Reposo inicial  | 0 – 40 s    | Condición basal             |
| CPT             | 40 – 80 s   | Estímulo frío               |
| Recuperación    | 80 – 120 s  | Retorno a estado basal      |


<img width="1148" height="1351" alt="image" src="https://github.com/user-attachments/assets/c29cedf3-9070-49d7-9453-e5d241199864" />

A su vez se espera obtener y visualizar la evolución del SPI en función del tiempo.


## RESULTADOS  COMPLETAAAAAAAAAAAAAAAAAAAAAAAAAAAAAR

###  Adquisición de señal   REVISSSSSAAAR

- Sensor óptico de reflectancia (MAX30102)
- ESP32 como sistema de adquisición
- Comunicación serial con MATLAB
- Circuito
 

```matlab
puerto = "COM3";
arduino = serialport(puerto, 9600);

tiempo_total = 120;
fs = 50;
dt = 1/fs;
N = tiempo_total * fs;

senal = zeros(1, N);

for i = 1:N
    dato = readline(arduino);
    senal(i) = str2double(dato);
    pause(dt);
end
```
---

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

## CONCLUSIONES

## Referencias

[1] J. Allen, “Photoplethysmography and its application in clinical physiological measurement,” *Physiological Measurement*, vol. 28, no. 3, pp. R1–R39, 2007.

[2] M. Huiku et al., “Assessment of surgical stress during general anaesthesia,” *British Journal of Anaesthesia*, vol. 98, no. 4, pp. 447–455, 2007.

[3] Y. C. Fung, *Biomechanics: Circulation*, 2nd ed. New York, NY, USA: Springer, 1997.

[4] W. Verkruysse, L. O. Svaasand, and J. S. Nelson, “Remote plethysmographic imaging using ambient light,” *Optics Express*, vol. 16, no. 26, pp. 21434–21445, 2008.

[5] V. Jambrik et al., “Usefulness of the cold pressor test in cardiovascular research,” *Heart*, vol. 90, no. 7, pp. 727–728, 2004.
