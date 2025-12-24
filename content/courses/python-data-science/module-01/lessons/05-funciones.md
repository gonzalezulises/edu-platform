# Funciones

Las funciones son bloques de codigo reutilizable. En lugar de repetir el mismo codigo, lo encapsulamos en una funcion y la llamamos cuando la necesitamos.

## Por que usar funciones?

- **Reutilizacion:** Escribe el codigo una vez, usalo muchas veces
- **Organizacion:** Divide programas complejos en partes manejables
- **Legibilidad:** Codigo mas facil de leer y entender
- **Mantenimiento:** Cambias en un solo lugar y se aplica en todos lados

## Definiendo una funcion

Usa `def` para crear una funcion:

```python
def saludar():
    print("Hola!")
    print("Bienvenido al curso")

# Llamar a la funcion
saludar()
```

### Ejercicio 11: Tu primera funcion

Crea una funcion simple:

<!-- exercise:ex-11-funcion-simple -->

## Funciones con parametros

Los parametros permiten pasar informacion a la funcion:

```python
def saludar(nombre):
    print(f"Hola, {nombre}!")

saludar("Maria")  # Hola, Maria!
saludar("Carlos") # Hola, Carlos!
```

### Multiples parametros

```python
def presentar(nombre, edad, ciudad):
    print(f"Soy {nombre}, tengo {edad} anos y vivo en {ciudad}")

presentar("Ana", 25, "Madrid")
```

### Ejercicio 12: Funcion con parametros

Practica creando funciones que reciben datos:

<!-- exercise:ex-12-funcion-parametros -->

## Parametros por defecto

Puedes dar valores por defecto a los parametros:

```python
def saludar(nombre, saludo="Hola"):
    print(f"{saludo}, {nombre}!")

saludar("Maria")              # Hola, Maria!
saludar("Carlos", "Buenos dias")  # Buenos dias, Carlos!
```

## Return: Devolver valores

`return` hace que la funcion devuelva un resultado:

```python
def sumar(a, b):
    resultado = a + b
    return resultado

# Usar el valor devuelto
total = sumar(5, 3)
print(total)  # 8

# Tambien puedes usarlo directamente
print(sumar(10, 20))  # 30
```

### Return termina la funcion

Cuando Python encuentra `return`, sale de la funcion:

```python
def verificar_edad(edad):
    if edad < 0:
        return "Edad invalida"
    if edad >= 18:
        return "Mayor de edad"
    return "Menor de edad"

print(verificar_edad(25))   # Mayor de edad
print(verificar_edad(-5))   # Edad invalida
print(verificar_edad(15))   # Menor de edad
```

### Ejercicio 13: Funcion con return

Crea funciones que devuelvan valores:

<!-- exercise:ex-13-funcion-return -->

## Retornar multiples valores

Python permite retornar varios valores como tupla:

```python
def calcular_estadisticas(numeros):
    minimo = min(numeros)
    maximo = max(numeros)
    promedio = sum(numeros) / len(numeros)
    return minimo, maximo, promedio

datos = [4, 8, 2, 9, 5]
min_val, max_val, prom = calcular_estadisticas(datos)
print(f"Min: {min_val}, Max: {max_val}, Promedio: {prom}")
```

## Argumentos con nombre

Puedes especificar argumentos por nombre:

```python
def crear_usuario(nombre, edad, ciudad):
    print(f"{nombre}, {edad} anos, {ciudad}")

# Por posicion
crear_usuario("Ana", 25, "Madrid")

# Por nombre (mas claro)
crear_usuario(nombre="Carlos", ciudad="Barcelona", edad=30)
```

## *args y **kwargs

Para funciones con numero variable de argumentos:

```python
# *args: multiples argumentos posicionales
def sumar_todos(*numeros):
    return sum(numeros)

print(sumar_todos(1, 2, 3))       # 6
print(sumar_todos(1, 2, 3, 4, 5)) # 15

# **kwargs: multiples argumentos con nombre
def mostrar_info(**datos):
    for clave, valor in datos.items():
        print(f"{clave}: {valor}")

mostrar_info(nombre="Ana", edad=25, ciudad="Madrid")
```

## Scope (alcance de variables)

Las variables dentro de una funcion son locales:

```python
x = 10  # Variable global

def cambiar():
    x = 20  # Variable local (diferente de la global)
    print(f"Dentro: {x}")

cambiar()          # Dentro: 20
print(f"Fuera: {x}")  # Fuera: 10
```

Para modificar una variable global, usa `global`:

```python
contador = 0

def incrementar():
    global contador
    contador += 1

incrementar()
print(contador)  # 1
```

## Funciones como objetos

En Python, las funciones son objetos de primera clase:

```python
def doble(x):
    return x * 2

# Asignar a otra variable
mi_funcion = doble
print(mi_funcion(5))  # 10

# Pasar como argumento
def aplicar(funcion, valor):
    return funcion(valor)

print(aplicar(doble, 10))  # 20
```

## Funciones lambda

Funciones anonimas de una linea:

```python
# Funcion normal
def cuadrado(x):
    return x ** 2

# Equivalente con lambda
cuadrado = lambda x: x ** 2

print(cuadrado(5))  # 25
```

Utiles con funciones como `map`, `filter`, `sorted`:

```python
numeros = [1, 2, 3, 4, 5]
cuadrados = list(map(lambda x: x**2, numeros))
print(cuadrados)  # [1, 4, 9, 16, 25]
```

## Documentacion (docstrings)

Documenta tus funciones con docstrings:

```python
def calcular_area(base, altura):
    """
    Calcula el area de un triangulo.

    Args:
        base: La base del triangulo
        altura: La altura del triangulo

    Returns:
        El area del triangulo
    """
    return (base * altura) / 2

# Ver la documentacion
help(calcular_area)
```

## Resumen

Aprendiste:

- Crear funciones con `def`
- Pasar parametros a funciones
- Usar valores por defecto
- Retornar valores con `return`
- Retornar multiples valores
- Argumentos por nombre
- `*args` y `**kwargs`
- Scope de variables
- Funciones lambda
- Documentar con docstrings

Felicidades! Has completado los fundamentos de Python. Ahora tienes las herramientas basicas para empezar a crear programas mas complejos.
