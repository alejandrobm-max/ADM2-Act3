# Actividad 3 - Proyecto Transversal: Inteligencia de Negocio Aplicada en AdventureWorks

El equipo de marketing de una empresa de bicicletas busca optimizar su estrategia de comunicación y producto mediante el análisis de las transacciones de los clientes. 

## Objetivos 

En esta actividad profundizarás sobre las técnicas de análisis exploratorio de los datos y el aprendizaje no supervisado.

## Pautas de elaboración

Juana Rider es Data Analyst en un grupo multinacional que fabrica y vende bicicletas y sus repuestos. Acaba de llegar a la compañía, por lo que, lo primero que ha hecho ha sido una consulta a la base de datos para poder tener una visión general de la situación de la empresa. En este sentido, Juana ha obtenido una consulta (dataset_AW.xlsx) con las siguientes pestañas:

•	ST Ventas Totales: son las ventas totales diarias de la empresa durante un período aproximado de tres años.
•	Var Discreta Adq Bicicleta: se trata del detalle de 18484 clientes en cuanto a sus características, el gasto total, etc.
•	Datos sin etiquetas (No Supervisado): son datos de los distintos productos que comercializa la empresa.


## Roles en el Ejercicio
•	Analista de Datos: Procesa la información de los datos.
•	Especialista en Modelado: Diseña el modelo de predicción.
•	Estratega de Marketing: Traduce los resultados en recomendaciones para campañas.
•	Presentador: Explica los hallazgos y propone estrategias de ajuste.

Como se ha indicado, el dataset se llama dataset_AW.xlsx. En base al conjunto de datos de los distintos productos que comercializa la empresa, la dirección general de la misma pide a Juana, antes de iniciar el proyecto de Inteligencia de Negocio, que conteste a las siguientes preguntas:

## Preguntas
1. Realiza un análisis exploratorio para poder contextualizar los productos de las tiendas y entender el nivel de beneficio. Investiga que significan las distintas variables y ten en cuenta diversos análisis relacionados el número de productos ordenados, su precio, coste, tipología de producto… La finalidad es que hagas un perfilado de compras de la tienda para que el CEO tenga una información base contextual. Para ello utiliza agrupa por diversas columnas y calcula valores medios o de la mediana en función de ese agrupamiento.
2. Realiza un análisis de clustering para encontrar patrones dentro de los datos. Esta agrupación debe considerar los criterios transaccionales (precio, cantidad, ...). Realiza una explicación analítica de los resultados con un enfoque nivel técnico e interpreta los grupos que han salido.
3. Con los resultados del clustering ahora se necesita elaborar una respuesta para el director de Marketing y así hacerle entender la información hallada, por lo que las explicaciones de los resultados deben tener un enfoque de negocio. ¿Qué grupos identificas?,¿Qué significan para la tienda?,¿Cuales tienen un mayor beneficio económico?,¿Cuáles menos?,¿hay algún patrón estético o funcional de los productos que sean tendencia?... HAY QUE APLICAR AL RESULTADO DEL CLUSTERING UN ÁRBOL DE DECISIÓN PARA INTERPRETARLO
4. Una vez elaborado el reporte para el director de marketing, llega el turno de elaborar una estrategia para el CEO. Recomienda acciones específicas basadas en todos los resultados anteriores para aumentar beneficios. Si se quiere aumentar beneficios, ¿qué tipo de productos hay que incentivar más?, ¿Qué tipo de diseños? ¿Qué productos podrían tener una retirada del mercado? 

## Extensión y formato 

- La entrega consistirá en adjuntar un notebook que deberá ser entendible, funcionar en el entorno notebook con los datos provistos. 
- Además, una presentación Powerpoint con los resultados expuestos y las explicaciones, 1 diapositiva por pregunta.

Además de que funcione correctamente, para la calificación de la actividad se tendrán en cuenta también aspectos como claridad en las explicaciones y el código, reglas de nomenclatura de variables y funciones, originalidad de la solución propuesta. De igual manera, la claridad de las explicaciones y originalidad de resultados en la presentación será evaluada.


Rúbrica: 

- Criterio 1	Es capaz de realizar el análisis exploratorio.	20%
- Criterio 2	Realiza y evalua correctamente el algoritmo de clusterización. 20%
- Criterio 3	Elabora una respuesta clara para el director de Marketing.	20%
- Criterio 4	Elabora una respuesta concisa para el CEO.	20%
- Criterio 5	Argumenta de forma clara y concisa todas las respuestas.	20%
