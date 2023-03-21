# ------ Libs  -------

library(sf)
library(mapview)
library(RPostgres)

stopifnot(length(Sys.getenv('PG_GIC_HOST')) > 0)


# ------ DB connection  -------

# Connect to alex's postgis db
conn <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= 'test',
  host = Sys.getenv('PG_GIC_HOST'),
  user = Sys.getenv('PG_GIC_USER'),
  password = Sys.getenv('PG_GIC_PASSWORD'),
  port=Sys.getenv('PG_GIC_POST')
)


# ------ Read in given shp files -------

# Connect with sf to recover the geometry
shp_buffer <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "SELECT  buffer
  	from
  	public.mvt_params_from_point(1,0,0,-71.3449155, 46.8571419 ,100)  "
  ),
  geometry_column ='buffer'
)

shp_mvt_bounds <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "SELECT  bounds
  	from
  	public.mvt_params_from_point(1,0,0,-71.3449155, 46.8571419 ,100)  "
  ),
  geometry_column ='bounds'
)


shp_qc_city <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "SELECT ST_Transform(\"GEOMETRY\", 3857) as proj_geom
    FROM public.qc_city_test_tbl"
  ),
  geometry_column ='proj_geom'
)



# ------ Map to inspect results -------


mapview(shp_qc_city) +
  mapview(shp_mvt_bounds) +
  mapview(shp_buffer)



# -----

big_query <- "
WITH trans_geom_tbl AS (
  SELECT ST_Transform(\"GEOMETRY\", 3857) as proj_geom
  FROM public.qc_city_test_tbl
),
args as
(
  SELECT  *
    from
  public.mvt_params_from_point(1, 0,0,-71.3449155,46.8571419,100)
)

SELECT
  ST_Intersection(
    trans_geom_tbl.proj_geom ,
    args.buffer
  ) AS geom
FROM
args  , trans_geom_tbl
WHERE
ST_Intersects(
  trans_geom_tbl.proj_geom,
  args.bounds
)
AND
ST_Intersects(
  trans_geom_tbl.proj_geom,
  args.buffer
) ;
"


shp_big_query <- sf::st_read(
  dsn = conn,
  query = "SELECT * from public.mvt_geom_from_point(1,0,0,radius=>5000)",
  geometry_column ='geom'
)

mapview(shp_big_query)


# -----------



shp_big_query <- sf::st_read(
  dsn = conn,
  query = big_query,
  geometry_column ='geom'
)


# ----- -----

big_query_2 <- "
WITH trans_geom_tbl AS (
  SELECT ST_Transform(\"GEOMETRY\", 3857) as proj_geom
  FROM public.qc_city_test_tbl
),
args as
(
  SELECT  *
    from
  public.mvt_params_from_point(1, 0,0,-71.3449155,46.8571419,100)
)

SELECT
ST_AsMVTGeom(
    geom=> \"trans_geom_tbl.proj_geom\" ,
     bounds=>st_extent(args.bounds)
     )  AS geom

FROM
args  , trans_geom_tbl
WHERE
ST_Intersects(
  trans_geom_tbl.proj_geom,
  args.bounds
)
AND
ST_Intersects(
  trans_geom_tbl.proj_geom,
  args.buffer
) ;
"


shpbig_query_2 <- sf::st_read(
  dsn = conn,
  query = big_query_2,
  geometry_column ='geom'
)


bla <- "
SELECT ST_AsMVTGeom(
            st_transform( geom, 3857 ),
            ST_TileEnvelope(1, 0, 0) ) AS geom
  FROM public.geospatial_test_bugs"

shpbla <- sf::st_read(
  dsn = conn,
  query = bla,
  geometry_column ='geom'
)
shpbla %>% mapview
