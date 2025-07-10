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
DECLARE @DropConstraints NVARCHAR(MAX) = '';

SELECT @DropConstraints +=
    'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id)) + '.' +
    QUOTENAME(OBJECT_NAME(fk.parent_object_id)) + 
    ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(13)
FROM sys.foreign_keys fk
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'DROP_TABLE'
  AND OBJECT_NAME(fk.parent_object_id) LIKE 'BI_%';

IF LEN(@DropConstraints) > 0
    EXEC sp_executesql @DropConstraints;
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
IF OBJECT_ID('DROP_TABLE.BI_dimension_estado_pedido','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_dimension_estado_pedido;
IF OBJECT_ID('DROP_TABLE.BI_hechos_compras','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_compras;
IF OBJECT_ID('DROP_TABLE.BI_hechos_envios','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_envios;
IF OBJECT_ID('DROP_TABLE.BI_hechos_pedidos','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_pedidos;
IF OBJECT_ID('DROP_TABLE.BI_hechos_facturacion','U') IS NOT NULL
  DROP TABLE [DROP_TABLE].BI_hechos_facturacion;
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
  turno_descripcion NVARCHAR (255)
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
WHERE [name] = 'BI_hechos_pedidos')
CREATE TABLE [DROP_TABLE].[BI_hechos_pedidos]
(
  pedido_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  numero DECIMAL (18, 0),
  tiempo_id INT, -- FK
  sillon_modelo INT, -- FK
  turno INT, -- FK
  sucursal_numero BIGINT,
  estado INT -- FK
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(sillon_modelo) REFERENCES [DROP_TABLE].[BI_dimension_modelo_sillon],
  FOREIGN KEY(turno) REFERENCES [DROP_TABLE].[BI_dimension_turnos],
  FOREIGN KEY(estado) REFERENCES [DROP_TABLE].[BI_dimension_estado_pedido]
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_facturacion')
CREATE TABLE [DROP_TABLE].[BI_hechos_facturacion]
(
  facturacion_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  tiempo_id INT, -- FK
  dias_desde_pedido_a_factura INT,
  sucursal_numero BIGINT,
  sillon_modelo INT, -- FK
  ubicacion_id INT, -- FK
  rango_etario_cliente INT, -- FK
  cantidad BIGINT,
  total_facturacion DECIMAL (18, 2),
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(ubicacion_id) REFERENCES [DROP_TABLE].[BI_dimension_ubicaciones],
  FOREIGN KEY(rango_etario_cliente) REFERENCES [DROP_TABLE].[BI_dimension_rangos_edades],
  FOREIGN KEY(sillon_modelo) REFERENCES [DROP_TABLE].[BI_dimension_modelo_sillon],
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_compras')
CREATE TABLE [DROP_TABLE].[BI_hechos_compras]
(
  compras_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  tiempo_id INT, -- FK
  sucursal_numero BIGINT,
  ubicacion_id INT, -- FK
  tipo_material INT, -- FK
  cantidad BIGINT,
  total_compra DECIMAL (18, 2),
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(ubicacion_id) REFERENCES [DROP_TABLE].[BI_dimension_ubicaciones],
  FOREIGN KEY(tipo_material) REFERENCES [DROP_TABLE].[BI_dimension_tipo_material],
)

IF NOT EXISTS(SELECT [name]
FROM sys.tables
WHERE [name] = 'BI_hechos_envios')
CREATE TABLE [DROP_TABLE].[BI_hechos_envios]
(
  envios_id DECIMAL (18, 0) IDENTITY(1,1) PRIMARY KEY,
  tiempo_id INT, -- FK
  ubicacion_id INT, -- FK
  estado_envio INT, -- FK
  envio_fecha_programada DATETIME2(2),
  envio_fecha_entrega DATETIME2(2),
  costo DECIMAL(18,2),
  FOREIGN KEY(tiempo_id) REFERENCES [DROP_TABLE].[BI_dimension_tiempos],
  FOREIGN KEY(estado_envio) REFERENCES [DROP_TABLE].[BI_dimension_estado_pedido],
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
  WHERE T.turno_descripcion = '08:00 - 14:00'
	ELSE IF @hora BETWEEN 14 AND 20
		SELECT @turno_id = turno_id
  FROM [DROP_TABLE].BI_dimension_turnos AS T
  WHERE T.turno_descripcion = '14:00 - 20:00'
	ELSE
		SELECT @turno_id = turno_id
  FROM [DROP_TABLE].BI_dimension_turnos AS T
  WHERE T.turno_descripcion = 'Otros'
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

  SET @anio = YEAR(@fecha)
  SET @mes = MONTH(@fecha)
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
  IF TRY_CAST(@fechaEntregado AS DATE) <= TRY_CAST(@fechaProgramado AS DATE)
	SET @Cumplido = 1
  ELSE
    SET @Cumplido = 0
  RETURN @Cumplido
END;
GO

-- ================= Carga datos =============================
BEGIN TRANSACTION

INSERT INTO [DROP_TABLE].[BI_dimension_tiempos]
  (
  mes,
  cuatrimestre,
  anio
  )
SELECT DISTINCT MONTH(fecha), [DROP_TABLE].fn_GetCuatrimestre(fecha), YEAR(fecha)
FROM (
  SELECT fecha FROM [DROP_TABLE].Pedido
  UNION
  SELECT fecha FROM [DROP_TABLE].Factura
  UNION
  SELECT fecha_compra FROM [DROP_TABLE].Compra
) AS fechas

ORDER BY 1
GO

INSERT INTO [DROP_TABLE].[BI_dimension_turnos]
  (turno_descripcion)
VALUES
  ('08:00 - 14:00'),
  ('14:00 - 20:00'),
  ('Otros')
GO

INSERT INTO [DROP_TABLE].[BI_dimension_rangos_edades]
  (rango_descripcion)
VALUES
  ('< 25'),
  ('25 - 35'),
  ('35 - 50'),
  ('> 50')
GO

INSERT INTO [DROP_TABLE].[BI_dimension_ubicaciones]
  (
  localidad_descripcion,
  provincia_descripcion
  )
SELECT L.descripcion, P.descripcion
FROM [DROP_TABLE].Localidad L
  JOIN [DROP_TABLE].Provincia P ON L.provincia = P.provincia_id
GO

INSERT INTO [DROP_TABLE].[BI_dimension_tipo_material]
  (
  tipo_descripcion
  )
SELECT DISTINCT descripcion
FROM [DROP_TABLE].TipoMaterial
GO

INSERT INTO [DROP_TABLE].[BI_dimension_modelo_sillon]
  (
  modelo,
  modelo_codigo,
  modelo_descripcion
  )
SELECT DISTINCT modelo, modelo_codigo, modelo_descripcion
FROM [DROP_TABLE].SillonModelo
GO

INSERT INTO [DROP_TABLE].[BI_dimension_estado_pedido]
  (
  estado_descripcion
  )
SELECT DISTINCT descripcion
FROM [DROP_TABLE].Estado
GO

INSERT INTO [DROP_TABLE].[BI_hechos_pedidos]
  (
  numero,
  tiempo_id,
  sillon_modelo,
  turno,
  sucursal_numero,
  estado
  )
SELECT
  p.numero,
  [DROP_TABLE].fn_GetTiempoId(p.fecha),
  dm.modelo_id,
  [DROP_TABLE].fn_GetTurnoId(p.fecha),
  su.numero,
  p.estado
FROM [DROP_TABLE].Pedido p
  LEFT JOIN [DROP_TABLE].ItemPedido ps ON ps.pedido_id = p.pedido_id
  LEFT JOIN [DROP_TABLE].Sillon s ON s.sillon_id = ps.sillon_id
  LEFT JOIN [DROP_TABLE].BI_dimension_modelo_sillon dm ON dm.modelo_id = ps.sillon_id
  LEFT JOIN [DROP_TABLE].Sucursal su ON su.sucursal_id = p.sucursal
GO

INSERT INTO [DROP_TABLE].[BI_hechos_facturacion]
  (
  tiempo_id,
  dias_desde_pedido_a_factura,
  sucursal_numero,
  sillon_modelo,
  ubicacion_id,
  rango_etario_cliente,
  cantidad,
  total_facturacion
  )
SELECT
  [DROP_TABLE].fn_GetTiempoId(f.fecha) AS tiempo_id,
  DATEDIFF(DAY, p.fecha, f.fecha) AS dias_desde_pedido_a_factura,
  s.numero AS sucursal_numero,
  si.modelo AS sillon_modelo,
  [DROP_TABLE].fn_GetUbicacionId(L.descripcion, Pr.descripcion) AS ubicacion_id,
  [DROP_TABLE].fn_GetRangoEdadId(c.fecha_nacimiento) AS rango_etario_cliente,
  COUNT(*) AS cantidad,
  SUM(ISNULL(f.total, 0)) AS total_facturacion
FROM DROP_TABLE.Factura f
JOIN DROP_TABLE.DetalleFactura df ON df.factura_id = f.factura_id
JOIN DROP_TABLE.ItemPedido ip ON ip.item_pedido_id = df.detalle_pedido
JOIN DROP_TABLE.Pedido p ON p.pedido_id = ip.pedido_id
  AND p.sucursal = f.sucursal
JOIN DROP_TABLE.Sucursal s ON s.sucursal_id = p.sucursal
JOIN DROP_TABLE.Localidad l ON l.localidad_id = s.localidad
JOIN DROP_TABLE.Provincia pr ON pr.provincia_id = l.provincia
JOIN DROP_TABLE.Cliente c ON c.cliente_id = p.cliente
JOIN DROP_TABLE.Sillon si ON si.sillon_id = ip.sillon_id
GROUP BY
  [DROP_TABLE].fn_GetTiempoId(f.fecha),
  DATEDIFF(DAY, p.fecha, f.fecha),
  s.numero,
  si.modelo,
  [DROP_TABLE].fn_GetUbicacionId(l.descripcion, pr.descripcion),
  [DROP_TABLE].fn_GetRangoEdadId(c.fecha_nacimiento)
GO

INSERT INTO [DROP_TABLE].[BI_hechos_compras]
  (
  tiempo_id,
  sucursal_numero,
  ubicacion_id,
  tipo_material,
  cantidad,
  total_compra
  )
SELECT
  [DROP_TABLE].fn_GetTiempoId(c.fecha_compra) AS tiempo_id,
  s.numero AS sucursal_numero,
  [DROP_TABLE].fn_GetUbicacionId(l.descripcion, p.descripcion) AS ubicacion_id,
  tm.tipo_id AS tipo_material,
  COUNT(*) AS cantidad,
  SUM(ISNULL(c.total, 0)) AS total_compra
FROM [DROP_TABLE].[Compra] c
JOIN [DROP_TABLE].[DetalleCompra] dc ON dc.detalle_compra_id = c.compra_id
JOIN [DROP_TABLE].[Material] m ON m.material_id = dc.material_id
JOIN [DROP_TABLE].[TipoMaterial] tm ON tm.tipo_id = m.tipo
JOIN [DROP_TABLE].[Sucursal] s ON s.sucursal_id = c.sucursal
JOIN [DROP_TABLE].[Localidad] l ON l.localidad_id = s.localidad
JOIN [DROP_TABLE].[Provincia] p ON p.provincia_id = l.provincia
GROUP BY
  [DROP_TABLE].fn_GetTiempoId(c.fecha_compra),
  s.numero,
  [DROP_TABLE].fn_GetUbicacionId(l.descripcion, p.descripcion),
  tm.tipo_id
ORDER BY 2
GO

INSERT INTO [DROP_TABLE].[BI_hechos_envios]
  (
  tiempo_id,
  ubicacion_id,
  estado_envio,
  envio_fecha_programada,
  envio_fecha_entrega,
  costo
  )
SELECT DISTINCT
  [DROP_TABLE].fn_GetTiempoId(f.fecha),
  u.ubicacion_id,
  es.estado_id,
  e.fecha_programada,
  e.fecha_entrega,
  SUM(e.total)
FROM [DROP_TABLE].Envio E
  LEFT JOIN [DROP_TABLE].Factura F ON F.factura_id = e.factura
  JOIN [DROP_TABLE].Sucursal s ON s.sucursal_id = f.sucursal
  JOIN [DROP_TABLE].Localidad l ON l.localidad_id = s.localidad
  JOIN [DROP_TABLE].Provincia p ON p.provincia_id = l.provincia
  JOIN [DROP_TABLE].Cliente c ON c.cliente_id = f.cliente
  JOIN [DROP_TABLE].Pedido pe ON pe.pedido_id = c.cliente_id
  JOIN [DROP_TABLE].Estado es ON es.estado_id = pe.estado
  JOIN [DROP_TABLE].BI_dimension_ubicaciones u ON u.localidad_descripcion = l.descripcion
    AND u.provincia_descripcion = p.descripcion
GROUP BY
  f.numero,
  e.numero,
  [DROP_TABLE].fn_GetTiempoId(F.fecha),
  F.fecha,
  u.ubicacion_id,
  es.estado_id,
	e.fecha_programada,
	e.fecha_entrega
GO

COMMIT
GO

-- ================= Vistas =============================
-- Punto 1
CREATE VIEW [DROP_TABLE].v_ganancias
AS
  SELECT DISTINCT
    t.mes,
    t.anio,
    f.sucursal_numero,
    SUM(ISNULL(f.total_facturacion, 0)) - SUM(ISNULL(c.total_compra, 0)) AS ganancia
  FROM [DROP_TABLE].BI_hechos_facturacion f
  LEFT JOIN [DROP_TABLE].BI_hechos_compras c ON c.sucursal_numero = f.sucursal_numero
    AND c.tiempo_id = f.tiempo_id
    AND c.ubicacion_id = f.ubicacion_id
  LEFT JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = f.tiempo_id
  GROUP BY
    t.mes,
    t.anio,
    f.sucursal_numero
GO

-- Punto 2
CREATE VIEW [DROP_TABLE].v_factura_promedio
AS
  SELECT DISTINCT
    CAST(SUM(ISNULL(f.total_facturacion, 0)) / SUM(ISNULL(f.cantidad, 0)) AS DECIMAL(18,2)) AS promedio_factura,
    u.provincia_descripcion AS provincia,
    t.cuatrimestre,
    t.anio
  FROM [DROP_TABLE].BI_hechos_facturacion f
  JOIN [DROP_TABLE].BI_dimension_ubicaciones u ON u.ubicacion_id = f.ubicacion_id
  JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = f.tiempo_id
  GROUP BY
    u.provincia_descripcion,
    t.cuatrimestre,
    t.anio
GO

-- Punto 3
CREATE VIEW [DROP_TABLE].v_rendimiento_modelos
AS
  SELECT *
  FROM (
    SELECT
      t.anio,
      t.cuatrimestre,
      m.modelo_descripcion,
      u.ubicacion_id,
      e.rango_descripcion,
      SUM(f.total_facturacion) AS total_facturacion,
      ROW_NUMBER() OVER (
        PARTITION BY
          t.anio,
          t.cuatrimestre,
          u.ubicacion_id,
          e.rango_descripcion
        ORDER BY SUM(f.total_facturacion) DESC
      ) AS ranking_ventas
    FROM [DROP_TABLE].BI_hechos_facturacion f
    JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = f.tiempo_id
    JOIN [DROP_TABLE].BI_dimension_modelo_sillon m ON m.modelo_id = f.sillon_modelo
    JOIN [DROP_TABLE].BI_dimension_rangos_edades e ON e.rango_id = f.rango_etario_cliente
    JOIN [DROP_TABLE].BI_dimension_ubicaciones u ON u.ubicacion_id = f.ubicacion_id
    GROUP BY
      t.anio,
      t.cuatrimestre,
      m.modelo_descripcion,
      u.ubicacion_id,
      e.rango_descripcion
  ) AS ventas_con_ranking
  WHERE ranking_ventas <= 3
GO

--Punto 4
CREATE VIEW [DROP_TABLE].v_volumen_de_pedidos
AS
SELECT
    t.anio,
    t.mes,
    tr.turno_descripcion AS turno,
    h.sucursal_numero,
    COUNT(*) AS cantidad_pedidos
	FROM DROP_TABLE.BI_hechos_pedidos h
JOIN DROP_TABLE.BI_dimension_tiempos t ON h.tiempo_id = t.tiempo_id
JOIN DROP_TABLE.BI_dimension_turnos tr ON h.turno = tr.turno_id
GROUP BY
    t.anio,
    t.mes,
    tr.turno_descripcion,
    h.sucursal_numero;
GO

-- Punto 5
CREATE VIEW [DROP_TABLE].v_conversion_de_pedidos
AS
SELECT DISTINCT
	t.cuatrimestre,
	p.sucursal_numero,
	t.anio,
	p.estado,
	CAST(COUNT(p.pedido_id) * 100.0 / SUM(COUNT(p.estado)) OVER (PARTITION BY t.cuatrimestre, p.sucursal_numero, t.anio)AS DECIMAL(10, 2)) AS porcentaje
	FROM DROP_TABLE.BI_hechos_pedidos p
JOIN DROP_TABLE.BI_dimension_tiempos t ON p.tiempo_id = t.tiempo_id
JOIN DROP_TABLE.BI_dimension_estado_pedido ep ON p.estado= ep.estado_id
GROUP BY
	t.cuatrimestre,
	p.sucursal_numero,
	t.anio,
	p.estado
GO

-- Punto 6
CREATE VIEW [DROP_TABLE].v_promedio_fabricacion
AS
SELECT
	t.cuatrimestre,
	t.anio,
	f.sucursal_numero,
	AVG(f.dias_desde_pedido_a_factura) AS promedio_fabricacion
FROM DROP_TABLE.BI_hechos_facturacion f
LEFT JOIN DROP_TABLE.BI_dimension_tiempos t ON t.tiempo_id = f.tiempo_id
GROUP BY
	t.cuatrimestre,
	t.anio,
	f.sucursal_numero
GO

-- Punto 7
CREATE VIEW [DROP_TABLE].v_promedio_compras
AS
  SELECT
    t.mes,
    t.anio,
    CAST(SUM(ISNULL(c.total_compra, 0)) / SUM(ISNULL(c.cantidad, 0)) AS DECIMAL(18,2)) AS promedio_compra
  FROM [DROP_TABLE].BI_hechos_compras c
  JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = c.tiempo_id
  GROUP BY t.mes, t.anio
GO

-- Punto 8
CREATE VIEW [DROP_TABLE].v_compras_por_tipo_material
AS
  SELECT
    m.tipo_descripcion AS material,
    SUM(ISNULL(c.total_compra, 0)) AS total_compras,
    c.sucursal_numero,
    t.cuatrimestre,
    t.anio
  FROM [DROP_TABLE].BI_hechos_compras c
  JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = c.tiempo_id
  JOIN [DROP_TABLE].BI_dimension_tipo_material m ON m.tipo_id = c.tipo_material
  GROUP BY
    m.tipo_descripcion,
    c.sucursal_numero,
    t.cuatrimestre,
    t.anio
GO

-- Punto 9
CREATE VIEW [DROP_TABLE].v_porcentaje_cumplimiento_envios
AS
  SELECT
    t.anio AS Anio,
    t.mes AS Mes,
    (SUM([DROP_TABLE].fn_EnvioCumplido(e.envio_fecha_entrega, e.envio_fecha_programada)) * 100 / COUNT(1)) AS PorcentajeCumplimientoEnvio
  FROM [DROP_TABLE].BI_hechos_envios e
  JOIN [DROP_TABLE].BI_dimension_tiempos t ON t.tiempo_id = e.tiempo_id
  JOIN [DROP_TABLE].BI_dimension_estado_pedido es ON es.estado_id = e.estado_envio
  WHERE es.estado_descripcion = 'ENTREGADO'
  GROUP BY t.anio, t.mes
GO

-- Punto 10
CREATE VIEW [DROP_TABLE].v_top3_localidades_costo_envio
AS
  SELECT
    localidad_descripcion,
    total_costo_envio
  FROM (
    SELECT TOP 3
      u.localidad_descripcion,
      SUM(e.costo) / COUNT(*) AS total_costo_envio
    FROM [DROP_TABLE].BI_hechos_envios e
      JOIN [DROP_TABLE].BI_dimension_ubicaciones u ON e.ubicacion_id = u.ubicacion_id
    GROUP BY u.localidad_descripcion
    ORDER BY SUM(e.costo) / COUNT(*) DESC
) AS subquery;
GO
