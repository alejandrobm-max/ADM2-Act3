# =========================================================
# 0. CONFIGURACIÓN
# =========================================================

# Librerías
library(quantmod)
library(zoo)
library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)
library(prophet)

# Parámetros
ticker <- "AAPL"
fecha_inicio <- "2015-01-01"
fecha_fin    <- "2025-06-01"

# =========================================================
# 1. DESCARGA Y PREPARACIÓN DE DATOS
# =========================================================

getSymbols(ticker, src = "yahoo", from = fecha_inicio, to = fecha_fin)

precio_cierre <- Cl(AAPL)

df_precios <- data.frame(
  fecha = index(precio_cierre),
  cierre = as.numeric(precio_cierre)
)

# =========================================================
# 2. ANÁLISIS DESCRIPTIVO
# =========================================================

resumen <- df_precios %>%
  summarise(
    precio_inicial = first(cierre),
    precio_final   = last(cierre),
    variacion_abs  = precio_final - precio_inicial,
    variacion_pct  = (variacion_abs / precio_inicial) * 100,
    minimo         = min(cierre, na.rm = TRUE),
    maximo         = max(cierre, na.rm = TRUE),
    media          = mean(cierre, na.rm = TRUE),
    desviacion     = sd(cierre, na.rm = TRUE)
  )

print(round(resumen, 2))

# =========================================================
# 3. FEATURE ENGINEERING
# =========================================================

df_precios <- df_precios %>%
  mutate(
    mm30 = rollmean(cierre, k = 30, fill = NA, align = "right")
  )

# Retornos logarítmicos
retornos <- diff(log(precio_cierre)) %>% na.omit()

# =========================================================
# 4. ESTACIONARIEDAD
# =========================================================

adf_precio   <- adf.test(as.numeric(precio_cierre), k = 10)
adf_retornos <- adf.test(as.numeric(retornos), k = 10)

print(adf_precio)
print(adf_retornos)

# =========================================================
# 5. TRAIN / TEST SPLIT
# =========================================================

train <- precio_cierre["/2025-04-30"]
test  <- precio_cierre["2025-05-01/2025-05-31"]

h <- nrow(test)

# =========================================================
# 6. MODELOS
# =========================================================

# ---- ARIMA ----
train_ts <- ts(as.numeric(train), frequency = 252)
modelo_arima <- auto.arima(train_ts)

pred_arima <- forecast(modelo_arima, h = h)

# ---- PROPHET ----
df_prophet <- data.frame(
  ds = index(train),
  y  = as.numeric(train)
)

modelo_prophet <- prophet() %>%
  add_country_holidays(country_name = "US") %>%
  fit.prophet(df_prophet)

future <- data.frame(ds = index(test))
pred_prophet <- predict(modelo_prophet, future)

# =========================================================
# 7. DATAFRAME DE EVALUACIÓN
# =========================================================

df_eval <- data.frame(
  fecha   = index(test),
  real    = as.numeric(test),
  arima   = as.numeric(pred_arima$mean),
  prophet = pred_prophet$yhat,
  lo80    = pred_arima$lower[,1],
  hi80    = pred_arima$upper[,1]
) %>%
  mutate(
    error        = real - arima,
    error_abs    = abs(error),
    error_pct    = (error / real) * 100
  )

# =========================================================
# 8. MÉTRICAS
# =========================================================

metricas <- df_eval %>%
  summarise(
    MAE  = mean(error_abs),
    RMSE = sqrt(mean(error^2)),
    MAPE = mean(abs(error_pct))
  )

print(round(metricas, 3))

# =========================================================
# 9. VISUALIZACIONES
# =========================================================

# ---- Precio + Media móvil ----
p_precio <- ggplot(df_precios, aes(x = fecha)) +
  geom_line(aes(y = cierre, color = "Precio"), linewidth = 0.8) +
  geom_line(aes(y = mm30, color = "MM30"), linewidth = 1.2) +
  scale_color_manual(values = c("Precio" = "gray", "MM30" = "blue")) +
  theme_minimal()

# ---- Comparativa modelos ----
p_modelos <- ggplot(df_eval, aes(x = fecha)) +
  geom_ribbon(aes(ymin = lo80, ymax = hi80), alpha = 0.1) +
  geom_line(aes(y = real, color = "Real")) +
  geom_line(aes(y = arima, color = "ARIMA")) +
  geom_line(aes(y = prophet, color = "Prophet")) +
  theme_minimal()

# ---- Error ----
p_error <- ggplot(df_eval, aes(x = fecha, y = error)) +
  geom_col() +
  geom_hline(yintercept = 0) +
  theme_minimal()

# =========================================================
# 10. EXPORTS
# =========================================================

ggsave("precio_mm30.png", p_precio, width = 12, height = 5)
ggsave("comparativa_modelos.png", p_modelos, width = 12, height = 5)
ggsave("error_arima.png", p_error, width = 12, height = 5)