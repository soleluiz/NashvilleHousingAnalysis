-- Cleaning Data in SQL Queries 

Select * 
From PortfolioProject..NashvilleHousing


-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing 
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;


-- Populate Property Address data

Select *
FROM PortfolioProject..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
     And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL     

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
     And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL     


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
-- Where PropertyAddress is null
-- order by ParcelID

HARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address2
FROM PortfolioProject..NashvilleHousing;

-- Add the PropertySplitAddress column to the table
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(100);

-- Update the PropertySplitAddress with the part before the comma
UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Update the PropertySplitAddress with the part after the comma
UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- Add the columns for owner's split address, city, and state
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(100),
    OwnerSplitCity NVARCHAR(100),
    OwnerSplitState NVARCHAR(100);

-- Update the owner's split address, city, and state using PARSENAME
UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(100);

UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(100);

UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(100);

UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


-- Change Y an N to YES and No in "Sold as Vacant" fiedl

Select Distinct(SoldasVacant), Count(SoldasVacant)
From PortfolioProject..NashvilleHousing
Group by Soldasvacant 
Order by 2 

Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant 
       END
From PortfolioProject..NashvilleHousing              


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
       Else SoldAsVacant 
       END   


 -- Remove Duplicates 

WITH ROWNumCTE As(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SaleDate,
                     SalePrice,
                     LegalReference
        ORDER BY 
        UniqueID
    ) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
Select * 
From ROWNumCTE
Where row_num > 1 
Order by PropertyAddress


-- Delete Unused Columns 

Select * 
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate 