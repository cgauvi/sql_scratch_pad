# Collection of ad-hoc postgres sql queries 

## MVT

Contains functions used in conjunction with pg_tileserv for custom on-the-fly tile filtering 

### Details on tile numbering

Postgis provides a convenience function to extract tiles for a given zoom level with `ST_TileEnvelope(z, x, y)`

- `(z,x,y)` returns the `xth` tile from the `yth` row for zoom `z`. uses power of 2 for num rows & cols: `0..2^z-1`
- See this [documentation](https://www.thunderforest.com/docs/tile-numbering/)

For example:

- `ST_TileEnvelope(0, 0, 0)` contains the entire globe
- North America falls completely within `ST_TileEnvelope(1, 0, 0)`