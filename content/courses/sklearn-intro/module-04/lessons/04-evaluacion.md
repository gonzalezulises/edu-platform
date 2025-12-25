# Evaluacion de modelos

## Objetivos de aprendizaje

- Calcular e interpretar precision, recall y F1-score
- Elegir la metrica correcta segun el costo de errores del negocio
- Ajustar el umbral de decision para balancear precision vs recall
- Interpretar curvas ROC y AUC para comparar modelos

---

## Introduccion: El trade-off fundamental

Dos modelos para detectar fraude:

| Modelo | Fraudes detectados | Falsas alarmas |
|--------|-------------------|----------------|
| **Modelo A** | 90 de 100 | 500 transacciones legitimas |
| **Modelo B** | 70 de 100 | 50 transacciones legitimas |

**Cual es mejor?**

**Depende**: Es peor perder un fraude o molestar a un cliente bloqueando su compra?

---

## Matriz de confusion

```
                      PREDICHO
                   |  Neg (0) |  Pos (1) |
        -----------+----------+----------+
        Neg (0)    |    TN    |    FP    |  <- "Falsa alarma"
REAL    -----------+----------+----------+
        Pos (1)    |    FN    |    TP    |  <- "Se escapo"
        -----------+----------+----------+
```

| Termino | Significado | Ejemplo (fraude) |
|---------|-------------|------------------|
| **TP** (True Positive) | Era positivo, predije positivo | Era fraude, detecte fraude |
| **TN** (True Negative) | Era negativo, predije negativo | No era fraude, dije no fraude |
| **FP** (False Positive) | Era negativo, predije positivo | No era fraude, dije fraude (falsa alarma) |
| **FN** (False Negative) | Era positivo, predije negativo | Era fraude, dije no fraude (se escapo) |

---

## Las 4 metricas fundamentales

| Metrica | Formula | Pregunta que responde |
|---------|---------|----------------------|
| **Accuracy** | (TP+TN) / Total | Que % de predicciones fueron correctas? |
| **Precision** | TP / (TP+FP) | De los que marque positivos, que % realmente lo era? |
| **Recall** | TP / (TP+FN) | De los positivos reales, que % detecte? |
| **F1** | 2 * (P*R)/(P+R) | Balance entre precision y recall |

### Reglas practicas

| Situacion | Metrica a maximizar | Ejemplo |
|-----------|---------------------|---------|
| Perder un positivo es costoso | **Recall** | Diagnostico de cancer |
| Falsos positivos son costosos | **Precision** | Spam que borra emails importantes |
| Ambos errores son igualmente costosos | **F1** | Clasificacion general |

```python
from sklearn.metrics import classification_report

print(classification_report(y_test, y_pred))
#               precision  recall  f1-score
# clase 0          0.95     0.98     0.96
# clase 1          0.87     0.76     0.81
```

---

## Ejercicio: Calcular metricas

<!-- exercise:ex-metrics-calculation -->

---

## Ejercicio: Elegir la metrica correcta

<!-- exercise:ex-metric-selection -->

---

## Ajustar el umbral de decision

```python
# Por defecto, predict() usa umbral = 0.5
y_pred = modelo.predict(X_test)  # Si proba >= 0.5 -> 1

# Pero podemos obtener las probabilidades
y_proba = modelo.predict_proba(X_test)[:, 1]  # Prob de clase 1

# Y elegir nuestro propio umbral
umbral = 0.3  # Mas sensible: mas positivos, mas recall
y_pred_custom = (y_proba >= umbral).astype(int)
```

### Trade-off del umbral

| Umbral | Efecto |
|--------|--------|
| **Bajo** (ej: 0.3) | Mas recall, menos precision |
| **Alto** (ej: 0.7) | Menos recall, mas precision |

**Ejemplo practico**: Si fraude cuesta $10,000 y falsa alarma $10, preferimos umbral bajo para no perder fraudes.

---

## Ejercicio: Ajustar umbral

<!-- exercise:ex-threshold-tuning -->

---

## Curva ROC y AUC

La curva ROC muestra el trade-off para **TODOS** los umbrales posibles.

- **Eje X**: False Positive Rate = FP / (FP + TN)
- **Eje Y**: True Positive Rate = Recall = TP / (TP + FN)

```python
from sklearn.metrics import roc_curve, roc_auc_score

fpr, tpr, thresholds = roc_curve(y_test, y_proba)
auc = roc_auc_score(y_test, y_proba)
```

### Interpretacion de AUC

| AUC | Interpretacion |
|-----|----------------|
| 0.5 | Modelo aleatorio (inutil) |
| 0.7-0.8 | Aceptable |
| 0.8-0.9 | Bueno |
| 0.9+ | Excelente |

> **AUC responde**: Si tomo un positivo y un negativo al azar, que probabilidad hay de que el modelo asigne mayor score al positivo?

---

## Importante: AUC no es todo

AUC mide calidad promedio de ranking, **no** performance en un umbral especifico.

Un modelo con menor AUC podria ser mejor en el umbral operativo que te importa.

AUC es util para comparar, pero la eleccion final depende del umbral y los costos del negocio.

---

## Reflexion practica

> Tu modelo de deteccion de fraude tiene 95% precision pero 40% recall. Que significa esto?

**Significado**:
- Cuando el modelo dice "fraude", acierta el 95% de las veces
- Pero solo detecta el 40% de los fraudes reales (60% se escapan!)

**Recomendacion**: Bajar el umbral para aumentar recall, aceptando mas falsas alarmas.

---

## Resumen

> **Por que NO deberias optimizar siempre por accuracy?**
>
> Porque en datasets desbalanceados, un modelo tonto que predice la clase mayoritaria tiene accuracy alta pero no detecta la clase importante. Ademas, accuracy no considera el costo diferencial de FP vs FN.

### Siguiente paso

Tienes las herramientas. Ahora aplicalas: en el **proyecto final** construiras un clasificador de churn de principio a fin.
