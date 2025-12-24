# Variables y Tipos de Datos

Bienvenido a tu primera leccion de Python! Aqui aprenderas los conceptos fundamentales que necesitas para empezar a programar.

## Que es Python?

Python es un lenguaje de programacion creado en 1991 por Guido van Rossum. Es conocido por su sintaxis clara y legible, lo que lo hace perfecto para principiantes.

## Tu primer programa

Todo programador comienza con el clasico "Hola Mundo". En Python, mostrar texto en pantalla es muy sencillo usando la funcion `print()`:

```python
print("Hola, Mundo!")
```

### Ejercicio 1: Tu primer print

Vamos a practicar! Escribe tu primer programa:

<!-- exercise:ex-01-hola-mundo -->

## Variables

Una **variable** es como una caja donde guardamos informacion. Le damos un nombre y le asignamos un valor:

```python
nombre = "Maria"
edad = 25
```

### Reglas para nombrar variables

- Deben empezar con una letra o guion bajo (`_`)
- Solo pueden contener letras, numeros y guiones bajos
- No pueden ser palabras reservadas de Python (`if`, `for`, `while`, etc.)
- Son sensibles a mayusculas (`nombre` y `Nombre` son diferentes)

**Buenos nombres:**
```python
mi_variable = 10
usuario1 = "Ana"
_privado = "secreto"
```

**Nombres invalidos:**
```python
1variable = 10    # No puede empezar con numero
mi-variable = 10  # No puede tener guion medio
for = 10          # 'for' es palabra reservada
```

### Ejercicio 2: Crea tus variables

Practica creando variables con diferentes valores:

<!-- exercise:ex-02-variables-basicas -->

## Tipos de datos

Python tiene varios tipos de datos basicos:

| Tipo | Nombre | Ejemplo | Descripcion |
|------|--------|---------|-------------|
| `str` | String | `"Hola"` | Texto entre comillas |
| `int` | Integer | `42` | Numero entero |
| `float` | Float | `3.14` | Numero decimal |
| `bool` | Boolean | `True` | Verdadero o Falso |

### Strings (texto)

Los strings son secuencias de caracteres entre comillas simples o dobles:

```python
mensaje = "Hola, Python!"
otro = 'Tambien funciona con comillas simples'
```

### Numeros

Python distingue entre enteros y decimales:

```python
entero = 42        # int
decimal = 3.14159  # float
negativo = -10     # int negativo
```

### Booleanos

Solo pueden ser `True` o `False` (con mayuscula inicial):

```python
es_mayor = True
tiene_cuenta = False
```

### Funcion type()

Puedes verificar el tipo de una variable con `type()`:

```python
x = 10
print(type(x))  # <class 'int'>

y = "hola"
print(type(y))  # <class 'str'>
```

### Ejercicio 3: Tipos de datos

Ahora practica identificando y creando diferentes tipos:

<!-- exercise:ex-03-tipos-datos -->

## Resumen

En esta leccion aprendiste:

- Como usar `print()` para mostrar mensajes
- Que son las variables y como nombrarlas
- Los tipos de datos basicos: `str`, `int`, `float`, `bool`
- Como verificar el tipo con `type()`

En la siguiente leccion aprenderemos a hacer operaciones con estos datos!
