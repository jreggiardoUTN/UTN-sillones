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

-- Borrado de funciones auxiliar si existe

DROP FUNCTION IF EXISTS [DROP_TABLE].fn_GetRangoEdadId;
DROP FUNCTION IF EXISTS [DROP_TABLE].fn_GetTurnoId;
DROP FUNCTION IF EXISTS [DROP_TABLE].fn_GetCuatrimestre;
DROP FUNCTION IF EXISTS [DROP_TABLE].fn_GetTiempoId;
DROP FUNCTION IF EXISTS [DROP_TABLE].fn_GetUbicacionId;
DROP FUNCTION IF EXISTS [DROP_TABLE].fn_EnvioCumplido;

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
GO

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
IF OBJECT_ID('DROP_TABLE.BI_dimension_pedido','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_pedido;
IF OBJECT_ID('DROP_TABLE.BI_dimension_estado_pedido','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_estado_pedido;
IF OBJECT_ID('DROP_TABLE.BI_dimension_sucursales','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_sucursales;
IF OBJECT_ID('DROP_TABLE.BI_hechos_compras','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_compras;
IF OBJECT_ID('DROP_TABLE.BI_hechos_envios','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_envios;
IF OBJECT_ID('DROP_TABLE.BI_hechos_pedidos','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_pedidos;
IF OBJECT_ID('DROP_TABLE.BI_hechos_ventas','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_ventas;
GO

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
  ubicacion_id INT IDENTITY(1,1) PRIMARY KEY,
  localidad_descripcion NVARCHAR (255),
  provincia_descripcion NVARCHAR (255),
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

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_dimension_sucursales')
CREATE TABLE [DROP_TABLE].[BI_dimension_sucursales]
(
  sucursal_id INT IDENTITY(1,1) PRIMARY KEY,
  sucursal_nombre NVARCHAR (255),
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_pedidos')
CREATE TABLE [DROP_TABLE].[BI_hechos_pedidos]
(
  pedido_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL (18, 0),
  tiempo_id INT,
  sillon_modelo INT,
  turno INT,
  sucursal_id INT,
  estado INT
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(sillon_modelo) REFERENCES [DROP_TABLE].[BI_dimension_modelo_sillon],
  FOREIGN KEY(turno) REFERENCES [DROP_TABLE].[BI_dimension_turnos],
  FOREIGN KEY(sucursal_id) REFERENCES [DROP_TABLE].[BI_dimension_sucursales],
  FOREIGN KEY(estado) REFERENCES [DROP_TABLE].[BI_dimension_estado_pedido],
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_ventas')
CREATE TABLE [DROP_TABLE].[BI_hechos_ventas]
(
  hechos_facturacion_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  total_facturacion DECIMAL (18, 2),
  tiempo_id INT,
  ubicacion_id INT,
  sucursal_id INT,
  rango_etario_cliente INT,
  pedido DECIMAL (18, 0),
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(ubicacion_id) REFERENCES [DROP_TABLE].[BI_dimension_ubicaciones],
  FOREIGN KEY(sucursal_id) REFERENCES [DROP_TABLE].[BI_dimension_sucursales],
  FOREIGN KEY(rango_etario_cliente) REFERENCES [DROP_TABLE].[BI_dimension_rangos_edades],
  FOREIGN KEY(pedido) REFERENCES [DROP_TABLE].[BI_hechos_pedidos],
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_compras')
CREATE TABLE [DROP_TABLE].[BI_hechos_compras]
(
  hechos_compras_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  total_compra DECIMAL (18, 2),
  tiempo_id INT,
  ubicacion_id INT,
  sucursal_id INT,
  tipo_material INT,
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(ubicacion_id) REFERENCES [DROP_TABLE].[BI_dimension_ubicaciones],
  FOREIGN KEY(sucursal_id) REFERENCES [DROP_TABLE].[BI_dimension_sucursales],
  FOREIGN KEY(tipo_material) REFERENCES [DROP_TABLE].[BI_dimension_tipo_material],
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_envios')
CREATE TABLE [DROP_TABLE].[BI_hechos_envios]
(
  hechos_envios_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  tiempo_id INT,
  ubicacion_id INT,
  estado_envio NVARCHAR(255),
  envio_fecha_programada DATETIME2(2),
  envio_fecha_entrega DATETIME2(2),
  costo DECIMAL(18,2),
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(ubicacion_id) REFERENCES [DROP_TABLE].[BI_dimension_ubicaciones],
)

COMMIT
GO

-- ================= Funciones auxiliares ==================

CREATE FUNCTION [DROP_TABLE].fn_GetRangoEdadId(@fecha_nacimiento DATETIME2) RETURNS INT AS
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

CREATE FUNCTION [DROP_TABLE].fn_GetTurnoId(@fecha DATETIME2) RETURNS INT AS
BEGIN
  DECLARE @turno_id INT;
  DECLARE @hora INT;
  SET @hora = DATEPART(HOUR, @fecha);

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

CREATE FUNCTION [DROP_TABLE].fn_GetCuatrimestre(@fecha DATETIME2) RETURNS SMALLINT AS
BEGIN
  RETURN (CEILING (DATEPART (mm,@fecha)* 1.0 / 4 ) )
END
GO

CREATE FUNCTION [DROP_TABLE].fn_GetTiempoId(@fecha DATETIME2) RETURNS INT AS
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

CREATE FUNCTION [DROP_TABLE].fn_GetUbicacionId(@localidad NVARCHAR(255), @provincia NVARCHAR(255)) RETURNS INT AS
BEGIN
    DECLARE @ubicacion INT

  	SELECT @ubicacion = U.ubicacion_id
		FROM [DROP_TABLE].BI_dimension_ubicaciones U
		WHERE U.localidad_descripcion = @localidad AND U.provincia_descripcion = @provincia

    RETURN @ubicacion
END
GO

CREATE FUNCTION [DROP_TABLE].fn_EnvioCumplido(@fechaEntregado DATETIME2, @fechaProgramado DATETIME) RETURNS INT AS
BEGIN
  DECLARE @Cumplido INT;
  IF TRY_CAST(@fechaEntregado AS DATE) <= TRY_CAST(@fechaEntregado AS DATE)
	SET @Cumplido = 1
  ELSE
    SET @Cumplido = 0
  RETURN @Cumplido
END;
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

INSERT INTO [DROP_TABLE].[BI_hechos_pedidos](
  numero,
  tiempo_id,
  sillon_modelo,
  turno,
  sucursal_id,
  estado
)
SELECT
  P.numero,
  [DROP_TABLE].fn_GetTiempoId(P.fecha),
  DM.modelo_id,
  [DROP_TABLE].fn_GetTurnoId(P.fecha),
  P.sucursal,
  P.estado
FROM [DROP_TABLE].Pedido P
LEFT JOIN [DROP_TABLE].PedidoSillon PS ON PS.pedido_id = P.pedido_id
LEFT JOIN [DROP_TABLE].Sillon S ON S.sillon_id = PS.sillon_id
LEFT JOIN [DROP_TABLE].BI_dimension_modelo_sillon DM ON DM.modelo_id = PS.sillon_id
GO

INSERT INTO [DROP_TABLE].[BI_hechos_ventas] (
  total_facturacion,
  tiempo_id,
  ubicacion_id,
  sucursal_id,
  rango_etario_cliente
)
SELECT
  F.total,
  [DROP_TABLE].fn_GetTiempoId(F.fecha),
  U.ubicacion_id,
  F.sucursal,
  [DROP_TABLE].fn_GetRangoEdadId(C.fecha_nacimiento)
FROM [DROP_TABLE].Factura F
LEFT JOIN [DROP_TABLE].Sucursal S ON S.sucursal_id = F.sucursal
LEFT JOIN [DROP_TABLE].Localidad L ON L.localidad_id = S.localidad
LEFT JOIN [DROP_TABLE].Provincia P ON P.provincia_id = L.provincia
JOIN [DROP_TABLE].BI_dimension_ubicaciones U
  ON L.descripcion = U.localidad_descripcion
  AND P.descripcion = U.provincia_descripcion
JOIN [DROP_TABLE].Cliente C ON C.cliente_id = F.cliente
GO

-- INSERT INTO [DROP_TABLE].[BI_hechos_compras](
--   total_compra,
--   tiempo_id,
--   ubicacion_id,
--   sucursal_id,
--   tipo_material
-- )
-- SELECT
--   C.total,
--   [DROP_TABLE].fn_GetTiempoId(C.fecha_compra),
--   [DROP_TABLE].fn_GetUbicacionId(L.descripcion, P.descripcion),
--   C.sucursal,
--   M.tipo_material
-- FROM [DROP_TABLE].Compra C
-- LEFT JOIN [DROP_TABLE].Sucursal S ON S.sucursal_id = C.sucursal
-- LEFT JOIN [DROP_TABLE].Localidad L ON L.localidad_id = S.localidad
-- LEFT JOIN [DROP_TABLE].Provincia P ON P.provincia_id = L.provincia

-- Como se vincula Compra con detalle compra?
-- GO

INSERT INTO [DROP_TABLE].[BI_hechos_envios](
  tiempo_id,
  ubicacion_id,
  estado_envio,
  envio_fecha_programada,
  envio_fecha_entrega,
  costo
)
SELECT DISTINCT
  [DROP_TABLE].fn_GetTiempoId(F.fecha),
  U.ubicacion_id,
  Es.descripcion,
  E.fecha_programada,
  E.fecha_entrega,
  SUM(E.total)
FROM [DROP_TABLE].Envio E
LEFT JOIN [DROP_TABLE].Factura F ON F.factura_id = E.factura
JOIN [DROP_TABLE].Cliente Cl ON Cl.cliente_id = F.cliente
JOIN [DROP_TABLE].Localidad L ON L.localidad_id = Cl.localidad
JOIN [DROP_TABLE].Provincia P ON P.provincia_id = L.provincia
JOIN [DROP_TABLE].BI_dimension_ubicaciones U
  ON L.descripcion = U.localidad_descripcion
  AND P.descripcion = U.provincia_descripcion
JOIN [DROP_TABLE].FacturaDetalleFactura FDF ON FDF.factura_id = F.factura_id
JOIN [DROP_TABLE].DetalleFactura DF ON DF.detalle_id = FDF.detalle_id
JOIN [DROP_TABLE].Sillon S ON S.sillon_id = DF.detalle_pedido
JOIN [DROP_TABLE].PedidoSillon PS ON PS.sillon_id = S.sillon_id
JOIN [DROP_TABLE].Pedido Pe ON Pe.pedido_id = PS.pedido_id
JOIN [DROP_TABLE].Estado Es ON Es.estado_id = Pe.estado
GROUP BY 
  [DROP_TABLE].fn_GetTiempoId(F.fecha),
  U.ubicacion_id,
	Es.descripcion,
	E.fecha_programada,
	E.fecha_entrega
GO

-- ================= Vistas =============================

-- Punto 9
CREATE VIEW [DROP_TABLE].v_porcentaje_cumplimiento_envios AS
SELECT
  T.anio AS Anio,
  T.mes AS Mes,
  (SUM([DROP_TABLE].fn_EnvioCumplido(HE.envio_fecha_entrega, HE.envio_fecha_programada)) / COUNT(1)) * 100 AS PorcentajeCumplimientoEnvio
FROM [DROP_TABLE].BI_hechos_envios HE
INNER JOIN [DROP_TABLE].BI_dimension_tiempos T ON T.tiempo_id = HE.tiempo_id
GROUP BY t.anio, t.mes;
GO

-- Punto 10
CREATE VIEW [DROP_TABLE].v_top3_localidades_costo_envio AS
SELECT
    localidad_descripcion,
    total_costo_envio
FROM (
    SELECT TOP 5
        DU.localidad_descripcion,
        SUM(HE.costo) AS total_costo_envio
    FROM [DROP_TABLE].BI_hechos_envios HE
    JOIN [DROP_TABLE].BI_dimension_ubicaciones DU ON HE.ubicacion_id = DU.ubicacion_id
    GROUP BY DU.localidad_descripcion
    ORDER BY SUM(HE.costo) DESC
) AS subquery;
GO