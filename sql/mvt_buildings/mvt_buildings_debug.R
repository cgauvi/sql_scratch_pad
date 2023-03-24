
# ------ Libs  -------

library(sf)
library(mapview)
library(RPostgres)

stopifnot(length(Sys.getenv('PG_GIC_HOST')) > 0)


# ------ DB connection  -------

# Connect to alex's postgis db
conn <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname= 'gis', # gis! not test
  host = Sys.getenv('PG_GIC_HOST'),
  user = Sys.getenv('PG_GIC_USER'),
  password = Sys.getenv('PG_GIC_PASSWORD'),
  port=Sys.getenv('PG_GIC_POST')
)



# ------ Zoomed in: high zoom - use all features and orig table ------

# Connect with sf to recover the geometry
shp_geom_mvt <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "select *
    from public.mvt_geom_from_point(14, 4844, 5853)"
  ),
  geometry_column ='geom'
)

shp_tile_env <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "select ST_TileEnvelope(14, 4844, 5853) as geom "
  ),
  geometry_column ='geom'
)

mapview::mapview(shp_geom_mvt) +
  mapview::mapview(shp_tile_env)



# ------ Zoomed out: sample from randomly ordered table ------

# Connect with sf to recover the geometry
shp_geom_mvt <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "select *
    from public.mvt_geom_from_point(8, 77, 90)"
  ),
  geometry_column ='geom'
)


shp_all <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "SELECT
    ST_Intersection( geom, ST_TileEnvelope( 8,77,90) ) AS geom
    FROM public.building_footprints_open_data_rnd
    WHERE ST_Intersects(geom,  ST_TileEnvelope( 8,77,90) )
 ;" ),
  geometry_column ='geom'
)

shp_tile_env <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "select ST_TileEnvelope(8, 77, 90) as geom "
  ),
  geometry_column ='geom'
)

mapview::mapview(shp_geom_mvt) +
  mapview::mapview(shp_tile_env) +
  mapview::mapview(shp_all)
