# El patron fit/predict: Tu primer modelo

## Objetivos de aprendizaje

- Dividir datos en train/test usando train_test_split con parametros apropiados
- Entrenar un clasificador y generar predicciones sobre datos nuevos
- Explicar por que es necesario separar datos de entrenamiento y prueba
- Calcular accuracy e interpretar su significado

---

## Introduccion

Un modelo que memoriza todos los datos de entrenamiento tiene 100% de accuracy. **Es un buen modelo?**

**No.** Es como un estudiante que memoriza las respuestas de un examen especifico. Cuando le cambian las preguntas, fracasa.

Hoy aprenderas a entrenar Y evaluar modelos de forma que puedas confiar en su desempeno real.

---

## Concepto erroneo comun

> "Si mi modelo tiene 95% de accuracy en los datos que use para entrenarlo, puedo esperar ~95% de accuracy en datos nuevos."

**FALSO.** El accuracy en datos de entrenamiento es optimista porque el modelo ya 'vio' esos datos. El accuracy real en datos nuevos (test) suele ser menor. Por eso siempre separamos train/test ANTES de entrenar.

---

## El problema del overfitting

**Overfitting**: El modelo memoriza el ruido de los datos de entrenamiento en lugar de aprender patrones generalizables.

**Solucion**: Evaluar en datos que el modelo nunca vio durante entrenamiento.

```
Dataset completo
+-----------------------------------------------------+
|                                                     |
|  +---------------------+  +---------------------+   |
|  |   Training Set      |  |     Test Set        |   |
|  |   (70-80%)          |  |     (20-30%)        |   |
|  |                     |  |                     |   |
|  |   fit() aqui        |  |   predict() aqui    |   |
|  |                     |  |   evaluar aqui      |   |
|  +---------------------+  +---------------------+   |
|                                                     |
+-----------------------------------------------------+
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

| Parametro | Descripcion |
|-----------|-------------|
| `test_size=0.2` | Reserva 20% para evaluacion |
| `random_state=42` | Fijo = mismos resultados cada vez |
| `stratify=y` | Asegura misma proporcion de clases en ambos sets |

---

## Ejercicio: Dividir datos

<!-- exercise:ex-train-test-split -->

---

## Flujo completo: Entrenar -> Predecir -> Evaluar

```
+---------------+
|   Dataset     |
+-------+-------+
        | train_test_split()
        v
+---------------+     +---------------+
|   X_train     |     |   X_test      |
|   y_train     |     |   y_test      |
+-------+-------+     +-------+-------+
        |                     |
        v                     |
+---------------+             |
|  model.fit()  |             |
|  (entrena)    |             |
+-------+-------+             |
        |                     |
        v                     v
+----------------------------------+
|      model.predict(X_test)       |
|      -> y_pred                   |
+----------------+-----------------+
                 |
                 v
+----------------------------------+
|   Comparar y_pred vs y_test      |
|   -> accuracy, precision, etc.   |
+----------------------------------+
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

### Puntos clave:

- **random_state** para reproducibilidad del modelo
- **fit()** recibe X_train e y_train
- **predict()** recibe solo X_test (no y_test)
- **accuracy_score** compara predicciones vs realidad
- **Atajo**: `.score()` = predict() + accuracy_score()

---

## Ejercicio: Tu primer modelo

<!-- exercise:ex-primer-modelo -->

---

## Ejercicio: Analisis de accuracy

<!-- exercise:ex-accuracy-analysis -->

---

## Reflexion importante

> Tu modelo tiene 98% accuracy en train pero 72% en test. Que esta pasando?

**Overfitting.** El modelo memorizo patrones especificos del training set que no generalizan a datos nuevos.

Posibles soluciones:
- Usar un modelo mas simple
- Regularizacion
- Mas datos de entrenamiento
- Feature engineering

---

## Resumen

> **Por que train_test_split debe ejecutarse ANTES de cualquier preprocesamiento o entrenamiento?**
>
> Para evitar data leakage. Si preproceso con todo el dataset, informacion de test 'contamina' el entrenamiento y el accuracy estimado sera falsamente optimista.

### Proxima leccion

Tu modelo funciona, pero los datos del mundo real vienen sucios. La siguiente leccion: **preprocesamiento con sklearn**.
