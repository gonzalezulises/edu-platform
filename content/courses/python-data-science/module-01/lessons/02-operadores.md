# Operadores y Expresiones

Ahora que conoces las variables, aprenderemos a hacer operaciones con ellas.

## Operadores Aritmeticos

Python puede funcionar como una calculadora poderosa:

| Operador | Nombre | Ejemplo | Resultado |
|----------|--------|---------|-----------|
| `+` | Suma | `5 + 3` | `8` |
| `-` | Resta | `10 - 4` | `6` |
| `*` | Multiplicacion | `6 * 7` | `42` |
| `/` | Division | `15 / 4` | `3.75` |
| `//` | Division entera | `15 // 4` | `3` |
| `%` | Modulo (resto) | `15 % 4` | `3` |
| `**` | Potencia | `2 ** 3` | `8` |

### Ejemplos practicos

```python
# Operaciones basicas
suma = 10 + 5      # 15
resta = 20 - 8     # 12
producto = 4 * 7   # 28
cociente = 15 / 4  # 3.75

# Division entera (descarta decimales)
division_entera = 15 // 4  # 3

# Modulo (el resto de la division)
resto = 15 % 4  # 3 (porque 15 = 4*3 + 3)

# Potencia
cuadrado = 5 ** 2  # 25
cubo = 2 ** 3      # 8
```

### Ejercicio 4: Calculadora basica

Practica realizando operaciones aritmeticas:

<!-- exercise:ex-04-aritmetica -->

## Operadores de Comparacion

Estos operadores comparan valores y devuelven `True` o `False`:

| Operador | Significado | Ejemplo | Resultado |
|----------|-------------|---------|-----------|
| `==` | Igual a | `5 == 5` | `True` |
| `!=` | Diferente de | `5 != 3` | `True` |
| `>` | Mayor que | `7 > 3` | `True` |
| `<` | Menor que | `2 < 5` | `True` |
| `>=` | Mayor o igual | `5 >= 5` | `True` |
| `<=` | Menor o igual | `3 <= 4` | `True` |

### Ejemplos

```python
x = 10
y = 5

print(x == y)   # False (10 no es igual a 5)
print(x != y)   # True (10 es diferente de 5)
print(x > y)    # True (10 es mayor que 5)
print(x < y)    # False (10 no es menor que 5)
print(x >= 10)  # True (10 es mayor o igual a 10)
print(y <= 5)   # True (5 es menor o igual a 5)
```

> **Importante:** No confundas `=` (asignacion) con `==` (comparacion).
> - `x = 5` asigna el valor 5 a x
> - `x == 5` pregunta si x es igual a 5

### Ejercicio 5: Comparaciones

Practica usando operadores de comparacion:

<!-- exercise:ex-05-comparaciones -->

## Operadores Logicos

Combinan expresiones booleanas:

| Operador | Descripcion | Ejemplo |
|----------|-------------|---------|
| `and` | Verdadero si ambos son True | `True and False` → `False` |
| `or` | Verdadero si al menos uno es True | `True or False` → `True` |
| `not` | Invierte el valor | `not True` → `False` |

### Ejemplos

```python
edad = 25
tiene_licencia = True

# and: ambas condiciones deben ser verdaderas
puede_conducir = edad >= 18 and tiene_licencia  # True

# or: al menos una condicion debe ser verdadera
es_fin_de_semana = False
es_feriado = True
dia_libre = es_fin_de_semana or es_feriado  # True

# not: invierte el valor
esta_lloviendo = False
buen_clima = not esta_lloviendo  # True
```

## Operadores de Asignacion

Atajos para modificar variables:

| Operador | Equivale a | Ejemplo |
|----------|------------|---------|
| `+=` | `x = x + n` | `x += 5` |
| `-=` | `x = x - n` | `x -= 3` |
| `*=` | `x = x * n` | `x *= 2` |
| `/=` | `x = x / n` | `x /= 4` |

```python
contador = 10

contador += 5   # contador = 15
contador -= 3   # contador = 12
contador *= 2   # contador = 24
contador /= 4   # contador = 6.0
```

## Concatenacion de Strings

El operador `+` tambien une strings:

```python
nombre = "Maria"
apellido = "Garcia"
nombre_completo = nombre + " " + apellido
print(nombre_completo)  # "Maria Garcia"
```

Y `*` repite strings:

```python
risa = "ja" * 3
print(risa)  # "jajaja"
```

## Resumen

Aprendiste:

- Operadores aritmeticos: `+`, `-`, `*`, `/`, `//`, `%`, `**`
- Operadores de comparacion: `==`, `!=`, `>`, `<`, `>=`, `<=`
- Operadores logicos: `and`, `or`, `not`
- Operadores de asignacion: `+=`, `-=`, `*=`, `/=`
- Concatenacion de strings con `+` y `*`

En la siguiente leccion aprenderemos a tomar decisiones con `if` y `else`!
