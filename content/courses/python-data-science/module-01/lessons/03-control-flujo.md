# Estructuras de Control

Hasta ahora, nuestros programas ejecutan instrucciones de arriba hacia abajo. Pero a veces necesitamos que el programa tome decisiones. Para eso usamos las estructuras de control.

## La sentencia if

`if` ejecuta un bloque de codigo solo si una condicion es verdadera:

```python
edad = 18

if edad >= 18:
    print("Eres mayor de edad")
```

### La indentacion es importante!

En Python, la indentacion (espacios al inicio) define que codigo pertenece al `if`:

```python
if condicion:
    # Este codigo se ejecuta si la condicion es True
    print("Dentro del if")
    print("Tambien dentro del if")

print("Esto esta fuera del if, siempre se ejecuta")
```

> **Regla:** Usa 4 espacios para indentar. La mayoria de editores lo hacen automaticamente con Tab.

## if-else

`else` define que hacer cuando la condicion es falsa:

```python
edad = 15

if edad >= 18:
    print("Puedes votar")
else:
    print("Aun no puedes votar")
```

### Ejercicio 6: Tu primer if-else

Practica tomando decisiones en tu codigo:

<!-- exercise:ex-06-if-else -->

## elif (else if)

Cuando tienes multiples condiciones, usa `elif`:

```python
nota = 85

if nota >= 90:
    print("Excelente - A")
elif nota >= 80:
    print("Muy bien - B")
elif nota >= 70:
    print("Bien - C")
elif nota >= 60:
    print("Suficiente - D")
else:
    print("Reprobado - F")
```

### Como funciona

Python evalua las condiciones de arriba hacia abajo:
1. Si la primera es `True`, ejecuta ese bloque y salta el resto
2. Si es `False`, pasa a la siguiente condicion
3. `else` captura todos los casos que no cumplieron ninguna condicion

### Ejercicio 7: Multiples condiciones

Practica usando elif para clasificar valores:

<!-- exercise:ex-07-elif -->

## Condiciones anidadas

Puedes poner un `if` dentro de otro:

```python
tiene_boleto = True
edad = 12

if tiene_boleto:
    if edad < 12:
        print("Entrada infantil")
    else:
        print("Entrada adulto")
else:
    print("Necesitas comprar un boleto")
```

Aunque muchas veces es mejor usar `and`:

```python
if tiene_boleto and edad < 12:
    print("Entrada infantil")
elif tiene_boleto:
    print("Entrada adulto")
else:
    print("Necesitas comprar un boleto")
```

## Operador ternario

Para condiciones simples, puedes usar una sola linea:

```python
edad = 20
mensaje = "Mayor" if edad >= 18 else "Menor"
print(mensaje)  # "Mayor"
```

Es equivalente a:

```python
if edad >= 18:
    mensaje = "Mayor"
else:
    mensaje = "Menor"
```

## Valores Truthy y Falsy

En Python, algunos valores se consideran "falsos" en condiciones:

**Valores Falsy (se evaluan como False):**
- `False`
- `0` y `0.0`
- `""` (string vacio)
- `[]` (lista vacia)
- `None`

**Todo lo demas es Truthy:**

```python
nombre = ""

if nombre:
    print(f"Hola, {nombre}")
else:
    print("No ingresaste un nombre")
```

## Comparando strings

Los strings se comparan alfabeticamente:

```python
"apple" < "banana"  # True (a viene antes que b)
"Ana" < "ana"       # True (mayusculas van antes)
```

Para comparar sin importar mayusculas:

```python
nombre = "Maria"
if nombre.lower() == "maria":
    print("Encontrado!")
```

## Resumen

Aprendiste:

- `if` para ejecutar codigo condicionalmente
- `else` para el caso alternativo
- `elif` para multiples condiciones
- La importancia de la indentacion
- El operador ternario para condiciones simples
- Valores truthy y falsy

En la siguiente leccion aprenderemos sobre listas y bucles!
