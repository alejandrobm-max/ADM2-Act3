# Actividad 2: El Desafío de los Analistas de Wall Street
Imagina que formas parte del equipo de analistas financieros de una prestigiosa firma de inversión y el primer trabajo que te asignan corresponde a presentar un informe predictivo sobre la evolución de los precios de las acciones de Apple Inc. (AAPL) a un grupo de inversores institucionales. La firma tiene acceso a datos históricos, análisis de sentimiento en redes sociales, noticias del sector tecnológico y variables macroeconómicas. La misión es clara: deben construir un modelo de predicción que ayude a los clientes a tomar decisiones informadas en un mercado volátil.
 
## Objetivos
 
Objetivo: Aplicar técnicas de modelado de series temporales para predecir el precio de cierre de una acción.
 
## Pautas de elaboración
Apple (ticker=’AAPL’) es una de las empresas más seguidas por inversores, con una base de clientes fiel y una estrategia de innovación constante. Sin embargo, el precio de su acción depende de entre otros factores los resultados financieros trimestrales, el lanzamiento de nuevos productos, las tendencias del mercado electrónico y la competencia y la política monetaria ejercida por la Reserva Federal Estadounidense.
 
Cada equipo tendréis que desarrollar un modelo de predicción utilizando técnicas de predicción de series temporales. Deberéis justificar la elección de sus variables y evaluar la precisión de sus predicciones frente a datos reales.
 
## Roles en el Ejercicio
Analista de Datos: Encargado de limpiar y procesar los datos históricos de AAPL.
Especialista en Modelado: Diseña el modelo de predicción basado en técnicas de inteligencia de negocio.
Analista Financiero: Interpreta los resultados y hace recomendaciones estratégicas.
Presentador: Explica los hallazgos al comité de inversores.
 
## Fases
Para facilitar la comprensión del ejercicio a continuación se detallan algunas de las etapas que los equipos deberán llevar a cabo en cuánto a código:
 
1. Instalar las librerías necesarias
2. Descarga y exploración de datos. Realiza un análisis exploratorio del precio de cierre de la acción.
3. Análisis de estacionariedad. Algunos algoritmos de predicción de series temporales necesitan que la serie sea estacionaria, en caso de que no lo sea se tiene que diferenciar.
4. Seleccionar, entrenar, predecir y evaluar el modelo de predicción de las series temporales.
 
El objetivo es que seáis capaces de responder las siguientes preguntas:
1  Analiza la tendencia general del precio de cierre de la acción APPLE hasta el 1 de Junio de 2025. ¿Cuál ha sido la tendencia del precio de la acción? ¿Por qué factores puede estar justificada esta evolución del precio de la acción? Realiza un análisis exploratorio de los datos.
2  Predice el valor de los últimos 30 días correspondientes a Mayo del año 2025. ¿Qué modelo de predicción has utilizado? ¿Has tenido que modificar la serie original? Si es que sí, ¿por qué?. Analiza la fiabilidad de la predicción.
3  Desde la perspectiva del departamento de finanzas de una empresa, deben evaluar cómo las fluctuaciones del precio pueden influir en decisiones estratégicas clave: valorización de la empresa, estrategias de inversión, gestión del riesgo y planificación financiera. Consideren aspectos como la emisión de deuda, recompra de acciones, dividendos y ajustes en la estrategia financiera.
 
## Extensión y formato
 
La entrega consistirá en adjuntar un notebook que deberá ser entendible, funcionar en el entorno notebook con los datos provistos. Además, una presentación Powerpoint con los resultados expuestos y las explicaciones, 1 diapositiva por pregunta.
