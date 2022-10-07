CREATE VIEW ss_moyenne_loyer_integral AS
WITH RECURSIVE
summary_stats AS
(
 SELECT 
  ROUND(AVG(s.moyenne_loyer_mensuel::numeric), 2) AS mean,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.moyenne_loyer_mensuel) AS median,
  MIN(s.moyenne_loyer_mensuel) AS min,
  MAX(s.moyenne_loyer_mensuel) AS max,
  MAX(s.moyenne_loyer_mensuel) - MIN(s.moyenne_loyer_mensuel) AS range,
  ROUND(STDDEV(s.moyenne_loyer_mensuel::numeric), 2) AS standard_deviation,
  ROUND(VARIANCE(s.moyenne_loyer_mensuel::numeric), 2) AS variance,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY s.moyenne_loyer_mensuel) AS q1,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY s.moyenne_loyer_mensuel) AS q3  

FROM 
(

SELECT sub.data_year data_year
	  ,sub.zone zone
	  ,sub.type_habitat habitat
	  ,CASE WHEN sub.nombre_pieces IS NULL THEN ROUND(sub.surface_moyenne/30) ELSE sub.nombre_pieces END nombre_pieces
	  ,CASE WHEN sub.lm IS NULL THEN 11.55 ELSE sub.lm END loyer_moyen 
      ,sub.surface_moyenne surface_moyenne
	  ,sub.moyenne_loyer_mensuel
	  ,CASE WHEN LENGTH(sub.nombre_observations)<=1 THEN 1 ELSE sub.nombre_observations::int END nombre_observations
	  
	  
FROM
(
	SELECT l.data_year
	   ,CASE WHEN l.zone LIKE '%.13%' THEN '69013' 
	   		 WHEN l.zone LIKE '%.12%' THEN '69012'
			 WHEN l.zone LIKE '%.11%' THEN '69011'
			 WHEN l.zone LIKE '%.10%' THEN '69010'
			 WHEN l.zone LIKE '%.09%' THEN '69009'
			 WHEN l.zone LIKE '%.08%' THEN '69008'
			 WHEN l.zone LIKE '%.07%' THEN '69007'
			 WHEN l.zone LIKE '%.06%' THEN '69006'
			 WHEN l.zone LIKE '%.05%' THEN '69005'
			 WHEN l.zone LIKE '%.04%' THEN '69004'
			 WHEN l.zone LIKE '%.03%' THEN '69003'
			 WHEN l.zone LIKE '%.02%' THEN '69002'
			 WHEN l.zone LIKE '%.01%' THEN '69001'
			 ELSE '69000'
			 END zone
	   ,CASE WHEN l.type_habitat IS NULL THEN 
	         	CASE WHEN l.surface_moyenne > 80 THEN 'Maison' ELSE 'Appartement' END
			 ELSE l.type_habitat END type_habitat
	   ,CASE WHEN l.nombre_pieces LIKE '%1%' THEN 1 
	   		 WHEN l.nombre_pieces LIKE '%2%' THEN 2
			 WHEN l.nombre_pieces LIKE '%3%' THEN 3
			 WHEN l.nombre_pieces LIKE '%4%' THEN 4
	         WHEN l.nombre_pieces ILIKE '%plus%' OR l.nombre_pieces ILIKE '%+%' THEN ROUND(surface_moyenne/20)
			 ELSE ROUND(surface_moyenne/50) END nombre_pieces
	   ,CASE WHEN loyer_moyen IS NULL THEN 11.55 
	   		 WHEN loyer_moyen LIKE '_,%' THEN (LEFT(loyer_moyen, 1) || '.' || RIGHT(loyer_moyen,1))::numeric
		     WHEN loyer_moyen LIKE '__,%' THEN (LEFT(loyer_moyen, 2) || '.' || RIGHT(loyer_moyen,1))::numeric END lm 
	   ,CASE WHEN l.surface_moyenne IS NULL THEN 63 ELSE l.surface_moyenne END
	   ,CASE WHEN l.moyenne_loyer_mensuel IS NULL THEN 695.5 ELSE l.moyenne_loyer_mensuel END moyenne_loyer_mensuel
	   ,CASE WHEN l.nombre_observations LIKE '%,%' THEN LEFT(l.nombre_observations, LENGTH(l.nombre_observations) - 1) 
	         ELSE l.nombre_observations END nombre_observations 
FROM public.loyer l 
) sub
) s
),
row_summary_stats AS
(
SELECT 
 'mean' AS statistic, 
 mean AS value 
  FROM summary_stats
UNION
SELECT 
 'median', 
 median 
  FROM summary_stats
UNION
SELECT 
 'minimum', 
 min 
  FROM summary_stats
UNION
SELECT 
 'maximum', 
 max 
  FROM summary_stats
UNION
SELECT 
 'range', 
 range 
  FROM summary_stats
UNION
SELECT 
 'standard deviation', 
 standard_deviation 
  FROM summary_stats
UNION
SELECT 
 'variance', 
 variance 
  FROM summary_stats
UNION
SELECT 
 'Q1', 
 q1 
  FROM summary_stats
UNION
SELECT 
 'Q3', 
 q3 
  FROM summary_stats
UNION
SELECT 
 'Interquartile range', 
 (q3 - q1) 
  FROM summary_stats
UNION
SELECT 
 'skewness', 
 ROUND(3 * (mean - median)::NUMERIC / standard_deviation, 2) AS skewness 
  FROM summary_stats
)
SELECT * 
 FROM row_summary_stats;
 
SELECT * FROM ss_moyenne_loyer_integral;
  
