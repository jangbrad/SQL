--Cleaning Data in SQL

SELECT *
FROM PorfolioProject.dbo.NashvilleHousing


--Standardize Date Format

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date

UPDATE PorfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PorfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data given ParcelID refers to the same PropertyAddress

SELECT *
FROM PorfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject.dbo.NashvilleHousing a 
JOIN PorfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


----------------------------------------------------------------------------------------------------------------------
--Break out PropertyAddress into individual columns (address, city)

SELECT PropertyAddress
FROM PorfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE PorfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE PorfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


----------------------------------------------------------------------------------------------------------------------
--Break out OwnerAddress into individual columns (address, city, state)

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PorfolioProject.dbo.NashvilleHousing;


ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PorfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PorfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PorfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


----------------------------------------------------------------------------------------------------------------------
--There are "Yes", "No", "Y", "N" in the SoldAsVacant column. Change "Y" and "N" to "Yes" and "No"

SELECT DISTINCT SoldAsVacant
FROM PorfolioProject.dbo.NashvilleHousing

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PorfolioProject.dbo.NashvilleHousing

UPDATE PorfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


----------------------------------------------------------------------------------------------------------------------
--Remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PorfolioProject.dbo.NashvilleHousing
)
DELETE  
FROM RowNumCTE
WHERE row_num >1


----------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM PorfolioProject.dbo.NashvilleHousing
