/* cleaning data in SQL */
select *
from nashvillehousing;


--standardize date format
select saledateconverted,CONVERT(date,SaleDate)
from nashvillehousing

update nashvillehousing
set SaleDate=CONVERT(date,SaleDate);

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted=CONVERT(date,saledateconverted);

--populate property address data
select *
from [nashvillehousing ]
--where PropertyAddress is null
order by ParcelID 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [nashvillehousing ] a
join [nashvillehousing ] b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <>b.UniqueID
where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [nashvillehousing ] a
join [nashvillehousing ] b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <>b.UniqueID
where a.PropertyAddress IS NULL


--breaking out address into individual columns (address,city,state)
select PropertyAddress
from [nashvillehousing ]

select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',' ,PropertyAddress)-1) as Address,
 SUBSTRING (PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1,LEN(PropertyAddress)) as Address
from [nashvillehousing ]


alter table nashvillehousing
add PropertySplitAddress Nvarchar(255);

update nashvillehousing
set PropertySplitAddress=SUBSTRING (PropertyAddress,1,CHARINDEX(',' ,PropertyAddress)-1) ;

alter table nashvillehousing
add PropertySplitCity Nvarchar(255);

update nashvillehousing
set PropertySplitCity=SUBSTRING (PropertyAddress,CHARINDEX(',' ,PropertyAddress)+1,LEN(PropertyAddress));

SELECT *
from [nashvillehousing ]

select OwnerAddress
from [nashvillehousing ]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [nashvillehousing ]

alter table nashvillehousing
add OwnerSplitAddress Nvarchar(255);

update nashvillehousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity Nvarchar(255);

update nashvillehousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState Nvarchar(255);

update nashvillehousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
from [nashvillehousing ]


--Change Y and N to Yes and No in Sold AS vacant column

SELECT DISTINCT SoldAsVacant,COUNT(SoldAsVacant)
FROM [nashvillehousing ]
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM [nashvillehousing ]

UPDATE [nashvillehousing ]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END



--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY
			     UniqueID
				 ) row_num
FROM [nashvillehousing ]
)
SELECT * 
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress


SELECT *
FROM [nashvillehousing ]


--Delete unused columns


SELECT *
FROM [nashvillehousing ]

ALTER TABLE [nashvillehousing ]
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress