
CREATE DATABASE cafeteria
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
	
CREATE TABLE public.employee
(
    id serial NOT NULL,
    name character varying(200) NOT NULL,
    PRIMARY KEY (id)
);
	
CREATE TABLE public.product
(
    id serial NOT NULL,
    name character varying(200) NOT NULL,
    price integer NOT NULL,
    PRIMARY KEY (id)
);
	
CREATE TABLE public.purchase
(
    id serial NOT NULL,
    employee_id integer,
	created_at date NOT NULL DEFAULT current_date,
    PRIMARY KEY (id)
);
	
ALTER TABLE public.purchase
    ADD CONSTRAINT employee_id_fkey FOREIGN KEY (employee_id)
    REFERENCES public.employee (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX fki_employee_id_fkey
    ON public.purchase(employee_id);
	
CREATE TABLE public.purchase_has_product
(
    id serial NOT NULL,
    product_id integer,
    amount integer NOT NULL,
    purchase_price_total integer NOT NULL,
    purchase_id integer,
    PRIMARY KEY (id)
);
	
ALTER TABLE public.purchase_has_product
    ADD CONSTRAINT product_id_fkey FOREIGN KEY (product_id)
    REFERENCES public.product (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX fki_product_id_fkey
    ON public.purchase_has_product(product_id);
	
ALTER TABLE public.purchase_has_product
    ADD CONSTRAINT purchase_id_fkey FOREIGN KEY (purchase_id)
    REFERENCES public.purchase (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
CREATE INDEX fki_purchase_id_fkey
    ON public.purchase_has_product(purchase_id);
	
CREATE FUNCTION public.get_all_employees(
	)
    RETURNS SETOF employee 
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$select * from employee;$BODY$;

CREATE FUNCTION public.get_all_products(
	)
    RETURNS SETOF product 
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$select * from product;$BODY$;
	
CREATE FUNCTION public.create_purchase(
	employee_id_in integer)
    RETURNS integer
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    
AS $BODY$insert into public.purchase(employee_id)
	values (employee_id_in)
	returning purchase.id
$BODY$;

CREATE FUNCTION public.create_purchase_has_product(
	product_id_in integer,
	amount_in integer,
	purchase_id_in integer,
	purchase_price_total_in integer)
    RETURNS void
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    
AS $BODY$insert into public.purchase_has_product(product_id, amount, purchase_id, purchase_price_total)
VALUES(product_id_in, 	amount_in, 	purchase_id_in,	purchase_price_total_in);$BODY$;
	
CREATE FUNCTION public.get_debt_of_all_employees_by_month(
	month_in integer)
    RETURNS TABLE(employee_name text, debt bigint) 
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$select 
	employee.name, sum (purchase_has_product.purchase_price_total) 
	from (
	select * from purchase
	where EXTRACT(MONTH from created_at) = month_in
	) as filtered_purchases
	inner join employee
	on employee.id = filtered_purchases.employee_id
	inner join purchase_has_product
	on filtered_purchases.id = purchase_has_product.purchase_id
	where employee.id = filtered_purchases.employee_id
    group by employee.name
    order by employee.name asc
$BODY$;

CREATE FUNCTION public.get_product_amount_sold_by_month(
	month_in integer)
    RETURNS TABLE(product_name text, sum bigint) 
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    ROWS 1000
    
AS $BODY$select 
	product.name, sum (purchase_has_product.amount) 
	from (
	select * from purchase
	where EXTRACT(MONTH from created_at) = month_in
	) as filtered_purchases
	inner join purchase_has_product
    on purchase_has_product.purchase_id = filtered_purchases.id
	inner join product
	on purchase_has_product.product_id  = product.id
	group by product.name
    order by sum asc
$BODY$;

INSERT INTO public.employee(name) VALUES
('Kovács Béla'),
('Gipsz Jakab'),
('Sándor Csilla'),
('Szabó Margit'),
('Kis Jenő Dezső'),
('Molnár Piroska'),
('Tóth Ilonka'),
('Stagl Anita'),
('Csonka Ferenc'),
('Liszt Ferenc');		

INSERT INTO public.product(name, price)	VALUES
('kávé', 250),
('szendvics', 350),
('víz', 100),
('pizza', 600),
('hot-dog', 400),
('tea', 200),
('csoki', 150),
('energia ital', 200),
('pogácsa', 100),
('sör', 350);

INSERT INTO public.purchase(employee_id, created_at) VALUES
(1, '2020-02-04'),
(2, '2020-02-04'),
(3, '2020-02-06'),
(4, '2020-02-12'),
(5, '2020-02-19'),
(6, '2020-02-20'),
(7, '2020-03-04'),
(8, '2020-03-09'),
(1, '2020-03-11'),
(2, '2020-03-16'),
(3, '2020-03-21'),
(4, '2020-03-24'),
(5, '2020-04-02'),
(6, '2020-04-10'),
(7, '2020-04-10'),
(8, '2020-04-10'),
(9, '2020-04-23');

INSERT INTO public.purchase_has_product(product_id, amount, purchase_id, purchase_price_total) VALUES
(1, 1, 1, 250),
(2, 2, 2, 700),
(3, 1, 3, 100),
(4, 1, 4, 600),
(5, 1, 5, 400),
(6, 2, 6, 400),
(7, 1, 7, 150),
(8, 1, 7, 200),
(9, 1, 8, 100),
(10, 2, 8, 700),
(1, 1, 9, 250),
(2, 1, 9, 350),
(3, 1, 10, 100),
(4, 2, 11, 1200),
(5, 1, 11, 400),
(6, 1, 12, 200),
(7, 1, 13, 150),
(8, 2, 13, 400),
(9, 1, 13, 100),
(10, 1, 14, 350),
(1, 1, 14, 250),
(2, 2, 15, 700),
(3, 1, 16, 100),
(4, 1, 17, 600),
(5, 1, 17, 400);

