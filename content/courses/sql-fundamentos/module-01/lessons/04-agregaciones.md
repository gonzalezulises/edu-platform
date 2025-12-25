---
title: "Agregaciones y GROUP BY"
slug: "04-agregaciones"
module: "module-01"
order: 4
duration_minutes: 50

pedagogy:
  bloomLevels: [apply]
  learningObjectives:
    - verb: apply
      statement: "Calcular conteos, sumas y promedios con COUNT, SUM, AVG"
      assessedBy: [ex-13-count, ex-14-sum-avg]
    - verb: apply
      statement: "Agrupar datos con GROUP BY para calcular métricas por categoría"
      assessedBy: [ex-15-group-by, ex-16-group-having]
    - verb: apply
      statement: "Combinar agregaciones con filtros WHERE y HAVING"
      assessedBy: [ex-16-group-having]
  
  phases:
    connection: 5
    concepts: 18
    practice: 22
    conclusions: 5
  
  practiceRatio: 0.44
---

# Agregaciones y GROUP BY

De filas individuales a resúmenes de negocio.

---

## 🎯 Connection

### El salto clave

Hasta ahora, cada fila que traes es un registro individual:
- Una venta
- Un producto
- Un vendedor

Pero las preguntas de negocio piden resúmenes:
- **¿Cuántas** ventas hubo este mes?
- **¿Cuál fue el total** vendido por región?
- **¿Cuál es el promedio** de precio por categoría?

Esto es exactamente lo que hacen las tablas dinámicas de Excel. En SQL, se llaman **agregaciones**.

### Lo que ya sabes (y no sabías)

Si usas tablas dinámicas, ya conoces estos conceptos:

| Excel (Tabla Dinámica) | SQL |
|------------------------|-----|
| Suma de valores | `SUM(columna)` |
| Cuenta de valores | `COUNT(columna)` |
| Promedio | `AVG(columna)` |
| Agrupar por campo | `GROUP BY columna` |

---

## 📚 Concepts

### Funciones de agregación

| Función | Qué hace | Ejemplo |
|---------|----------|---------|
| `COUNT(*)` | Cuenta filas | Número de ventas |
| `COUNT(columna)` | Cuenta valores no nulos | Cuántos tienen email |
| `SUM(columna)` | Suma valores | Total vendido |
| `AVG(columna)` | Promedio | Ticket promedio |
| `MIN(columna)` | Valor mínimo | Venta más baja |
| `MAX(columna)` | Valor máximo | Venta más alta |

### Agregación simple (toda la tabla)

~~~sql
SELECT COUNT(*) FROM ventas
~~~

Resultado: **15** (el total de filas)

~~~sql
SELECT SUM(monto) FROM ventas
~~~

Resultado: **17,666.18** (suma de todos los montos)

~~~sql
SELECT AVG(monto) FROM ventas
~~~

Resultado: **1,177.75** (promedio por venta)

### GROUP BY: Agregación por grupos

`GROUP BY` divide los datos en grupos y calcula agregaciones para cada uno:

~~~sql
SELECT vendedor_id, SUM(monto)
FROM ventas
GROUP BY vendedor_id
~~~

Resultado:

~~~
┌─────────────┬───────────────┐
│ vendedor_id │  SUM(monto)   │
├─────────────┼───────────────┤
│      1      │    5669.85    │
│      2      │    6309.82    │
│      3      │    2259.71    │
│      4      │    3429.78    │
└─────────────┴───────────────┘
~~~

### Regla crítica de GROUP BY

**Todo lo que aparece en SELECT debe ser:**
1. Una columna en GROUP BY, **o**
2. Una función de agregación

~~~sql
-- ✅ CORRECTO: categoria está en GROUP BY
SELECT categoria, AVG(precio)
FROM productos
GROUP BY categoria

-- ❌ INCORRECTO: nombre no está en GROUP BY ni es agregación
SELECT nombre, categoria, AVG(precio)
FROM productos
GROUP BY categoria
~~~

### Alias para columnas calculadas

Las columnas calculadas pueden tener nombres más claros:

~~~sql
SELECT 
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria
~~~

~~~
┌──────────────┬──────────────────┬──────────────────┐
│   categoria  │ total_productos  │ precio_promedio  │
├──────────────┼──────────────────┼──────────────────┤
│ Accesorios   │        2         │     104.99       │
│ Computadoras │        3         │     816.66       │
│ Periféricos  │        3         │     161.99       │
└──────────────┴──────────────────┴──────────────────┘
~~~

### WHERE vs HAVING

- `WHERE` filtra **filas individuales** (antes de agrupar)
- `HAVING` filtra **grupos** (después de agrupar)

~~~sql
-- Ventas mayores a $500, agrupadas por vendedor
-- Mostrar solo vendedores con total > $3000
SELECT 
    vendedor_id,
    SUM(monto) AS total
FROM ventas
WHERE monto > 500           -- Filtra filas individuales
GROUP BY vendedor_id
HAVING SUM(monto) > 3000    -- Filtra grupos
~~~

### Orden completo con agregaciones

~~~sql
SELECT columnas, AGG(columna)     -- 1. ¿Qué?
FROM tabla                         -- 2. ¿De dónde?
WHERE condicion_fila              -- 3. Filtrar filas (opcional)
GROUP BY columna_grupo            -- 4. Agrupar
HAVING condicion_grupo            -- 5. Filtrar grupos (opcional)
ORDER BY columna                  -- 6. Ordenar (opcional)
LIMIT n                           -- 7. Limitar (opcional)
~~~

---

## 💻 Concrete Practice

### Ejercicio 13: Conteo básico

¿Cuántos productos hay en total? ¿Cuántos vendedores activos?

<!-- exercise:ex-13-count -->

### Ejercicio 14: Suma y promedio

Calcula el **monto total** y el **monto promedio** de todas las ventas.

<!-- exercise:ex-14-sum-avg -->

### ¿Qué retorna?

~~~sql
SELECT categoria, COUNT(*) 
FROM productos 
GROUP BY categoria
~~~

**Si hay 3 Computadoras, 3 Periféricos y 2 Accesorios, ¿cuántas filas retorna?**

- A) 8 (una por producto)
- B) 3 (una por categoría)
- C) 1 (solo el total)
- D) Error

<!-- quiz:predict-group-count -->

### Ejercicio 15: Ventas por vendedor

Muestra el **total vendido por cada vendedor**, ordenado de mayor a menor.

<!-- exercise:ex-15-group-by -->

### Ejercicio 16: Filtrar grupos con HAVING

Muestra solo vendedores que hayan vendido **más de $3,000 en total**.

<!-- exercise:ex-16-group-having -->

---

## 🎓 Conclusions

### Tu resumen

> ¿Cuál es la diferencia entre WHERE y HAVING? Da un ejemplo de cuándo usarías cada uno.

### Quiz de cierre del módulo

<!-- quiz:quiz-04-agregaciones -->

### Recapitulación del módulo

En 3 horas aprendiste a:

1. **SELECT**: Elegir qué columnas traer
2. **FROM**: Especificar de qué tabla
3. **WHERE**: Filtrar filas con condiciones
4. **ORDER BY**: Ordenar resultados
5. **LIMIT**: Limitar cantidad
6. **COUNT, SUM, AVG**: Calcular agregaciones
7. **GROUP BY**: Agrupar datos
8. **HAVING**: Filtrar grupos

**Próximo módulo**: Conectar tablas con JOIN para combinar vendedores, productos y ventas en una sola consulta.
