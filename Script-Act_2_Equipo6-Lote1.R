# =========================================================
# 0. LIBRERÍAS
# =========================================================

library(quantmod)
library(zoo)
library(dplyr)
library(ggplot2)
library(forecast)
library(tseries)
library(prophet)

# =========================================================
# 1. DESCARGA DE DATOS
# =========================================================

getSymbols("AAPL", src = "yahoo", from = "2015-01-01", to = "2025-06-01")

precio_cierre <- Cl(AAPL)

df <- data.frame(
  fecha = index(precio_cierre),
  cierre = as.numeric(precio_cierre)
)

df$mm30 <- rollmean(df$cierre, k = 30, fill = NA, align = "right")

# =========================================================
# 2. GRÁFICO PRECIO + MEDIA MÓVIL 
# =========================================================

p1 <- ggplot(df, aes(x = fecha)) +
  
  geom_line(aes(y = cierre, color = "Precio de cierre"), linewidth = 0.8) +
  geom_line(aes(y = mm30, color = "Media móvil 30 días"), linewidth = 1.3) +
  
  scale_color_manual(
    values = c(
      "Precio de cierre" = "#8E8E93",
      "Media móvil 30 días" = "#0A84FF"
    ),
    name = NULL
  ) +
  
  labs(x = NULL, y = NULL, title = NULL) +
  
  theme_minimal(base_size = 30) +
  
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text  = element_text(color = "#3C3C43", size = 12),
    axis.title = element_text(color = "#3C3C43", size = 14),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    legend.text = element_text(size = 12)
  )

ggsave("grafico_aapl.png", p1, width = 14, height = 6, dpi = 300, bg = "transparent")

# =========================================================
# 3. RETORNOS Y ACF / PACF
# =========================================================

retornos <- diff(log(precio_cierre)) %>% na.omit()

acf_vals  <- acf(retornos, plot = FALSE)
pacf_vals <- pacf(retornos, plot = FALSE)

df_acf <- data.frame(
  lag = acf_vals$lag[-1],
  value = acf_vals$acf[-1],
  type = "ACF"
)

df_pacf <- data.frame(
  lag = pacf_vals$lag,
  value = pacf_vals$acf,
  type = "PACF"
)

df_acf_pacf <- bind_rows(df_acf, df_pacf)

# =========================================================
# 4. GRÁFICO ACF + PACF 
# =========================================================

p2 <- ggplot(df_acf_pacf, aes(x = lag, y = value, color = type)) +
  
  geom_hline(yintercept = 0, color = "#3C3C43", linewidth = 0.4) +
  geom_segment(aes(xend = lag, yend = 0), linewidth = 0.8) +
  geom_point(size = 1.8) +
  
  scale_color_manual(
    values = c("ACF" = "#0A84FF", "PACF" = "#FF9F0A"),
    name = NULL
  ) +
  
  labs(x = "Lags", y = "Autocorrelación") +
  
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

ggsave("acf_pacf.png", p2, width = 14, height = 6, dpi = 300, bg = "transparent")

# =========================================================
# 5. TRAIN / TEST SPLIT
# =========================================================

train <- precio_cierre["/2025-04-30"]
test  <- precio_cierre["2025-05-01/2025-05-31"]

h <- nrow(test)

# =========================================================
# 6. MODELO ARIMA
# =========================================================

train_ts <- ts(as.numeric(train), frequency = 252)

modelo_arima <- auto.arima(train_ts)

pred_arima <- forecast(modelo_arima, h = h)

# =========================================================
# 7. MODELO PROPHET
# =========================================================

df_prophet <- data.frame(
  ds = index(train),
  y = as.numeric(train)
)

modelo_prophet <- prophet() %>%
  add_country_holidays(country_name = "US") %>%
  fit.prophet(df_prophet)

future <- data.frame(ds = index(test))

pred_prophet <- predict(modelo_prophet, future)

# =========================================================
# 8. DATAFRAME FINAL DE EVALUACIÓN
# =========================================================

df_eval <- data.frame(
  fecha = index(test),
  real = as.numeric(test),
  arima = as.numeric(pred_arima$mean),
  prophet = pred_prophet$yhat,
  lo80 = pred_arima$lower[,1],
  hi80 = pred_arima$upper[,1]
)

df_eval$error <- df_eval$real - df_eval$arima

# =========================================================
# 9. GRÁFICO COMPARATIVO
# =========================================================

p3 <- ggplot(df_eval, aes(x = fecha)) +
  
  geom_ribbon(aes(ymin = lo80, ymax = hi80),
              fill = "#0A84FF", alpha = 0.10) +
  
  geom_line(aes(y = real, color = "Real"), linewidth = 1) +
  geom_line(aes(y = arima, color = "ARIMA"), linewidth = 1.1) +
  geom_line(aes(y = prophet, color = "Prophet"), linewidth = 1.1) +
  
  scale_color_manual(
    values = c(
      "Real" = "#3C3C43",
      "ARIMA" = "#0A84FF",
      "Prophet" = "#FF9F0A"
    ),
    name = NULL
  ) +
  
  labs(x = NULL, y = "Precio de cierre") +
  
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

ggsave("comparativa_modelos.png", p3, width = 14, height = 6, dpi = 300, bg = "transparent")

# =========================================================
# 10. GRÁFICO ERROR ARIMA 
# =========================================================

p4 <- ggplot(df_eval, aes(x = fecha, y = error)) +
  
  geom_hline(yintercept = 0, color = "#3C3C43", linewidth = 0.8) +
  geom_col(fill = "#FF453A", alpha = 0.8) +
  geom_point(color = "#FF453A", size = 1.8) +
  
  labs(x = NULL, y = "Error (Real - Predicho)") +
  
  theme_minimal(base_size = 24) +
  
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "#3C3C43"),
    axis.title = element_text(color = "#3C3C43"),
    legend.position = "none"
  )

ggsave("error_arima.png", p4, width = 14, height = 5, dpi = 300, bg = "transparent")

# =========================================================
# 11. MÉTRICAS
# =========================================================

mae  <- mean(abs(df_eval$error))
rmse <- sqrt(mean(df_eval$error^2))
mape <- mean(abs(df_eval$error / df_eval$real)) * 100

metricas <- data.frame(
  Metrica = c("MAE", "RMSE", "MAPE"),
  Valor = c(mae, rmse, mape)
)

print(round(metricas, 3))