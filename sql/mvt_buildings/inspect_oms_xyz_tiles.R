
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



# ------ Get the x, y offset of the tile covering a given point for a given zoom level -------

# From https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames


deg2num<-function(lat_deg, lon_deg, zoom){
  lat_rad <- lat_deg * pi /180
  n <- 2.0 ^ zoom
  xtile <- floor((lon_deg + 180.0) / 360.0 * n)
  ytile = floor((1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2.0 * n)
  return( c(xtile, ytile))
  #  return(paste(paste("https://a.tile.openstreetmap.org", zoom, xtile, ytile, sep="/"),".png",sep=""))
}

zoom_level <- 8
lat <- 46.8
lon <- -71.3449155
xy <- deg2num(lat, lon, zoom_level)

string_params <- paste0(zoom_level, ',' , paste0(xy, collapse = ','), collapse = '')
string_params2 <- paste0(zoom_level, '/' , paste0(xy, collapse = '/'), collapse = '')

shp_tile_env <- sf::st_read(
  dsn = conn,
  query =  glue::glue(
    "select ST_TileEnvelope({string_params}) as geom "
  ),
  geometry_column ='geom'
)


mapview::mapview(shp_tile_env)
