CREATE TABLE layoffs_staging 
(
    LIKE layoffs INCLUDING ALL
);

select * from layoffs_staging;

insert into layoffs_staging
select * from layoffs;

--to find duplicates we use row_num()
select *,
row_number() over(
partition by company,location,industry,total_laid_off,
percentage_laid_off,date,stage,country,funds_raised_millions )as row_num
from layoffs_staging;

with duplicate_cte as (
select *,
row_number() over(
partition by company,location,industry,total_laid_off,
percentage_laid_off,date,stage,country,funds_raised_millions)as row_num
from layoffs_staging
)
select * from duplicate_cte 
where row_num>1;

select * from layoffs_staging
where company='Casper'


--delete the duplicates from the table 
--can't directly be delelted from the cte

DELETE FROM layoffs_staging
WHERE ctid IN (
  SELECT ctid FROM (
    SELECT ctid,
           ROW_NUMBER() OVER (
             PARTITION BY company, location, industry, total_laid_off,
                          percentage_laid_off, date, stage, country, funds_raised_millions
             ORDER BY company
           ) AS row_num
    FROM layoffs_staging
  ) sub
  WHERE row_num > 1
);

--Standardizing data
select company,trim(company) 
from layoffs_staging;

update layoffs_staging
set company=trim(company);--removes the leading and trailing character

select distinct industry 
from layoffs_staging
order by 1;

--going to update crypto related terms into crypto
update layoffs_staging
set industry='Crypto'
where industry like 'Crypto%';

select distinct country,trim(trailing '.' from country)
from layoffs_staging
order by 1;

update layoffs_staging 
set country=trim(trailing '.' from country)
where country like 'United States%';

--it gives the standard sql format not our desired one
select date ,to_date(date,'MM/DD/YYYY')as new_date
from layoffs_staging;

update layoffs_staging
set date=to_date(date,'MM/DD/YYYY');

--chnaging the type of date column from text to date permanently
alter table layoffs_staging
alter column "date" type date 
using to_date("date",'YYYY/MM/DD');

--Handling the Null / Blank values
select * from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null;

delete from layoffs_staging
where total_laid_off is null
and percentage_laid_off is null;

select count(*) from layoffs_staging
where percentage_laid_off is null;

delete from layoffs_staging
where percentage_laid_off is null;

select count(*) from layoffs_staging;

--to check the null values percentage in the whole column
SELECT COUNT(*) FILTER (WHERE total_laid_off IS NULL)::float / COUNT(*) * 100 
AS null_percentage 
FROM layoffs;


