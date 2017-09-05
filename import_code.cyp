CREATE CONSTRAINT ON (c:CROSSROAD) ASSERT c.id IS UNIQUE;
// Load nodes
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///nodes.csv" AS line
MERGE(p:CROSSROAD { id: line.id, long: toFloat(line.long), lat:toFloat(line.lat) })

CREATE CONSTRAINT ON (r:ROAD) ASSERT r.id IS UNIQUE;

// Load edges
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM "file:///edges.csv" AS line
MATCH (start_node:CROSSROAD { id: line.start_node })
MATCH (end_node:CROSSROAD { id: line.end_node })
CREATE (start_node)-[r:ROAD]->(end_node)
SET r.id =line.id,
r.distance=toFloat(line.distance);

CREATE INDEX on :ROAD(start_node);
CREATE INDEX on :ROAD(end_node);

//load poi for csv load 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS
FROM "file:///has_poi.csv" AS line
MATCH (start_node:CROSSROAD { id:line.start_node})
CREATE (p:POI { id:line.cat_id})
CREATE (start_node)-[h:HAS_POI]->(p)
SET h.dist_start_node =toFloat(line.distance)

// Load poi category names
USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS FROM "file:///POI-name-id.csv" AS line
MATCH(p:POI { id: line.cat_id})
SET  p.name=UPPER(line.cat_name);

CREATE INDEX on :POI(id);
CREATE INDEX on :POI(name);

//add number of poi
USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS FROM "file:///has_number_of_poi.csv" AS line
MATCH (start_node:CROSSROAD { id: line.start_node })
MATCH (end_node:CROSSROAD { id: line.end_node })
MATCH (start_node)-[r:ROAD]->(end_node)
SET r.number_of_poi=toInteger(line.number_of_poi)

