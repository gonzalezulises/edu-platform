# Preprocesamiento de datos

## Objetivos de aprendizaje

- Escalar features numericas con StandardScaler y MinMaxScaler
- Codificar variables categoricas con OneHotEncoder y LabelEncoder
- Identificar cuando usar cada tipo de preprocesamiento segun el algoritmo
- Manejar valores faltantes con SimpleImputer

---

## Introduccion

Dataset real de clientes:
- `edad`: 18-85
- `ingreso_anual`: $15,000-$500,000
- `ciudad`: "Lima", "Bogota", "CDMX", NaN
- `tiempo_cliente_meses`: 0-120, con algunos NaN

**Puedes entrenar un modelo directamente con esto?**

Tecnicamente si. Pero probablemente funcione mal.

Los modelos esperan datos numericos, sin missing, y a escalas comparables.

---

## Por que escalar?

Muchos algoritmos son sensibles a la escala:

| Algoritmo | Por que le afecta la escala |
|-----------|----------------------------|
| **KNN** | Usa distancia euclidiana. Feature con rango 0-500,000 domina sobre 0-100 |
| **SVM** | Kernel RBF asume features en escala similar |
| **Regresion con regularizacion** | L1/L2 penaliza coeficientes grandes |
| **Redes neuronales** | Gradientes explotan o desvanecen con escalas extremas |

**NO sensibles a escala**: Arboles (Decision Tree, Random Forest, XGBoost)

### Tipos de scalers

| Scaler | Formula | Cuando usar |
|--------|---------|-------------|
| **StandardScaler** | (x - mean) / std | Default. Asume distribucion ~normal |
| **MinMaxScaler** | (x - min) / (max - min) | Rango [0,1]. Sensible a outliers |
| **RobustScaler** | (x - median) / IQR | Con outliers |

---

## Ejercicio: Escalar features

<!-- exercise:ex-scaling -->

---

## Codificacion de variables categoricas

```python
from sklearn.preprocessing import OneHotEncoder, LabelEncoder
import pandas as pd

# Datos
df = pd.DataFrame({'ciudad': ['Lima', 'Bogota', 'Lima', 'CDMX']})

# OneHotEncoder: Para features (crea columnas binarias)
ohe = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
ciudades_encoded = ohe.fit_transform(df[['ciudad']])
# Resultado: [[1,0,0], [0,1,0], [1,0,0], [0,0,1]]

# LabelEncoder: Para target (convierte a numeros)
le = LabelEncoder()
ciudades_label = le.fit_transform(df['ciudad'])
# Resultado: [1, 0, 1, 2]  # Bogota=0, CDMX=1, Lima=2
```

### Regla importante

> **NUNCA uses LabelEncoder para features**
>
> Los modelos interpretarian CDMX > Bogota como orden, cuando no existe tal relacion.

---

## Ejercicio: Codificar variables

<!-- exercise:ex-encoding -->

---

## Manejo de valores faltantes

```python
from sklearn.impute import SimpleImputer

# Numericos: media, mediana, o constante
imputer_num = SimpleImputer(strategy='median')
X_num_clean = imputer_num.fit_transform(X_num)

# Categoricos: moda o constante
imputer_cat = SimpleImputer(strategy='most_frequent')
X_cat_clean = imputer_cat.fit_transform(X_cat)
```

### Estrategias disponibles

| Estrategia | Descripcion | Uso recomendado |
|------------|-------------|-----------------|
| `mean` | Promedio | Numericos sin outliers |
| `median` | Mediana | Numericos con outliers |
| `most_frequent` | Moda | Categoricos |
| `constant` | Valor fijo | Cuando NaN tiene significado |

**Advertencia**: SimpleImputer no detecta patrones en missing. Si los NaN no son aleatorios (ej: ingresos faltantes = no reportan), considera crear un feature binario `ingreso_missing`.

---

## Ejercicio: Imputar valores faltantes

<!-- exercise:ex-imputation -->

---

## Orden correcto de preprocesamiento

```
+-------------------------------------------------------------+
| 1. TRAIN/TEST SPLIT (antes de todo!)                        |
+-------------------------------------------------------------+
                             |
               +-------------+-------------+
               v                           v
         +----------+               +----------+
         |  TRAIN   |               |   TEST   |
         +----+-----+               +----+-----+
              |                          |
+-------------v-------------+            |
| 2. fit() preprocesadores  |            |
|    en TRAIN unicamente    |            |
+-------------+-------------+            |
              |                          |
+-------------v-------------+  +---------v--------+
| 3. transform() TRAIN      |  | transform() TEST |
+-------------+-------------+  +---------+--------+
              |                          |
+-------------v-------------+            |
| 4. fit() modelo en TRAIN  |            |
+-------------+-------------+            |
              |                          |
              +------------+-------------+
                           v
+-------------------------------------------------------------+
| 5. predict() en TEST -> evaluar                             |
+-------------------------------------------------------------+
```

**Regla**: Solo fit() en train. Transform ambos con los mismos parametros.

---

## Por que fit() solo en train?

Porque fit() aprende estadisticas de los datos (media, std, categorias).

Si incluyes test, esas estadisticas reflejan datos que el modelo no deberia conocer, causando **data leakage**.

### Ejemplo de data leakage

```python
# INCORRECTO - data leakage
scaler.fit(X)  # Aprende de TODO incluyendo test
X_train, X_test = train_test_split(X)

# CORRECTO - sin leakage
X_train, X_test = train_test_split(X)
scaler.fit(X_train)  # Aprende solo de train
X_train_scaled = scaler.transform(X_train)
X_test_scaled = scaler.transform(X_test)
```

---

## Resumen

> **Por que fit() de los preprocesadores solo debe ejecutarse en train, nunca en test?**
>
> Porque fit() aprende estadisticas de los datos (media, std, categorias). Si incluyes test, esas estadisticas reflejan datos que el modelo no deberia conocer, causando data leakage.

### Proxima leccion

Datos limpios, modelo entrenado. Pero accuracy no es suficiente. Siguiente: **evaluacion de modelos con metricas relevantes al negocio**.
