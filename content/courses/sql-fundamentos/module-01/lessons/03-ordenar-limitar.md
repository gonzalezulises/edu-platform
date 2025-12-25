---
title: "Ordenando y limitando resultados"
slug: "03-ordenar-limitar"
module: "module-01"
order: 3
duration_minutes: 40

pedagogy:
  bloomLevels: [understand, apply]
  learningObjectives:
    - verb: apply
      statement: "Ordenar resultados ascendente y descendentemente con ORDER BY"
      assessedBy: [ex-09-order-asc, ex-10-order-desc]
    - verb: apply
      statement: "Limitar cantidad de resultados con LIMIT"
      assessedBy: [ex-11-limit, ex-12-top-n]
    - verb: apply
      statement: "Combinar SELECT, WHERE, ORDER BY y LIMIT en una consulta"
      assessedBy: [ex-12-top-n]
  
  phases:
    connection: 4
    concepts: 12
    practice: 20
    conclusions: 4
  
  practiceRatio: 0.50
---

# Ordenando y limitando resultados

El arte de presentar datos en el orden que importa.

---

## 🎯 Connection

### El contexto

Tu jefe dice:

> "Dame los 5 productos más caros"

Ya sabes cómo traer todos los productos. Pero necesitas:
1. Ordenarlos por precio (del mayor al menor)
2. Traer solo los primeros 5

Sin estas herramientas, tendrías que ordenar manualmente en Excel.

### Pregunta diagnóstica

> **¿Cómo ordenas datos actualmente?**
> - En Excel: Datos → Ordenar
> - Tablas dinámicas
> - Manualmente (copiar y pegar)
> - No suelo ordenar, trabajo con lo que viene

---

## 📚 Concepts

### ORDER BY: Controlando el orden

Por defecto, SQL no garantiza ningún orden. `ORDER BY` lo especifica:

~~~sql
SELECT nombre, precio
FROM productos
ORDER BY precio
~~~

**Por defecto ordena ascendente** (menor a mayor):

~~~
┌──────────────────┬─────────┐
│      nombre      │ precio  │
├──────────────────┼─────────┤
│ Mouse Ergonómico │   45.99 │
│ Webcam HD        │   79.99 │
│ Teclado Mecánico │   89.99 │
│ ...              │   ...   │
└──────────────────┴─────────┘
~~~

### ASC y DESC

| Palabra clave | Significado | Ejemplo |
|---------------|-------------|---------|
| `ASC` | Ascendente (A→Z, 1→9) | `ORDER BY precio ASC` |
| `DESC` | Descendente (Z→A, 9→1) | `ORDER BY precio DESC` |

~~~sql
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
~~~

Ahora va del **mayor al menor**:

~~~
┌────────────────┬──────────┐
│     nombre     │  precio  │
├────────────────┼──────────┤
│ Laptop Pro 15  │ 1299.99  │
│ Laptop Basic 14│  699.99  │
│ Tablet 10"     │  449.99  │
│ ...            │   ...    │
└────────────────┴──────────┘
~~~

### LIMIT: Solo los primeros N

`LIMIT` restringe cuántas filas devuelve la consulta:

~~~sql
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 3
~~~

Solo los **3 más caros**:

~~~
┌────────────────┬──────────┐
│     nombre     │  precio  │
├────────────────┼──────────┤
│ Laptop Pro 15  │ 1299.99  │
│ Laptop Basic 14│  699.99  │
│ Tablet 10"     │  449.99  │
└────────────────┴──────────┘
~~~

### El orden completo de una consulta

~~~sql
SELECT columnas           -- 1. ¿Qué?
FROM tabla                -- 2. ¿De dónde?
WHERE condiciones         -- 3. ¿Cuáles? (opcional)
ORDER BY columna DESC     -- 4. ¿En qué orden? (opcional)
LIMIT n                   -- 5. ¿Cuántos? (opcional)
~~~

**El orden de las cláusulas es fijo**. No puedes poner `LIMIT` antes de `ORDER BY`.

### Ordenar por múltiples columnas

Puedes ordenar por varios criterios:

~~~sql
SELECT nombre, categoria, precio
FROM productos
ORDER BY categoria ASC, precio DESC
~~~

Primero agrupa por categoría (A→Z), luego dentro de cada categoría ordena por precio (mayor→menor).

---

## 💻 Concrete Practice

### Ejercicio 9: Ordenar ascendente

Muestra todos los productos ordenados por **stock** de menor a mayor.

<!-- exercise:ex-09-order-asc -->

### Ejercicio 10: Ordenar descendente

Muestra nombre y precio de productos ordenados por **precio** de mayor a menor.

<!-- exercise:ex-10-order-desc -->

### ¿Qué retorna primero?

~~~sql
SELECT nombre FROM vendedores ORDER BY nombre LIMIT 1
~~~

**Vendedores**: Ana García, Carlos López, Laura Sánchez, María Rodríguez, Pedro Martínez

- A) Ana García
- B) Pedro Martínez
- C) Carlos López
- D) María Rodríguez

<!-- quiz:predict-order-limit -->

### Ejercicio 11: Limitar resultados

Muestra solo los **primeros 5 productos** (cualquier orden está bien).

<!-- exercise:ex-11-limit -->

### Ejercicio 12: Top N combinado

Muestra el **nombre** y **monto** de las **3 ventas más grandes** (mayor monto primero).

<!-- exercise:ex-12-top-n -->

---

## 🎓 Conclusions

### Tu resumen

> ¿Por qué es importante que LIMIT venga después de ORDER BY y no antes?

### Quiz de cierre

<!-- quiz:quiz-03-order-limit -->

### Próximo paso

Ya puedes filtrar, ordenar y limitar. Pero los datos de negocio necesitan resúmenes: totales, promedios, conteos...

**Próxima lección**: Agregaciones con COUNT, SUM, AVG y GROUP BY →
