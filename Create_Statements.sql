Create table public."Author" (
	"Author_ID" integer NOT NULL ,
    "Name" character varying COLLATE pg_catalog."default",
    "Birth_Date" date,
    "Nationality" character varying COLLATE pg_catalog."default",
    CONSTRAINT "Author_ID" PRIMARY KEY ("Author_ID")
);

Create table public."Staff" ( 
	"Staff_ID" integer NOT NULL,
    "Name" character varying COLLATE pg_catalog."default",
    "Contact_Info" character varying COLLATE pg_catalog."default",
    "Job_Title" character varying COLLATE pg_catalog."default",
    "Hire_Date" date,
    CONSTRAINT "Staff_ID" PRIMARY KEY ("Staff_ID")

);
	
Create table public."Member" (
	"Member_ID" integer NOT NULL,
    "Name" character varying COLLATE pg_catalog."default",
    "Contact_Info" character varying COLLATE pg_catalog."default",
    "Join_Date" date,
    CONSTRAINT "Member_ID" PRIMARY KEY ("Member_ID")
);

Create table public."Genre" (
	"Genre_ID" integer NOT NULL,
    "Name" character varying COLLATE pg_catalog."default",
    "Description" character varying COLLATE pg_catalog."default",
    CONSTRAINT "Genre_ID" PRIMARY KEY ("Genre_ID")
);

Create table public."Catalog" (
	"Catalog_ID" integer NOT NULL,
    "Name" character varying COLLATE pg_catalog."default",
    "Location" character varying COLLATE pg_catalog."default",
    CONSTRAINT "Catalog_ID" PRIMARY KEY ("Catalog_ID")
);

CREATE TABLE public."Material" (
    Material_ID SERIAL PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Publication_Date DATE,
    Catalog_ID INT REFERENCES public."Catalog"("Catalog_ID"),
    Genre_ID INT REFERENCES public."Genre"("Genre_ID")
);

CREATE TABLE public."Borrow" (
    Borrow_ID SERIAL PRIMARY KEY,
    Material_ID INT REFERENCES public."Material"("material_id"),
    Member_ID INT REFERENCES public."Member"("Member_ID"),
    Staff_ID INT REFERENCES public."Staff"("Staff_ID"),
    Borrow_Date DATE,
    Due_Date DATE,
    Return_Date DATE
);

CREATE TABLE public."Authorship" (
    Authorship_ID SERIAL PRIMARY KEY,
    Author_ID INT REFERENCES public."Author"("Author_ID"),
    Material_ID INT REFERENCES public."Material"("material_id")
);
