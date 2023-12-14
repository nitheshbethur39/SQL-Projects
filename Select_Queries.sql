/*.Which materials are currently available in the library? */
Select 
a."material_id" ,
a."title"
From public."Material" as a
where a."material_id" not in (
Select b."material_id" 
from public."Borrow" as b 
where b."return_date" is null or b."return_date">CURRENT_DATE)

/*Which materials are currently overdue? Suppose today is 04/01/2023, 
and show the borrow date and due date of each material.
*/
Select  
m."material_id",
m."title",
b."borrow_date",
b."due_date"
from public."Material" as m
inner join public."Borrow" as b on b."material_id"=m."material_id"
WHERE b."due_date" < '2023-04-01' AND b."return_date" IS NULL
order by b."due_date" asc;


/*What are the top 10 most borrowed materials in the library? */
SELECT 
m."title", 
COUNT(*) AS borrow_count
FROM public."Material" m
INNER JOIN public."Borrow" b ON m."material_id" = b."material_id"
GROUP BY m."material_id"
ORDER BY borrow_count DESC
LIMIT 10;

/*How many books has the author Lucas Piki written*/
select  
COUNT(*) as number_of_books 
FROM public."Authorship" a 
WHERE "author_id" IN (
       SELECT "Author_ID" FROM public."Author" b
       WHERE b."Name"='Lucas Piki');

/*How many materials were written by two or more authors*/
SELECT 
COUNT(*) as material_count
FROM ( 
  SELECT COUNT(DISTINCT a."Author_ID")
  FROM public."Author" a
  JOIN public."Authorship" b ON a."Author_ID" = b."author_id"
  GROUP BY b."material_id"
  HAVING COUNT(DISTINCT b."author_id") > 1 
) AS subquery;

/*What are the most popular genres in the library ranked by the total number of borrowed times of each genre*/

SELECT 
g."Genre_ID",
g."Name" AS Genre_Name,
COUNT(b."borrow_id") AS Borrowed_times
FROM public."Genre" as g
LEFT JOIN public."Material" m ON g."Genre_ID" = m."genre_id"
LEFT JOIN public."Borrow"  b ON m."material_id" = b."material_id"
GROUP BY g."Genre_ID",g."Name"
ORDER BY Borrowed_times DESC;


/*How many materials had been borrowed from 09/2020-10/2020*/
Select 
count(distinct b."material_id") as Borrowed_Materials
from public."Borrow" b
where b."borrow_date" >= '2020-09-01' 
and b."borrow_date" <= '2020-10-31';


/*How do you update the “Harry Potter and the Philosopher's Stone” when it is returned on 04/01/2023*/

UPDATE public."Borrow"
SET return_date = '2023-04-01'
WHERE Material_ID=(SELECT material_id from public."Material" m WHERE m."title"='Harry Potter and the Philosopher''s Stone')
AND Return_Date IS NULL;

SELECT * from public."Borrow";
				   
/*How do you delete the member Emily Miller and all her related records from the database*/
Delete from public."Member"
where "Member"."Name"='Emily Miller'
DELETE FROM public."Borrow"
WHERE "Borrow"."Member_ID" IN (Select "Member_ID" from public."Member" 
where "Member_ID"=5);


/*Delete the member Emily Miller and all her related records from the database*/
Delete from public."Member"
where "Member"."Name"='Emily Miller'
DELETE FROM public."Borrow"
WHERE "Borrow"."Member_ID" IN (Select "Member_ID" from public."Member" 
where "Member_ID"=5);

/*Title: New book Date: 2020-08-01 Catalog: E-Books  Genre: Mystery & Thriller Author: Lucas Luke*/
INSERT INTO public."Author"(
	"Author_ID", "Name")
	VALUES (21, 'Lucas Luke');
	
Select * from public."Author"	


INSERT into public."Material" ("material_id", "title", "publication_date", "catalog_id", "genre_id")
VALUES (32, 'New book', '2020-08-01', 
		(SELECT "Catalog_ID" FROM public."Catalog" WHERE "Name" = 'E-Books'), 
		(SELECT "Genre_ID" FROM public."Genre" WHERE "Name" = 'Mystery & Thriller'));
		
SELECT * FROM public."Material"

INSERT INTO public."Authorship" (Authorship_ID, Material_ID, Author_ID)
VALUES (35, 
		(SELECT "material_id" FROM public."Material" WHERE "title" = 'New book'), 
		(SELECT "Author_ID" FROM public."Author" WHERE "Name" = 'Lucas Luke'));
SELECT * FROM public."Authorship"

--Running Select statements to verify the above
SELECT * FROM public."Author"
SELECT * FROM public."Authorship"
SELECT * FROM public."Material"


/*Calculate the average number of materials borrowed per member.*/
Select 
a."member_id" ,
a."Name" AS Member_Name,
count(b."member_id") as Borrow_count
from public."Member" a
left outer join public."Borrow" b on b."member_id"=a."member_id"
group by a."Member_ID" ,a."Name"
order by Borrow_count;


/*Alert staff about overdue materials on a daily-basis?*/
CREATE TABLE Alert_staff (
    Allert_ID SERIAL PRIMARY KEY,
    Material_ID INTEGER,
    Member_ID INTEGER,
    Staff_ID INTEGER,
    Alert_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*Creating Store Procedure to generate alert*/
CREATE OR REPLACE FUNCTION generate_overdue_alert()
RETURNS VOID AS $$
BEGIN
    INSERT INTO Alert_staff (Material_ID, Member_ID, Staff_ID)
    SELECT b."material_id",b."member_id",b."staff_id"
    FROM public."Borrow" b
    WHERE b."return_date" IS NULL AND b."due_date" < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION schedule_daily_alerts()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('alert_staff', 'generate_overdue_alert');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER daily_notification_alert
AFTER INSERT ON public."Alert_staff"
EXECUTE FUNCTION schedule_daily_notifications();

/*Automatically deactivate the membership based on the member’s overdue occurrence (>=three times). 
And reactivate the membership once the member pays the overdue fee.*/


ALTER TABLE public."Member"
ADD COLUMN membership_status BOOLEAN DEFAULT TRUE ;

CREATE TABLE public."payments" (
    payment_id SERIAL PRIMARY KEY,
    member_id INT REFERENCES public."Member"("Member_ID"),
    payment_date DATE,
    payment_amount DECIMAL(10, 2)
);

CREATE OR REPLACE FUNCTION update_membership_status() RETURNS TRIGGER AS $$
BEGIN
    -- If overdue_occurrences is greater than or equal to three, deactivate membership
    IF NEW.overdue_occurrences >= 3 THEN
        UPDATE members SET membership_status = FALSE WHERE id = NEW.id;
    END IF;

    -- If a payment is made, reactivate membership
    IF TG_TABLE_NAME = 'payments' THEN
        UPDATE members SET membership_status = TRUE WHERE id = NEW.member_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_membership_status
AFTER INSERT OR UPDATE ON public."Member"
FOR EACH ROW EXECUTE FUNCTION update_membership_status();

CREATE TRIGGER check_payment
AFTER INSERT ON public."payments"
FOR EACH ROW EXECUTE FUNCTION update_membership_status();








Select * from public."Borrow"