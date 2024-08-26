-- Exploratory Data Analysis
use world_layoffs;
Select * from layoffs_staging2;

-- Maximum layoff in one day
Select max(total_laid_off) from layoffs_staging2;
select * from layoffs_staging2 where total_laid_off=(Select max(total_laid_off) from layoffs_staging2);

-- Maximum percentage layoff in one day
select max(percentage_laid_off) from layoffs_staging2;
-- 1 means 100% , i.e. all the employees were laid off. Let's look at the company name.
select * from layoffs_staging2 where percentage_laid_off=(select max(percentage_laid_off) from layoffs_staging2);

select * from layoffs_staging2 where percentage_laid_off=(select max(percentage_laid_off) from layoffs_staging2)
order by total_laid_off desc;
select * from layoffs_staging2 where percentage_laid_off=(select max(percentage_laid_off) from layoffs_staging2)
order by funds_raised_millions desc;

-- Let's look at the total_laid_off by each company

select company,sum(total_laid_off) from layoffs_staging2 
group by company
order by 2 desc;

-- Let's see the time range of this data,i.e. the starting date and the last date.

select min(`date`),max(`date`) from layoffs_staging2; 

-- Let's look at the total_laid_off by each industry

select industry,sum(total_laid_off) from layoffs_staging2 
group by industry
order by 2 desc;

-- Let's look after layoffs in each country

select country,sum(total_laid_off) from layoffs_staging2 
group by country
order by 2 desc;

-- Let's look at the loyoffs by year

select year(`date`),sum(total_laid_off) from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- most number of layoffs took place in 2022 .
-- Although we have data of only three months in 2023 , so 2023 is going to be a wild one.

-- Let's look at the layoffs by stage of company.
select stage,sum(total_laid_off) from layoffs_staging2 
group by stage
order by 2 desc;

-- let's analyze the data by percentage laid off.

select company,round(avg(percentage_laid_off),2) from layoffs_staging2 
group by company
order by 2 desc;

-- let's calculate the rolling total layoffs per month

with rolling_total as (select substring(`date`,1,7) as 'month' , sum(total_laid_off) as 'total_off' from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc)

select `month`,total_off, sum(total_off) over(order by `month` asc) as 'rolling_total' 
from rolling_total;

-- let's take a look at how much each company is laying off per year

select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by company;

-- let's rank the companies on the basis of most number of layoffs in each year

with company_year (company,`year`,total_laid_off) as (
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)),

company_year_rank as(
select * , dense_rank() over(partition by `year` order by total_laid_off desc) as ranking 
from company_year 
where `year` is not null
order by ranking asc)

select * from company_year_rank
where ranking<=5;






