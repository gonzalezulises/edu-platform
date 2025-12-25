-- Schema: Base de datos de ventas para módulo SQL
-- Contexto: Empresa de productos electrónicos

-- Tabla de vendedores
CREATE TABLE vendedores (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    region TEXT NOT NULL,
    fecha_ingreso DATE,
    activo INTEGER DEFAULT 1
);

INSERT INTO vendedores VALUES (1, 'Ana García', 'Norte', '2021-03-15', 1);
INSERT INTO vendedores VALUES (2, 'Carlos López', 'Sur', '2020-06-01', 1);
INSERT INTO vendedores VALUES (3, 'María Rodríguez', 'Centro', '2019-11-20', 1);
INSERT INTO vendedores VALUES (4, 'Pedro Martínez', 'Norte', '2022-01-10', 1);
INSERT INTO vendedores VALUES (5, 'Laura Sánchez', 'Sur', '2020-09-05', 0);

-- Tabla de productos
CREATE TABLE productos (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    categoria TEXT NOT NULL,
    precio REAL NOT NULL,
    stock INTEGER DEFAULT 0
);

INSERT INTO productos VALUES (1, 'Laptop Pro 15', 'Computadoras', 1299.99, 45);
INSERT INTO productos VALUES (2, 'Monitor 27"', 'Periféricos', 349.99, 120);
INSERT INTO productos VALUES (3, 'Teclado Mecánico', 'Periféricos', 89.99, 200);
INSERT INTO productos VALUES (4, 'Mouse Ergonómico', 'Periféricos', 45.99, 350);
INSERT INTO productos VALUES (5, 'Laptop Basic 14', 'Computadoras', 699.99, 80);
INSERT INTO productos VALUES (6, 'Webcam HD', 'Accesorios', 79.99, 150);
INSERT INTO productos VALUES (7, 'Audífonos BT', 'Accesorios', 129.99, 95);
INSERT INTO productos VALUES (8, 'Tablet 10"', 'Computadoras', 449.99, 60);

-- Tabla de ventas
CREATE TABLE ventas (
    id INTEGER PRIMARY KEY,
    vendedor_id INTEGER,
    producto_id INTEGER,
    cantidad INTEGER NOT NULL,
    fecha DATE NOT NULL,
    monto REAL NOT NULL,
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

INSERT INTO ventas VALUES (1, 1, 1, 2, '2024-01-15', 2599.98);
INSERT INTO ventas VALUES (2, 1, 3, 5, '2024-01-15', 449.95);
INSERT INTO ventas VALUES (3, 2, 2, 3, '2024-01-16', 1049.97);
INSERT INTO ventas VALUES (4, 3, 5, 1, '2024-01-16', 699.99);
INSERT INTO ventas VALUES (5, 2, 4, 10, '2024-01-17', 459.90);
INSERT INTO ventas VALUES (6, 4, 1, 1, '2024-01-18', 1299.99);
INSERT INTO ventas VALUES (7, 1, 7, 4, '2024-01-18', 519.96);
INSERT INTO ventas VALUES (8, 3, 6, 8, '2024-01-19', 639.92);
INSERT INTO ventas VALUES (9, 2, 8, 2, '2024-01-19', 899.98);
INSERT INTO ventas VALUES (10, 4, 3, 15, '2024-01-20', 1349.85);
INSERT INTO ventas VALUES (11, 1, 2, 2, '2024-01-21', 699.98);
INSERT INTO ventas VALUES (12, 3, 4, 20, '2024-01-21', 919.80);
INSERT INTO ventas VALUES (13, 2, 1, 3, '2024-01-22', 3899.97);
INSERT INTO ventas VALUES (14, 4, 7, 6, '2024-01-22', 779.94);
INSERT INTO ventas VALUES (15, 1, 5, 2, '2024-01-23', 1399.98);

-- Tabla de clientes (para ejercicios avanzados)
CREATE TABLE clientes (
    id INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    email TEXT,
    ciudad TEXT,
    tipo TEXT DEFAULT 'regular'
);

INSERT INTO clientes VALUES (1, 'Empresa ABC', 'compras@abc.com', 'Lima', 'corporativo');
INSERT INTO clientes VALUES (2, 'Tech Solutions', 'info@techsol.com', 'Bogotá', 'corporativo');
INSERT INTO clientes VALUES (3, 'Juan Pérez', 'juan@email.com', 'CDMX', 'regular');
INSERT INTO clientes VALUES (4, 'Startup XYZ', 'ops@xyz.io', 'Lima', 'startup');
INSERT INTO clientes VALUES (5, 'María Torres', 'maria.t@email.com', 'Panamá', 'regular');
