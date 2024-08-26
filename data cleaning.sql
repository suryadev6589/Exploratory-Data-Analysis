-- Data Cleaning
use world_layoffs;
select * from layoffs;

-- Project :
-- 1.Drop duplicates
--  2. Standardize the data
-- 3. Null values/ blank values
-- 4. Remove columns not needed

create table layoffs_staging like layoffs;
select * from layoffs_staging;
Insert layoffs_staging select * from layoffs;
select * from layoffs_staging;

-- Removing Duplicates
with duplicates_cte as(
select *, row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging)
select * from duplicates_cte where row_num>1;

-- Deleting duplicates is not possible directly beacause we can't delete/update in CTE
-- so we will create another table same as this cte and then delete duplicates from that table

create table layoffs_staging2 like layoffs_staging ;
alter table layoffs_staging2 add column row_num integer;
select * from layoffs_staging2;
insert into layoffs_staging2
select *, row_number() over (
partition by company, location, industry, total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

delete from layoffs_staging2 where row_num>1;
select * from layoffs_staging2;


-- standardizing data

select company,trim(company) from layoffs_staging2;
update layoffs_staging2 set company=trim(company);

select distinct(industry) from layoffs_staging2;

select * from layoffs_staging2 where industry like 'Crypto%';
update layoffs_staging2 set industry='Crypto' where industry like 'Crypto%';

select distinct country from layoffs_staging2;

select distinct country, trim(trailing '.' from country) from layoffs_staging2;
update layoffs_staging2 set country=trim(trailing '.' from country) where country like 'United States%';

-- the date column in this table is of type text we have to typecast it in date type. 
-- to do this typecasting , we first need to change string to standard date format.

select `date`, str_to_date(`date`,'%m/%d/%Y') from layoffs_staging2;
update layoffs_staging2 set `date`= str_to_date(`date`,'%m/%d/%Y');

-- now we can change the type of date columnn

alter table layoffs_staging2 modify column `date` date;
select distinct industry from layoffs_staging2;
update layoffs_staging2 set industry = null where industry='';

select * from layoffs_staging2 where industry is null;

-- we are trying populate industry of each company

select t1.industry,t2.industry from layoffs_staging2 t1 join layoffs_staging2 t2 on t1.company=t2.company and t1.location=t2.location 
where t1.industry is null  and t2.industry is not null;

update layoffs_staging2 t1 join layoffs_staging2 t2 on t1.company=t2.company and t1.location=t2.location 
set t1.industry=t2.industry
where t1.industry is null  and t2.industry is not null;

select * from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null ;

delete from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null;

select  * from layoffs_staging2;

-- now most of the null values has been tackled. So , now we will drop the column row_num which is no longer needed

Alter table layoffs_staging2 drop column row_num;

select  * from layoffs_staging2;

-- Now this is a clean data on which we can do EDA.



