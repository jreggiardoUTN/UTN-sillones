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

-- Borrado de vistas si existen en caso que el schema exista

IF OBJECT_ID('DROP_TABLE.v_ganancias') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_ganancias
IF OBJECT_ID('DROP_TABLE.v_factura_promedio_mensual') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_factura_promedio_mensual
IF OBJECT_ID('DROP_TABLE.v_rendimiento_modelos') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_rendimiento_modelos
IF OBJECT_ID('DROP_TABLE.v_volumen_de_pedidos') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_volumen_de_pedidos
IF OBJECT_ID('DROP_TABLE.v_conversion_de_pedidos') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_conversion_de_pedidos
IF OBJECT_ID('DROP_TABLE.v_promedio_fabricacion') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_promedio_fabricacion
IF OBJECT_ID('DROP_TABLE.v_promedio_compras') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_promedio_compras;
IF OBJECT_ID('DROP_TABLE.v_compras_por_tipo_material') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_compras_por_tipo_material;
IF OBJECT_ID('DROP_TABLE.v_porcentaje_cumplimiento_envios') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_porcentaje_cumplimiento_envios;
IF OBJECT_ID('DROP_TABLE.v_top3_localidades_costo_envio') IS NOT NULL
  DROP VIEW [DROP_TABLE].v_top3_localidades_costo_envio;

-- Borrado de tablas si existen en caso que el schema exista

IF OBJECT_ID('DROP_TABLE.BI_dimension_tiempos','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_tiempos;
IF OBJECT_ID('DROP_TABLE.BI_dimension_ubicaciones','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_ubicaciones;
IF OBJECT_ID('DROP_TABLE.BI_dimension_rangos_edades','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_rangos_edades;
IF OBJECT_ID('DROP_TABLE.BI_dimension_turnos','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_turnos;
IF OBJECT_ID('DROP_TABLE.BI_dimension_tipo_material','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_tipo_material;
IF OBJECT_ID('DROP_TABLE.BI_dimension_modelo_sillon','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_modelo_sillon;
IF OBJECT_ID('DROP_TABLE.BI_dimension_estado_pedido','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_estado_pedido;
IF OBJECT_ID('DROP_TABLE.BI_hechos_ventas','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_ventas;
IF OBJECT_ID('DROP_TABLE.BI_hecho_compras','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hecho_compras;
IF OBJECT_ID('DROP_TABLE.BI_hechos_envios','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_envios;

-- Creacion de tablas
BEGIN TRANSACTION

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_tiempos')
CREATE TABLE [DROP_TABLE].[BI_dimension_tiempos]
(
  tiempo_id INT IDENTITY(1,1) PRIMARY KEY,
  mes INT,
  cuatrimestre INT,
  anio INT
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_ubicaciones')
CREATE TABLE [DROP_TABLE].[BI_dimension_ubicaciones]
(
  categoria_id INT IDENTITY(1,1) PRIMARY KEY,
  categoria_descripcion NVARCHAR (255),
  subcategoria_descripcion NVARCHAR (255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_rangos_edades')
CREATE TABLE [DROP_TABLE].[BI_dimension_rangos_edades]
(
  rango_id INT IDENTITY(1,1) PRIMARY KEY,
  rango_descripcion NVARCHAR (255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_turnos')
CREATE TABLE [DROP_TABLE].[BI_dimension_turnos]
(
  turno_id INT IDENTITY(1,1) PRIMARY KEY,
  descripcion NVARCHAR (255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_tipo_material')
CREATE TABLE [DROP_TABLE].[BI_dimension_tipo_material]
(
  tipo_id INT IDENTITY(1,1) PRIMARY KEY,
  tipo_descripcion NVARCHAR (255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_modelo_sillon')
CREATE TABLE [DROP_TABLE].[BI_dimension_modelo_sillon]
(
  modelo_id INT IDENTITY(1,1) PRIMARY KEY,
  modelo NVARCHAR (255),
  modelo_codigo BIGINT,
  modelo_descripcion NVARCHAR (255)
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_estado_pedido')
CREATE TABLE [DROP_TABLE].[BI_dimension_estado_pedido]
(
  estado_id INT IDENTITY(1,1) PRIMARY KEY,
  estado_descripcion NVARCHAR (255)
)

IF NOT EXISTS(SELECT [name]  ---BI_hechos_envios
FROM sys.tables
WHERE [name] = 'BI_hechos_envios')
CREATE TABLE DROP_TABLE.BI_hechos_envios (
  envio_id INT IDENTITY(1,1) PRIMARY KEY,
  tiempo_id INT,
  ubicacion_id INT,
  importe_traslado DECIMAL(18,2),
  importe_subida DECIMAL(18,2),
  total DECIMAL(18,2)
)

COMMIT
GO

-- ================= Funciones auxiliares ==================

CREATE FUNCTION [DROP_TABLE].fn_GetRangoEdadId(@fecha_nacimiento datetime) RETURNS INT AS
BEGIN
  DECLARE @rango_id INT;
  DECLARE @edad INT;
  SET @edad = (DATEDIFF(DAY, @fecha_nacimiento, GETDATE()) / 365)

  IF @edad BETWEEN 0 AND 24
		SELECT @rango_id = rango_id
  FROM [DROP_TABLE].BI_dimension_rangos_edades
  WHERE rango_descripcion = '< 25'
	ELSE IF @edad BETWEEN 25 AND 34
		SELECT @rango_id = rango_id
  FROM [DROP_TABLE].BI_dimension_rangos_edades
  WHERE rango_descripcion = '25 - 35'
	ELSE IF @edad BETWEEN 35 AND 50
		SELECT @rango_id = rango_id
  FROM [DROP_TABLE].BI_dimension_rangos_edades
  WHERE rango_descripcion = '35 - 50'
	ELSE
		SELECT @rango_id = rango_id
  FROM [DROP_TABLE].BI_dimension_rangos_edades
  WHERE rango_descripcion = '> 50'
  RETURN @rango_id;
END
GO

CREATE FUNCTION [DROP_TABLE].fn_GetTurnoId(@fecha_compra DATETIME) RETURNS INT AS
BEGIN
  DECLARE @turno_id INT;
  DECLARE @hora INT;
  SET @hora = DATEPART(HOUR, @fecha_compra);

  -- Para simplificar, dado que los turnos tienen distinta hora_inicio, se compara solo contra esta
  IF @hora BETWEEN 8 AND 14
		SELECT @turno_id = turno_id
  FROM [DROP_TABLE].BI_dimension_turnos AS T
  WHERE T.descripcion = '08:00 - 14:00'
	ELSE IF @hora BETWEEN 14 AND 20
		SELECT @turno_id = turno_id
  FROM [DROP_TABLE].BI_dimension_turnos AS T
  WHERE T.descripcion = '14:00 - 20:00'
	ELSE
		SELECT @turno_id = turno_id
  FROM [DROP_TABLE].BI_dimension_turnos AS T
  WHERE T.descripcion = 'Otros'
  RETURN @turno_id;
END
GO

CREATE FUNCTION [DROP_TABLE].fn_GetCuatrimestre(@fecha DATETIME) RETURNS SMALLINT AS
BEGIN
  RETURN (CEILING (DATEPART (mm,@fecha)* 1.0 / 4 ) )
END
GO

CREATE FUNCTION [DROP_TABLE].fn_GetTiempoId(@fecha DATETIME) RETURNS INT AS
BEGIN
	DECLARE @anio INT,
			@mes INT,
			@cuatrimestre INT,
			@id_tiempo INT

	SET @anio = DATEPART(YEAR, @fecha)
	SET @mes = DATEPART(MONTH, @fecha)
	SET @cuatrimestre = [DROP_TABLE].fn_GetCuatrimestre(@fecha)

	SELECT @id_tiempo = tiempo_id
		FROM DROP_TABLE.BI_dimension_tiempos
		WHERE anio = @anio AND mes = @mes AND cuatrimestre = @cuatrimestre

	RETURN @id_tiempo
END
GO

-- ================= Carga datos =============================

BEGIN TRANSACTION

INSERT INTO [DROP_TABLE].[BI_dimension_tiempos](
  mes,
  cuatrimestre,
  anio
)
SELECT DISTINCT MONTH(fecha), [DROP_TABLE].fn_GetCuatrimestre(fecha), YEAR(fecha)
FROM [DROP_TABLE].Factura
ORDER BY 1
GO

INSERT INTO [DROP_TABLE].[BI_dimension_turnos](descripcion)
VALUES
  ('08:00 - 14:00'),
  ('14:00 - 20:00'),
  ('Otros')
GO

INSERT INTO [DROP_TABLE].[BI_dimension_rangos_edades](rango_descripcion)
VALUES
  ('< 25'),
  ('25 - 35'),
  ('35 - 50'),
  ('> 50')
GO

INSERT INTO [DROP_TABLE].[BI_dimension_ubicaciones](
  localidad_descripcion,
  provincia_descripcion
)
SELECT L.descripcion, P.descripcion
FROM [DROP_TABLE].Localidad L
JOIN [DROP_TABLE].Provincia P ON L.provincia = P.provincia_id
GO

INSERT INTO [DROP_TABLE].[BI_dimension_tipo_material](
  tipo_descripcion
)
SELECT DISTINCT descripcion
FROM [DROP_TABLE].TipoMaterial
GO

INSERT INTO [DROP_TABLE].[BI_dimension_modelo_sillon](
  modelo,
  modelo_codigo,
  modelo_descripcion
)
SELECT DISTINCT modelo, modelo_codigo, modelo_descripcion
FROM [DROP_TABLE].SillonModelo
GO

INSERT INTO [DROP_TABLE].[BI_dimension_estado_pedido](
  estado_descripcion
)
SELECT DISTINCT descripcion
FROM [DROP_TABLE].Estado
GO


--INSERT INTO [DROP_TABLE].[BI_hechos_envios]
INSERT INTO DROP_TABLE.BI_hechos_envios (
  tiempo_id,
  ubicacion_id,
  importe_traslado,
  importe_subida,
  total
)
SELECT 
  DROP_TABLE.fn_GetTiempoId(e.fecha_entrega),
  ubi.ubicacion_id,
  e.importe_traslado,
  e.importe_subida,
  e.total
FROM DROP_TABLE.Envio e
JOIN DROP_TABLE.Factura f ON f.factura_id = e.factura
JOIN DROP_TABLE.Sucursal s ON s.sucursal_id = f.sucursal
JOIN DROP_TABLE.Localidad l ON l.localidad_id = s.localidad
JOIN DROP_TABLE.Provincia p ON p.provincia_id = l.provincia
JOIN DROP_TABLE.BI_dimension_ubicaciones ubi 
     ON ubi.localidad_descripcion = l.descripcion 
     AND ubi.provincia_descripcion = p.descripcion;

GO

-- INSERT INTO [DROP_TABLE].[BI_hechos_ventas](
-- GO

-- INSERT INTO [DROP_TABLE].[BI_hecho_compra](
-- GO


COMMIT
GO

-- ================= Vistas =============================
