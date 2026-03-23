# LAB3-Instrumentacion
Cálculo ambulatorio del índice pletismográfico quirúrgico (SPI)


# Fotopletismografía (PPG) y Cálculo del SPI



##  Descripción

Este proyecto presenta el desarrollo de un sistema para la adquisición y procesamiento de señales de **fotopletismografía (PPG)**, con el objetivo de analizar variaciones del volumen sanguíneo periférico y calcular el **Índice Pletismográfico Quirúrgico (SPI)**.

El análisis se realiza bajo condiciones de reposo y durante la aplicación del **Cold Pressor Test (CPT)**, permitiendo observar la respuesta fisiológica del sistema cardiovascular.

---

##  Objetivos

- Adquirir señales PPG mediante sensor óptico
- Filtrar y procesar la señal
- Detectar latidos cardíacos
- Calcular el índice SPI
- Analizar cambios fisiológicos durante el CPT
- Documentar el proceso en GitHub

---

## ⚙️ Metodología

###  Adquisición de señal

- Sensor óptico de reflectancia (MAX30102)
- Arduino como sistema de adquisición
- Comunicación serial con MATLAB
- Circuito
  <img width="570" height="306" alt="image" src="https://github.com/user-attachments/assets/9a62d22b-2cbc-48d0-b756-7e689326cc5a" />


---

###  Procesamiento de señal en MATLAB

1. **Captura de datos**
   - Duración: 120 segundos
   - Frecuencia de muestreo: 50 Hz

2. **Filtrado**
   - Filtro pasa banda: 0.5 – 5 Hz

3. **Detección de latidos**
   - Algoritmo `findpeaks`
   - Identificación de picos y valles

4. **Cálculo del SPI**

\[
SPI = \frac{AC}{DC}
\]

Donde:

- **AC**: amplitud del pulso (pico - valle)  
- **DC**: valor medio de la señal  

---

###  Protocolo experimental (CPT)

| Fase            | Tiempo        | Descripción                  |
|-----------------|-------------|-----------------------------|
| Reposo inicial  | 0 – 40 s    | Condición basal             |
| CPT             | 40 – 80 s   | Estímulo frío               |
| Recuperación    | 80 – 120 s  | Retorno a estado basal      |

---

## 📈 Resultados

###  Señal PPG (Original vs Filtrada)
