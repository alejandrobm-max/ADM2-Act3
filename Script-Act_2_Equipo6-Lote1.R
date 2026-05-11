# 0. INTRODUCCIÓN Y OBJETIVO DEL ANÁLISIS

### En esta actividad analizamos la evolución histórica del precio de cierre de ###
### Apple Inc. (AAPL) con el objetivo de construir un modelo de predicción      ###
### basado en series temporales. Para ello, trabajamos con datos financieros    ###
### descargados desde Yahoo Finance, realizamos un análisis exploratorio de la  ###
### serie, comprobamos su estacionariedad y aplicamos modelos predictivos que   ###
### permitan estimar el comportamiento del precio durante mayo de 2025.         ###

### El propósito final del análisis es evaluar la fiabilidad de la predicción   ###
### obtenida y extraer conclusiones útiles desde una perspectiva financiera,    ###
### considerando cómo las fluctuaciones del precio pueden influir en decisiones ###
### de inversión, gestión del riesgo, valoración empresarial y planificación    ###
### financiera.                                                                 ###

# 1. DESCARGA, PREPARACIÓN Y EXPLORACIÓN INICIAL DE LOS DATOS
# 1.1 Carga de librerías
library(quantmod)
library(forecast)
library(tseries)
library(prophet)
library(dplyr)
library(ggplot2)

# 1.2 Descarga de datos de AAPL
getSymbols("AAPL", src = "yahoo", from = "2015-01-01", to = "2025-06-01")

# Nos quedamos con el precio de cierre
precio_cierre <- Cl(AAPL)
head(precio_cierre)

# 1.3 Análisis exploratorio inicial del precio de cierre de la acción de APPLE

# Convertimos la serie de precio de cierre en un dataframe para facilitar el análisis
datos_precio <- data.frame(
  fecha = index(precio_cierre),
  precio_cierre = as.numeric(precio_cierre)
)

# Resumen estadístico básico
summary(datos_precio$precio_cierre)

# Cálculo de indicadores descriptivos principales
precio_inicial <- first(datos_precio$precio_cierre)
precio_final <- last(datos_precio$precio_cierre)

variacion_absoluta <- precio_final - precio_inicial
variacion_porcentual <- (variacion_absoluta / precio_inicial) * 100

precio_minimo <- min(datos_precio$precio_cierre, na.rm = TRUE)
precio_maximo <- max(datos_precio$precio_cierre, na.rm = TRUE)
precio_medio <- mean(datos_precio$precio_cierre, na.rm = TRUE)
desviacion_precio <- sd(datos_precio$precio_cierre, na.rm = TRUE)

# Tabla resumen del precio de cierre
resumen_precio <- data.frame(
  Indicador = c(
    "Precio inicial",
    "Precio final",
    "Variación absoluta",
    "Variación porcentual",
    "Precio mínimo",
    "Precio máximo",
    "Precio medio",
    "Desviación típica"
  ),
  Valor = round(c(
    precio_inicial,
    precio_final,
    variacion_absoluta,
    variacion_porcentual,
    precio_minimo,
    precio_maximo,
    precio_medio,
    desviacion_precio
  ), 2)
)

resumen_precio

# Gráfico de evolución del precio de cierre
plot(
  precio_cierre,
  main = "Evolución del precio de cierre de Apple (AAPL)",
  xlab = "Fecha",
  ylab = "Precio de cierre",
  col = "blue"
)

# Cálculo de media móvil de 30 días
media_movil_30 <- rollmean(precio_cierre, k = 30, fill = NA, align = "right")

# Gráfico del precio de cierre con media móvil
plot(
  precio_cierre,
  main = "Precio de cierre de Apple con media móvil de 30 días",
  xlab = "Fecha",
  ylab = "Precio de cierre",
  col = "gray"
)

lines(media_movil_30, col = "red", lwd = 2)

legend(
  "topleft",
  legend = c("Precio de cierre", "Media móvil 30 días"),
  col = c("gray", "red"),
  lty = 1,
  bty = "n"
)


# 2. ESTACIONARIEDAD Y TRANSFORMACIÓN DE LA SERIE
# 2.1 Retornos logarítmicos

# Cálculo de retornos logarítmicos diarios
retornos <- diff(log(precio_cierre))
retornos <- na.omit(retornos)

# 2.2 ACF y PACF
# ACF y PACF de los retornos logarítmicos
par(mfrow = c(1, 2))

acf(retornos, main = "ACF retornos")
pacf(retornos, main = "PACF retornos")

par(mfrow = c(1, 1))

# 2.3 Dickey-Fuller aumentado

# Test ADF sobre la serie de precios de cierre
adf_precio <- adf.test(as.numeric(precio_cierre), k = 10)
adf_precio
## p-value = 0.2529: La serie original del precio de cierre de Apple no puede 
## considerarse estacionaria

# Test ADF sobre retornos
adf_retornos <- adf.test(as.numeric(retornos), k = 10)
adf_retornos
## p‑value = 0.01. Esto implica:

  # Rechazamos la hipótesis nula (H0): la serie tiene raíz unitaria → no es estacionaria.

  # Aceptamos la hipótesis alternativa (H1): la serie es estacionaria.

# 2.4 Justificación de la modificación de la serie
## El análisis de la estacionariedad nos lleva a una conclusión clara: para 
## construir el modelo predictivo no debemos ignorar la falta de estacionariedad 
## de la serie original. En el caso de ARIMA, esto justifica el uso de diferenciación,
## ya que el modelo necesita trabajar con una serie estabilizada para poder generar 
## predicciones más consistentes.


# 3. MODELOS PREDICTIVOS
# 3.1 División entrenamiento/test

# Separación de datos para evitar fuga de información.
# Utilizamos indexación nativa para preservar la estructura temporal.
train <- precio_cierre["/2025-04-30"]
test  <- precio_cierre["2025-05-01/2025-05-31"]

# Cálculo de los días reales de cotización en la ventana de test (Mayo)
h_dias <- nrow(test)
print(paste("Días hábiles a predecir en mayo de 2025:", h_dias))


# 3.2 Modelo estadístico: ARIMA

# Transformación a objeto ts usando la frecuencia de 252 (días bursátiles anuales).
train_ts <- ts(as.numeric(train), frequency = 252)

# auto.arima() ajusta el modelo y aplica la diferenciación automáticamente.
modelo_arima <- auto.arima(train_ts)
summary(modelo_arima)


# 3.3 Modelo de inteligencia de negocio: Prophet

# Estructuración del dataframe al formato requerido por la librería (ds, y).
df_prophet_train <- data.frame(
  ds = index(train),
  y  = as.numeric(train)
)

# Inicialización del modelo integrando el impacto de los festivos de EE.UU. (NASDAQ).
modelo_prophet <- prophet()
modelo_prophet <- add_country_holidays(modelo_prophet, country_name = 'US')

# Entrenamiento del algoritmo con el histórico hasta abril de 2025.
modelo_prophet <- fit.prophet(m = modelo_prophet, df = df_prophet_train)


# 3.4 Generación de pronósticos para mayo de 2025

# --- Predicción con ARIMA ---
# Proyección ajustada al horizonte temporal exacto del set de test (h_dias).
pred_arima <- forecast(modelo_arima, h = h_dias)

autoplot(pred_arima) +
  labs(title = "Predicción ARIMA - Precio de Apple (AAPL) para Mayo 2025",
       y = "Precio de cierre (USD)",
       x = "Tiempo")

# --- Predicción con Prophet ---
# Proyección mapeando las fechas exactas del conjunto de prueba.
future_prophet <- data.frame(ds = index(test))
pred_prophet <- predict(modelo_prophet, future_prophet)

plot(modelo_prophet, pred_prophet) +
  labs(title = "Predicción Prophet - Precio de Apple (AAPL) para Mayo 2025",
       y = "Precio de cierre (USD)",
       x = "Fecha")


# 4. EVALUACIÓN DEL MODELO
# 4.1 Real vs predicho


# 4.2 MAE, RMSE y MAPE


# 4.3 Comparación de modelos


# 4.4 Fiabilidad de la predicción



# 5. INTERPRETACIÓN FINANCIERA ESTRATÉGICA (Prueba edición)
# 5.1 Valoración


# 5.2 Inversión


# 5.3 Riesgo


# 5.4 Deuda, recompra de acciones y dividendos



# 6. CONCLUSIONES FINALES

# 1 ----
library(zoo)
library(ggplot2)

# Dataframe base
df <- data.frame(
  fecha = index(precio_cierre),
  cierre = as.numeric(precio_cierre)
)

# Media móvil 30 días
df$mm30 <- rollmean(df$cierre, k = 30, fill = NA, align = "right")

# Gráfico estilo Apple (transparente)
p <- ggplot(df, aes(x = fecha)) +
  
  # Precio
  geom_line(aes(y = cierre, color = "Precio de cierre"), linewidth = 0.8) +
  
  # Media móvil
  geom_line(aes(y = mm30, color = "Media móvil 30 días"), linewidth = 1.3) +
  
  # Leyenda
  scale_color_manual(
    values = c(
      "Precio de cierre" = "#8E8E93",
      "Media móvil 30 días" = "#0A84FF"
    ),
    name = NULL
  ) +
  
  labs(
    title = NULL,
    x = NULL,
    y = NULL
  ) +
  
  theme_minimal(base_size = 30) +
  
  theme(
    # fondo transparente
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    
    # sin grids
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    # texto estilo Apple
    axis.text  = element_text(color = "#3C3C43", size = 12),
    axis.title = element_text(color = "#3C3C43", size = 14),
    
    plot.title = element_text(
      color = "#1C1C1E",
      size = 20,
      face = "bold",
      hjust = 0.5
    ),
    
    axis.ticks = element_blank(),
    
    # estilo de leyenda
    legend.position = "bottom",
    legend.text = element_text(size = 12)
  )

# Exportación con fondo transparente
ggsave(
  "grafico_aapl_transparente.png",
  plot = p,
  width = 14,
  height = 6,
  dpi = 300,
  bg = "transparent"
)

# 2 ----

# =========================
# LIBRERÍAS
# =========================
library(quantmod)
library(zoo)
library(ggplot2)
library(dplyr)
library(forecast)
library(tseries)

# =========================
# DESCARGA DATOS
# =========================
getSymbols("AAPL", src = "yahoo", from = "2015-01-01", to = "2025-06-01")

precio_cierre <- Cl(AAPL)

# =========================
# RETORNOS LOGARÍTMICOS
# =========================
retornos <- diff(log(precio_cierre))
retornos <- na.omit(retornos)

# =========================
# ACF Y PACF (sin plot base)
# =========================
acf_vals  <- acf(retornos, plot = FALSE)
pacf_vals <- pacf(retornos, plot = FALSE)

# =========================
# DATAFRAMES
# =========================
df_acf <- data.frame(
  lag = acf_vals$lag[-1],
  valor = acf_vals$acf[-1],
  tipo = "ACF"
)

df_pacf <- data.frame(
  lag = pacf_vals$lag,
  valor = pacf_vals$acf,
  tipo = "PACF"
)

df_acf_pacf <- bind_rows(df_acf, df_pacf)

# =========================
# GRÁFICO ACF + PACF (ESTILO APPLE)
# =========================
p_acf_pacf <- ggplot(df_acf_pacf, aes(x = lag, y = valor, color = tipo)) +
  
  geom_hline(yintercept = 0, color = "#3C3C43", linewidth = 0.4) +
  
  geom_segment(aes(xend = lag, yend = 0), linewidth = 0.8) +
  
  geom_point(size = 1.8) +
  
  scale_color_manual(
    values = c(
      "ACF" = "#0A84FF",
      "PACF" = "#FF9F0A"
    ),
    name = NULL
  ) +
  
  labs(
    title = NULL,
    x = "Lags",
    y = "Autocorrelación"
  ) +
  
  theme_minimal(base_size = 18) +
  
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    axis.text  = element_text(color = "#3C3C43"),
    axis.title = element_text(color = "#3C3C43"),
    
    axis.ticks = element_blank(),
    
    legend.position = "bottom",
    legend.text = element_text(size = 12)
  )

# =========================
# EXPORTAR PNG
# =========================
ggsave(
  "acf_pacf_aapl.png",
  plot = p_acf_pacf,
  width = 14,
  height = 6,
  dpi = 300,
  bg = "transparent"
)

# 3 ----

library(ggplot2)
library(forecast)

# =========================
# ARIMA + INTERVALOS
# =========================
pred_arima <- forecast(modelo_arima, h = h_dias)

df_arima <- data.frame(
  fecha = index(test),
  real = as.numeric(test),
  arima = as.numeric(pred_arima$mean),
  lo80 = as.numeric(pred_arima$lower[,1]),
  hi80 = as.numeric(pred_arima$upper[,1])
)

# =========================
# PROPHET
# =========================
future_prophet <- data.frame(ds = index(test))
pred_prophet <- predict(modelo_prophet, future_prophet)

df_arima$prophet <- pred_prophet$yhat

# =========================
# DATAFRAME LONG
# =========================
df_plot <- data.frame(
  fecha = rep(df_arima$fecha, 4),
  valor = c(
    df_arima$real,
    df_arima$arima,
    df_arima$prophet,
    df_arima$lo80
  ),
  tipo = rep(
    c("Real", "ARIMA", "Prophet", "IC inferior"),
    each = nrow(df_arima)
  )
)

df_plot2 <- data.frame(
  fecha = df_arima$fecha,
  lo80 = df_arima$lo80,
  hi80 = df_arima$hi80
)

# =========================
# GRÁFICO ÚNICO
# =========================
p_final <- ggplot(df_arima, aes(x = fecha)) +
  
  # Banda de confianza ARIMA
  geom_ribbon(aes(ymin = lo80, ymax = hi80),
              fill = "#0A84FF", alpha = 0.10) +
  
  # Real
  geom_line(aes(y = real, color = "Real"), linewidth = 1) +
  
  # ARIMA
  geom_line(aes(y = arima, color = "ARIMA"), linewidth = 1.1) +
  
  # Prophet
  geom_line(aes(y = prophet, color = "Prophet"), linewidth = 1.1) +
  
  scale_color_manual(
    values = c(
      "Real" = "#3C3C43",
      "ARIMA" = "#0A84FF",
      "Prophet" = "#FF9F0A"
    ),
    name = NULL
  ) +
  
  labs(
    title = NULL,
    x = NULL,
    y = "Precio de cierre"
  ) +
  
  theme_minimal(base_size = 24) +
  
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    
    panel.grid = element_blank(),
    
    axis.text = element_text(color = "#3C3C43"),
    axis.title = element_text(color = "#3C3C43"),
    
    legend.position = "bottom",
    axis.ticks = element_blank()
  )

# =========================
# EXPORTAR
# =========================
ggsave(
  "comparativa_modelos_mayo_2025.png",
  plot = p_final,
  width = 14,
  height = 6,
  dpi = 300,
  bg = "transparent"
)