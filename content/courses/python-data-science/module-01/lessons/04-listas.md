# Listas y Bucles

Las listas son una de las estructuras de datos mas importantes en Python. Te permiten almacenar multiples valores en una sola variable.

## Creando listas

Una lista se crea con corchetes `[]`:

```python
# Lista de numeros
numeros = [1, 2, 3, 4, 5]

# Lista de strings
frutas = ["manzana", "banana", "naranja"]

# Lista mixta (no recomendado, pero posible)
mixta = [1, "hola", 3.14, True]

# Lista vacia
vacia = []
```

### Ejercicio 8: Crea tu lista

Practica creando listas:

<!-- exercise:ex-08-crear-lista -->

## Accediendo a elementos

Cada elemento tiene un indice, empezando desde 0:

```python
frutas = ["manzana", "banana", "naranja", "pera"]
#            0          1         2         3

print(frutas[0])   # "manzana"
print(frutas[2])   # "naranja"
print(frutas[-1])  # "pera" (ultimo elemento)
print(frutas[-2])  # "naranja" (penultimo)
```

## Modificando listas

Las listas son mutables (se pueden cambiar):

```python
frutas = ["manzana", "banana", "naranja"]

# Cambiar un elemento
frutas[1] = "fresa"
print(frutas)  # ["manzana", "fresa", "naranja"]

# Agregar al final
frutas.append("pera")
print(frutas)  # ["manzana", "fresa", "naranja", "pera"]

# Insertar en posicion especifica
frutas.insert(1, "kiwi")
print(frutas)  # ["manzana", "kiwi", "fresa", "naranja", "pera"]

# Eliminar por valor
frutas.remove("fresa")

# Eliminar por indice
del frutas[0]

# Eliminar y obtener el ultimo
ultimo = frutas.pop()
```

## Longitud de una lista

Usa `len()` para saber cuantos elementos tiene:

```python
numeros = [10, 20, 30, 40, 50]
print(len(numeros))  # 5
```

## El bucle for

`for` recorre cada elemento de una lista:

```python
frutas = ["manzana", "banana", "naranja"]

for fruta in frutas:
    print(f"Me gusta la {fruta}")
```

Salida:
```
Me gusta la manzana
Me gusta la banana
Me gusta la naranja
```

### Ejercicio 9: Bucle for

Practica recorriendo listas con for:

<!-- exercise:ex-09-for-loop -->

## range()

`range()` genera secuencias de numeros:

```python
# range(fin) - desde 0 hasta fin-1
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

# range(inicio, fin)
for i in range(2, 6):
    print(i)  # 2, 3, 4, 5

# range(inicio, fin, paso)
for i in range(0, 10, 2):
    print(i)  # 0, 2, 4, 6, 8
```

## enumerate()

Si necesitas el indice y el valor:

```python
frutas = ["manzana", "banana", "naranja"]

for indice, fruta in enumerate(frutas):
    print(f"{indice}: {fruta}")
```

Salida:
```
0: manzana
1: banana
2: naranja
```

## El bucle while

`while` repite mientras una condicion sea verdadera:

```python
contador = 0

while contador < 5:
    print(contador)
    contador += 1  # Importante: actualizar la condicion!
```

> **Cuidado:** Si no actualizas la condicion, crearas un bucle infinito!

### Ejercicio 10: Bucle while

Practica usando while:

<!-- exercise:ex-10-while-loop -->

## break y continue

Controla el flujo dentro de bucles:

```python
# break: sale del bucle completamente
for i in range(10):
    if i == 5:
        break
    print(i)  # 0, 1, 2, 3, 4

# continue: salta a la siguiente iteracion
for i in range(5):
    if i == 2:
        continue
    print(i)  # 0, 1, 3, 4
```

## Operaciones comunes con listas

```python
numeros = [3, 1, 4, 1, 5, 9, 2, 6]

# Ordenar
numeros.sort()           # Modifica la lista original
ordenados = sorted(numeros)  # Crea una nueva lista

# Invertir
numeros.reverse()

# Buscar
if 5 in numeros:
    print("5 esta en la lista")

indice = numeros.index(5)  # Posicion del 5

# Contar ocurrencias
cantidad = numeros.count(1)  # Cuantos 1 hay

# Suma, minimo, maximo
total = sum(numeros)
minimo = min(numeros)
maximo = max(numeros)
```

## Slicing (rebanado)

Extrae porciones de una lista:

```python
letras = ['a', 'b', 'c', 'd', 'e']

print(letras[1:4])   # ['b', 'c', 'd']
print(letras[:3])    # ['a', 'b', 'c']
print(letras[2:])    # ['c', 'd', 'e']
print(letras[::2])   # ['a', 'c', 'e'] (cada 2)
print(letras[::-1])  # ['e', 'd', 'c', 'b', 'a'] (invertida)
```

## Resumen

Aprendiste:

- Crear y acceder a listas con `[]`
- Modificar listas: `append()`, `insert()`, `remove()`, `pop()`
- Bucle `for` para recorrer elementos
- `range()` para generar secuencias
- Bucle `while` para repetir mientras una condicion sea True
- `break` y `continue` para controlar bucles
- Operaciones: `sort()`, `sum()`, `min()`, `max()`, `in`
- Slicing para extraer porciones

En la siguiente leccion aprenderemos a crear funciones!
