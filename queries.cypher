//1.
match (a:CROSSROAD)-[h:HAS_POI]-(c:POI)
with  a.id as id ,count(h) as degree ,collect(c.name) as nameList 
unwind nameList AS name
WITH id,degree,name, count(*) AS count
ORDER BY count DESC
with id,degree,collect({n:name,c:count}) as list
return id,degree,list
ORDER BY degree DESC
limit 1


//2-3.
MATCH path=allShortestPaths((start_node:CROSSROAD {id:'10'})-[ROAD*]-(end_node:CROSSROAD {id:'16'}))
RETURN length(path) as length,path

//4.
match (a:CROSSROAD)-[h:HAS_POI]-(c:POI{name:'BAR'})
RETURN a.id,count(h) as degree
ORDER BY degree DESC
limit 3

//5.
MATCH path1=shortestPath( (a:CROSSROAD{id:'10'})-[r1:ROAD*]-(c:CROSSROAD{id:'17'}))
MATCH path2=shortestPath( (c:CROSSROAD{id:'17'})-[r2:ROAD*]-(b:CROSSROAD{id:'21'}))

RETURN path1, path2, LENGTH(path1) + LENGTH(path2) AS length
ORDER BY length
LIMIT 1

//6.
MATCH (o:CROSSROAD)
WITH ({ id: 'POINT', long: -123, lat: 39 }) AS p1, ({ id: o.id, long: o.long, lat: o.lat }) AS p2
RETURN  p1 as point, p2 as nearestCrossroads, sqrt((p1.long-p2.long)^2 + abs(p1.lat-p2.lat)^2) AS dist
ORDER BY dist
LIMIT 5
