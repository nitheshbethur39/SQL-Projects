# Library Management System/SQL

Library Management System ER Diagram
This ER diagram represents the structure of the database that supports the management of library materials, members, staff, and borrowing activities.

Relationships
Authorship is a relationship which has complete or total participation with Material entity and partial participation with Author entity.
The “Material” entity is related to “Author” through “Authorship” relationship with Author_ID and Material_ID attributes as foreign key constraints in Authorship table.
The “Material” entity is related to the “Catalog” entity through the “Catalog_ID” attribute, establishing a link between individual materials and their catalog entries.
The “Material” entity is related to the “Genre” entity through the “Genre_ID” attribute, associating materials with their respective genres.
The “Borrow” entity is related to the “Material” entity through the “Material_ID” attribute, representing the borrowing activity of library materials by members.
