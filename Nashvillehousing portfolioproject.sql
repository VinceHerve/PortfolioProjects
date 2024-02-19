--Cleaning Data in SQL
select*
from nashvillehousing

--Standardize Date Format

select saledate, CONVERT(date,saledate)as Sale_Date
from nashvillehousing

update Nashvillehousing
set SaleDate = CONVERT(date,saledate) 
-- Add a new colum to the table
Alter table nashvillehousing
add Sale_Date date;

update Nashvillehousing
set Sale_Date = CONVERT(date,saledate) 

--Populate property Address Date

select parcelid, Propertyaddress, owneraddress
from nashvillehousing
--where propertyaddress is null

-- merge propertyaddress to owneraddress to fill in the null using coalesce

select uniqueid, parcelid, coalesce(propertyaddress,owneraddress) as Property_address
from Nashvillehousing

Alter table nashvillehousing
add Property_address nvarchar (255);
update nashvillehousing
set Property_address = coalesce(propertyaddress,owneraddress)

-- merge propertyaddress to owneraddress to fill in the null using Temp table

select uniqueid,parcelid,property_address
from nashvillehousing
where property_address is null

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from nashvillehousing a join nashvillehousing b
on a.parcelid = b.parcelid
and a.[uniqueid]<>b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress= ISNULL(a.propertyaddress,b.propertyaddress)
from nashvillehousing a join nashvillehousing b
on a.parcelid = b.parcelid
and a.[uniqueid]<>b.[uniqueid]
where a.propertyaddress is null


--Breaking out Address into Individual columns(Address,city,state)

select propertyaddress
from Nashvillehousing

select
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as Home_Address 
,substring(propertyaddress,charindex(',',propertyaddress)+1 , len(propertyaddress)) as City

from nashvillehousing

-- Using PARSENAME we will divid the  address into city, state and home_address
--note that parsename only recognizes periods(.), ... (,) should be replaced by (.)

Select
--PARSENAME(replace(propertyaddress,',','.'),3),
PARSENAME(replace(propertyaddress,',','.'),2)as Home_Address,
PARSENAME(replace(propertyaddress,',','.'),1)as City
from nashvillehousing 

--change Y and N to Yes and No in "SoldAsVacant"


select distinct(SoldAsvacant),COUNT (soldasvacant)
from nashvillehousing
group by SoldAsvacant
order by 2

select soldasvacant,
case when soldasvacant ='Y' then 'Yes'
	 when SoldasVacant = 'N' then 'No'
	 else soldasvacant
	 end as Sold_as_vacant
from nashvillehousing

--Remove Duplicates
with Rownumcte as(
select*,
	ROW_NUMBER() over(
	partition by parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	order by uniqueid) as row_num

from nashvillehousing
--order by parcelid
)
delete
from rownumcte
where row_num>1

select*
from rownumcte
where ROW_NUM>1
order by propertyaddress

--Delete unused Columns

alter table nashvillehousing
drop column saledate

select*
from nashvillehousing