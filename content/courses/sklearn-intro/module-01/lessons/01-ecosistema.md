# El ecosistema de Scikit-Learn

## Objetivos de aprendizaje

- Identificar los tipos de problemas que sklearn puede resolver (clasificacion, regresion, clustering, reduccion dimensional)
- Explicar la API consistente de sklearn (estimator, fit, predict, transform)
- Distinguir cuando usar sklearn vs alternativas (statsmodels, deep learning, AutoML)

---

## Introduccion

Tienes un dataset de 10,000 clientes con 20 variables. Tu jefe quiere saber quienes van a cancelar el proximo mes.

Podrias escribir reglas manuales ("si edad < 25 y tenure < 6 meses, alto riesgo")... O podrias dejar que un algoritmo descubra los patrones por ti.

**Scikit-learn es la herramienta estandar para esto en Python.**

---

## Que es Scikit-Learn?

Una libreria de ML **clasico** para Python. No hace deep learning (eso es PyTorch/TensorFlow).

Resuelve 4 tipos de problemas:

| Tipo | Input | Output | Ejemplo |
|------|-------|--------|---------|
| **Clasificacion** | Features | Categoria | Spam o no spam? |
| **Regresion** | Features | Numero continuo | Precio de casa? |
| **Clustering** | Features | Grupo (sin labels) | Segmentos de clientes |
| **Reduccion dimensional** | Features | Menos features | Visualizacion, compresion |

### Cuando NO usar sklearn:

- **Imagenes, texto, audio** -> Deep learning (PyTorch, TensorFlow)
- **Inferencia estadistica** (p-values, intervalos) -> statsmodels
- **Series temporales** -> prophet, statsmodels, sktime
- **Datos tabulares masivos con AutoML** -> auto-sklearn, H2O

---

## La API consistente de sklearn

```python
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

# 1. Crear el objeto (estimator)
modelo = LogisticRegression()
scaler = StandardScaler()

# 2. Ajustar a los datos (fit)
scaler.fit(X_train)
modelo.fit(X_train_scaled, y_train)

# 3. Usar el objeto ajustado
X_test_scaled = scaler.transform(X_test)  # transform para preprocesadores
predicciones = modelo.predict(X_test_scaled)  # predict para modelos

# Patron comun: fit_transform (fit + transform en un paso)
X_train_scaled = scaler.fit_transform(X_train)
```

### Puntos clave:

- **Todo en sklearn es un 'estimator'** con la misma interfaz
- **fit()** aprende de los datos (parametros, estadisticas)
- **transform()** para preprocesadores, **predict()** para modelos
- **fit_transform()** es un atajo comun

---

## Diagrama de la API

```
+-------------------------------------------------------------+
|                      BaseEstimator                          |
|                                                             |
|  fit(X, y=None)    Aprende de los datos                    |
|  get_params()      Retorna hiperparametros                 |
|  set_params()      Modifica hiperparametros                |
+-------------------------------------------------------------+
              |                              |
              v                              v
+---------------------+      +---------------------+
|   TransformerMixin  |      |   ClassifierMixin   |
|                     |      |   RegressorMixin    |
|  transform(X)       |      |                     |
|  fit_transform(X)   |      |  predict(X)         |
|                     |      |  predict_proba(X)   |
|  Ej: StandardScaler |      |  score(X, y)        |
|      PCA            |      |                     |
|      OneHotEncoder  |      |  Ej: LogisticReg    |
+---------------------+      |      RandomForest   |
                             |      SVC            |
                             +---------------------+
```

**Esta consistencia significa que puedes cambiar un modelo por otro con una sola linea de codigo.** El resto del pipeline no cambia.

---

## Comparacion: Sklearn vs Alternativas

| Criterio | Scikit-Learn | Statsmodels | PyTorch/TF |
|----------|--------------|-------------|------------|
| **Foco** | Prediccion | Inferencia estadistica | Deep learning |
| **Output tipico** | predict() | summary() con p-values | forward() |
| **Datos** | Tabulares pequenos/medianos | Tabulares | Cualquiera, GPUs |
| **Curva de aprendizaje** | Baja | Media | Alta |
| **Produccion** | Facil (joblib) | Limitado | Complejo (serving) |

---

## Ejercicio: Identificar el metodo correcto

<!-- exercise:ex-match-problems -->

---

## Resumen

> **En una oracion**: La API consistente de sklearn permite cambiar algoritmos con una linea de codigo porque todos comparten fit/predict/transform, reduciendo el costo de experimentacion.

### Proxima leccion

Ya conoces la API. En la siguiente leccion escribiras tu primer modelo completo con el patron fit/predict.
