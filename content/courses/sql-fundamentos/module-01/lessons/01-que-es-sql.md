---
title: "¿Qué es SQL y por qué lo necesitas?"
slug: "01-que-es-sql"
module: "module-01"
order: 1
duration_minutes: 40

pedagogy:
  bloomLevels: [remember, understand]
  learningObjectives:
    - verb: identify
      statement: "Identificar qué es SQL y para qué sirve"
      assessedBy: [quiz-01-q1, quiz-01-q2]
    - verb: explain
      statement: "Explicar la estructura básica de una tabla (filas, columnas)"
      assessedBy: [quiz-01-q3]
    - verb: apply
      statement: "Escribir una consulta SELECT básica para ver todos los datos"
      assessedBy: [ex-01-select-todo, ex-02-select-tabla]
  
  phases:
    connection: 4
    concepts: 14
    practice: 18
    conclusions: 4
  
  practiceRatio: 0.45
---

# ¿Qué es SQL y por qué lo necesitas?

Tu primer paso para dejar de depender de "alguien que sabe Excel".

---

## 🎯 Connection

### El problema real

Es viernes 4pm. Tu jefe necesita un reporte urgente:

> "Necesito saber cuánto vendió cada vendedor este mes, filtrado por región Norte, ordenado de mayor a menor. Lo necesito en 30 minutos."

Los datos están en el sistema. Alguien de TI te manda un archivo Excel de 50,000 filas.

Empiezas con filtros, SUMAR.SI, tablas dinámicas... y cuando terminas, te dicen que ahora lo necesitan por semana, no por mes.

**¿Te suena familiar?**

### ¿Dónde estás hoy?

> **¿Cómo accedes a datos actualmente?**
> - Pido reportes a TI o a alguien más
> - Uso Excel con datos que me pasan
> - Tengo acceso a algún sistema pero no sé cómo sacar los datos
> - Ya he usado SQL pero muy básico

La realidad: **los datos ya existen** en una base de datos. SQL es el idioma para pedirlos directamente.

---

## 📚 Concepts

### SQL: El idioma de los datos

**SQL** (Structured Query Language) es el lenguaje estándar para comunicarte con bases de datos. 

No es programación tradicional. Es más como escribir una pregunta estructurada:

~~~
Dame todos los vendedores de la región Norte
~~~

En SQL:

~~~sql
SELECT * FROM vendedores WHERE region = 'Norte'
~~~

La base de datos entiende tu pregunta y te devuelve exactamente lo que pediste.

### Anatomía de una tabla

Una **tabla** es exactamente como una hoja de Excel con estructura fija:

~~~
Tabla: vendedores
┌────┬──────────────────┬────────┬──────────────┬────────┐
│ id │      nombre      │ region │ fecha_ingreso│ activo │
├────┼──────────────────┼────────┼──────────────┼────────┤
│  1 │ Ana García       │ Norte  │ 2021-03-15   │   1    │
│  2 │ Carlos López     │ Sur    │ 2020-06-01   │   1    │
│  3 │ María Rodríguez  │ Centro │ 2019-11-20   │   1    │
│  4 │ Pedro Martínez   │ Norte  │ 2022-01-10   │   1    │
└────┴──────────────────┴────────┴──────────────┴────────┘
~~~

| Concepto | En Excel | En SQL |
|----------|----------|--------|
| Hoja | Hoja de cálculo | Tabla |
| Fila | Fila (registro) | Row / Registro |
| Columna | Columna (A, B, C...) | Campo / Column |
| Celda | Celda (A1, B2...) | Valor |

### Tu primera consulta: SELECT

La consulta más básica tiene dos partes:

~~~sql
SELECT *          -- ¿Qué columnas quiero?
FROM vendedores   -- ¿De qué tabla?
~~~

**Desglose:**

| Palabra | Significado |
|---------|-------------|
| `SELECT` | "Dame..." / "Muéstrame..." |
| `*` | Todas las columnas (asterisco = todo) |
| `FROM` | "...de la tabla..." |
| `vendedores` | Nombre de la tabla |

> **💡 Tip**: SQL no distingue mayúsculas. `SELECT`, `select` y `Select` funcionan igual. Pero por convención escribimos las palabras reservadas en mayúsculas.

### SQL vs Excel: La diferencia crítica

| Escenario | Excel | SQL |
|-----------|-------|-----|
| Datos cambian | Re-descargar archivo, rehacer filtros | Ejecutar la misma consulta |
| 1 millón de filas | Se congela | Funciona igual |
| Automatizar | Macros complejas | Guardar consulta y reutilizar |
| Compartir lógica | Enviar archivo con instrucciones | Compartir texto de consulta |

---

## 💻 Concrete Practice

### Ejercicio 1: Tu primera consulta

Escribe una consulta que muestre **todos los datos** de la tabla `productos`.

<!-- exercise:ex-01-select-todo -->

### Ejercicio 2: Otra tabla

Ahora haz lo mismo con la tabla `vendedores`.

<!-- exercise:ex-02-select-tabla -->

### ¿Qué retorna esta consulta?

~~~sql
SELECT * FROM productos
~~~

**Si la tabla tiene 8 productos con 5 columnas cada uno, ¿cuántas celdas de datos obtienes?**

- A) 8
- B) 5
- C) 40
- D) 13

<!-- quiz:predict-select-count -->

### Ejercicio 3: Explorando ventas

Ahora consulta la tabla `ventas` para ver la estructura de datos transaccionales.

<!-- exercise:ex-03-select-ventas -->

---

## 🎓 Conclusions

### Tu resumen

> En una oración: ¿cuál es la diferencia fundamental entre pedir un reporte a TI vs escribir tu propia consulta SQL?

### Quiz de cierre

<!-- quiz:quiz-01-que-es-sql -->

### Próximo paso

Ya puedes ver todos los datos de una tabla. Pero rara vez necesitas todo.

**Próxima lección**: Aprende a filtrar exactamente lo que necesitas con `SELECT` columnas específicas y `WHERE` →
