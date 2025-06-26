USE [GD1C2025]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Creacion de schema si no existe

IF NOT EXISTS ( SELECT *
FROM sys.schemas
WHERE name = 'DROP_TABLE')
BEGIN
  EXECUTE('CREATE SCHEMA DROP_TABLE')
END
GO

-- Borrado de FK Constraints

DECLARE @DropConstraints NVARCHAR(max) = ''
SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
EXECUTE sp_executesql @DropConstraints;
GO

-- Borrado de tablas si existen en caso que el schema exista

IF OBJECT_ID('DROP_TABLE.Envio','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Envio;
IF OBJECT_ID('DROP_TABLE.Factura','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Factura;
IF OBJECT_ID('DROP_TABLE.DetalleFactura','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].DetalleFactura;
IF OBJECT_ID('DROP_TABLE.FacturaDetalleFactura','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].FacturaDetalleFactura;
IF OBJECT_ID('DROP_TABLE.Pedido','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Pedido;
IF OBJECT_ID('DROP_TABLE.PedidoCancelacion','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].PedidoCancelacion;
IF OBJECT_ID('DROP_TABLE.Cliente','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Cliente;
IF OBJECT_ID('DROP_TABLE.Sucursal','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Sucursal;
IF OBJECT_ID('DROP_TABLE.Compra','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Compra;
IF OBJECT_ID('DROP_TABLE.Estado','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Estado;
IF OBJECT_ID('DROP_TABLE.PedidoSillon','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].PedidoSillon;
IF OBJECT_ID('DROP_TABLE.Sillon','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Sillon;
IF OBJECT_ID('DROP_TABLE.SillonModelo','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].SillonModelo;
IF OBJECT_ID('DROP_TABLE.Medida','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Medida;
IF OBJECT_ID('DROP_TABLE.SillonMaterial','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].SillonMaterial;
IF OBJECT_ID('DROP_TABLE.Material','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Material;
IF OBJECT_ID('DROP_TABLE.TipoMaterial','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].TipoMaterial;
IF OBJECT_ID('DROP_TABLE.Tela','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Tela;
IF OBJECT_ID('DROP_TABLE.Madera','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Madera;
IF OBJECT_ID('DROP_TABLE.Relleno','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Relleno;
IF OBJECT_ID('DROP_TABLE.Proveedor','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Proveedor;
IF OBJECT_ID('DROP_TABLE.DetalleCompra','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].DetalleCompra;
IF OBJECT_ID('DROP_TABLE.Localidad','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Localidad;
IF OBJECT_ID('DROP_TABLE.Provincia','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].Provincia;

-- Creacion de tablas
BEGIN TRANSACTION

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Envio')
CREATE TABLE [DROP_TABLE].[Envio]
(
  envio_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  factura DECIMAL(18, 0), -- FK
  fecha_programada DATETIME2(2),
  fecha_entrega DATETIME2(2),
  importe_traslado DECIMAL(18, 2),
  importe_subida DECIMAL(18, 2),
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Factura')
CREATE TABLE [DROP_TABLE].[Factura]
(
  factura_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero BIGINT,
  cliente DECIMAL(18, 0), -- FK
  sucursal INT, -- FK
  fecha DATETIME2(6),
  total DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'DetalleFactura')
CREATE TABLE [DROP_TABLE].[DetalleFactura]
(
  detalle_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  detalle_pedido DECIMAL(18, 0), -- FK
  precio DECIMAL(18, 2),
  cantidad DECIMAL(18, 0),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'FacturaDetalleFactura')
CREATE TABLE [DROP_TABLE].[FacturaDetalleFactura]
(
  factura_id DECIMAL(18, 0), -- PK, FK
  detalle_id DECIMAL (18, 0), -- PK, FK
  PRIMARY KEY (factura_id, detalle_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Pedido')
CREATE TABLE [DROP_TABLE].[Pedido]
(
  pedido_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  sucursal INT, -- FK
  cliente DECIMAL(18, 0), -- FK
  fecha DATETIME2(6),
  estado INT, -- FK
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Estado')
CREATE TABLE [DROP_TABLE].[Estado]
(
  estado_id INT IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'PedidoCancelacion')
CREATE TABLE [DROP_TABLE].[PedidoCancelacion]
(
  cancelacion_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  pedido DECIMAL(18, 0), -- FK
  fecha DATETIME2(6),
  motivo NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Cliente')
CREATE TABLE [DROP_TABLE].[Cliente]
(
  cliente_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  dni BIGINT,
  nombre NVARCHAR(255),
  apellido NVARCHAR(255),
  fecha_nacimiento DATETIME2(6),
  mail NVARCHAR(255),
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  localidad DECIMAL(18, 0) -- FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Sucursal')
CREATE TABLE [DROP_TABLE].[Sucursal]
(
  sucursal_id INT IDENTITY(1,1) PRIMARY KEY,
  numero BIGINT,
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  mail NVARCHAR(255),
  localidad DECIMAL(18, 0) -- FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Compra')
CREATE TABLE [DROP_TABLE].[Compra]
(
  compra_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  sucursal INT, -- FK
  proveedor DECIMAL(18, 0), -- FK
  fecha_compra DATETIME2(6),
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Sillon')
CREATE TABLE [DROP_TABLE].[Sillon]
(
  sillon_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  codigo BIGINT,
  modelo DECIMAL(18, 0), -- FK
  medidas INT, -- FK
  cantidad BIGINT,
  precio DECIMAL(18, 2),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'PedidoSillon')
CREATE TABLE [DROP_TABLE].[PedidoSillon]
(
  pedido_id DECIMAL(18, 0), -- PK, FK
  sillon_id DECIMAL (18, 0), -- PK, FK
  PRIMARY KEY (pedido_id, sillon_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'SillonModelo')
CREATE TABLE [DROP_TABLE].[SillonModelo]
(
  modelo_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  modelo NVARCHAR(255),
  modelo_codigo BIGINT,
  modelo_descripcion NVARCHAR(255),
  modelo_precio DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Medida')
CREATE TABLE [DROP_TABLE].[Medida]
(
  medida_id INT IDENTITY(1,1) PRIMARY KEY,
  medida_alto DECIMAL(18, 2),
  medida_ancho DECIMAL(18, 2),
  medida_profundidad DECIMAL(18, 2),
  medida_precio DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Material')
CREATE TABLE [DROP_TABLE].[Material]
(
  material_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  tipo DECIMAL(18,0), -- FK
  nombre NVARCHAR(255),
  descripcion NVARCHAR(255),
  precio DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'SillonMaterial')
CREATE TABLE [DROP_TABLE].[SillonMaterial]
(
  sillon_id DECIMAL(18, 0), -- PK, FK
  material_id DECIMAL (18, 0), -- PK, FK
  PRIMARY KEY (sillon_id, material_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'TipoMaterial')
CREATE TABLE [DROP_TABLE].[TipoMaterial]
(
  tipo_id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Tela')
CREATE TABLE [DROP_TABLE].[Tela]
(
  tela_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0), -- FK
  color NVARCHAR(255),
  textura NVARCHAR(255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Madera')
CREATE TABLE [DROP_TABLE].[Madera]
(
  madera_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0), -- FK
  color NVARCHAR(255),
  dureza NVARCHAR(255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Relleno')
CREATE TABLE [DROP_TABLE].[Relleno]
(
  relleno_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0), -- FK
  relleno_densidad DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'DetalleCompra')
CREATE TABLE [DROP_TABLE].[DetalleCompra]
(
  detalle_compra_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0), -- FK
  precio_unitario DECIMAL(18, 2),
  cantidad DECIMAL(18, 0),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Proveedor')
CREATE TABLE [DROP_TABLE].[Proveedor]
(
  proveedor_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  razon_social NVARCHAR(255),
  cuit NVARCHAR(255),
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  mail NVARCHAR(255),
  localidad DECIMAL(18, 0) -- FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Localidad')
CREATE TABLE [DROP_TABLE].[Localidad]
(
  localidad_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255),
  provincia INT -- FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Provincia')
CREATE TABLE [DROP_TABLE].[Provincia]
(
  provincia_id INT IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255),
)

COMMIT
GO

-- ================= Definicion de FKs =============================

BEGIN TRANSACTION

ALTER TABLE [DROP_TABLE].[Envio]
ADD FOREIGN KEY (factura) REFERENCES [DROP_TABLE].Factura(factura_id);

ALTER TABLE [DROP_TABLE].[Factura]
ADD FOREIGN KEY (cliente) REFERENCES [DROP_TABLE].Cliente(cliente_id);

ALTER TABLE [DROP_TABLE].[Factura]
ADD FOREIGN KEY (sucursal) REFERENCES [DROP_TABLE].Sucursal(sucursal_id);

ALTER TABLE [DROP_TABLE].[Pedido]
ADD FOREIGN KEY (sucursal) REFERENCES [DROP_TABLE].Sucursal(sucursal_id);

ALTER TABLE [DROP_TABLE].[Pedido]
ADD FOREIGN KEY (cliente) REFERENCES [DROP_TABLE].Cliente(cliente_id);

ALTER TABLE [DROP_TABLE].[Pedido]
ADD FOREIGN KEY (estado) REFERENCES [DROP_TABLE].Estado(estado_id);

ALTER TABLE [DROP_TABLE].[PedidoCancelacion]
ADD FOREIGN KEY (pedido) REFERENCES [DROP_TABLE].Pedido(pedido_id);

ALTER TABLE [DROP_TABLE].[Cliente]
ADD FOREIGN KEY (localidad) REFERENCES [DROP_TABLE].Localidad(localidad_id);

ALTER TABLE [DROP_TABLE].[Sucursal]
ADD FOREIGN KEY (localidad) REFERENCES [DROP_TABLE].Localidad(localidad_id);

ALTER TABLE [DROP_TABLE].[Compra]
ADD FOREIGN KEY (sucursal) REFERENCES [DROP_TABLE].Sucursal(sucursal_id);

ALTER TABLE [DROP_TABLE].[Compra]
ADD FOREIGN KEY (proveedor) REFERENCES [DROP_TABLE].Proveedor(proveedor_id);

ALTER TABLE [DROP_TABLE].[PedidoSillon]
ADD FOREIGN KEY (pedido_id) REFERENCES [DROP_TABLE].Pedido(pedido_id);

ALTER TABLE [DROP_TABLE].[PedidoSillon]
ADD FOREIGN KEY (sillon_id) REFERENCES [DROP_TABLE].Sillon(sillon_id);

ALTER TABLE [DROP_TABLE].[Sillon]
ADD FOREIGN KEY (modelo) REFERENCES [DROP_TABLE].SillonModelo(modelo_id);

ALTER TABLE [DROP_TABLE].[Sillon]
ADD FOREIGN KEY (medidas) REFERENCES [DROP_TABLE].Medida(medida_id);

ALTER TABLE [DROP_TABLE].[Material]
ADD FOREIGN KEY (tipo) REFERENCES [DROP_TABLE].TipoMaterial(tipo_id);

ALTER TABLE [DROP_TABLE].[SillonMaterial]
ADD FOREIGN KEY (sillon_id) REFERENCES [DROP_TABLE].Sillon(sillon_id);

ALTER TABLE [DROP_TABLE].[SillonMaterial]
ADD FOREIGN KEY (material_id) REFERENCES [DROP_TABLE].Material(material_id);

ALTER TABLE [DROP_TABLE].[DetalleCompra]
ADD FOREIGN KEY (material_id) REFERENCES [DROP_TABLE].Material(material_id);

ALTER TABLE [DROP_TABLE].[Tela]
ADD FOREIGN KEY (material_id) REFERENCES [DROP_TABLE].Material(material_id);

ALTER TABLE [DROP_TABLE].[Madera]
ADD FOREIGN KEY (material_id) REFERENCES [DROP_TABLE].Material(material_id);

ALTER TABLE [DROP_TABLE].[Relleno]
ADD FOREIGN KEY (material_id) REFERENCES [DROP_TABLE].Material(material_id);

ALTER TABLE [DROP_TABLE].[Proveedor]
ADD FOREIGN KEY (localidad) REFERENCES [DROP_TABLE].Localidad(localidad_id);

ALTER TABLE [DROP_TABLE].[Localidad]
ADD FOREIGN KEY (provincia) REFERENCES [DROP_TABLE].Provincia(provincia_id);

ALTER TABLE [DROP_TABLE].[DetalleFactura]
ADD FOREIGN KEY (detalle_pedido) REFERENCES [DROP_TABLE].Sillon(sillon_id);

ALTER TABLE [DROP_TABLE].[FacturaDetalleFactura]
ADD FOREIGN KEY (factura_id) REFERENCES [DROP_TABLE].Factura(factura_id);

ALTER TABLE [DROP_TABLE].[FacturaDetalleFactura]
ADD FOREIGN KEY (detalle_id) REFERENCES [DROP_TABLE].DetalleFactura(detalle_id);

COMMIT
GO

-- ================= Migracion =============================

BEGIN TRANSACTION

INSERT INTO [DROP_TABLE].[Provincia]
  (descripcion)
SELECT DISTINCT PROVINCIA
FROM (
        SELECT Sucursal_Provincia AS PROVINCIA
    FROM gd_esquema.Maestra
  UNION
    SELECT Cliente_Provincia AS PROVINCIA
    FROM gd_esquema.Maestra
  UNION
    SELECT Proveedor_Provincia AS PROVINCIA
    FROM gd_esquema.Maestra
) AS PROVINCIAS
WHERE PROVINCIA IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Localidad]
  (Localidades.descripcion, provincia)
SELECT DISTINCT localidad, provincia_id
FROM (
    SELECT Sucursal_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Sucursal_Provincia
  UNION
    SELECT Cliente_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Cliente_Provincia
  UNION
    SELECT Proveedor_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Proveedor_Provincia
) AS Localidades
WHERE localidad IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Sucursal]
  (
  numero,
  direccion,
  telefono,
  mail,
  localidad
  )
SELECT DISTINCT Sucursal_NroSucursal, Sucursal_Direccion, Sucursal_telefono, Sucursal_mail, l.localidad_id
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Sucursal_Provincia
  LEFT JOIN DROP_TABLE.Localidad l ON l.descripcion = m.Sucursal_Localidad
    AND p.provincia_id = l.provincia
WHERE Sucursal_NroSucursal IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Cliente]
  (
  dni,
  nombre,
  apellido,
  fecha_nacimiento,
  mail,
  direccion,
  telefono,
  localidad
  )
SELECT DISTINCT Cliente_Dni, Cliente_Nombre, Cliente_Apellido, Cliente_FechaNacimiento, Cliente_Mail, Cliente_Direccion, Cliente_Telefono, l.localidad_id
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Cliente_Provincia
  LEFT JOIN DROP_TABLE.Localidad l ON l.descripcion = m.Cliente_Localidad
    AND p.provincia_id = l.provincia
WHERE Cliente_Dni IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Estado]
  (descripcion)
SELECT DISTINCT Pedido_Estado
FROM gd_esquema.Maestra
WHERE Pedido_Estado IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Pedido]
  (numero, sucursal, cliente, fecha, total, estado)
SELECT DISTINCT m.Pedido_Numero, s.sucursal_id, c.cliente_id, m.Pedido_Fecha, m.Pedido_Total, e.estado_id
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Sucursal s ON s.numero = m.Sucursal_NroSucursal
    AND s.direccion = m.Sucursal_Direccion
  LEFT JOIN DROP_TABLE.Cliente c ON c.nombre = m.Cliente_Nombre
    AND c.apellido = m.Cliente_Apellido
    AND c.direccion = m.Cliente_Direccion
    AND c.dni = m.Cliente_Dni
    AND c.fecha_nacimiento = m.Cliente_FechaNacimiento
    AND c.telefono = m.Cliente_Telefono
  LEFT JOIN DROP_TABLE.Estado e ON e.descripcion = m.Pedido_Estado
WHERE m.Pedido_Numero IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[PedidoCancelacion]
  (pedido, fecha, motivo)
SELECT DISTINCT p.pedido_id, m.Pedido_Cancelacion_Fecha, m.Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Pedido p ON p.numero = m.Pedido_Numero
    AND p.fecha = m.Pedido_Fecha
    AND p.total = m.Pedido_Total
  LEFT JOIN DROP_TABLE.Estado e ON e.descripcion = m.Pedido_Estado
WHERE m.Pedido_Cancelacion_Fecha IS NOT NULL OR m.Pedido_Cancelacion_Motivo IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[SillonModelo]
  (modelo, modelo_codigo, modelo_descripcion, modelo_precio)
SELECT DISTINCT m.Sillon_Modelo, m.Sillon_Modelo_Codigo, m.Sillon_Modelo_Descripcion, m.Sillon_Modelo_Precio
FROM gd_esquema.Maestra m
WHERE m.Sillon_Modelo IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Medida]
  (medida_alto, medida_ancho, medida_profundidad, medida_precio)
SELECT DISTINCT m.Sillon_Medida_Alto, m.Sillon_Medida_Ancho, m.Sillon_Medida_Profundidad, m.Sillon_Medida_Precio
FROM gd_esquema.Maestra m
GO

INSERT INTO [DROP_TABLE].[TipoMaterial]
  (descripcion)
SELECT DISTINCT Material_Tipo
FROM gd_esquema.Maestra
WHERE Material_Tipo IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Material]
  (tipo, nombre, descripcion, precio)
SELECT DISTINCT t.tipo_id, m.Material_Nombre, m.Material_Descripcion, m.Material_Precio
FROM gd_esquema.Maestra m
  JOIN DROP_TABLE.TipoMaterial t ON t.descripcion = m.Material_Tipo
WHERE m.Material_Nombre IS NOT NULL
ORDER BY 1, 2
GO

INSERT INTO [DROP_TABLE].[Tela]
  (material_id, color, textura)
SELECT DISTINCT ma.material_id, m.Tela_Color, m.Tela_Textura
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Material ma ON ma.nombre = m.Material_Nombre
    AND ma.descripcion = m.Material_Descripcion
    AND ma.precio = m.Material_Precio
WHERE ma.material_id IS NOT NULL
  AND m.Tela_Color IS NOT NULL
  AND m.Tela_Textura IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Madera]
  (material_id, color, dureza)
SELECT DISTINCT ma.material_id, m.Madera_Color, m.Madera_Dureza
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Material ma ON ma.nombre = m.Material_Nombre
    AND ma.descripcion = m.Material_Descripcion
    AND ma.precio = m.Material_Precio
WHERE ma.material_id IS NOT NULL
  AND m.Madera_Color IS NOT NULL
  AND m.Madera_Dureza IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Relleno]
  (material_id, relleno_densidad)
SELECT DISTINCT ma.material_id, m.Relleno_Densidad
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Material ma ON ma.nombre = m.Material_Nombre
    AND ma.descripcion = m.Material_Descripcion
    AND ma.precio = m.Material_Precio
WHERE ma.material_id IS NOT NULL
  AND m.Relleno_Densidad IS NOT NULL
GO

INSERT INTO [DROP_TABLE].[Sillon]
  (codigo, modelo, medidas, cantidad, precio, subtotal)
SELECT DISTINCT m.Sillon_Codigo, mo.modelo_id, me.medida_id, m.Detalle_Pedido_Cantidad, m.Detalle_Pedido_Precio, m.Detalle_Pedido_SubTotal
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.SillonModelo mo ON mo.modelo = m.Sillon_Modelo
    AND mo.modelo_codigo = m.Sillon_Modelo_Codigo
    AND mo.modelo_descripcion = m.Sillon_Modelo_Descripcion
    AND mo.modelo_precio = m.Sillon_Modelo_Precio
  LEFT JOIN DROP_TABLE.Medida me ON me.medida_alto = m.Sillon_Medida_Alto
    AND me.medida_ancho = m.Sillon_Medida_Ancho
    AND me.medida_precio = m.Sillon_Medida_Precio
    AND me.medida_profundidad = m.Sillon_Medida_Profundidad
WHERE (m.Sillon_Codigo IS NOT NULL
  OR m.Sillon_Modelo IS NOT NULL
  OR m.Sillon_Modelo_Codigo IS NOT NULL)
  AND m.Factura_Numero IS NULL
GO

INSERT INTO [DROP_TABLE].[PedidoSillon]
  (pedido_id, sillon_id)
SELECT DISTINCT p.pedido_id, s.sillon_id
FROM gd_esquema.Maestra m
INNER JOIN DROP_TABLE.Pedido p ON p.numero = m.Pedido_Numero
  AND p.fecha = m.Pedido_Fecha
  AND p.total = m.Pedido_Total
INNER JOIN DROP_TABLE.Sucursal su ON su.numero = m.Sucursal_NroSucursal
  AND su.direccion = m.Sucursal_Direccion
  AND su.telefono = m.Sucursal_telefono
  AND su.mail = m.Sucursal_mail
  AND su.sucursal_id = p.sucursal
INNER JOIN DROP_TABLE.Sillon s ON s.codigo = m.Sillon_Codigo
  AND s.cantidad = m.Detalle_Pedido_Cantidad
  AND s.precio = m.Detalle_Pedido_Precio
  AND s.subtotal = m.Detalle_Pedido_SubTotal
INNER JOIN DROP_TABLE.SillonModelo mo ON mo.modelo_codigo = m.Sillon_Modelo_Codigo
  AND mo.modelo = m.Sillon_Modelo
  AND mo.modelo_descripcion = m.Sillon_Modelo_Descripcion
GO

INSERT INTO [DROP_TABLE].[SillonMaterial]
  (sillon_id, material_id)
SELECT DISTINCT s.sillon_id, ma.material_id
FROM gd_esquema.Maestra m
INNER JOIN DROP_TABLE.Sillon s ON s.codigo = m.Sillon_Codigo
  AND s.cantidad = m.Detalle_Pedido_Cantidad
  AND s.precio = m.Detalle_Pedido_Precio
  AND s.subtotal = m.Detalle_Pedido_SubTotal
INNER JOIN DROP_TABLE.SillonModelo mo ON mo.modelo_codigo = m.Sillon_Modelo_Codigo
  AND mo.modelo = m.Sillon_Modelo
  AND mo.modelo_descripcion = m.Sillon_Modelo_Descripcion
INNER JOIN DROP_TABLE.TipoMaterial tm ON tm.descripcion = m.Material_Tipo
INNER JOIN DROP_TABLE.Material ma ON ma.tipo = tm.tipo_id
  AND ma.nombre = m.Material_Nombre
  AND ma.descripcion = m.Material_Descripcion
  AND ma.precio = m.Material_Precio
GO

INSERT INTO [DROP_TABLE].[Proveedor]
  (
  razon_social,
  cuit,
  direccion,
  telefono,
  mail,
  localidad
  )
SELECT DISTINCT
  Proveedor_RazonSocial,
  Proveedor_Cuit,
  Proveedor_Direccion,
  Proveedor_Telefono,
  Proveedor_Mail,
  l.localidad_id
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Provincia p ON p.descripcion = m.Proveedor_Provincia
  LEFT JOIN DROP_TABLE.Localidad l ON l.descripcion = m.Proveedor_Localidad
    AND l.provincia = p.provincia_id
WHERE Proveedor_Cuit IS NOT NULL
ORDER BY 1;
GO

INSERT INTO [DROP_TABLE].[Factura]
  (
  numero,
  cliente,
  sucursal,
  fecha,
  total
  )
SELECT DISTINCT
  Factura_Numero,
  c.cliente_id,
  s.sucursal_id,
  Factura_Fecha,
  Factura_Total
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Cliente c ON c.nombre = m.Cliente_Nombre
    AND c.apellido = m.Cliente_Apellido
    AND c.direccion = m.Cliente_Direccion
    AND c.dni = m.Cliente_Dni
    AND c.fecha_nacimiento = m.Cliente_FechaNacimiento
    AND c.telefono = m.Cliente_Telefono
  LEFT JOIN DROP_TABLE.Sucursal s ON s.numero = m.Sucursal_NroSucursal
WHERE Factura_Numero IS NOT NULL
ORDER BY 1;
GO

INSERT INTO [DROP_TABLE].[DetalleFactura]
  (
  detalle_pedido,
  precio,
  cantidad,
  subtotal
  )
SELECT DISTINCT
  s.sillon_id,
  Detalle_Factura_Precio,
  Detalle_Factura_Cantidad,
  Detalle_Factura_SubTotal
FROM gd_esquema.Maestra m
INNER JOIN DROP_TABLE.Pedido p ON p.numero = m.Pedido_Numero
  AND p.fecha = m.Pedido_Fecha
  AND p.total = m.Pedido_Total
JOIN DROP_TABLE.PedidoSillon ps ON ps.pedido_id = p.pedido_id
JOIN DROP_TABLE.Sillon s ON s.sillon_id = ps.sillon_id
WHERE Factura_Numero IS NOT NULL

INSERT INTO [DROP_TABLE].[Envio]
  (
  numero,
  factura,
  fecha_programada,
  fecha_entrega,
  importe_traslado,
  importe_subida,
  total
  )
SELECT DISTINCT
  Envio_Numero,
  f.factura_id,
  Envio_Fecha_Programada,
  Envio_Fecha,
  Envio_ImporteTraslado,
  Envio_ImporteSubida,
  Envio_Total
FROM gd_esquema.Maestra m
  JOIN DROP_TABLE.Factura f ON f.numero = m.Factura_Numero
WHERE Envio_Numero IS NOT NULL
ORDER BY 1;
GO

INSERT INTO [DROP_TABLE].[Compra]
  (
  numero,
  sucursal,
  proveedor,
  fecha_compra,
  total
  )
SELECT DISTINCT
  Compra_Numero,
  s.sucursal_id,
  p.proveedor_id,
  Compra_Fecha,
  Compra_Total
FROM gd_esquema.Maestra m
  LEFT JOIN DROP_TABLE.Sucursal s ON s.numero = m.Sucursal_NroSucursal
  LEFT JOIN DROP_TABLE.Proveedor p ON p.cuit = m.Proveedor_Cuit
WHERE Compra_Numero IS NOT NULL
ORDER BY 1;
GO

INSERT INTO [DROP_TABLE].[DetalleCompra]
  (
  material_id,
  precio_unitario,
  cantidad,
  subtotal
  )
SELECT DISTINCT
  mat.material_id,
  Detalle_Compra_Precio,
  Detalle_Compra_Cantidad,
  Detalle_Compra_SubTotal
FROM gd_esquema.Maestra m
  JOIN DROP_TABLE.Material mat
  ON mat.nombre = m.Material_Nombre
    AND mat.descripcion = m.Material_Descripcion
    AND mat.precio = m.Material_Precio
WHERE Detalle_Compra_Precio IS NOT NULL
ORDER BY 1;
GO

INSERT INTO [DROP_TABLE].[FacturaDetalleFactura]
  (
  factura_id,
  detalle_id
  )
SELECT DISTINCT
  f.factura_id,
  df.detalle_id
FROM gd_esquema.Maestra m
JOIN DROP_TABLE.Factura f ON f.numero = m.Factura_Numero
JOIN DROP_TABLE.Pedido p ON p.numero = m.Pedido_Numero
JOIN DROP_TABLE.DetalleFactura df ON df.detalle_pedido = p.pedido_id
WHERE m.Factura_Numero IS NOT NULL;
GO

COMMIT
GO
