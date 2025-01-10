DELIMITER //

CREATE PROCEDURE sp_GetProducts(
    IN BrandID INT,
    IN MinPrice DECIMAL(10, 2),
    IN MaxPrice DECIMAL(10, 2),
    IN ProductName VARCHAR(40),
    IN PageSize INT,
    IN PageNumber INT,
    IN SortColumn VARCHAR(128),
    IN SortDirection BOOLEAN
)
BEGIN
    IF SortColumn NOT IN ('product_id', 'product_name', 'list_price', 'brand_id') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid value for SortColumn';
    END IF;

    SET @Offset = (PageNumber - 1) * PageSize;
    SET @SortQuery = CONCAT(
            'ORDER BY ', SortColumn, ' ', IF(SortDirection = 0, 'ASC', 'DESC'), ' '
                     );

    SET @Query = CONCAT(
            'SELECT p.product_id, p.product_name, p.list_price, b.brand_name ',
            'FROM product p ',
            'JOIN brand b ON p.brand_id = b.brand_id ',
            'WHERE (', BrandID IS NULL, ' OR p.brand_id = ', IFNULL(BrandID, 'NULL'), ') ',
            'AND (', MinPrice IS NULL, ' OR p.list_price >= ', IFNULL(MinPrice, 'NULL'), ') ',
            'AND (', MaxPrice IS NULL, ' OR p.list_price <= ', IFNULL(MaxPrice, 'NULL'), ') ',
            'AND (', ProductName IS NULL, ' OR p.product_name LIKE ', IFNULL(CONCAT("'", ProductName, "%'"), 'NULL'), ') ',
            @SortQuery,
            'LIMIT ', PageSize, ' OFFSET ', @Offset
                 );

    PREPARE stmt FROM @Query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;