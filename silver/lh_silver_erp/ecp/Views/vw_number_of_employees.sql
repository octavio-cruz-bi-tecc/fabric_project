-- Auto Generated (Do not modify) 3DDAAA682EB88B6D8F732224D42CB7B96A5D7569955F51D013786E4E416BC62A
create view ecp.vw_number_of_employees as 
SELECT 
  storage_location_id AS company_address, 
  CAST( (CURRENT_TIMESTAMP AT TIME ZONE 'UTC') AT TIME ZONE 'Central Standard Time (Mexico)' AS date ) AS date,
  --CAST(CURRENT_TIMESTAMP AS DATE) AS date_reg, 
  YEAR(CURRENT_TIMESTAMP) AS anio, 
  MONTH(CURRENT_TIMESTAMP) AS mes, 
  COUNT(*) AS total
FROM ecp.employees
WHERE 
  UPPER(status) = 'AC'
  AND NOT (
    UPPER(storage_location_id) = 'SCS' 
    AND UPPER(segment_id) = 'SCM'
  )
GROUP BY storage_location_id;