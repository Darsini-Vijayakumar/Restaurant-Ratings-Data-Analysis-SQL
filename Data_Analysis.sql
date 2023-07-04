--The objective of this analysis is to find the factors that influences ratings of the restaurants and understand if there are any correlation between the ratings and other attributes

--This project is divided in two parts

--Exploration & Data analysis : Used the data to find the characteristics of Restaurants with high ratings and then provided insights and answered key questions based on the findings


-- Importing the data

select * from `sustained-node-382818.SQL.Restaurants` limit 5;
select * from `sustained-node-382818.SQL.Cuisine` limit 5;
select * from `sustained-node-382818.SQL.Parking` limit 5;
select * from `sustained-node-382818.SQL.Payment` limit 5;
select * from `sustained-node-382818.SQL.Ratings` limit 5;
select * from `sustained-node-382818.SQL.Hours` limit 5;

-- I wanted to analyse if the number of payment methods available at the Restaurants affects the ratings hence creating column ‘Payment_types’ that provides the number of number of payment methods available at the Restaurants

-- Payments Table

CREATE VIEW `sustained-node-382818.SQL.Payment_types` AS
SELECT
  ID,
  MAX(CASE WHEN rn = 1 THEN Payment_method END) AS Pay_Type1,
  MAX(CASE WHEN rn = 2 THEN Payment_method END) AS Pay_Type2,
  MAX(CASE WHEN rn = 3 THEN Payment_method END) AS Pay_Type3,
  MAX(CASE WHEN rn = 4 THEN Payment_method END) AS Pay_Type4,
  MAX(CASE WHEN rn = 5 THEN Payment_method END) AS Pay_Type5,
  MAX(CASE WHEN rn = 6 THEN Payment_method END) AS Pay_Type6,
  MAX(CASE WHEN rn = 7 THEN Payment_method END) AS Pay_Type7,
  MAX(CASE WHEN rn = 8 THEN Payment_method END) AS Pay_Type8,
  Max(rn) as Payment_types
FROM (
  SELECT
    ID,
    Payment_method,
    ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Payment_method) AS rn
  FROM `sustained-node-382818.SQL.Payment`
) t
GROUP BY ID;

--QC
select * from `sustained-node-382818.SQL.Payment_types` limit 5;

--Similarly I wanted to analyse if the number of cuisines available at the Restaurants affects the ratings hence creating column ‘Number_of_cuisine’ that provides the number of number of cuisines available at the Restaurants

--Cuisine Table

CREATE VIEW `sustained-node-382818.SQL.Cuisine_types` AS
SELECT
  ID,
  MAX(CASE WHEN rn = 1 THEN Cuisine END) AS Cuisine_type1,
  MAX(CASE WHEN rn = 2 THEN Cuisine END) AS Cuisine_type2,
  MAX(CASE WHEN rn = 3 THEN Cuisine END) AS Cuisine_type3,
  MAX(CASE WHEN rn = 4 THEN Cuisine END) AS Cuisine_type4,
  MAX(CASE WHEN rn = 5 THEN Cuisine END) AS Cuisine_type5,
  MAX(CASE WHEN rn = 6 THEN Cuisine END) AS Cuisine_type6,
  MAX(CASE WHEN rn = 7 THEN Cuisine END) AS Cuisine_type7,
  MAX(CASE WHEN rn = 8 THEN Cuisine END) AS Cuisine_type8,
  MAX(CASE WHEN rn = 9 THEN Cuisine END) AS Cuisine_type9,
  Max(rn) as Number_of_cuisine
FROM (
  SELECT
    ID,
    Cuisine,
    ROW_NUMBER() OVER (PARTITION BY ID ORDER BY Cuisine) AS rn
  FROM `sustained-node-382818.SQL.Cuisine`
) t
GROUP BY ID;

-- QC
SELECT * FROM `sustained-node-382818.SQL.Cuisine_types` LIMIT 5;


-- Modifying Hours table to Weekday and Weekend working hours of Restaurants
CREATE OR REPLACE TABLE `sustained-node-382818.SQL.Hours` AS
SELECT ID,
    CONCAT(MIN(CASE WHEN category = 'Weekdays' THEN Open_hour END), ' - ', MAX(CASE WHEN category = 'Weekdays' THEN Close_hour END)) AS Weekday_hours,
    CONCAT(MIN(CASE WHEN category = 'Weekend' THEN Open_hour END), ' - ', MAX(CASE WHEN category = 'Weekend' THEN Close_hour END)) AS Weekend_hours
FROM `sustained-node-382818.SQL.Hours`
GROUP BY ID;


--Creating a single source of data
CREATE OR REPLACE VIEW `sustained-node-382818.SQL.Dataset` AS
WITH RESTAURANTS AS
(
select
a.ID,a.name,e.Weekday_hours,e.Weekend_hours,
b.Cuisine_type1, Cuisine_type2, Cuisine_type3, b.Number_of_cuisine,
a.price,a.alcohol, a.smoking_area, a.dress_code, a.accessibility, a.ambience, a.area, a.other_services,
d.Payment_types,
c.parking_lot
FROM `sustained-node-382818.SQL.Restaurants` a
left join `sustained-node-382818.SQL.Cuisine_types` b ON a.ID = b.ID
left join `sustained-node-382818.SQL.Parking` c ON a.ID = c.ID
left join `sustained-node-382818.SQL.Payment_types` d ON a.ID = d.ID
left join `sustained-node-382818.SQL.Hours` e ON a.ID = e.ID
order by 1,2
),

RATING AS
(
SELECT DISTINCT ID,
ROUND(AVG(overall_rating) OVER (PARTITION BY ID ORDER BY ID), 2) AS overall_rating,
ROUND(AVG(food_rating) OVER (PARTITION BY ID ORDER BY ID), 2) AS food_rating,
ROUND(AVG(service_rating) OVER (PARTITION BY ID ORDER BY ID), 2) AS service_rating
FROM `sustained-node-382818.SQL.Ratings`
)

SELECT A.*, B.OVERALL_RATING, B.FOOD_RATING, B.SERVICE_RATING
FROM RESTAURANTS A
JOIN RATING B
ON A.ID = B.ID ;

-- Viewing the Combined Table
SELECT * FROM `sustained-node-382818.SQL.Dataset` LIMIT 5;


----------------------------------------------------------------------DATA EXPLORATION-----------------------------------------------------------------------------------

--How many Restaurants do we have in our dataset to analyse?

SELECT count(distinct ID) FROM `sustained-node-382818.SQL.Dataset` ;
--130 unique restaurants are being analysed

--Checking if all the rows are unique
SELECT COUNT(*), COUNT (DISTINCT a.ID)
FROM `sustained-node-382818.SQL.Restaurants` a;
-- 130, 130
-- Yes all the rows are unique


--Does all the restaurants in our dataset have ratings ?

select count (distinct a.ID),
from `sustained-node-382818.SQL.Restaurants` a
where a.ID not in
(
  select distinct b.ID
  from `sustained-node-382818.SQL.Ratings` b
  );
-- Yes, All restaurants have ratings


-- Do these restaurants belong any specific type of cuisine category ?
select Cuisine, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
from `sustained-node-382818.SQL.Cuisine`
where ID in
(
  select distinct b.ID
  from `sustained-node-382818.SQL.Restaurants` b
)
GROUP BY 1
order by percent desc ;
--There are wide variety of cuisines from fastfoods, cakeshops to regional cuisines
--26% of restaurants served Mexican cuisine, followed by 13% bars


--How many cuisines do each of these restaurants serve ?
SELECT A.Number_of_cuisine, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
FROM `sustained-node-382818.SQL.Dataset` A
GROUP BY 1
order by percent desc ;
--62% restaurants serve only one type of cuisine followed by 10% and 2% of the restaurants with and 2 and 3 types of cuisines respectively
--we don’t have ‘cuisine’ data for 27% of the restaurants

--Do these restaurants serve alcohol ?
select A.alcohol, count(*), ROUND( count(*) / 130 * 100, 0) AS percent
from `sustained-node-382818.SQL.Dataset` A
group by 1;
--67% of the restaurants do not serve alcohol
--26% of restaurants serve Wine and Beer
--7% of restaurants serve full bar

 
--What is the price range of these restaurants ?
SELECT A.PRICE, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
FROM `sustained-node-382818.SQL.Dataset` A
GROUP BY 1
--35% restaurants belong to low price category
--46% restaurants belong to medium price category
--19% restaurants belong to high price category


--What is ambience of these restaurants ?
SELECT A.ambience, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
FROM `sustained-node-382818.SQL.Dataset` A
GROUP BY 1
-- 93% restaurants belong to Familiar category
-- 7% restaurants belong to Quiet category


-------------------------------------------------------------------------DATA ANALYSIS---------------------------------------------------------------------------------------------

--What are the restaurants with highest ratings across all three rating categories?

SELECT A.ID, A.name, A.overall_rating, A.food_rating, A.service_rating
FROM `sustained-node-382818.SQL.Dataset` A
ORDER BY A.overall_rating DESC, A.food_rating DESC, A.service_rating DESC
LIMIT 10;
-- Restaurant Las Mananitas has highest overall rating including food and service followed by Michiko Restaurant Japones, emilianos


--What are the restaurants with highest ratings in overall rating category?

SELECT A.ID, A.name, A.overall_rating
FROM `sustained-node-382818.SQL.Dataset` A
ORDER BY A.overall_rating DESC
LIMIT 5;
--Restaurant Las Mananitas has highest overall rating including food and service followed by Michiko Restaurant Japones, emilianos

 
--What are the restaurants with highest ratings in food rating category?
SELECT A.ID, A.name, A.food_rating,
FROM `sustained-node-382818.SQL.Dataset` A
ORDER BY  A.food_rating DESC
LIMIT 5;
--Interms of Food, little pizza Emilio Portes Gil, La Estrella de Dimas, Giovannis have highest rating apart from the restaurants in rating

 
--What are the restaurants with highest ratings in service rating category?

SELECT A.ID, A.name, A.service_rating,
FROM `sustained-node-382818.SQL.Dataset` A
ORDER BY  A.service_rating DESC
LIMIT 5;
--In terms of service, cafe punta del cielo, El cotorreo have highest rating apart from the restaurants in rating

--These findings showcase that, though Restaurant Las Mananitas and Michiko Restaurant Japones top performs in rating but when in comes to food and service there are other top performers

 
---------------------------------------------------------------------Data Analysis | Ratings - Deep Dive ---------------------------------------------------------------------------

--I’m bucketing the restaurants into ‘Excellent’, ‘Good’, ‘Bad’ categories based on their ratings to perform deep dive analysis
CREATE OR REPLACE VIEW `sustained-node-382818.SQL.Dataset_bucket` AS
SELECT A.*,
  CASE
    WHEN A.overall_rating <= 1 THEN 'BAD'
    WHEN A.overall_rating > 1 AND A.overall_rating <= 1.5 THEN 'GOOD'
    WHEN A.overall_rating > 1.5 AND A.overall_rating <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS bucket,
  CASE
    WHEN A.Food_rating <= 1 THEN 'BAD'
    WHEN A.Food_rating > 1 AND A.Food_rating <= 1.5 THEN 'GOOD'
    WHEN A.Food_rating > 1.5 AND A.Food_rating <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS Food_bucket,
  CASE
    WHEN A.service_rating <= 1 THEN 'BAD'
    WHEN A.service_rating > 1 AND A.service_rating <= 1.5 THEN 'GOOD'
    WHEN A.service_rating > 1.5 AND A.service_rating <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS service_bucket,
FROM `sustained-node-382818.SQL.Dataset` A ;

 

SELECT A. BUCKET, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
FROM `sustained-node-382818.SQL.Dataset_bucket` A
GROUP BY 1;
--14% of restuarants had ratings greater than 1.5
--48% of restuarants had ratings between 1 and 1.5
--38% of restuarants had ratings less than 1

 
--Is there a relationship among price, ambience, smoking area, cuisine and ratings ?

WITH counts AS (
  SELECT a.dress_code,
  -- a.price, a.Rambience, a.area, a.smoking_area, a.number_of_cuisine, a.Rcuisine1, a.dress_code
  COUNT(*) AS count
  FROM `sustained-node-382818.SQL.Dataset_bucket` a
  WHERE bucket IN ('EXCELLENT','GOOD')
  GROUP BY 1
)
SELECT c.dress_code,
-- c.price, c.Rambience, c.area, c.smoking_area, c.number_of_cuisine, c.Rcuisine1, c.dress_code
c.count, ROUND(c.count / total.total_count * 100, 0) AS percent
FROM counts c
JOIN (SELECT COUNT(*) AS total_count
      FROM `sustained-node-382818.SQL.Dataset_bucket`
      WHERE bucket IN ('EXCELLENT','GOOD')) total
ON 1=1
ORDER BY percent desc;

--52% of restaurants in Excellent and Good category were mid priced restaurants followed by 26% low priced restaurants
--95% of restaurants in Excellent and Good category had 'Familiar' ambience
--89% the restaurants were of Closed area, with excellent rated restaurants being only closed
--66% of restaurants in Excellent and Good category category had no smoking area
--59% of restaurants served only one cuisine
--For 27% of the restaurants, cuisine is not known. 15% had Mexican cuisine followed by Bar

 
-----------------------------------------------------------------------------Data Analysis | Food Ratings - Deep Dive -----------------------------------------------------------

SELECT A. FOOD_BUCKET, COUNT(*)
FROM  `sustained-node-382818.SQL.Dataset_bucket` A
GROUP BY 1;
--12% of restuarants had ratings greater than 1.5
--59% of restuarants had ratings between 1 and 1.5
--29% of restuarants had ratings less than 1


--What is the relationship among smoking area, alcohol , cuisine and Food ratings ?

WITH counts AS (
  SELECT a.cuisine_type1,
  -- a.alcohol, a.smoking_area, a.number_of_cuisine, a.Rcuisine1,
  COUNT(*) AS count
  FROM `sustained-node-382818.SQL.Dataset_bucket`a
  WHERE food_bucket IN ('EXCELLENT','GOOD')
  GROUP BY 1
)
SELECT c.cuisine_type1,
--  c.alcohol ,c.smoking_area, c.number_of_cuisine, c.Rcuisine1,
c.count, ROUND(c.count / total.total_count * 100, 0) AS percent
FROM counts c
JOIN (SELECT COUNT(*) AS total_count
      FROM `sustained-node-382818.SQL.Dataset_bucket`
      WHERE food_bucket IN ('EXCELLENT','GOOD')) total
ON 1=1;

--62% of restaurants in Excellent and Good category were 'No Alcohol served'
--52% of restaurants in Excellent and Good category didnt not have smoking area
--64% the restaurants in Excellent and Good category served only one cuisine
--For 25% of the restaurants, cusine is not known. 22% had Mexican cuisine followed by Bar

 

----------------------------------------------------------------------------Data Analysis | Service Ratings - Deep Dive ----------------------------------------------------------

SELECT A. SERVICE_BUCKET, COUNT(*)
FROM  `sustained-node-382818.SQL.Dataset_bucket` A
GROUP BY 1;
--10% of restuarants had ratings greater than 1.5
--37% of restuarants had ratings between 1 and 1.5
--53% of restuarants had ratings less than 1

 

--What is the relation among parking, payment , other services and service ratings ?

WITH counts AS (
  SELECT a.parking_lot,
  -- a.other_services, a.payment_methods, a.parking_lot1, a.parking_lot2,
  COUNT(*) AS count
  FROM `sustained-node-382818.SQL.Dataset_bucket` a
  WHERE service_bucket IN ('EXCELLENT','GOOD')
  GROUP BY 1
)
SELECT c.parking_lot,
--  c.other_services, c.payment_methods, c.parking_lot1, c.parking_lot2,
c.count, ROUND(c.count / total.total_count * 100, 0) AS percent
FROM counts c
JOIN (SELECT COUNT(*) AS total_count
      FROM `sustained-node-382818.SQL.Dataset_bucket`
      WHERE service_bucket IN ('EXCELLENT','GOOD')) total
ON 1=1;

--87% of restaurants in Excellent and Good category did not have any other services
--55% of restaurants had only one payment method whereas only 34% of restaurants in Excellent and Good category had only one payment method
--49% of restaurants in Excellent and Good category did not have any parking facility

 
----------------------------------------------------Identifying Correlation between ratings, cuisines and number of payment method available---------------------------------------

SELECT
  CORR(overall_rating, number_of_cuisine) AS corr_cuisines,
  CORR(overall_rating, Payment_types) AS corr_payment,
  CORR(food_rating, number_of_cuisine) AS corr_cuisines_food,
  CORR(service_rating, Payment_types) AS corr_payment_service
FROM  `sustained-node-382818.SQL.Dataset_bucket`;

--correlation between restaurant rating and number of cuisine served = 0.10064901223819836
--correlation between restaurant rating and number of payment method available = 0.27159236397050907
--correlation between restaurant food rating and number of cuisine served = -0.07932895719755062
--correlation between restaurant service rating and number of payment method available = 0.34756923224914443

 
--This suggests that, the number of cuisines served does not strongly influence the restaurant rating.
--There is a tendency for higher-rated restaurants to offer a greater variety of payment methods
