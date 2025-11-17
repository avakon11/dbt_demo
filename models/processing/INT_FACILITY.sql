{{ config(materialized='incremental', unique_key='"J_BACI"', schema='dev_marts', alias='DEMO_FACILITIES_SCD_2') }}
WITH AMT AS (
   SELECT "J_BACI", "ORIGINAL" FROM {{ ref('INT_ORIGINAL') }}
)
SELECT
   FACILITY."J_BACI" AS "J_BACI",
   COALESCE(CAMS."J_BABI", FACILITY."J_BABI") AS "J_BABI",
   FACILITY."J_BAGT",
   MISC."J_BAEC",
   MISC."J_BAYC",
   MISC."J_BCGL",
   'EUR' AS "J_BAZC",
   CASE
       WHEN SYXM."J_SGMC" = 'M' THEN FACILITY."J_CRI_" * SYXM."J_SGLP"
       ELSE FACILITY."J_CRI_" / SYXM."J_SGLP"
   END
   - CASE
       WHEN SYXM."J_SGMC" = 'M' THEN FACILITY."J_BBW_" * SYXM."J_SGLP"
       ELSE FACILITY."J_BBW_" / SYXM."J_SGLP"
   END
   - COALESCE(
       CASE
           WHEN SYXM."J_SGMC" = 'M' THEN SUM(ADALM."J_BGA_" * SYXM."J_SGLP")
           ELSE SUM(ADALM."J_BGA_" / SYXM."J_SGLP")
       END,
       0.00
   ) AS "ORIGINAL",
   FACILITY."J_CRDC",
   MISC."J_BCDL"
FROM {{ source('staging', 'J_ADWB') }} BINDER
JOIN {{ source('staging', 'J_ADWC') }} CHAPTER
   ON CHAPTER."J_IZXI" = BINDER."J_ICWI"
JOIN {{ source('staging', 'J_ADAMS') }} FACILITY
   ON FACILITY."J_IPPI" = CHAPTER."J_IZYI"
JOIN {{ source('staging', 'J_ADAMI') }} MISC
   ON FACILITY."J_IPPI" = MISC."J_IPPI"
LEFT JOIN {{ source('staging', 'J_CAMS') }} CAMS
   ON CAMS."J_BACI" = FACILITY."J_BACI"
LEFT JOIN (
   SELECT
       ADALM."J_BFCI",
       ADALM."J_CQJC",
       ADWP."J_IDNT",
       ADWP."J_IDOC",
       ADWP."J_KGCC",
       ADALM."J_BGA_"
   FROM {{ source('staging', 'J_ADALM') }} ADALM
   JOIN {{ source('staging', 'J_ADWP') }} ADWP
       ON ADALM."J_IPNI" = ADWP."J_IDII"
   WHERE ADWP."J_KGCC" = '0'
     AND ADALM."J_CQJC" = '900'
) ADALM
   ON ADALM."J_BFCI" = FACILITY."J_BACI"
JOIN {{ source('staging', 'J_SYXM') }} SYXM
   ON FACILITY."J_BAZC" = SYXM."J_SGIC"
  AND SYXM."J_ICKC" = 'EUR'
  AND SYXM."J_ICJC" = 'NETHERLAND'
WHERE BINDER."J_ICYC" NOT IN ('5', '6')
 AND CHAPTER."J_IZZC" = 'CA'
 AND BINDER."J_IWGI" <> 'TEMPLATEE'
 AND BINDER."ADACDL" = 'N'
 AND CHAPTER."J_KUTC" <> '1'
 AND FACILITY."J_BACI" <> ''
 AND MISC."J_BAEC" <> 'GR'
GROUP BY
   FACILITY."J_BACI",
   CAMS."J_BABI",
   FACILITY."J_BABI",
   FACILITY."J_BAGT",
   MISC."J_BAEC",
   MISC."J_BAYC",
   MISC."J_BCGL",
   FACILITY."J_CRI_",
   FACILITY."J_BBW_",
   FACILITY."J_CRDC",
   SYXM."J_SGMC",
   SYXM."J_SGLP",
   MISC."J_BCDL"
UNION ALL
SELECT
   CAMS."J_BACI" AS "J_BACI",
   CAMS."J_BABI" AS "J_BABI",
   CAMS."J_BAGT",
   CAMI."J_BAEC",
   CAMI."J_BAYC",
   CAMI."J_BCGL",
   'EUR' AS "J_BAZC",
   AMT."ORIGINAL" AS "ORIGINAL",
   CAMS."J_CRDC",
   CAMI."J_BCDL"
FROM {{ source('staging', 'J_CAMS') }} CAMS
JOIN {{ source('staging', 'J_CAMI') }} CAMI
   ON CAMS."J_BACI" = CAMI."J_BACI"
JOIN AMT
   ON AMT."J_BACI" = CAMS."J_BACI"
WHERE CAMI."J_BCAC" <> 'B'
 AND CAMI."J_BAEC" NOT IN ('GR', 'WO')