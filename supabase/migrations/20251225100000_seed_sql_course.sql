-- =====================================================
-- Seed: Curso Fundamentos de SQL para Analistas de Negocio
-- Este curso tiene ejercicios interactivos SQL con sql.js
-- =====================================================

-- 1. Insertar el curso
INSERT INTO courses (id, title, description, slug, thumbnail_url, is_published)
VALUES (
  'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
  'Fundamentos de SQL para Analistas de Negocio',
  'Aprende a consultar bases de datos desde cero. Sin prerrequisitos de programacion. Al terminar, podras extraer y resumir datos de cualquier base de datos relacional.',
  'sql-fundamentos',
  'https://upload.wikimedia.org/wikipedia/commons/8/87/Sql_data_base_with_logo.png',
  true
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  slug = EXCLUDED.slug,
  is_published = EXCLUDED.is_published;

-- 2. Insertar el modulo
INSERT INTO modules (id, course_id, title, description, order_index, is_locked)
VALUES (
  'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a',
  'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
  'Fundamentos de SQL para Analistas de Negocio',
  'Aprende a consultar bases de datos desde cero. SELECT, WHERE, ORDER BY, LIMIT, agregaciones y GROUP BY.',
  1,
  false
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description;

-- 3. Insertar las lecciones
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, video_url)
VALUES
  -- Leccion 1: Que es SQL
  (
    'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b',
    'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
    'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a',
    'Que es SQL y por que lo necesitas?',
    $CONTENT$# Que es SQL y por que lo necesitas?

Tu primer paso para dejar de depender de "alguien que sabe Excel".

---

## El problema real

Es viernes 4pm. Tu jefe necesita un reporte urgente:

> "Necesito saber cuanto vendio cada vendedor este mes, filtrado por region Norte, ordenado de mayor a menor. Lo necesito en 30 minutos."

Los datos estan en el sistema. Alguien de TI te manda un archivo Excel de 50,000 filas.

Empiezas con filtros, SUMAR.SI, tablas dinamicas... y cuando terminas, te dicen que ahora lo necesitan por semana, no por mes.

**Te suena familiar?**

---

## SQL: El idioma de los datos

**SQL** (Structured Query Language) es el lenguaje estandar para comunicarte con bases de datos.

No es programacion tradicional. Es mas como escribir una pregunta estructurada:

```
Dame todos los vendedores de la region Norte
```

En SQL:

```sql
SELECT * FROM vendedores WHERE region = 'Norte'
```

La base de datos entiende tu pregunta y te devuelve exactamente lo que pediste.

## Anatomia de una tabla

Una **tabla** es exactamente como una hoja de Excel con estructura fija:

| id | nombre | region | fecha_ingreso | activo |
|----|--------|--------|---------------|--------|
| 1 | Ana Garcia | Norte | 2021-03-15 | 1 |
| 2 | Carlos Lopez | Sur | 2020-06-01 | 1 |
| 3 | Maria Rodriguez | Centro | 2019-11-20 | 1 |

| Concepto | En Excel | En SQL |
|----------|----------|--------|
| Hoja | Hoja de calculo | Tabla |
| Fila | Fila (registro) | Row / Registro |
| Columna | Columna (A, B, C...) | Campo / Column |

## Tu primera consulta: SELECT

La consulta mas basica tiene dos partes:

```sql
SELECT *          -- Que columnas quiero?
FROM vendedores   -- De que tabla?
```

**Desglose:**

| Palabra | Significado |
|---------|-------------|
| `SELECT` | "Dame..." / "Muestrame..." |
| `*` | Todas las columnas (asterisco = todo) |
| `FROM` | "...de la tabla..." |
| `vendedores` | Nombre de la tabla |

> **Tip**: SQL no distingue mayusculas. `SELECT`, `select` y `Select` funcionan igual.

---

## Ejercicio 1: Tu primera consulta

Escribe una consulta que muestre **todos los datos** de la tabla `productos`.

<!-- exercise:ex-01-select-todo -->

## Ejercicio 2: Otra tabla

Ahora haz lo mismo con la tabla `vendedores`.

<!-- exercise:ex-02-select-tabla -->

## Ejercicio 3: Explorando ventas

Ahora consulta la tabla `ventas` para ver la estructura de datos transaccionales.

<!-- exercise:ex-03-select-ventas -->

---

## Resumen

En esta leccion aprendiste:

- Que es SQL y para que sirve
- La estructura de una tabla (filas y columnas)
- Tu primera consulta: `SELECT * FROM tabla`

**Proxima leccion**: Aprende a filtrar exactamente lo que necesitas con `SELECT` columnas especificas y `WHERE`
$CONTENT$,
    'text',
    1,
    40,
    true,
    null
  ),
  -- Leccion 2: SELECT y WHERE
  (
    'f4a5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8c',
    'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
    'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a',
    'Extrayendo datos: SELECT y WHERE',
    $CONTENT$# Extrayendo datos: SELECT y WHERE

La diferencia entre traer todo y traer exactamente lo que necesitas.

---

## Del "*" a lo especifico

En el ejercicio anterior trajiste todos los datos de una tabla. En la realidad, casi nunca necesitas todo.

Tu jefe no dice:

> "Dame toda la tabla de ventas"

Dice:

> "Dame el nombre y monto de las ventas mayores a $1,000 de la region Norte"

Hoy aprenderas a pedir exactamente eso.

---

## Seleccionando columnas especificas

En lugar de `*`, lista las columnas que quieres:

```sql
SELECT nombre, region
FROM vendedores
```

**Resultado**: Solo 2 columnas en lugar de 5.

**Reglas:**
- Separa columnas con coma
- El orden en que las listas es el orden en que aparecen

## Filtrando con WHERE

`WHERE` viene despues de `FROM` y define que filas quieres:

```sql
SELECT nombre, region
FROM vendedores
WHERE region = 'Norte'
```

**Resultado**: Solo vendedores de la region Norte.

## Operadores de comparacion

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `=` | Igual a | `region = 'Norte'` |
| `<>` o `!=` | Diferente de | `region <> 'Norte'` |
| `>` | Mayor que | `precio > 100` |
| `<` | Menor que | `stock < 50` |
| `>=` | Mayor o igual | `monto >= 1000` |
| `<=` | Menor o igual | `cantidad <= 5` |

> **Importante**: Para texto, usa comillas simples: `'Norte'`. Para numeros, sin comillas: `100`.

## Combinando condiciones: AND y OR

**AND**: Ambas condiciones deben cumplirse

```sql
SELECT nombre, precio, categoria
FROM productos
WHERE categoria = 'Perifericos' AND precio < 100
```

**OR**: Al menos una condicion debe cumplirse

```sql
SELECT nombre, region
FROM vendedores
WHERE region = 'Norte' OR region = 'Sur'
```

---

## Ejercicio 4: Columnas especificas

Muestra solo el **nombre** y **precio** de cada producto.

<!-- exercise:ex-04-columnas-especificas -->

## Ejercicio 5: Columnas de ventas

De la tabla `ventas`, muestra solo la **fecha** y el **monto**.

<!-- exercise:ex-05-columnas-ventas -->

## Ejercicio 6: Filtro de texto

Muestra todos los datos de productos de la categoria **'Perifericos'**.

<!-- exercise:ex-06-where-basico -->

## Ejercicio 7: Filtro numerico

Muestra el nombre y stock de productos con **stock mayor a 100**.

<!-- exercise:ex-07-where-numerico -->

## Ejercicio 8: Condiciones compuestas

Muestra el nombre y precio de productos que sean **Perifericos** con precio **menor a $100**.

<!-- exercise:ex-08-where-compuesto -->

---

## Resumen

Aprendiste:

- Seleccionar columnas especificas: `SELECT columna1, columna2`
- Filtrar filas: `WHERE condicion`
- Operadores: `=`, `>`, `<`, `>=`, `<=`, `<>`
- Combinar condiciones: `AND`, `OR`

**Proxima leccion**: Ordenar resultados y limitar cantidad
$CONTENT$,
    'text',
    2,
    50,
    true,
    null
  ),
  -- Leccion 3: Ordenar y limitar
  (
    'a5b6c7d8-e9f0-4a1b-2c3d-4e5f6a7b8c9d',
    'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
    'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a',
    'Ordenando y limitando resultados',
    $CONTENT$# Ordenando y limitando resultados

El arte de presentar datos en el orden que importa.

---

## El contexto

Tu jefe dice:

> "Dame los 5 productos mas caros"

Ya sabes como traer todos los productos. Pero necesitas:
1. Ordenarlos por precio (del mayor al menor)
2. Traer solo los primeros 5

Sin estas herramientas, tendrias que ordenar manualmente en Excel.

---

## ORDER BY: Controlando el orden

Por defecto, SQL no garantiza ningun orden. `ORDER BY` lo especifica:

```sql
SELECT nombre, precio
FROM productos
ORDER BY precio
```

**Por defecto ordena ascendente** (menor a mayor).

## ASC y DESC

| Palabra clave | Significado | Ejemplo |
|---------------|-------------|---------|
| `ASC` | Ascendente (A-Z, 1-9) | `ORDER BY precio ASC` |
| `DESC` | Descendente (Z-A, 9-1) | `ORDER BY precio DESC` |

```sql
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
```

Ahora va del **mayor al menor**.

## LIMIT: Solo los primeros N

`LIMIT` restringe cuantas filas devuelve la consulta:

```sql
SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 3
```

Solo los **3 mas caros**.

## El orden completo de una consulta

```sql
SELECT columnas           -- 1. Que?
FROM tabla                -- 2. De donde?
WHERE condiciones         -- 3. Cuales? (opcional)
ORDER BY columna DESC     -- 4. En que orden? (opcional)
LIMIT n                   -- 5. Cuantos? (opcional)
```

**El orden de las clausulas es fijo**. No puedes poner `LIMIT` antes de `ORDER BY`.

---

## Ejercicio 9: Ordenar ascendente

Muestra todos los productos ordenados por **stock** de menor a mayor.

<!-- exercise:ex-09-order-asc -->

## Ejercicio 10: Ordenar descendente

Muestra nombre y precio de productos ordenados por **precio** de mayor a menor.

<!-- exercise:ex-10-order-desc -->

## Ejercicio 11: Limitar resultados

Muestra solo los **primeros 5 productos** (cualquier orden esta bien).

<!-- exercise:ex-11-limit -->

## Ejercicio 12: Top N combinado

Muestra el **vendedor_id**, **fecha** y **monto** de las **3 ventas mas grandes** (mayor monto primero).

<!-- exercise:ex-12-top-n -->

---

## Resumen

Aprendiste:

- `ORDER BY columna` para ordenar resultados
- `ASC` (ascendente) y `DESC` (descendente)
- `LIMIT n` para limitar cantidad de filas
- El orden correcto de las clausulas SQL

**Proxima leccion**: Agregaciones con COUNT, SUM, AVG y GROUP BY
$CONTENT$,
    'text',
    3,
    40,
    true,
    null
  ),
  -- Leccion 4: Agregaciones y GROUP BY
  (
    'b6c7d8e9-f0a1-4b2c-3d4e-5f6a7b8c9d0e',
    'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f',
    'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a',
    'Agregaciones y GROUP BY',
    $CONTENT$# Agregaciones y GROUP BY

De filas individuales a resumenes de negocio.

---

## El salto clave

Hasta ahora, cada fila que traes es un registro individual:
- Una venta
- Un producto
- Un vendedor

Pero las preguntas de negocio piden resumenes:
- **Cuantas** ventas hubo este mes?
- **Cual fue el total** vendido por region?
- **Cual es el promedio** de precio por categoria?

Esto es exactamente lo que hacen las tablas dinamicas de Excel. En SQL, se llaman **agregaciones**.

---

## Funciones de agregacion

| Funcion | Que hace | Ejemplo |
|---------|----------|---------|
| `COUNT(*)` | Cuenta filas | Numero de ventas |
| `COUNT(columna)` | Cuenta valores no nulos | Cuantos tienen email |
| `SUM(columna)` | Suma valores | Total vendido |
| `AVG(columna)` | Promedio | Ticket promedio |
| `MIN(columna)` | Valor minimo | Venta mas baja |
| `MAX(columna)` | Valor maximo | Venta mas alta |

## Agregacion simple (toda la tabla)

```sql
SELECT COUNT(*) FROM ventas
```

Resultado: **15** (el total de filas)

```sql
SELECT SUM(monto) FROM ventas
```

Resultado: **17,666.18** (suma de todos los montos)

## GROUP BY: Agregacion por grupos

`GROUP BY` divide los datos en grupos y calcula agregaciones para cada uno:

```sql
SELECT vendedor_id, SUM(monto)
FROM ventas
GROUP BY vendedor_id
```

## Regla critica de GROUP BY

**Todo lo que aparece en SELECT debe ser:**
1. Una columna en GROUP BY, **o**
2. Una funcion de agregacion

## Alias para columnas calculadas

Las columnas calculadas pueden tener nombres mas claros:

```sql
SELECT
    categoria,
    COUNT(*) AS total_productos,
    AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria
```

## WHERE vs HAVING

- `WHERE` filtra **filas individuales** (antes de agrupar)
- `HAVING` filtra **grupos** (despues de agrupar)

```sql
SELECT
    vendedor_id,
    SUM(monto) AS total
FROM ventas
WHERE monto > 500           -- Filtra filas individuales
GROUP BY vendedor_id
HAVING SUM(monto) > 3000    -- Filtra grupos
```

---

## Ejercicio 13: Conteo basico

Cuantos productos hay en total?

<!-- exercise:ex-13-count -->

## Ejercicio 14: Suma y promedio

Calcula el **monto total** y el **monto promedio** de todas las ventas.

<!-- exercise:ex-14-sum-avg -->

## Ejercicio 15: Ventas por vendedor

Muestra el **total vendido por cada vendedor**, ordenado de mayor a menor.

<!-- exercise:ex-15-group-by -->

## Ejercicio 16: Filtrar grupos con HAVING

Muestra solo vendedores que hayan vendido **mas de $3,000 en total**.

<!-- exercise:ex-16-group-having -->

---

## Recapitulacion del modulo

En 3 horas aprendiste a:

1. **SELECT**: Elegir que columnas traer
2. **FROM**: Especificar de que tabla
3. **WHERE**: Filtrar filas con condiciones
4. **ORDER BY**: Ordenar resultados
5. **LIMIT**: Limitar cantidad
6. **COUNT, SUM, AVG**: Calcular agregaciones
7. **GROUP BY**: Agrupar datos
8. **HAVING**: Filtrar grupos

**Proximo modulo**: Conectar tablas con JOIN para combinar vendedores, productos y ventas en una sola consulta.
$CONTENT$,
    'text',
    4,
    50,
    true,
    null
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content;

-- Verificacion
SELECT
    'Curso SQL creado' as status,
    (SELECT COUNT(*) FROM courses WHERE slug = 'sql-fundamentos') as cursos,
    (SELECT COUNT(*) FROM modules WHERE course_id = 'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f') as modulos,
    (SELECT COUNT(*) FROM lessons WHERE course_id = 'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f') as lecciones;
