-- Base de datos de ZONA 15
-- Estructura construida a partir de las entidades JPA del proyecto.
-- Motor: MySQL 8+ / InnoDB

CREATE DATABASE IF NOT EXISTS zona15
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE zona15;

-- 1. Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(10) NOT NULL,
    direccion VARCHAR(120) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_clientes_telefono (telefono)
) ENGINE=InnoDB;

-- 2. Mesas
CREATE TABLE IF NOT EXISTS mesas (
    id BIGINT NOT NULL AUTO_INCREMENT,
    numero INT NOT NULL,
    sillas INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_mesas_numero (numero)
) ENGINE=InnoDB;

-- 3. Productos
CREATE TABLE IF NOT EXISTS productos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    categoria VARCHAR(40) NOT NULL,
    precio INT NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- 4. Proveedores
CREATE TABLE IF NOT EXISTS proveedores (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    telefono VARCHAR(10) NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- 5. Zonas de domicilio
CREATE TABLE IF NOT EXISTS zonas (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_zonas_nombre (nombre)
) ENGINE=InnoDB;

-- 6. Usuarios: cliente_id es opcional; el administrador no tiene cliente asociado.
CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL,
    clave VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL,
    cliente_id BIGINT NULL,
    creado DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_usuarios_username (username),
    UNIQUE KEY uk_usuarios_cliente (cliente_id),
    CONSTRAINT fk_usuarios_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB;

-- 7. Compras de insumos a proveedores
CREATE TABLE IF NOT EXISTS compras (
    id BIGINT NOT NULL AUTO_INCREMENT,
    proveedor_id BIGINT NOT NULL,
    fecha DATE NOT NULL,
    insumo VARCHAR(80) NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    unidad VARCHAR(20) NOT NULL,
    costo_total INT NOT NULL,
    PRIMARY KEY (id),
    KEY idx_compras_proveedor (proveedor_id),
    CONSTRAINT fk_compras_proveedor
        FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
) ENGINE=InnoDB;

-- 8. Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    cliente_id BIGINT NULL,
    tipo VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha DATETIME(6) NOT NULL,
    mesa_id BIGINT NULL,
    mesa_en_uso BIT(1) NULL,
    zona_entrega VARCHAR(60) NULL,
    PRIMARY KEY (id),
    KEY idx_pedidos_cliente (cliente_id),
    KEY idx_pedidos_mesa (mesa_id),
    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    CONSTRAINT fk_pedidos_mesa
        FOREIGN KEY (mesa_id) REFERENCES mesas(id)
) ENGINE=InnoDB;

-- 9. Detalles de cada pedido
CREATE TABLE IF NOT EXISTS detalles_pedido (
    id BIGINT NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT NOT NULL,
    producto_id BIGINT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario INT NOT NULL,
    PRIMARY KEY (id),
    KEY idx_detalles_pedido_pedido (pedido_id),
    KEY idx_detalles_pedido_producto (producto_id),
    CONSTRAINT fk_detalles_pedido_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    CONSTRAINT fk_detalles_pedido_producto
        FOREIGN KEY (producto_id) REFERENCES productos(id)
) ENGINE=InnoDB;

-- 10. Facturas: un pedido solo puede tener una factura.
CREATE TABLE IF NOT EXISTS facturas (
    id BIGINT NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT NOT NULL,
    fecha DATETIME(6) NOT NULL,
    total INT NOT NULL,
    metodo_pago VARCHAR(20) NOT NULL,
    subtotal INT NULL,
    impuesto INT NULL,
    impuesto_porcentaje INT NULL,
    identificacion_cliente VARCHAR(20) NULL,
    cufe VARCHAR(96) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_facturas_pedido (pedido_id),
    CONSTRAINT fk_facturas_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
) ENGINE=InnoDB;

-- Valores permitidos por los enums definidos en Java:
-- usuarios.rol: ADMIN, USUARIO
-- pedidos.tipo: LOCAL, DOMICILIO
-- pedidos.estado: RECIBIDO, EN_PREPARACION, LISTO, ENTREGADO, CANCELADO
-- facturas.metodo_pago: EFECTIVO, TRANSFERENCIA, TARJETA
