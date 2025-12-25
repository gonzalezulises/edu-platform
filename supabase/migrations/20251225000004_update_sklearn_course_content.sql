-- =====================================================
-- Actualizar contenido del curso de Scikit-Learn
-- =====================================================

-- Actualizar el contenido de las lecciones con Markdown completo
-- El curso fue creado con ID: 7483519d-cc1d-4cba-bf52-6dde74ce8933

DO $$
DECLARE
  v_course_id UUID := '7483519d-cc1d-4cba-bf52-6dde74ce8933';
  v_lesson_01_id UUID;
  v_lesson_02_id UUID;
  v_lesson_03_id UUID;
  v_lesson_04_id UUID;
BEGIN

  -- Obtener IDs de las lecciones
  SELECT id INTO v_lesson_01_id FROM lessons
  WHERE course_id = v_course_id AND title LIKE '%ecosistema%' LIMIT 1;

  SELECT id INTO v_lesson_02_id FROM lessons
  WHERE course_id = v_course_id AND title LIKE '%fit/predict%' LIMIT 1;

  SELECT id INTO v_lesson_03_id FROM lessons
  WHERE course_id = v_course_id AND title LIKE '%Preprocesamiento%' LIMIT 1;

  SELECT id INTO v_lesson_04_id FROM lessons
  WHERE course_id = v_course_id AND title LIKE '%Evaluacion%' LIMIT 1;

  -- Actualizar Leccion 1: El ecosistema de Scikit-Learn
  UPDATE lessons SET content = E'# El ecosistema de Scikit-Learn

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

- **Todo en sklearn es un ''estimator''** con la misma interfaz
- **fit()** aprende de los datos (parametros, estadisticas)
- **transform()** para preprocesadores, **predict()** para modelos
- **fit_transform()** es un atajo comun

---

## Ejercicio: Identificar el metodo correcto

<!-- exercise:ex-match-problems -->

---

## Resumen

> **En una oracion**: La API consistente de sklearn permite cambiar algoritmos con una linea de codigo porque todos comparten fit/predict/transform, reduciendo el costo de experimentacion.

### Proxima leccion

Ya conoces la API. En la siguiente leccion escribiras tu primer modelo completo con el patron fit/predict.'
  WHERE id = v_lesson_01_id;

  -- Actualizar Leccion 2: El patron fit/predict
  UPDATE lessons SET content = E'# El patron fit/predict: Tu primer modelo

## Objetivos de aprendizaje

- Dividir datos en train/test usando train_test_split con parametros apropiados
- Entrenar un clasificador y generar predicciones sobre datos nuevos
- Explicar por que es necesario separar datos de entrenamiento y prueba
- Calcular accuracy e interpretar su significado

---

## Introduccion

Un modelo que memoriza todos los datos de entrenamiento tiene 100% de accuracy. **Es un buen modelo?**

**No.** Es como un estudiante que memoriza las respuestas de un examen especifico. Cuando le cambian las preguntas, fracasa.

---

## El problema del overfitting

**Overfitting**: El modelo memoriza el ruido de los datos de entrenamiento en lugar de aprender patrones generalizables.

**Solucion**: Evaluar en datos que el modelo nunca vio durante entrenamiento.

**Regla de oro**: El test set es sagrado. Solo lo tocas UNA vez al final.

---

## Dividir datos con train_test_split

```python
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,      # 20% para test
    random_state=42,    # Reproducibilidad
    stratify=y          # Mantener proporcion de clases
)
```

### Parametros importantes:

| Parametro | Descripcion |
|-----------|-------------|
| `test_size=0.2` | Reserva 20% para evaluacion |
| `random_state=42` | Fijo = mismos resultados cada vez |
| `stratify=y` | Asegura misma proporcion de clases en ambos sets |

---

## Ejercicio: Dividir datos

<!-- exercise:ex-train-test-split -->

---

## Entrenar y evaluar un modelo

```python
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# 1. Crear el modelo
modelo = LogisticRegression(random_state=42)

# 2. Entrenar (solo con train)
modelo.fit(X_train, y_train)

# 3. Predecir (en test)
y_pred = modelo.predict(X_test)

# 4. Evaluar
accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy:.2%}")
```

---

## Ejercicio: Tu primer modelo

<!-- exercise:ex-primer-modelo -->

---

## Ejercicio: Analisis de accuracy

<!-- exercise:ex-accuracy-analysis -->

---

## Resumen

> **Por que train_test_split debe ejecutarse ANTES de cualquier preprocesamiento?**
>
> Para evitar data leakage. Si preproceso con todo el dataset, informacion de test contamina el entrenamiento.

### Proxima leccion

Tu modelo funciona, pero los datos del mundo real vienen sucios. Siguiente: **preprocesamiento con sklearn**.'
  WHERE id = v_lesson_02_id;

  -- Actualizar Leccion 3: Preprocesamiento de datos
  UPDATE lessons SET content = E'# Preprocesamiento de datos

## Objetivos de aprendizaje

- Escalar features numericas con StandardScaler y MinMaxScaler
- Codificar variables categoricas con OneHotEncoder y LabelEncoder
- Identificar cuando usar cada tipo de preprocesamiento segun el algoritmo
- Manejar valores faltantes con SimpleImputer

---

## Por que escalar?

Muchos algoritmos son sensibles a la escala:

| Algoritmo | Por que le afecta |
|-----------|-------------------|
| **KNN** | Usa distancia euclidiana |
| **SVM** | Kernel RBF asume escalas similares |
| **Regresion regularizada** | L1/L2 penaliza coeficientes grandes |

**NO sensibles**: Arboles (Decision Tree, Random Forest, XGBoost)

### Tipos de scalers

| Scaler | Cuando usar |
|--------|-------------|
| **StandardScaler** | Default, distribucion ~normal |
| **MinMaxScaler** | Rango [0,1], sensible a outliers |
| **RobustScaler** | Con outliers |

---

## Ejercicio: Escalar features

<!-- exercise:ex-scaling -->

---

## Codificacion de variables categoricas

```python
from sklearn.preprocessing import OneHotEncoder

ohe = OneHotEncoder(sparse_output=False, handle_unknown=''ignore'')
ciudades_encoded = ohe.fit_transform(df[[''ciudad'']])
```

> **NUNCA uses LabelEncoder para features** - implica orden falso

---

## Ejercicio: Codificar variables

<!-- exercise:ex-encoding -->

---

## Manejo de valores faltantes

```python
from sklearn.impute import SimpleImputer

imputer = SimpleImputer(strategy=''median'')
X_clean = imputer.fit_transform(X)
```

---

## Ejercicio: Imputar valores faltantes

<!-- exercise:ex-imputation -->

---

## Orden correcto

1. **SPLIT** primero (train_test_split)
2. **fit()** preprocesadores solo en train
3. **transform()** en train y test

**Regla**: Solo fit() en train para evitar data leakage.

---

## Resumen

Datos limpios, modelo entrenado. Pero accuracy no es suficiente. Siguiente: **evaluacion de modelos**.'
  WHERE id = v_lesson_03_id;

  -- Actualizar Leccion 4: Evaluacion de modelos
  UPDATE lessons SET content = E'# Evaluacion de modelos

## Objetivos de aprendizaje

- Calcular e interpretar precision, recall y F1-score
- Elegir la metrica correcta segun el costo de errores del negocio
- Ajustar el umbral de decision para balancear precision vs recall
- Interpretar curvas ROC y AUC para comparar modelos

---

## Matriz de confusion

| | Predicho Neg | Predicho Pos |
|-|--------------|--------------|
| **Real Neg** | TN | FP (falsa alarma) |
| **Real Pos** | FN (se escapo) | TP |

---

## Las 4 metricas fundamentales

| Metrica | Formula | Pregunta |
|---------|---------|----------|
| **Accuracy** | (TP+TN)/Total | % predicciones correctas |
| **Precision** | TP/(TP+FP) | De los positivos predichos, cuantos son reales? |
| **Recall** | TP/(TP+FN) | De los positivos reales, cuantos detecte? |
| **F1** | 2*(P*R)/(P+R) | Balance precision-recall |

### Reglas practicas

- **Maximiza Recall**: cuando FN es costoso (diagnostico cancer)
- **Maximiza Precision**: cuando FP es costoso (spam)
- **Maximiza F1**: ambos errores igual de costosos

---

## Ejercicio: Calcular metricas

<!-- exercise:ex-metrics-calculation -->

---

## Ejercicio: Elegir la metrica correcta

<!-- exercise:ex-metric-selection -->

---

## Ajustar el umbral

```python
y_proba = modelo.predict_proba(X_test)[:, 1]
umbral = 0.3  # Mas sensible
y_pred = (y_proba >= umbral).astype(int)
```

- Umbral bajo -> mas recall, menos precision
- Umbral alto -> menos recall, mas precision

---

## Ejercicio: Ajustar umbral

<!-- exercise:ex-threshold-tuning -->

---

## Curva ROC y AUC

| AUC | Interpretacion |
|-----|----------------|
| 0.5 | Aleatorio |
| 0.7-0.8 | Aceptable |
| 0.8-0.9 | Bueno |
| 0.9+ | Excelente |

---

## Resumen

Tienes las herramientas. Ahora aplicalas en el **proyecto final**: clasificador de churn.'
  WHERE id = v_lesson_04_id;

  RAISE NOTICE 'Contenido actualizado para las 4 lecciones del curso sklearn';

END $$;
