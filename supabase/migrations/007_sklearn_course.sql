-- =====================================================
-- CURSO: Introduccion a Scikit-Learn
-- Modulo 1: De cero a entrenar y evaluar tu primer modelo
-- =====================================================

-- Variables para IDs (usando DO block para manejar UUIDs)
DO $$
DECLARE
  v_course_id UUID;
  v_module_01_id UUID;
  v_module_02_id UUID;
  v_module_03_id UUID;
  v_module_04_id UUID;
  v_lesson_01_id UUID;
  v_lesson_02_id UUID;
  v_lesson_03_id UUID;
  v_lesson_04_id UUID;
  v_quiz_01_id UUID;
  v_quiz_02_id UUID;
BEGIN

  -- ============================================
  -- 1. CREAR CURSO
  -- ============================================
  INSERT INTO courses (title, description, thumbnail_url, is_published)
  VALUES (
    'Introduccion a Scikit-Learn',
    'De cero a entrenar y evaluar tu primer modelo de machine learning. Aprende el ecosistema sklearn, el patron fit/predict, preprocesamiento de datos y evaluacion de modelos con metricas de negocio.',
    '/images/courses/sklearn-intro.jpg',
    true
  )
  RETURNING id INTO v_course_id;

  -- ============================================
  -- 2. CREAR MODULOS
  -- ============================================

  -- Modulo 1: El ecosistema de Scikit-Learn
  INSERT INTO modules (course_id, title, description, order_index)
  VALUES (
    v_course_id,
    'El ecosistema de Scikit-Learn',
    'Entender que es sklearn, su API consistente, y cuando usarlo vs alternativas',
    1
  )
  RETURNING id INTO v_module_01_id;

  -- Modulo 2: El patron fit/predict
  INSERT INTO modules (course_id, title, description, order_index, unlock_after_module)
  VALUES (
    v_course_id,
    'El patron fit/predict',
    'Entrenar, predecir y evaluar un clasificador desde cero',
    2,
    v_module_01_id
  )
  RETURNING id INTO v_module_02_id;

  -- Modulo 3: Preprocesamiento de datos
  INSERT INTO modules (course_id, title, description, order_index, unlock_after_module)
  VALUES (
    v_course_id,
    'Preprocesamiento de datos',
    'Transformar datos crudos en features listas para modelos',
    3,
    v_module_02_id
  )
  RETURNING id INTO v_module_03_id;

  -- Modulo 4: Evaluacion de modelos
  INSERT INTO modules (course_id, title, description, order_index, unlock_after_module)
  VALUES (
    v_course_id,
    'Evaluacion de modelos',
    'Metricas de clasificacion y como elegir la correcta segun el problema',
    4,
    v_module_03_id
  )
  RETURNING id INTO v_module_04_id;

  -- ============================================
  -- 3. CREAR LECCIONES
  -- ============================================

  -- Leccion 1: El ecosistema de Scikit-Learn
  INSERT INTO lessons (course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required)
  VALUES (
    v_course_id,
    v_module_01_id,
    'El ecosistema de Scikit-Learn',
    E'# El ecosistema de Scikit-Learn

## Objetivos de aprendizaje
- Identificar los tipos de problemas que sklearn puede resolver
- Explicar la API consistente de sklearn (estimator, fit, predict, transform)
- Distinguir cuando usar sklearn vs alternativas

---

## Que es Scikit-Learn?

Una libreria de ML **clasico** para Python. No hace deep learning (eso es PyTorch/TensorFlow).

Resuelve 4 tipos de problemas:

| Tipo | Input | Output | Ejemplo |
|------|-------|--------|---------|
| Clasificacion | Features | Categoria | Spam o no spam? |
| Regresion | Features | Numero continuo | Precio de casa? |
| Clustering | Features | Grupo (sin labels) | Segmentos de clientes |
| Reduccion dimensional | Features | Menos features | Visualizacion, compresion |

### Cuando NO usar sklearn:
- Imagenes, texto, audio → Deep learning
- Inferencia estadistica (p-values, intervalos) → statsmodels
- Series temporales → prophet, statsmodels, sktime
- Datos tabulares masivos con AutoML → auto-sklearn, H2O

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

### Diagrama de la API

```
┌─────────────────────────────────────────────────────────────┐
│                      BaseEstimator                          │
│                                                             │
│  fit(X, y=None)    Aprende de los datos                    │
│  get_params()      Retorna hiperparametros                 │
│  set_params()      Modifica hiperparametros                │
└─────────────────────────────────────────────────────────────┘
              │                              │
              ▼                              ▼
┌─────────────────────┐      ┌─────────────────────┐
│   TransformerMixin  │      │   ClassifierMixin   │
│                     │      │   RegressorMixin    │
│  transform(X)       │      │                     │
│  fit_transform(X)   │      │  predict(X)         │
│                     │      │  predict_proba(X)   │
│  Ej: StandardScaler │      │  score(X, y)        │
│      PCA            │      │                     │
│      OneHotEncoder  │      │  Ej: LogisticReg    │
└─────────────────────┘      │      RandomForest   │
                             │      SVC            │
                             └─────────────────────┘
```

Esta consistencia significa que puedes cambiar un modelo por otro
con una sola linea de codigo. El resto del pipeline no cambia.

---

## Comparacion: Sklearn vs Alternativas

| Criterio | Scikit-Learn | Statsmodels | PyTorch/TF |
|----------|--------------|-------------|------------|
| Foco | Prediccion | Inferencia estadistica | Deep learning |
| Output tipico | predict() | summary() con p-values | forward() |
| Datos | Tabulares pequenos/medianos | Tabulares | Cualquiera, GPUs |
| Curva de aprendizaje | Baja | Media | Alta |
| Produccion | Facil (joblib) | Limitado | Complejo (serving) |

---

## Resumen

En una oracion: la API consistente de sklearn permite cambiar algoritmos con una linea de codigo porque todos comparten fit/predict/transform, reduciendo el costo de experimentacion.',
    'text',
    1,
    45,
    true
  )
  RETURNING id INTO v_lesson_01_id;

  -- Leccion 2: El patron fit/predict
  INSERT INTO lessons (course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, unlock_after_lesson)
  VALUES (
    v_course_id,
    v_module_02_id,
    'El patron fit/predict: Tu primer modelo',
    E'# El patron fit/predict: Tu primer modelo

## Objetivos de aprendizaje
- Dividir datos en train/test usando train_test_split
- Entrenar un clasificador y generar predicciones
- Explicar por que es necesario separar datos
- Calcular accuracy e interpretar su significado

---

## El problema del overfitting

Un modelo que memoriza todos los datos de entrenamiento tiene 100% de accuracy.
Es un buen modelo? **No**. Es como un estudiante que memoriza las respuestas de un examen especifico. Cuando le cambian las preguntas, fracasa.

**Overfitting**: El modelo memoriza el ruido de los datos de entrenamiento
en lugar de aprender patrones generalizables.

**Solucion**: Evaluar en datos que el modelo nunca vio durante entrenamiento.

```
Dataset completo
┌─────────────────────────────────────────────────────┐
│                                                     │
│  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │   Training Set      │  │     Test Set        │  │
│  │   (70-80%)          │  │     (20-30%)        │  │
│  │                     │  │                     │  │
│  │   fit() aqui        │  │   predict() aqui    │  │
│  │                     │  │   evaluar aqui      │  │
│  └─────────────────────┘  └─────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Regla de oro**: El test set es sagrado. Solo lo tocas UNA vez al final.

---

## Dividir datos con train_test_split

```python
from sklearn.model_selection import train_test_split

# X: features (matriz), y: target (vector)
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,      # 20% para test
    random_state=42,    # Reproducibilidad
    stratify=y          # Mantener proporcion de clases
)

print(f"Train: {len(X_train)}, Test: {len(X_test)}")
print(f"Proporcion clase 1 en train: {y_train.mean():.2%}")
print(f"Proporcion clase 1 en test:  {y_test.mean():.2%}")
```

### Parametros importantes:
- `test_size=0.2`: Reserva 20% para evaluacion
- `random_state=42`: Fijo = mismos resultados cada vez
- `stratify=y`: Asegura misma proporcion de clases en ambos sets

---

## Flujo completo: Entrenar → Predecir → Evaluar

```
┌──────────────┐
│   Dataset    │
└──────┬───────┘
       │ train_test_split()
       ▼
┌──────────────┐     ┌──────────────┐
│   X_train    │     │   X_test     │
│   y_train    │     │   y_test     │
└──────┬───────┘     └──────┬───────┘
       │                    │
       ▼                    │
┌──────────────┐            │
│  model.fit() │            │
│  (entrena)   │            │
└──────┬───────┘            │
       │                    │
       ▼                    ▼
┌─────────────────────────────────┐
│      model.predict(X_test)      │
│      → y_pred                   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│   Comparar y_pred vs y_test     │
│   → accuracy, precision, etc.   │
└─────────────────────────────────┘
```

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

# Tambien: score() hace predict + accuracy en un paso
accuracy = modelo.score(X_test, y_test)
```

---

## Reflexion importante

Si tu modelo tiene 98% accuracy en train pero 72% en test, que esta pasando?

**Overfitting**. El modelo memorizo patrones especificos del training set que no generalizan a datos nuevos. Posibles soluciones:
- Usar un modelo mas simple
- Regularizacion
- Mas datos de entrenamiento
- Feature engineering',
    'text',
    1,
    60,
    true,
    v_lesson_01_id
  )
  RETURNING id INTO v_lesson_02_id;

  -- Leccion 3: Preprocesamiento de datos
  INSERT INTO lessons (course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, unlock_after_lesson)
  VALUES (
    v_course_id,
    v_module_03_id,
    'Preprocesamiento de datos',
    E'# Preprocesamiento de datos

## Objetivos de aprendizaje
- Escalar features numericas con StandardScaler y MinMaxScaler
- Codificar variables categoricas con OneHotEncoder y LabelEncoder
- Identificar cuando usar cada tipo de preprocesamiento
- Manejar valores faltantes con SimpleImputer

---

## Por que escalar?

Dataset real de clientes:
- `edad`: 18-85
- `ingreso_anual`: $15,000-$500,000
- `ciudad`: "Lima", "Bogota", "CDMX", NaN
- `tiempo_cliente_meses`: 0-120

Los modelos esperan datos numericos, sin missing, y a escalas comparables.

### Algoritmos sensibles a escala:
- **KNN**: Usa distancia euclidiana. Feature con rango 0-500,000 domina sobre 0-100.
- **SVM**: Kernel RBF asume features en escala similar.
- **Regresion con regularizacion**: L1/L2 penaliza coeficientes grandes.
- **Redes neuronales**: Gradientes explotan o desvanecen.

### NO sensibles a escala:
- Arboles (Decision Tree, Random Forest, XGBoost)

| Scaler | Formula | Cuando usar |
|--------|---------|-------------|
| StandardScaler | (x - μ) / σ | Default. Asume distribucion ~normal |
| MinMaxScaler | (x - min) / (max - min) | Rango [0,1]. Sensible a outliers |
| RobustScaler | (x - median) / IQR | Con outliers |

---

## Codificacion de variables categoricas

```python
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
import pandas as pd

# Datos
df = pd.DataFrame({''ciudad'': [''Lima'', ''Bogota'', ''Lima'', ''CDMX'']})

# OneHotEncoder: Para features (crea columnas binarias)
ohe = OneHotEncoder(sparse_output=False, handle_unknown=''ignore'')
ciudades_encoded = ohe.fit_transform(df[[''ciudad'']])
# Resultado: [[1,0,0], [0,1,0], [1,0,0], [0,0,1]]

# LabelEncoder: Para target (convierte a numeros)
le = LabelEncoder()
ciudades_label = le.fit_transform(df[''ciudad''])
# Resultado: [1, 0, 1, 2]  # Bogota=0, CDMX=1, Lima=2

# NUNCA uses LabelEncoder para features
# Los modelos interpretarian CDMX > Bogota como orden
```

---

## Manejo de valores faltantes

```python
from sklearn.impute import SimpleImputer

# Numericos: media, mediana, o constante
imputer_num = SimpleImputer(strategy=''median'')
X_num_clean = imputer_num.fit_transform(X_num)

# Categoricos: moda o constante
imputer_cat = SimpleImputer(strategy=''most_frequent'')
X_cat_clean = imputer_cat.fit_transform(X_cat)
```

### Estrategias:
- `mean`: Promedio. Sensible a outliers.
- `median`: Mediana. Robusto a outliers.
- `most_frequent`: Moda. Para categoricos.
- `constant`: Valor fijo (ej: 0, "MISSING").

**Advertencia**: SimpleImputer no detecta patrones en missing.
Si los NaN no son aleatorios (ej: ingresos faltantes = no reportan),
considera crear un feature binario `ingreso_missing`.

---

## Orden correcto de preprocesamiento

```
┌─────────────────────────────────────────────────────────────┐
│ 1. TRAIN/TEST SPLIT (antes de todo!)                       │
└─────────────────────────────────────────────────────────────┘
                             │
               ┌─────────────┴─────────────┐
               ▼                           ▼
         ┌──────────┐               ┌──────────┐
         │  TRAIN   │               │   TEST   │
         └────┬─────┘               └────┬─────┘
              │                          │
┌─────────────▼─────────────┐           │
│ 2. fit() preprocesadores  │           │
│    en TRAIN unicamente    │           │
└─────────────┬─────────────┘           │
              │                          │
┌─────────────▼─────────────┐  ┌────────▼────────┐
│ 3. transform() TRAIN      │  │ transform() TEST│
└─────────────┬─────────────┘  └────────┬────────┘
              │                          │
┌─────────────▼─────────────┐           │
│ 4. fit() modelo en TRAIN  │           │
└─────────────┬─────────────┘           │
              │                          │
              └──────────┬───────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. predict() en TEST → evaluar                             │
└─────────────────────────────────────────────────────────────┘
```

**Regla**: Solo fit() en train. Transform ambos con los mismos parametros.

---

## Por que fit() solo en train?

Porque fit() aprende estadisticas de los datos (media, std, categorias).
Si incluyes test, esas estadisticas reflejan datos que el modelo no deberia conocer, causando **data leakage**.',
    'text',
    1,
    75,
    true,
    v_lesson_02_id
  )
  RETURNING id INTO v_lesson_03_id;

  -- Leccion 4: Evaluacion de modelos
  INSERT INTO lessons (course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, unlock_after_lesson)
  VALUES (
    v_course_id,
    v_module_04_id,
    'Evaluacion de modelos',
    E'# Evaluacion de modelos

## Objetivos de aprendizaje
- Calcular e interpretar precision, recall y F1-score
- Elegir la metrica correcta segun el costo de errores
- Ajustar el umbral de decision para balancear precision vs recall
- Interpretar curvas ROC y AUC para comparar modelos

---

## El trade-off fundamental

Dos modelos para detectar fraude:
- **Modelo A**: Detecta 90 de 100 fraudes, pero marca 500 transacciones legitimas como fraude.
- **Modelo B**: Detecta 70 de 100 fraudes, pero solo marca 50 transacciones legitimas como fraude.

Cual es mejor? **Depende**: Es peor perder un fraude o molestar a un cliente bloqueando su compra?

---

## Matriz de confusion

```
                      PREDICHO
                   │  Neg (0) │  Pos (1) │
        ───────────┼──────────┼──────────┤
        Neg (0)    │    TN    │    FP    │  ← "Falsa alarma"
REAL    ───────────┼──────────┼──────────┤
        Pos (1)    │    FN    │    TP    │  ← "Se escapo"
        ───────────┴──────────┴──────────┘
```

- **TP (True Positive)**: Era fraude, detectamos fraude
- **TN (True Negative)**: No era fraude, dijimos no fraude
- **FP (False Positive)**: No era fraude, dijimos fraude (falsa alarma)
- **FN (False Negative)**: Era fraude, dijimos no fraude (se escapo)

---

## Las 4 metricas fundamentales

| Metrica | Formula | Pregunta que responde |
|---------|---------|----------------------|
| **Accuracy** | (TP+TN) / Total | Que % de predicciones fueron correctas? |
| **Precision** | TP / (TP+FP) | De los que marque positivos, que % realmente lo era? |
| **Recall** | TP / (TP+FN) | De los positivos reales, que % detecte? |
| **F1** | 2 × (P×R)/(P+R) | Balance entre precision y recall |

### Reglas practicas:
- **Maximiza Recall** cuando perder un positivo es costoso (ej: diagnostico de cancer)
- **Maximiza Precision** cuando los falsos positivos son costosos (ej: spam que borra emails)
- **Maximiza F1** cuando ambos errores son igualmente costosos

```python
from sklearn.metrics import classification_report

print(classification_report(y_test, y_pred))
#               precision  recall  f1-score
# clase 0          0.95     0.98     0.96
# clase 1          0.87     0.76     0.81
```

---

## Ajustar el umbral de decision

```python
# Por defecto, predict() usa umbral = 0.5
y_pred = modelo.predict(X_test)  # Si proba >= 0.5 → 1

# Pero podemos obtener las probabilidades
y_proba = modelo.predict_proba(X_test)[:, 1]  # Prob de clase 1

# Y elegir nuestro propio umbral
umbral = 0.3  # Mas sensible: mas positivos, mas recall
y_pred_custom = (y_proba >= umbral).astype(int)

# Umbral bajo → mas recall, menos precision
# Umbral alto → menos recall, mas precision

# Ejemplo: si fraude cuesta $10,000 y falsa alarma $10
# Preferimos umbral bajo para no perder fraudes
```

---

## Curva ROC y AUC

La curva ROC muestra el trade-off precision/recall para TODOS los umbrales posibles.

- **Eje X**: False Positive Rate = FP / (FP + TN)
- **Eje Y**: True Positive Rate = Recall = TP / (TP + FN)

```python
from sklearn.metrics import roc_curve, roc_auc_score

fpr, tpr, thresholds = roc_curve(y_test, y_proba)
auc = roc_auc_score(y_test, y_proba)
```

### Interpretacion de AUC:
- 0.5 = Modelo aleatorio (inutil)
- 0.7-0.8 = Aceptable
- 0.8-0.9 = Bueno
- 0.9+ = Excelente

**AUC responde**: Si tomo un positivo y un negativo al azar, que probabilidad hay de que el modelo asigne mayor score al positivo?

---

## Importante: AUC no es todo

AUC mide calidad promedio de ranking, no performance en un umbral especifico.
Un modelo con menor AUC podria ser mejor en el umbral operativo que te importa.
AUC es util para comparar, pero la eleccion final depende del umbral y los costos del negocio.

---

## Por que NO optimizar siempre por accuracy?

Porque en datasets desbalanceados, un modelo tonto que predice la clase mayoritaria tiene accuracy alta pero no detecta la clase importante.
Ademas, accuracy no considera el costo diferencial de FP vs FN.',
    'text',
    1,
    70,
    true,
    v_lesson_03_id
  )
  RETURNING id INTO v_lesson_04_id;

  -- ============================================
  -- 4. CREAR QUIZZES
  -- ============================================

  -- Quiz 1: Ecosistema de Scikit-Learn
  INSERT INTO quizzes (lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, is_published)
  VALUES (
    v_lesson_01_id,
    'Quiz: Ecosistema de Scikit-Learn',
    'Evalua tu comprension del ecosistema sklearn y su API consistente',
    60,
    2,
    8,
    true,
    true
  )
  RETURNING id INTO v_quiz_01_id;

  -- Preguntas Quiz 1
  INSERT INTO quiz_questions (quiz_id, question_type, question, options, correct_answer, points, order_index, explanation)
  VALUES
  (
    v_quiz_01_id,
    'mcq',
    'Cual de estos problemas NO es un tipo principal que sklearn resuelve?',
    '[{"id": "a", "text": "Clasificacion", "is_correct": false}, {"id": "b", "text": "Regresion", "is_correct": false}, {"id": "c", "text": "Generacion de texto", "is_correct": true}, {"id": "d", "text": "Clustering", "is_correct": false}]'::jsonb,
    NULL,
    1,
    1,
    'Sklearn resuelve clasificacion, regresion, clustering y reduccion dimensional. Generacion de texto requiere modelos de lenguaje (deep learning).'
  ),
  (
    v_quiz_01_id,
    'mcq',
    E'```python\nfrom sklearn.preprocessing import StandardScaler\nscaler = StandardScaler()\nX_scaled = scaler.fit_transform(X_train)\n```\nQue hace fit_transform en una sola llamada?',
    '[{"id": "a", "text": "Predice valores y los transforma", "is_correct": false}, {"id": "b", "text": "Aprende parametros de X_train y luego transforma X_train", "is_correct": true}, {"id": "c", "text": "Transforma y luego aprende de los datos transformados", "is_correct": false}, {"id": "d", "text": "Es equivalente a solo transform()", "is_correct": false}]'::jsonb,
    NULL,
    1,
    2,
    'fit_transform() primero ejecuta fit() (aprende media y std de X_train) y luego transform() (escala X_train con esos parametros). Es mas eficiente que llamarlos por separado.'
  ),
  (
    v_quiz_01_id,
    'mcq',
    'Por que usarias statsmodels en lugar de sklearn para un modelo de regresion?',
    '[{"id": "a", "text": "Statsmodels es mas rapido", "is_correct": false}, {"id": "b", "text": "Statsmodels da p-values e intervalos de confianza", "is_correct": true}, {"id": "c", "text": "Sklearn no puede hacer regresion lineal", "is_correct": false}, {"id": "d", "text": "Statsmodels tiene mejor accuracy", "is_correct": false}]'::jsonb,
    NULL,
    2,
    3,
    'Sklearn optimiza para prediccion; statsmodels para inferencia estadistica. Si necesitas saber si un coeficiente es estadisticamente significativo, usa statsmodels.'
  ),
  (
    v_quiz_01_id,
    'true_false',
    'En sklearn, tanto los preprocesadores (ej. StandardScaler) como los modelos (ej. LogisticRegression) tienen el metodo fit().',
    NULL,
    'true',
    1,
    4,
    'Correcto. Todos los estimators de sklearn tienen fit(). Los preprocesadores ademas tienen transform(); los modelos tienen predict().'
  ),
  (
    v_quiz_01_id,
    'mcq',
    E'Tienes un scaler ya ajustado con datos de entrenamiento:\n```python\nscaler.fit(X_train)\n```\nComo debes procesar X_test?',
    '[{"id": "a", "text": "scaler.fit(X_test)", "is_correct": false}, {"id": "b", "text": "scaler.fit_transform(X_test)", "is_correct": false}, {"id": "c", "text": "scaler.transform(X_test)", "is_correct": true}, {"id": "d", "text": "scaler.predict(X_test)", "is_correct": false}]'::jsonb,
    NULL,
    2,
    5,
    'Solo transform(). Si haces fit() o fit_transform() en test, introduces data leakage: el scaler aprenderia estadisticas de test que no deberia conocer.'
  );

  -- Quiz 2: Patron fit/predict
  INSERT INTO quizzes (lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, is_published)
  VALUES (
    v_lesson_02_id,
    'Quiz: Patron fit/predict',
    'Evalua tu comprension del patron fit/predict y division de datos',
    60,
    2,
    8,
    true,
    true
  )
  RETURNING id INTO v_quiz_02_id;

  -- Preguntas Quiz 2
  INSERT INTO quiz_questions (quiz_id, question_type, question, options, correct_answer, points, order_index, explanation)
  VALUES
  (
    v_quiz_02_id,
    'mcq',
    'Por que separamos los datos en train y test ANTES de cualquier preprocesamiento?',
    '[{"id": "a", "text": "Para que el codigo sea mas rapido", "is_correct": false}, {"id": "b", "text": "Para evitar que informacion de test influya en el entrenamiento (data leakage)", "is_correct": true}, {"id": "c", "text": "Porque sklearn lo requiere tecnicamente", "is_correct": false}, {"id": "d", "text": "No es necesario, se puede hacer despues", "is_correct": false}]'::jsonb,
    NULL,
    2,
    1,
    'Data leakage ocurre cuando informacion de test contamina el proceso de entrenamiento. Si calculas la media para normalizar con todo el dataset, esa media incluye info de test.'
  ),
  (
    v_quiz_02_id,
    'mcq',
    E'```python\nmodelo.fit(X_train, y_train)\naccuracy_train = modelo.score(X_train, y_train)\naccuracy_test = modelo.score(X_test, y_test)\n```\nSi accuracy_train = 0.99 y accuracy_test = 0.75, que indica esto?',
    '[{"id": "a", "text": "El modelo es muy bueno", "is_correct": false}, {"id": "b", "text": "Overfitting: el modelo memorizo train pero no generaliza", "is_correct": true}, {"id": "c", "text": "Underfitting: el modelo es muy simple", "is_correct": false}, {"id": "d", "text": "Los datos de test son de mala calidad", "is_correct": false}]'::jsonb,
    NULL,
    2,
    2,
    'Gran diferencia entre accuracy en train (99%) y test (75%) es senal clasica de overfitting. El modelo aprendio patrones especificos del train que no aplican a datos nuevos.'
  ),
  (
    v_quiz_02_id,
    'mcq',
    'Que hace el parametro stratify=y en train_test_split?',
    '[{"id": "a", "text": "Ordena los datos por el target antes de dividir", "is_correct": false}, {"id": "b", "text": "Asegura que train y test tengan la misma proporcion de cada clase", "is_correct": true}, {"id": "c", "text": "Elimina clases minoritarias del dataset", "is_correct": false}, {"id": "d", "text": "Hace oversampling de la clase minoritaria", "is_correct": false}]'::jsonb,
    NULL,
    1,
    3,
    'stratify=y divide manteniendo la proporcion original de clases. Si el dataset tiene 70% clase A y 30% clase B, tanto train como test tendran esa misma proporcion.'
  ),
  (
    v_quiz_02_id,
    'true_false',
    'modelo.score(X_test, y_test) es equivalente a accuracy_score(y_test, modelo.predict(X_test)) para clasificadores.',
    NULL,
    'true',
    1,
    4,
    'Para clasificadores, .score() calcula accuracy internamente. Hace predict() y compara con y_test.'
  ),
  (
    v_quiz_02_id,
    'mcq',
    'Un modelo con 95% accuracy en un dataset donde 95% de las muestras son de clase 0. Que puedes concluir?',
    '[{"id": "a", "text": "El modelo es excelente", "is_correct": false}, {"id": "b", "text": "No puedes concluir nada, necesitas ver otras metricas", "is_correct": true}, {"id": "c", "text": "El modelo tiene overfitting", "is_correct": false}, {"id": "d", "text": "El dataset es demasiado facil", "is_correct": false}]'::jsonb,
    NULL,
    2,
    5,
    'Un modelo que siempre predice clase 0 tendria 95% accuracy aqui. Necesitas ver recall, precision, o la confusion matrix para saber si realmente detecta la clase minoritaria.'
  );

  -- Mensaje de confirmacion
  RAISE NOTICE 'Curso de Scikit-Learn creado exitosamente!';
  RAISE NOTICE 'Course ID: %', v_course_id;
  RAISE NOTICE 'Modulos creados: 4';
  RAISE NOTICE 'Lecciones creadas: 4';
  RAISE NOTICE 'Quizzes creados: 2';

END $$;
