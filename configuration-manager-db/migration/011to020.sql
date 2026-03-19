-- Copyright (C) 2026 NEC Corporation.
-- 
-- Licensed under the Apache License, Version 2.0 (the "License"); you may
-- not use this file except in compliance with the License. You may obtain
-- a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations
-- under the License.

-- This migration script updates the graph schema from version v0.1.1 to v0.2.0.

--
-- 1. Define the vertex and edge labels added in v0.2.0, and create indexes.
--
SELECT CREATE_VLABEL('cdim_graph', 'DeviceUnit');
SELECT CREATE_VLABEL('cdim_graph', 'SourceFabricAdapter');
SELECT CREATE_VLABEL('cdim_graph', 'DestinationFabricAdapter');
SELECT CREATE_VLABEL('cdim_graph', 'Fabric');
SELECT CREATE_ELABEL('cdim_graph', 'Host');
CREATE INDEX cdim_graph_DeviceUnit_idx ON cdim_graph."DeviceUnit" USING gin (properties);
CREATE INDEX cdim_graph_SourceFabricAdapter_idx ON cdim_graph."SourceFabricAdapter" USING gin (properties);
CREATE INDEX cdim_graph_DestinationFabricAdapter_idx ON cdim_graph."DestinationFabricAdapter" USING gin (properties);
CREATE INDEX cdim_graph_Fabric_idx ON cdim_graph."Fabric" USING gin (properties);

--
-- 2. Delete and recreate all CXLswitch vertices because the CXLswitch vertex structure has changed.
--
SELECT * FROM cypher ('cdim_graph', $$
MATCH (vcx:CXLswitch)
DETACH DELETE vcx
RETURN vcx
$$ ) AS (vcx agtype);

--
-- 3. Change Unit Vertex to DeviceUnit Vertex. Also change the property from deviceID to id.
-- Create DeviceUnit Vertex and related Edges, then delete Unit Vertex.
--

-- 3-1. Create DeviceUnit Vertex and related Have Edges.
SELECT * FROM cypher ('cdim_graph', $$
MATCH (o_vut:Unit)-[o_ehv:Have]->(vutan:Annotation)
CREATE (n_vut:DeviceUnit {id: o_vut.deviceID})-[n_ehv:Have]->(vutan)
SET vutan = {systemItems: {available: true}, userItems: {}}
RETURN n_vut
$$ ) AS (deviceUnit agtype);

-- 3-2. Create Contain Edge related to the DeviceUnit Vertex created in 3-1.
SELECT * FROM cypher ('cdim_graph', $$
MATCH (o_vut:Unit)-[o_ect:Contain]->(vrs)
MATCH (n_vut:DeviceUnit {id: o_vut.deviceID})
CREATE (n_vut)-[n_ect:Contain]->(vrs)
RETURN n_vut
$$ ) AS (deviceUnit agtype);

-- 3-3. Delete Unit Vertex and related Edges.
SELECT * FROM cypher ('cdim_graph', $$
MATCH (o_vut:Unit)
DETACH DELETE o_vut
RETURN o_vut
$$ ) AS (deviceUnit agtype);

--
-- 4. Drop Vertices and indexes removed in v0.2.0.
--
DROP INDEX cdim_graph.cdim_graph_Unit_idx;
SELECT drop_label('cdim_graph', 'Unit');
