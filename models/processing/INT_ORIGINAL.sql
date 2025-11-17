{{ config(materialized='ephemeral') }}
SELECT
   CAMS."J_BACI",
   CASE
       WHEN SYXM."J_SGMC" = 'M'
           THEN CAMS."J_BBQ_" * SYXM."J_SGLP"
       ELSE
           CAMS."J_BBQ_" / SYXM."J_SGLP"
   END AS "ORIGINAL"
FROM {{ source('staging', 'J_CAMS') }} CAMS
JOIN {{ source('staging', 'J_CAMI') }} CAMI
   ON CAMI."J_BACI" = CAMS."J_BACI"
LEFT JOIN {{ source('staging', 'J_SYXM') }} SYXM
   ON CAMS."J_BAZC" = SYXM."J_SGIC"
   AND SYXM."J_ICKC" = 'EUR'
   AND SYXM."J_ICJC" = 'NETHERLAND'   
WHERE CAMI."J_BCAC" <> 'B'