# ACTIVIDAD 3 (ADM II) - Proyecto Transversal: Inteligencia de Negocio Aplicada en AdventureWorks

###################################################################################################################################################
# Hemos utilizado la BD dataset_AW.xlsx de la carpeta Actividad 3_Análisis II del aula virtual de la asignatura como objeto del presente trabajo. #
###################################################################################################################################################



# 1. CARGA, PREPARACIÓN Y ANÁLISIS EXPLORATORIO: CONTEXTUALIZACIÓN DE LOS PRODUCTOS DE LAS TIENDAS Y NIVEL DE BENEFICIO (JOEL)

  # Realizamos un análisis exploratorio para poder contextualizar los productos de las tiendas y entender el nivel de beneficio. 
  # Investigamos qué significan las distintas variables teniendo en cuenta diversos análisis relacionados:
  # El número de productos ordenados, su precio, coste, tipología de producto… 
  # La finalidad que perseguimos es realizar un perfilado de compras de la tienda para que el CEO tenga una información base contextual. 
  # Para ello utilizamos agrupaciones por diversas columnas y calcularemos valores medios o de la mediana en función de ese agrupamiento.

# 1.1 Carga de librerías
library(readxl)
library(dplyr)
library(janitor)     # Estandarizar automáticamente los nombres de las columnas
library(skimr)       # Resumen estadístico detallado y estructurado de un conjunto de datos
library(NbClust)     # Definir número de clusters: Método del codo
library(factoextra)  # Definir número de clusters
library(ClusterR)    # Método nuevo explicado el 19-05 por Amparo para definir el número de clusters en datasets muy grandes
library(rpart)
library(rpart.plot)

# 1.2 Carga de datos

data <- read_excel("dataset_AW.xlsx")

# 1.3 Análisis exploratorio inicial

str(data)

## 1.3.1 Limpieza inicial

data <- clean_names(data) # Limpiar nombres de columnas

# Factorizar columnas no numéricas

data <- data %>%
  mutate(
    bike_purchase = as.factor(bike_purchase),
    marital_status = as.factor(marital_status),
    gender = as.factor(gender),
    country = as.factor(country),
    group = as.factor(group),
    education = as.factor(education),
    occupation = as.factor(occupation),
    yearly_income = as.factor(yearly_income),
    home_owner_flag = as.factor(home_owner_flag)
  ) %>%
  select(-customer_id, -person_id)

# Aplicar formato fecha

data <- data %>%
  mutate(
    date_first_purchase = as.Date(date_first_purchase, origin = "1899-12-30"),
    birth_date = as.Date(birth_date, origin = "1899-12-30")
  )

## 1.3.2 EDA

# Estructura
str(data)

# Resumen estadístico
summary(data)

# Resumen más completo
skim(data)

# Valores nulos
colSums(is.na(data))

# Perfil de compra por ingresos

data %>%
  group_by(yearly_income) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount, na.rm = TRUE),
    count = n()
  ) %>%
  arrange(desc(purchase_rate))

# INSIGHT:
# - Los clientes con ingresos entre 50k–75k presentan la mayor tasa de compra (52%)
# - Los clientes con >100k tienen el mayor gasto medio (2300), aunque no la mayor tasa
# - Los clientes con menores ingresos (0–25k) muestran menor propensión (40%) y menor gasto
# CONCLUSIÓN:
# - Existe relación positiva entre ingresos y valor económico del cliente
# - La propensión a comprar no crece de forma lineal con el ingreso

# Perfil de compra por edad

data %>%
  group_by(bike_purchase) %>%
  summarise(
    avg_age = mean(age, na.rm = TRUE),
    median_age = median(age, na.rm = TRUE)
  )

data %>%
  mutate(age_group = cut(age, breaks = c(0,30,45,60,100))) %>%
  group_by(age_group) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase)))
  )

# INSIGHT:
# - Los compradores son ligeramente más jóvenes (57 vs 59 años)
# - El grupo 45–60 años presenta la mayor tasa de compra (56%)
# - Menor propensión en jóvenes (<45) y mayores (>60)
# CONCLUSIÓN:
# - El segmento principal está en edades medias

# Perfil por género

data %>%
  group_by(gender) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount)
  )

# INSIGHT:
# - Las mujeres tienen ligeramente mayor tasa de compra (50% vs 48%)
# - También presentan mayor gasto medio (1622 vs 1555)
# CONCLUSIÓN:
# - Diferencia moderada, pero el segmento femenino es ligeramente más valioso

# Perfil por educacion

data %>%
  group_by(education) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount)
  ) %>%
  arrange(desc(purchase_rate))

# INSIGHT:
# - A mayor nivel educativo, mayor tasa de compra:
#   Bachelors (56%) > Graduate (53%) > High School (41%) > Partial HS (31%)
# - El gasto medio también aumenta con la educación
# CONCLUSIÓN:
# - La educación actúa como proxy de ingresos y afinidad al producto

# Perfil por ocupación

data %>%
  group_by(occupation) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount)
  ) %>%
  arrange(desc(purchase_rate))

# INSIGHT:
# - Mayor tasa de compra en perfiles Clerical (56%) y Professional (50%)
# - Menor en perfiles Manual (43%)
# CONCLUSIÓN:
# - Perfiles más cualificados o administrativos presentan mayor propensión

# Hogar y compra

data %>%
  group_by(home_owner_flag) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase)))
  )

# INSIGHT:
# - Diferencias mínimas entre propietarios y no propietarios (49% vs 50%)
# CONCLUSIÓN:
# - Variable poco relevante para explicar la compra

# Hijos vs compra

data %>%
  group_by(total_children) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase)))
  )

# INSIGHT:
# - Máxima tasa de compra con 1 hijo (60%)
# - Disminuye progresivamente a partir de 3 hijos (31% con 5 hijos)
# CONCLUSIÓN:
# - Familias grandes reducen la probabilidad de compra (limitación económica/prioridades)

# Coches vs compra

data %>%
  group_by(number_cars_owned) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase)))
  )

# INSIGHT:
# - Mayor tasa de compra en clientes con 0 coches (63%)
# - Disminuye conforme aumenta el número de coches (37% con 4 coches)
# CONCLUSIÓN:
# - Relación inversa clara: la bicicleta actúa como sustituto del coche

# Country vs compra

data %>%
  group_by(country) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount, na.rm = TRUE),
    count = n()
  ) %>%
  arrange(desc(purchase_rate))

# INSIGHT:
# - Australia presenta la mayor tasa de compra (60%) y el mayor gasto medio (2523)
# - Reino Unido y Alemania también muestran altas tasas (>50%) con gasto elevado
# - Regiones como Southwest y Northwest tienen tasas medias (41–49%) pero alto volumen de clientes
# - Algunas regiones (Northeast, Southeast, Central) tienen tasas bajas y con muy bajo número de observaciones (n<15)

# CONCLUSIÓN:
# - Existen diferencias claras por país/región en comportamiento de compra
# - Australia destaca como el mercado más rentable (alta conversión + alto gasto)
# - Regiones con alto volumen (US) son clave en impacto total aunque con menor tasa

# Estado marital vs compra

data %>%
  group_by(marital_status) %>%
  summarise(
    purchase_rate = mean(as.numeric(as.character(bike_purchase))),
    avg_spending = mean(total_amount, na.rm = TRUE),
    count = n()
  )

# INSIGHT:
# - Los clientes solteros (S) presentan mayor tasa de compra (53% vs 46%)
# - También tienen mayor gasto medio (1673 vs 1517)
# - Los casados (M) representan mayor volumen de clientes

# CONCLUSIÓN:
# - Los solteros muestran mayor propensión y valor económico
# - Los casados, aunque menos propensos, tienen mayor peso en volumen
# - El estado civil influye, pero probablemente está capturando diferencias en el ciclo de vida (ej. hijos)


# CONCLUSIÓN GLOBAL:
# - Cliente tipo:
#   * Edad 45–60 años
#   * Ingresos medios-altos
#   * Nivel educativo alto
#   * Mayor probabilidad de ser soltero
#   * 0–1 hijos
#   * Pocos o ningún coche
#   * Mayor presencia en mercados de alto rendimiento (ej. Australia, UK)

# - Drivers principales de compra:
#   * Nivel de ingresos (capacidad económica)
#   * Educación (proxy de ingresos y afinidad)
#   * Ciclo de vida familiar (especialmente número de hijos)
#   * Sustitución con coche (menos coches → mayor compra)
#   * Factor geográfico (diferencias relevantes entre países)

# - Variables con impacto moderado:
#   * Estado civil (posiblemente influenciado por hijos y edad)
#   * Género (ligeras diferencias en tasa y gasto)

# - Variables poco relevantes:
#   * Propiedad de vivienda



# 2. ANÁLISIS CLUSTERING (DIEGO)

# Realizamos un análisis de clustering para encontrar patrones dentro de los datos. Esta agrupación considera los criterios 
# transaccionales (precio, cantidad, ...). Finalmente, realizamos una explicación analítica de los resultados con un enfoque 
# nivel técnico e interpreta los grupos que han salido.

View(data)

datos_clusterizacion <- data
colnames(datos_clusterizacion)

# Ahora seleccionamos las variables que nos interesan, que serían todas menos las variables fecha.

datos_clusterizacion <- datos_clusterizacion %>% select("total_amount","bike_purchase","country","country_region_code","group","age","marital_status","yearly_income","gender","total_children","education","occupation","home_owner_flag","number_cars_owned")

colSums(is.na(datos_clusterizacion))

str(datos_clusterizacion)

# Pasamos todas las variables texto y factor a númericas.

datos_clusterizacion$bike_purchase <- as.numeric(as.factor(datos_clusterizacion$bike_purchase))
datos_clusterizacion$country <- as.numeric(as.factor(datos_clusterizacion$country))
datos_clusterizacion$country_region_code <- as.factor(as.character(datos_clusterizacion$country_region_code))
datos_clusterizacion$country_region_code <- as.numeric(as.factor(datos_clusterizacion$country_region_code))
datos_clusterizacion$group <- as.numeric(as.factor(datos_clusterizacion$group))
datos_clusterizacion$marital_status <- as.numeric(as.factor(datos_clusterizacion$marital_status))
datos_clusterizacion$yearly_income <- as.numeric(as.factor(datos_clusterizacion$yearly_income))
datos_clusterizacion$gender <- as.numeric(as.factor(datos_clusterizacion$gender))
datos_clusterizacion$education <- as.numeric(as.factor(datos_clusterizacion$education))
datos_clusterizacion$occupation <- as.numeric(as.factor(datos_clusterizacion$occupation))
datos_clusterizacion$home_owner_flag <- as.numeric(as.factor(datos_clusterizacion$home_owner_flag))
str(datos_clusterizacion)

datos_cluster_scaled <- scale(datos_clusterizacion)
View(datos_cluster_scaled)

# Método del codo. 

# Primero he utilizado fviz_nbclust porque el método de Amparo me estaba dando problemas (no obstante, me ha salido posteriormente,
# pero dejo este también para que podamos elegir, el resultado óptimo son 4 clusters).

set.seed(123)

clusterizacion <- fviz_nbclust(datos_cluster_scaled,kmeans,method='wss')
plot(clusterizacion)
clusterizacion$data

library(ClusterR)

# Este es con ClusterR, tenemos un gráfico que nos llevaría a interpretar entre 3 y 4 clusters, más bien 4, coincide con el anterior.

wss <- numeric(10)

for (k in 2:10){
  # kmeans. 
  modelo <- kmeans(datos_cluster_scaled, centers = k, nstart = 10)
  
  # tot.withinss es el WCSS total directo.
  wss[k] <- modelo$tot.withinss
}

plot(2:10, wss[2:10], type = "b", xlab = "k", ylab = "WCSS")


# Ahora realizamos el modelo final para poder interpretar los resultados.


modelo_final <- kmeans(datos_cluster_scaled, centers = 4, nstart = 25)

# Asignamos el cluster a la base de datos original, así quedan reflejados en los datos reales y no escalados.
data_perfiles <- data %>% 
  mutate(cluster_asignado = as.factor(modelo_final$cluster))

# Calculamos las medias de cada cluster para ver cómo es cada grupo.
resumen_clusters <- data_perfiles %>%
  group_by(cluster_assigned = cluster_asignado) %>%
  summarise(
    Cantidad_Clientes = n(),
    Gasto_Promedio = mean(total_amount, na.rm = TRUE),
    Edad_Promedio = mean(age, na.rm = TRUE),
    Hijos_Promedio = mean(total_children, na.rm = TRUE),
    Coches_Promedio = mean(number_cars_owned, na.rm = TRUE)
  )

print(resumen_clusters)

# Para la identificación de patrones de comportamiento transaccional y demográfico en las tiendas se aplicó un algoritmo
# K-Means sobre el conjunto de datos escalado (estandarizado).
# La selección de variables cuantitativas nos ha permitido estructurar un entorno de análisis óptimo.
# Se ha utilizado el método del codo, que ha determinado un número óptimo de clusters k=4, representaría el punto de inflexión
# en el que la ganancia de información intraclusters se estabiliza.

# Basándonos en las medias obtenidas podemos perfilar los siguientes 4 segmentos:

# Cluster 1: Clientes VIP / Alta rentabilidad: n=4.841 (26,20% de la muestra).
# Son clientes de edad madura (57,10 años) con familia (1,73 hijos) y alto nivel de movilidad (1,76 coches).
# Es el segmento más valioso para la compañía, tiene el gasto promedio más alto (2.247$), se debe focalizar en ellos campañas
# de fidelización y venta de productos premium.

# Cluster 2: Senior: n=4.952 (26,80% de la muestra).
# Este grupo es el de mayor edad (68,60 años), mayor número de hijos (3,18) y de coches (2.33).
# Son por poco el grúpo más numeroso pero el menos rentable a nivel transaccional, tienen el menor gasto medio (1.32$).
# Asumimos que, coincidiendo con el análisis EDA, a mayor número de hijos y coches, las prioridades económicas se modifican y el
# gasto en bicicletas cae.

# Cluster 3: Adultos: n= 4.493 (24,30% de la muestra).
# Tienen una edad media de 55,10 años y 1,31 hijos con 0.914 vehículos. Su gasto es moderado-bajo (1.334$), encajarían en un perfil
# que al tener menos de un coche por hogar, admitiríamos la posibilidad del uso de la bicicleta como medio de transporte alternativo
# o recreativo. 

# Cluster 4: Edad media con potencial comprador: n= 4.198 (22,70% de la muestra).
# Es el grupo más joven con 51,50 años y con menos hijos, menos de uno por familia, también tienen la menor cantidad de vehículos por
# hogar. Observan el segundo mayor gasto promedio (1.521$), se considera un grupo joven sin cargas familiares elevadas ni dependencia
# de vehículos, los haría candidatos para estrategias de marketing digital que pusieran el foco en estilos de vida saludables.

# Este análisis clustering complementa el análisis exploratorio inicial. El modelo determina que el tráfico comercial de la compañía
# no depende únicamente de una masa particular sino que tendría dos focos principales basados en la capacidad económica del cluster 1
# y el gasto que pudiera generar el estilo de vida del cluster 4.
# Las variables referidas a número de hijos y coches serían la que actuarían como principales predictores inversos del volumen de gastos.




# 3. INTERPRETACIÓN DEL CLUSTERING: RESPUESTA PARA EL DIRECTOR DE MARKETING  (ALEX)

  # Con los resultados del clustering elaboramos una respuesta para el director de Marketing con el objetivo de hacerle entender 
  # la información hallada, por lo que las explicaciones de los resultados tienen un enfoque de negocio. Por tanto responderemos a 
  # preguntas como: ¿qué grupos identificamos?, ¿qué significan para la tienda?, ¿cuales tienen un mayor beneficio económico?, 
  # ¿cuáles menos?, ¿hay algún patrón estético o funcional de los productos que sean tendencia?... 

# HAY QUE APLICAR AL RESULTADO DEL CLUSTERING UN ÁRBOL DE DECISIÓN PARA INTERPRETARLO



# 4. ESTRATEGIA PARA EL CEO  (DAVID)

  # Ya elaborado el reporte para el director de marketing, llega el turno de elaborar una estrategia para el CEO. Recomendamos acciones 
  # específicas basadas en todos los resultados anteriores para aumentar beneficios. Atenderemos a cuestiones como: Si se quiere aumentar 
  # beneficios, ¿qué tipo de productos hay que incentivar más?, ¿qué tipo de diseños? ¿qué productos podrían tener una retirada del mercado?

