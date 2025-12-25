---
title: "Extrayendo datos: SELECT y WHERE"
slug: "02-select-where"
module: "module-01"
order: 2
duration_minutes: 50

pedagogy:
  bloomLevels: [understand, apply]
  learningObjectives:
    - verb: apply
      statement: "Seleccionar columnas específicas en lugar de todas"
      assessedBy: [ex-04-columnas-especificas, ex-05-columnas-ventas]
    - verb: apply
      statement: "Filtrar filas con condiciones WHERE usando operadores de comparación"
      assessedBy: [ex-06-where-basico, ex-07-where-numerico]
    - verb: apply
      statement: "Combinar múltiples condiciones con AND y OR"
      assessedBy: [ex-08-where-compuesto]
  
  phases:
    connection: 5
    concepts: 18
    practice: 22
    conclusions: 5
  
  practiceRatio: 0.44
---

# Extrayendo datos: SELECT y WHERE

La diferencia entre traer todo y traer exactamente lo que necesitas.

---

## 🎯 Connection

### Del "*" a lo específico

En el ejercicio anterior trajiste todos los datos de una tabla. En la realidad, casi nunca necesitas todo.

Tu jefe no dice:

> "Dame toda la tabla de ventas"

Dice:

> "Dame el nombre y monto de las ventas mayores a $1,000 de la región Norte"

Hoy aprenderás a pedir exactamente eso.

### Mito común

> "Es más fácil traer todo y luego filtrar en Excel"

**Realidad**: Con 100,000 filas, traer todo puede tardar minutos y colapsar Excel. Filtrar en SQL es instantáneo porque la base de datos está optimizada para eso.

---

## 📚 Concepts

### Seleccionando columnas específicas

En lugar de `*`, lista las columnas que quieres:

~~~sql
SELECT nombre, region
FROM vendedores
~~~

**Resultado**: Solo 2 columnas en lugar de 5.

~~~
┌──────────────────┬────────┐
│      nombre      │ region │
├──────────────────┼────────┤
│ Ana García       │ Norte  │
│ Carlos López     │ Sur    │
│ María Rodríguez  │ Centro │
│ Pedro Martínez   │ Norte  │
│ Laura Sánchez    │ Sur    │
└──────────────────┴────────┘
~~~

**Reglas:**
- Separa columnas con coma
- El orden en que las listas es el orden en que aparecen
- Los nombres son exactos (respeta mayúsculas si la tabla las tiene)

### Filtrando con WHERE

`WHERE` viene después de `FROM` y define qué filas quieres:

~~~sql
SELECT nombre, region
FROM vendedores
WHERE region = 'Norte'
~~~

**Resultado**: Solo vendedores de la región Norte.

~~~
┌────────────────┬────────┐
│     nombre     │ region │
├────────────────┼────────┤
│ Ana García     │ Norte  │
│ Pedro Martínez │ Norte  │
└────────────────┴────────┘
~~~

### Operadores de comparación

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `=` | Igual a | `region = 'Norte'` |
| `<>` o `!=` | Diferente de | `region <> 'Norte'` |
| `>` | Mayor que | `precio > 100` |
| `<` | Menor que | `stock < 50` |
| `>=` | Mayor o igual | `monto >= 1000` |
| `<=` | Menor o igual | `cantidad <= 5` |

> **⚠️ Importante**: Para texto, usa comillas simples: `'Norte'`. Para números, sin comillas: `100`.

### Combinando condiciones: AND y OR

**AND**: Ambas condiciones deben cumplirse

~~~sql
SELECT nombre, precio, categoria
FROM productos
WHERE categoria = 'Periféricos' AND precio < 100
~~~

Solo productos que son periféricos **Y** cuestan menos de $100.

**OR**: Al menos una condición debe cumplirse

~~~sql
SELECT nombre, region
FROM vendedores
WHERE region = 'Norte' OR region = 'Sur'
~~~

Vendedores del Norte **O** del Sur (excluye Centro).

### Anatomía completa de una consulta

~~~sql
SELECT columna1, columna2      -- 1. ¿Qué columnas?
FROM nombre_tabla              -- 2. ¿De qué tabla?
WHERE condicion1 AND condicion2 -- 3. ¿Qué filas? (opcional)
~~~

El orden importa: `SELECT` → `FROM` → `WHERE`

---

## 💻 Concrete Practice

### Ejercicio 4: Columnas específicas

Muestra solo el **nombre** y **precio** de cada producto.

<!-- exercise:ex-04-columnas-especificas -->

### Ejercicio 5: Columnas de ventas

De la tabla `ventas`, muestra solo la **fecha** y el **monto**.

<!-- exercise:ex-05-columnas-ventas -->

### ¿Qué retorna?

~~~sql
SELECT nombre FROM productos WHERE precio > 500
~~~

**La tabla productos tiene:**
- Laptop Pro 15: $1299.99
- Laptop Basic 14: $699.99  
- Tablet 10": $449.99

**¿Cuántas filas retorna?**

- A) 1
- B) 2
- C) 3
- D) 0

<!-- quiz:predict-where-precio -->

### Ejercicio 6: Filtro de texto

Muestra todos los datos de productos de la categoría **'Periféricos'**.

<!-- exercise:ex-06-where-basico -->

### Ejercicio 7: Filtro numérico

Muestra el nombre y stock de productos con **stock mayor a 100**.

<!-- exercise:ex-07-where-numerico -->

### Ejercicio 8: Condiciones compuestas

Muestra el nombre y precio de productos que sean **Periféricos** con precio **menor a $100**.

<!-- exercise:ex-08-where-compuesto -->

---

## 🎓 Conclusions

### Tu resumen

> ¿Cuál es el beneficio de filtrar con WHERE en SQL vs filtrar después en Excel?

### Quiz de cierre

<!-- quiz:quiz-02-select-where -->

### Próximo paso

Ya sabes qué datos traer y cómo filtrarlos. Pero los resultados vienen en cualquier orden...

**Próxima lección**: Ordenar resultados y limitar cantidad →
