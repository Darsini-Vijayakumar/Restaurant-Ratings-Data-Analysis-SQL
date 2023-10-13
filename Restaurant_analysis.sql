--SELECT * FROM `sustained-node-382818.Restaurants.Restaurants` LIMIT 5;
--SELECT * FROM `sustained-node-382818.Restaurants.Cuisine` LIMIT 5;
--SELECT * FROM `sustained-node-382818.Restaurants.Ratings` LIMIT 5;
--SELECT * FROM `sustained-node-382818.Restaurants.Payment` LIMIT 100;
--SELECT * FROM `sustained-node-382818.Restaurants.Parking` LIMIT 5;

--How many unique Restaurants do we have in our dataset to analyse?
SELECT count(distinct ID) FROM `sustained-node-382818.Restaurants.Restaurants` ;
--130 unique restaurants are being analysed

--Checking if all the rows are unique
SELECT COUNT(*), COUNT (DISTINCT a.ID)
FROM `sustained-node-382818.Restaurants.Restaurants` a;
-- 130, 130
-- Yes all the rows are unique

--Does all the restaurants in our dataset have ratings ?
select count (distinct a.ID),
from `sustained-node-382818.Restaurants.Restaurants` a
where a.ID not in
(
  select distinct b.ID
  from `sustained-node-382818.Restaurants.Ratings` b
  );
-- Yes, All restaurants have ratings

----------------------------------------------------------------------EXPLORATORY DATA ANALYSIS-----------------------------------------------------------------------------------

------------- Understanding Restaurant Features

-- Do these restaurants belong any specific type of cuisine category ?
select Cuisine, COUNT(*), ROUND( count(*) / 130 * 100, 0) AS percent
from `sustained-node-382818.Restaurants.Cuisine`
where ID in
(
  select distinct b.ID
  from `sustained-node-382818.Restaurants.Restaurants` b
)
GROUP BY 1
order by percent desc ;
--There are wide variety of cuisines from fastfoods, cakeshops to regional cuisines
--22% of restaurants served Mexican cuisine, followed by 10% of bars and 6% Fast food

--How many cuisines do each of these restaurants serve ?
SELECT total_cuisines_served, COUNT(ID) AS num_restaurants, ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM 
(
SELECT r.ID,COUNT(DISTINCT c.Cuisine) as total_cuisines_served
FROM `sustained-node-382818.Restaurants.Restaurants` r
LEFT JOIN `sustained-node-382818.Restaurants.Cuisine` c
ON r.ID = c.ID
GROUP BY r.ID
)
GROUP BY total_cuisines_served
ORDER BY total_cuisines_served ;
--62% restaurants serve only one type of cuisine followed by 10% and 2% of the restaurants with and 2 and 3 types of cuisines respectively
--we don’t have ‘cuisine’ data for 27% of the restaurants

-- Do these restaurants serve alcohol ?
select A.alcohol, count(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.Restaurants` A
group by 1;
--67% of the restaurants do not serve alcohol
--26% of restaurants serve Wine and Beer
--7% of restaurants serve full bar

-- What is ambience of these restaurants ?
SELECT A.ambience, COUNT(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.Restaurants` A
GROUP BY 1 ;
-- 93% restaurants belong to Familiar category
-- 7% restaurants belong to Quiet category

-- What is the price range of these restaurants ?
SELECT A.PRICE, COUNT(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.Restaurants` A
GROUP BY 1 ;
--35% restaurants belong to low price category
--46% restaurants belong to medium price category
--19% restaurants belong to high price category

-------------------------------- Finding Restaurants with Highest ratings 

---- Top Performers across all three rating category
SELECT A.ID, A.name, 
       ROUND(AVG(B.overall_rating), 2) AS avg_overall_rating, 
       ROUND(AVG(B.food_rating), 2) AS avg_food_rating, 
       ROUND(AVG(B.service_rating), 2) AS avg_service_rating
FROM `sustained-node-382818.Restaurants.Restaurants` A
LEFT JOIN `sustained-node-382818.Restaurants.Ratings` B
ON A.ID = B.ID 
GROUP BY 1, 2
ORDER BY avg_overall_rating DESC, avg_food_rating DESC, avg_service_rating DESC
LIMIT 10;

---- Top Restaurants with highest overall rating
--Restaurant Las Mananitas
--Michiko Restaurant Japones
--emilianos

---- Top Restaurants with highest Food rating
--Restaurant Las Mananitas
--Michiko Restaurant Japones
--Giovannis
--La Estrella de Dimas

---- Top Restaurants with highest service rating
--Restaurant Las Mananitas
--Michiko Restaurant Japones
--emilianos
--Giovannis
--La Estrella de Dimas

------------------------------- Ratings | Depp Dive

--- I’m bucketing the restaurants into ‘Excellent’, ‘Good’, ‘Bad’ categories based on their ratings to perform deep dive analysis
CREATE OR REPLACE VIEW `sustained-node-382818.Restaurants.buckets` AS
WITH RATINGS AS
(
  SELECT A.*, /*C.Cuisine,*/
       ROUND(AVG(B.overall_rating), 2) AS avg_overall_rating, 
       ROUND(AVG(B.food_rating), 2) AS avg_food_rating, 
       ROUND(AVG(B.service_rating), 2) AS avg_service_rating
  FROM `sustained-node-382818.Restaurants.Restaurants` A
  LEFT JOIN `sustained-node-382818.Restaurants.Ratings` B ON A.ID = B.ID 
  --LEFT JOIN  `sustained-node-382818.Restaurants.Cuisine` C ON A.ID = C.ID
  GROUP BY 1,2,3,4,5,6,7,8,9,10
)

SELECT R.*, 
  CASE
    WHEN ROUND(AVG(R.avg_overall_rating), 2) <= 1 THEN 'BAD'
    WHEN ROUND(AVG(R.avg_overall_rating), 2) > 1 AND ROUND(AVG(R.avg_overall_rating), 2)  <= 1.5 THEN 'GOOD'
    WHEN ROUND(AVG(R.avg_overall_rating), 2) > 1.5 AND ROUND(AVG(R.avg_overall_rating), 2) <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS bucket,
  CASE
    WHEN ROUND(AVG(R.avg_food_rating), 2)  <= 1 THEN 'BAD'
    WHEN ROUND(AVG(R.avg_food_rating), 2)  > 1 AND ROUND(AVG(R.avg_food_rating), 2)  <= 1.5 THEN 'GOOD'
    WHEN ROUND(AVG(R.avg_food_rating), 2)  > 1.5 AND ROUND(AVG(R.avg_food_rating), 2)  <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS Food_bucket,
  CASE
    WHEN ROUND(AVG(R.avg_service_rating), 2)  <= 1 THEN 'BAD'
    WHEN ROUND(AVG(R.avg_service_rating), 2)  > 1 AND ROUND(AVG(R.avg_service_rating), 2)  <= 1.5 THEN 'GOOD'
    WHEN ROUND(AVG(R.avg_service_rating), 2)  > 1.5 AND ROUND(AVG(R.avg_service_rating), 2) <= 2 THEN 'EXCELLENT'
    ELSE 'NULL'
  END AS service_bucket
FROM RATINGS R
--LEFT JOIN  `sustained-node-382818.Restaurants.Cuisine` C ON R.ID = C.ID
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13;

-- Viewing the Combined Table
SELECT * FROM `sustained-node-382818.Restaurants.buckets` LIMIT 5;


-------- Looking at the factors each restaurant have that led to Excellent and Good Overall Ratings

SELECT A. BUCKET, COUNT(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.buckets` A
GROUP BY 1;
--8% of restuarants had ratings greater than 1.5
--52% of restuarants had ratings between 1 and 1.5
--40% of restuarants had ratings less than 1

 
-- Looking at the characteristic of 60% of restaurants that belong to Excellent and Good Category

WITH bucket_counts AS (
  SELECT a.accessibility,
    -- a.price, a.ambience, a.area, a.smoking_area, a.accessibility
    COUNT(*) AS count
  FROM `sustained-node-382818.Restaurants.buckets` a
  WHERE bucket IN ('EXCELLENT', 'GOOD')
  GROUP BY 1
),
total_counts AS (
  SELECT COUNT(*) AS total_count
  FROM `sustained-node-382818.Restaurants.buckets` 
  WHERE bucket IN ('EXCELLENT', 'GOOD')
)
SELECT  b.accessibility,
  -- b.price, b.ambience, b.area, b.smoking_area, b.accessibility
  b.count,
  ROUND(b.count / t.total_count * 100, 0) AS percent
FROM bucket_counts b
JOIN total_counts t
ON 1 = 1
ORDER BY percent DESC;


--53% of restaurants in Excellent and Good category were mid priced restaurants followed by 28% low priced restaurants and 19% high price restaurants
--94% of restaurants in Excellent and Good category had 'Familiar' ambience
--90% the restaurants were of Closed area, with excellent rated restaurants being only closed
--56% of restaurants in Excellent and Good category category had no smoking area
--63% of these Restaurants where not accessible and yet received good and excellent ratings

WITH CuisineCounts AS (
  SELECT r.ID AS RestaurantID, 
         COUNT(DISTINCT c.cuisine) AS CuisineCount
  FROM `sustained-node-382818.Restaurants.buckets` r
  LEFT JOIN `sustained-node-382818.Restaurants.Cuisine` c ON r.ID = c.ID
  WHERE bucket IN ('EXCELLENT', 'GOOD')
  GROUP BY r.ID
)

SELECT CuisineCount, count(distinct RestaurantID), ROUND(100 * COUNT(distinct RestaurantID) / SUM(COUNT(distinct RestaurantID)) OVER (), 0) AS percent
FROM CuisineCounts
group by 1;
--62% of restaurants served only one cuisine and only 13% had more than one type of cuisine

-------- Looking at the factors each restaurant have that led to Excellent and Good Food Ratings
SELECT A. FOOD_BUCKET, COUNT(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.buckets` A
GROUP BY 1;
--8% of restuarants had ratings greater than 1.5
--57% of restuarants had ratings between 1 and 1.5
--35% of restuarants had ratings less than 1

 
-- Looking at the characteristic of 65% of restaurants that belong to Excellent and Good Category

WITH bucket_counts AS (
  SELECT a.smoking_area,
     -- a.alcohol, a.smoking_area
    COUNT(*) AS count
  FROM `sustained-node-382818.Restaurants.buckets` a
  WHERE food_bucket IN ('EXCELLENT', 'GOOD')
  GROUP BY 1
),
total_counts AS (
  SELECT COUNT(*) AS total_count
  FROM `sustained-node-382818.Restaurants.buckets` 
  WHERE food_bucket IN ('EXCELLENT', 'GOOD')
)
SELECT  b.smoking_area,
   -- b.alcohol, b.smoking_area
  b.count,
  ROUND(b.count / t.total_count * 100, 0) AS percent
FROM bucket_counts b
JOIN total_counts t
ON 1 = 1
ORDER BY percent DESC;

--66% of restaurants in Excellent and Good category didnt not serve alcohol, while 28% had wine-beer and only 6% had Full_Bar
--71% of restaurants in Excellent and Good category category had no smoking area or were not permitted

WITH CuisineCounts AS (
  SELECT r.ID AS RestaurantID, 
         COUNT(DISTINCT c.cuisine) AS CuisineCount
  FROM `sustained-node-382818.Restaurants.buckets` r
  LEFT JOIN `sustained-node-382818.Restaurants.Cuisine` c ON r.ID = c.ID
  WHERE food_bucket IN ('EXCELLENT', 'GOOD')
  GROUP BY r.ID
)

SELECT CuisineCount, count(distinct RestaurantID), ROUND(100 * COUNT(distinct RestaurantID) / SUM(COUNT(distinct RestaurantID)) OVER (), 0) AS percent
FROM CuisineCounts
group by 1;
--65% of restaurants served only one cuisine and only 10% had more than one type of cuisine

-------- Looking at the factors each restaurant have that led to Bad Service Ratings
SELECT A. SERVICE_BUCKET, COUNT(*), ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 0) AS percent
FROM `sustained-node-382818.Restaurants.buckets` A
GROUP BY 1;
--6% of restuarants had ratings greater than 1.5
--32% of restuarants had ratings between 1 and 1.5
--62% of restuarants had ratings less than 1

 
-- Looking at the characteristic of 62% of restaurants that belong to Bad Category

WITH bucket_counts AS (
  SELECT a.other_services,
    COUNT(*) AS count
  FROM `sustained-node-382818.Restaurants.buckets` a
  WHERE service_bucket IN ('BAD')
  GROUP BY 1
),
total_counts AS (
  SELECT COUNT(*) AS total_count
  FROM `sustained-node-382818.Restaurants.buckets` 
  WHERE service_bucket IN ('BAD')
)
SELECT  b.other_services,
  b.count,
  ROUND(b.count / t.total_count * 100, 0) AS percent
FROM bucket_counts b
JOIN total_counts t
ON 1 = 1
ORDER BY percent DESC;

--95% of restaurants in Bad category did not have any other special services like Internet

--- Payment Type available
WITH PaymentCounts AS (
  SELECT r.ID AS RestaurantID, 
         COUNT(DISTINCT p.Payment_method) AS PaymentCount
  FROM `sustained-node-382818.Restaurants.buckets` r
  LEFT JOIN `sustained-node-382818.Restaurants.Payment` p ON r.ID = p.ID
  WHERE service_bucket IN ('BAD')
  GROUP BY r.ID
)

SELECT PaymentCount, count(distinct RestaurantID), ROUND(100 * COUNT(distinct RestaurantID) / SUM(COUNT(distinct RestaurantID)) OVER (), 0) AS percent
FROM PaymentCounts
group by 1;
--49% of restaurants had only one payment method and 37% had more than one payment types

----------------------------------------------------Identifying Correlation between ratings, cuisines and number of payment method available---------------------------------------

WITH CuisineCounts AS (
  SELECT r.ID AS RestaurantID, r.avg_overall_rating, r.avg_food_rating,
         COUNT(DISTINCT c.cuisine) AS CuisineCount
  FROM `sustained-node-382818.Restaurants.buckets` r
  LEFT JOIN `sustained-node-382818.Restaurants.Cuisine` c ON r.ID = c.ID
  GROUP BY 1,2,3
)

SELECT
  CORR(CuisineCount, avg_overall_rating) AS correlation_cuisine_overall_rating,
  CORR(CuisineCount, avg_food_rating) AS correlation_cuisine_food_rating
FROM CuisineCounts;
-- 0.1444321785667
-- 0.0569168914951

WITH PaymentCounts AS (
  SELECT r.ID AS RestaurantID, r.avg_overall_rating, r.avg_service_rating,
         COUNT(DISTINCT p.Payment_method) AS PaymentCount
  FROM `sustained-node-382818.Restaurants.buckets` r
  LEFT JOIN `sustained-node-382818.Restaurants.Payment` p ON r.ID = p.ID
  GROUP BY 1,2,3
)

SELECT
  CORR(PaymentCount, avg_overall_rating) AS correlation_payment_overall_rating,
  CORR(PaymentCount, avg_service_rating) AS correlation_payment_service_rating
FROM PaymentCounts;
-- 0.196147211031
-- 0.1620013338925

----- No strong correlation
