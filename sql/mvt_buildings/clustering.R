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


# ------ Read in given shp files -------

# Connect with sf to recover the geometry
shp_cluster <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "SELECT ST_ClusterKMeans(st_centroid(geom), 10) OVER() AS cid, st_centroid(geom) as geom, table_orig
    FROM public.building_footprints_open_data
	limit 10000 "
  ),
  geometry_column ='geom'
)

mapview::mapview(shp_cluster, zcol = 'cid')
