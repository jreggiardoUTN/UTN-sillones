-- Pedido: borrar detalle_id porque usa tabla intermedia
-- PedidoSillon: cambiar detalle_id por sillon_id
-- Sillon: cambiar modelo nvarchar por decimal, es FK

USE [GD1C2025]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Creacion de schema si no existe

IF NOT EXISTS ( SELECT *
FROM sys.schemas
WHERE name = 'NULL_POINTER')
BEGIN
  EXECUTE('CREATE SCHEMA NULL_POINTER')
END
GO

-- Borrado de FK Constraints

DECLARE @DropConstraints NVARCHAR(max) = ''
SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
EXECUTE sp_executesql @DropConstraints;
GO

-- Borrado de funciones auxiliar si existe

DROP FUNCTION IF EXISTS [NULL_POINTER];

-- Borrado de tablas si existen en caso que el schema exista

IF OBJECT_ID('NULL_POINTER.Envio','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Envio;
IF OBJECT_ID('NULL_POINTER.Factura','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Factura;
IF OBJECT_ID('NULL_POINTER.DetalleFactura','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].DetalleFactura;
IF OBJECT_ID('NULL_POINTER.Pedido','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Pedido;
IF OBJECT_ID('NULL_POINTER.PedidoCancelacion','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].PedidoCancelacion;
IF OBJECT_ID('NULL_POINTER.Cliente','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Cliente;
IF OBJECT_ID('NULL_POINTER.Sucursal','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Sucursal;
IF OBJECT_ID('NULL_POINTER.Compra','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Compra;
IF OBJECT_ID('NULL_POINTER.Estado','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Estado;
IF OBJECT_ID('NULL_POINTER.PedidoSillon','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].PedidoSillon;
IF OBJECT_ID('NULL_POINTER.Sillon','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Sillon;
IF OBJECT_ID('NULL_POINTER.SillonModelo','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].SillonModelo;
IF OBJECT_ID('NULL_POINTER.Medida','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Medida;
IF OBJECT_ID('NULL_POINTER.SillonMaterial','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].SillonMaterial;
IF OBJECT_ID('NULL_POINTER.Material','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Material;
IF OBJECT_ID('NULL_POINTER.TipoMaterial','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].TipoMaterial;
IF OBJECT_ID('NULL_POINTER.Tela','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Tela;
IF OBJECT_ID('NULL_POINTER.Madera','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Madera;
IF OBJECT_ID('NULL_POINTER.Relleno','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Relleno;
IF OBJECT_ID('NULL_POINTER.Proveedor','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Proveedor;
IF OBJECT_ID('NULL_POINTER.DetalleCompra','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].DetalleCompra;
IF OBJECT_ID('NULL_POINTER.Localidad','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Localidad;
IF OBJECT_ID('NULL_POINTER.Provincia','U') IS NOT NULL
  DROP TABLE [NULL_POINTER].Provincia;
-- Creacion de tablas
BEGIN TRANSACTION

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Envio')
CREATE TABLE [NULL_POINTER].[Envio]
(
  envio_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  factura DECIMAL(18, 0),
  -- FK
  fecha_programada DATETIME2(2),
  fecha_entrega DATETIME2(2),
  importe_traslado DECIMAL(18, 2),
  importe_subida DECIMAL(18, 2),
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Factura')
CREATE TABLE [NULL_POINTER].[Factura] -- PK puede ser compuesta por numero+sucursal en lugar de usar generated?
(
  factura_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero BIGINT,
  cliente DECIMAL(18, 0),
  --FK
  sucursal INT,
  --FK
  fecha DATETIME2(6),
  total DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'DetalleFactura')
CREATE TABLE [NULL_POINTER].[DetalleFactura]
(
  detalle_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  detalle_pedido DECIMAL(18, 0),
  precio DECIMAL(18, 2),
  cantidad DECIMAL(18, 0),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'FacturaDetalleFactura')
CREATE TABLE [NULL_POINTER].[FacturaDetalleFactura]
(
  factura_id DECIMAL(18, 0),
  -- PK, FK
  detalle_id DECIMAL (18, 0),
  --PK, FK
  PRIMARY KEY (factura_id, detalle_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Pedido')
CREATE TABLE [NULL_POINTER].[Pedido]
(
  pedido_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  sucursal INT,
  --FK
  cliente DECIMAL(18, 0),
  --FK
  fecha DATETIME2(6),
  estado INT,
  --FK
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Estado')
CREATE TABLE [NULL_POINTER].[Estado]
(
  estado_id INT IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'PedidoCancelacion')
CREATE TABLE [NULL_POINTER].[PedidoCancelacion]
(
  cancelacion_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  pedido DECIMAL(18, 0),
  --FK
  fecha DATETIME2(6),
  motivo NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Cliente')
CREATE TABLE [NULL_POINTER].[Cliente]
(
  cliente_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  dni BIGINT,
  nombre NVARCHAR(255),
  apellido NVARCHAR(255),
  fecha_nacimiento DATETIME2(6),
  mail NVARCHAR(255),
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  localidad DECIMAL(18, 0)
  --FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Sucursal')
CREATE TABLE [NULL_POINTER].[Sucursal]
(
  sucursal_id INT IDENTITY(1,1) PRIMARY KEY,
  numero BIGINT,
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  mail NVARCHAR(255),
  localidad DECIMAL(18, 0)
  --FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Compra')
CREATE TABLE [NULL_POINTER].[Compra]
(
  compra_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL(18, 0),
  sucursal INT,
  -- FK
  proveedor DECIMAL(18, 0),
  --FK
  fecha_compra DATETIME2(6),
  total DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Sillon')
CREATE TABLE [NULL_POINTER].[Sillon]
(
  sillon_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  codigo BIGINT,
  modelo DECIMAL(18, 0),
  -- FK
  medidas INT,
  --FK
  cantidad BIGINT,
  precio DECIMAL(18, 2),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'PedidoSillon')
CREATE TABLE [NULL_POINTER].[PedidoSillon]
(
  pedido_id DECIMAL(18, 0),
  -- PK, FK
  sillon_id DECIMAL (18, 0),
  --PK, FK
  PRIMARY KEY (pedido_id, sillon_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'SillonModelo')
CREATE TABLE [NULL_POINTER].[SillonModelo]
(
  modelo_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  modelo NVARCHAR(255),
  modelo_codigo BIGINT,
  modelo_descripcion NVARCHAR(255),
  precio_precio DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Medida')
CREATE TABLE [NULL_POINTER].[Medida]
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
CREATE TABLE [NULL_POINTER].[Material]
(
  material_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  tipo DECIMAL(18,0),
  --FK
  nombre NVARCHAR(255),
  descripcion NVARCHAR(255),
  precio DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'SillonMaterial')
CREATE TABLE [NULL_POINTER].[SillonMaterial]
(
  sillon_id DECIMAL(18, 0),
  -- PK, FK
  material_id DECIMAL (18, 0),
  --PK, FK
  PRIMARY KEY (sillon_id, material_id)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'TipoMaterial')
CREATE TABLE [NULL_POINTER].[TipoMaterial]
(
  tipo_id DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Tela')
CREATE TABLE [NULL_POINTER].[Tela]
(
  tela_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0),
  --FK
  color NVARCHAR(255),
  textura NVARCHAR(255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Madera')
CREATE TABLE [NULL_POINTER].[Madera]
(
  madera_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0),
  --FK
  color NVARCHAR(255),
  dureza NVARCHAR(255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Relleno')
CREATE TABLE [NULL_POINTER].[Relleno]
(
  relleno_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0),
  --FK
  relleno_densidad DECIMAL(38, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'DetalleCompra')
CREATE TABLE [NULL_POINTER].[DetalleCompra]
(
  detalle_compra_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  material_id DECIMAL(18, 0),
  --FK
  precio_unitario DECIMAL(18, 2),
  cantidad DECIMAL(18, 0),
  subtotal DECIMAL(18, 2)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Proveedor')
CREATE TABLE [NULL_POINTER].[Proveedor]
(
  proveedor_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  cuit NVARCHAR(255),
  direccion NVARCHAR(255),
  telefono NVARCHAR(255),
  mail NVARCHAR(255),
  localidad DECIMAL(18, 0)
  --FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Localidad')
CREATE TABLE [NULL_POINTER].[Localidad]
(
  localidad_id DECIMAL(18, 0) IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255),
  provincia INT
  --FK
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'Provincia')
CREATE TABLE [NULL_POINTER].[Provincia]
(
  provincia_id INT IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR(255),
)

COMMIT
GO

-- ================= Definicion de FKs =============================

BEGIN TRANSACTION

ALTER TABLE [NULL_POINTER].[Envio]
ADD FOREIGN KEY (factura) REFERENCES [NULL_POINTER].Factura(factura_id);

ALTER TABLE [NULL_POINTER].[Factura]
ADD FOREIGN KEY (cliente) REFERENCES [NULL_POINTER].Cliente(cliente_id);

ALTER TABLE [NULL_POINTER].[Factura]
ADD FOREIGN KEY (sucursal) REFERENCES [NULL_POINTER].Sucursal(sucursal_id);

ALTER TABLE [NULL_POINTER].[Pedido]
ADD FOREIGN KEY (sucursal) REFERENCES [NULL_POINTER].Sucursal(sucursal_id);

ALTER TABLE [NULL_POINTER].[Pedido]
ADD FOREIGN KEY (cliente) REFERENCES [NULL_POINTER].Cliente(cliente_id);

ALTER TABLE [NULL_POINTER].[Pedido]
ADD FOREIGN KEY (estado) REFERENCES [NULL_POINTER].Estado(estado_id);

ALTER TABLE [NULL_POINTER].[PedidoCancelacion]
ADD FOREIGN KEY (pedido) REFERENCES [NULL_POINTER].Pedido(pedido_id);

ALTER TABLE [NULL_POINTER].[Cliente]
ADD FOREIGN KEY (localidad) REFERENCES [NULL_POINTER].Localidad(localidad_id);

ALTER TABLE [NULL_POINTER].[Sucursal]
ADD FOREIGN KEY (localidad) REFERENCES [NULL_POINTER].Localidad(localidad_id);

ALTER TABLE [NULL_POINTER].[Compra]
ADD FOREIGN KEY (sucursal) REFERENCES [NULL_POINTER].Sucursal(sucursal_id);

ALTER TABLE [NULL_POINTER].[Compra]
ADD FOREIGN KEY (proveedor) REFERENCES [NULL_POINTER].Proveedor(proveedor_id);

ALTER TABLE [NULL_POINTER].[PedidoSillon]
ADD FOREIGN KEY (pedido_id) REFERENCES [NULL_POINTER].Pedido(pedido_id);

ALTER TABLE [NULL_POINTER].[PedidoSillon]
ADD FOREIGN KEY (sillon_id) REFERENCES [NULL_POINTER].Sillon(sillon_id);

ALTER TABLE [NULL_POINTER].[FacturaDetalleFactura]
ADD FOREIGN KEY (factura_id) REFERENCES [NULL_POINTER].Factura(factura_id);

ALTER TABLE [NULL_POINTER].[FacturaDetalleFactura]
ADD FOREIGN KEY (detalle_id) REFERENCES [NULL_POINTER].DetalleFactura(detalle_id);

ALTER TABLE [NULL_POINTER].[Sillon]
ADD FOREIGN KEY (modelo) REFERENCES [NULL_POINTER].SillonModelo(modelo_id);

ALTER TABLE [NULL_POINTER].[Sillon]
ADD FOREIGN KEY (medidas) REFERENCES [NULL_POINTER].Medida(medida_id);

ALTER TABLE [NULL_POINTER].[Material]
ADD FOREIGN KEY (tipo) REFERENCES [NULL_POINTER].TipoMaterial(tipo_id);

ALTER TABLE [NULL_POINTER].[SillonMaterial]
ADD FOREIGN KEY (sillon_id) REFERENCES [NULL_POINTER].Sillon(sillon_id);

ALTER TABLE [NULL_POINTER].[SillonMaterial]
ADD FOREIGN KEY (material_id) REFERENCES [NULL_POINTER].Material(material_id);

ALTER TABLE [NULL_POINTER].[DetalleCompra]
ADD FOREIGN KEY (material_id) REFERENCES [NULL_POINTER].Material(material_id);

ALTER TABLE [NULL_POINTER].[Tela]
ADD FOREIGN KEY (material_id) REFERENCES [NULL_POINTER].Material(material_id);

ALTER TABLE [NULL_POINTER].[Madera]
ADD FOREIGN KEY (material_id) REFERENCES [NULL_POINTER].Material(material_id);

ALTER TABLE [NULL_POINTER].[Relleno]
ADD FOREIGN KEY (material_id) REFERENCES [NULL_POINTER].Material(material_id);

ALTER TABLE [NULL_POINTER].[Proveedor]
ADD FOREIGN KEY (localidad) REFERENCES [NULL_POINTER].Localidad(localidad_id);

ALTER TABLE [NULL_POINTER].[Localidad]
ADD FOREIGN KEY (provincia) REFERENCES [NULL_POINTER].Provincia(provincia_id);

COMMIT
GO

-- ================= Funciones auxiliares ==================

-- ================= Migracion =============================

BEGIN TRANSACTION

INSERT INTO [NULL_POINTER].[Provincia]
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
ORDER BY 1
GO

INSERT INTO [NULL_POINTER].[Localidad]
  (Localidades.descripcion, provincia)
SELECT DISTINCT localidad, provincia_id
FROM (
    SELECT Sucursal_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN NULL_POINTER.Provincia p ON p.descripcion = m.Sucursal_Provincia
  UNION
    SELECT Cliente_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN NULL_POINTER.Provincia p ON p.descripcion = m.Cliente_Provincia
  UNION
    SELECT Proveedor_Localidad AS localidad, provincia_id
    FROM gd_esquema.Maestra m
      JOIN NULL_POINTER.Provincia p ON p.descripcion = m.Proveedor_Provincia
) AS Localidades
WHERE localidad IS NOT NULL
ORDER BY 1
GO

INSERT INTO [NULL_POINTER].[Sucursal]
  (
  numero,
  direccion,
  telefono,
  mail,
  localidad
  )
SELECT DISTINCT Sucursal_NroSucursal, Sucursal_Direccion, Sucursal_telefono, Sucursal_mail, l.localidad_id
FROM gd_esquema.Maestra m
  LEFT JOIN NULL_POINTER.Provincia p ON p.descripcion = m.Sucursal_Provincia
  LEFT JOIN NULL_POINTER.Localidad l ON l.descripcion = m.Sucursal_Localidad
    AND p.provincia_id = l.provincia
WHERE Sucursal_NroSucursal IS NOT NULL
ORDER BY 1
GO

INSERT INTO [NULL_POINTER].[Cliente]
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
  LEFT JOIN NULL_POINTER.Provincia p ON p.descripcion = m.Cliente_Provincia
  LEFT JOIN NULL_POINTER.Localidad l ON l.descripcion = m.Cliente_Localidad
    AND p.provincia_id = l.provincia
WHERE Cliente_Dni IS NOT NULL
ORDER BY 1
GO

INSERT INTO [NULL_POINTER].[Estado]
  (descripcion)
SELECT DISTINCT Pedido_Estado
FROM gd_esquema.Maestra
WHERE Pedido_Estado IS NOT NULL

COMMIT
GO
