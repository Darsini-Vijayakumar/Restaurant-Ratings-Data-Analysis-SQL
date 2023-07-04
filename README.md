Project Overview and Insights
---------------------------------------------

**1. Project Objective**

This data consists of about 130 restaurants in Mexico and the amenities provided by them along with their customer ratings. This project is aimed to analyse the various attributes of the Restaurants and identify the factors that drives higher ratings. Through this analysis the following key questions can be answered

1. What makes an Restuarant recieve higher ratings?
2. What is the trend observed with respect to restaurant pricing/cuisine and ratings?
3. Are there any noticeable differences in ratings among restaurants with different characteristics ?
4. Is there any correlation between the ratings and other attributes ?

**2. Data Cleaning**

I started the analysis by creating a data dictionary to understand the structure of the dataset and what each attribute represents. Post that, I handled the missing values in some of the columns. I also transformed and some of the columns like cuisine, payments and hours for ease of analysis.

**3. Exploratory Data Analysis**

After establishing a good sense of each attribute, I proceeded with exploratory data analysis.

**3.1. Cuisine**

Broke down the Cuisines of the restaurants and found that the data consits of restaurants with wide variety of cuisines, from regional to continental to fastfood chains and bakeries. 26% of these restaurants offer Mexican cuisine and 62% of the restaurants offer only one type of cuisine followed by 10% and 2% of the restaurants with and 2 and 3 types of cuisines respectively. Also we don't have cuisine information for 26% of the restaurants

**3.2. Alchohol availability in Restaurants**

Analysed the 'Alcohol' serving category, to find 67% of the restaurants do not serve alcohol, 26% of restaurants serve Wine and Beer, and 7% of restaurants have full bar

**3.3. Pricing**

On similar analysis with Pricing of the restaurants, 35% restaurants belong to low price category, 46% restaurants belong to medium price category, 19% restaurants belong to high price category. Therefore, 81% of these restaurants are under the afforable price range

**3.4. Ambience**

93% restaurants belong to Familiar category, 7% restaurants belong to Quiet category

**3.5. Rating Distribution**

Our dataset consists of three ratings categories, Overall rating, Food rating and service rating each ranging from 0 to 2, with 0 being the lowest and 2 being highest. So for the ease of analysis, I bucketed the restaurants into three buckets as 'Bad' , 'Good' , 'Excellent' based on their ratings.

**4. Data Analysis**

Proceeded to analyse the restaurants in 'Excellent' and 'Good' bucket and their features.

**4.1. Overall Ratings**

15% of the restaurants fall under 'Excellent' bucket with ratings greater than 1.5, 48% of restaurants fall under 'Good' bucket with ratings between 1 and 1.5 and 38% of the restaurants fall under 'Bad' bucket with ratings less than 1

Analyzing the relationship among price, ambience, smoking area, cuisine and overall ratings led to the following findings

52% of restaurants in Excellent and Good category were mid priced restaurants followed by 26% low priced restaurants, 95% of restaurants in Excellent and Good category had 'Familiar' ambience, 89% the restaurants were of Closed area, with excellent rated restaurants being only closed, 66% of restaurants in Excellent and Good category category had no smoking area, 59% of restaurants served only one cuisine, For 27% of the restaurants, cuisine is not known. 15% had Mexican cuisine followed by Bar

**4.2. Food Ratings**

12% of the restaurants fall under 'Excellent' bucket with food ratings greater than 1.5, 59% of restaurants fall under 'Good' bucket with food ratings between 1 and 1.5 and 29% of the restaurants fall under 'Bad' bucket with food ratings less than 1. This suggest that the authencity of the cuisine or the taste influences the customer rating

Analyzing the relationship among smoking area, alcohol , cuisine and Food ratings led to the following findings

62% of restaurants in Excellent and Good category were 'No Alcohol served' , 52% of restaurants in Excellent and Good category didnt not have smoking area , 64% the restaurants in Excellent and Good category served only one cuisine , For 25% of the restaurants, cusine is not known. 22% had Mexican cuisine followed by Bar

**4.3. Service Ratings**

10% of the restaurants fall under 'Excellent' bucket with food ratings greater than 1.5, 37% of restaurants fall under 'Good' bucket with food ratings between 1 and 1.5 and 53% of the restaurants fall under 'Bad' bucket with food ratings less than 1. This suggests that a considerable 53% of restaurants have poor services that jeopardizes the customer experience

Analyzing the relation among parking, payment , other services and service ratings led to the following findings

87% of restaurants in Excellent and Good category did not have any other services, 55% of restaurants had only one payment method whereas only 34% of restaurants in Excellent and Good category had only one payment method, 49% of restaurants in Excellent and Good category did not have any parking facility

**4.4. Correlation**

Performed correlation between ratings, cuisines and number of payment method available to find patterns and the results suggests that, the number of cuisines served does not strongly influence the restaurant rating and there is a tendency for higher-rated restaurants to offer a more variety of payment methods

**5. Findings and Conclusion**
   
1. Pricing : Mid and Low priced restaurants attracted higher ratings from customers. Customers are looking for restaurants within the afforable price range for their dining experience
2. Ambience and area : 95% and 89% of Familiar ambience and closed space restaurants received higher ratings, this suggest that customer prefer comfortable, welcoming and closed type atmosphere
3. A considerable percentage 66% of restaurants in the 'Excellent' and 'Good' categories had no smoking area. This reflects the growing trend of providing smoke-free dining spaces to cater to customer preferences and health concerns.
4. Cuisine: A significant proportion 59% of restaurants with higher ratings served only one cuisine. This highlights the importance of specialization and focusing on delivering high-quality dishes within a specific culinary genre.
5. Unknown Cuisine: It is worth noting that for 27% of the restaurants, the cuisine information is not known. This suggests a need for better data collection and categorization in order to gain a comprehensive understanding of the restaurant landscape.
6. 53% of restaurants had lower service ratings, this implies that restaurants should had more services to enhance customer experience
