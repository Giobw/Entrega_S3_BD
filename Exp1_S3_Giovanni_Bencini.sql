-- CASO 1: Análisis de Propiedades
SELECT 
    nro_propiedad AS "PROPIEDAD",
    direccion_propiedad AS "DIRECCION",
    TO_CHAR(valor_arriendo, '$999G999G999') AS "ARRIENDO",
    TO_CHAR(valor_gasto_comun, '$999G999G999') AS "GGCC_ACTUAL",
    TO_CHAR(ROUND(valor_gasto_comun * 1.10), '$999G999G999') AS "GGCC_AJUSTADO",
    'Propiedad ubicada en comuna ' || id_comuna AS "UBICACION"
FROM 
    propiedad
WHERE 
    valor_arriendo < &VALOR_MAXIMO
    AND nro_dormitorios IS NOT NULL
    AND id_comuna IN (82, 84, 87)
ORDER BY 
    valor_gasto_comun ASC NULLS LAST, 
    valor_arriendo DESC;
    
    
    -- CASO 2: Análisis de antigüedad de arriendo
SELECT 
    nro_propiedad AS "Propiedad",
    numrut_cli AS "Código Arrendatario",
    TO_CHAR(fecini_arriendo, 'dd.mon.yyyy') AS "Fecha Inicio Arriendo",
    NVL(TO_CHAR(fecter_arriendo, 'dd.mon.yyyy'), 'PROPIEDAD ACTUALMENTE ARRENDADA') AS "Fecha Término Arriendo",
    TO_CHAR(TRUNC(NVL(fecter_arriendo, SYSDATE) - fecini_arriendo), '999G999') AS "Días Arriendo",
    ROUND((NVL(fecter_arriendo, SYSDATE) - fecini_arriendo) / 365) AS "Años Arriendo",
    CASE 
        WHEN ROUND((NVL(fecter_arriendo, SYSDATE) - fecini_arriendo) / 365) >= 10 THEN 'COMPROMISO DE VENTA'
        WHEN ROUND((NVL(fecter_arriendo, SYSDATE) - fecini_arriendo) / 365) BETWEEN 5 AND 9 THEN 'CLIENTE ANTIGUO'
        ELSE 'CLIENTE NUEVO'
    END AS "Clasificación Estado"
FROM 
    arriendo_propiedad
WHERE 
    TRUNC(NVL(fecter_arriendo, SYSDATE) - fecini_arriendo) > &DIAS_MINIMOS
ORDER BY 
    TRUNC(NVL(fecter_arriendo, SYSDATE) - fecini_arriendo) DESC;
    
    
    -- CASO 3: Arriendo Promedio por Tipo de Propiedad
SELECT 
    id_tipo_propiedad AS "TIPO PROPIEDAD",
    CASE id_tipo_propiedad
        WHEN 'A' THEN 'Casa'
        WHEN 'B' THEN 'Departamento'
        WHEN 'C' THEN 'Local'
        WHEN 'D' THEN 'Parcela sin casa'
        WHEN 'E' THEN 'Parcela con casa'
    END AS "DESCRIPCION",
    TO_CHAR(ROUND(AVG(valor_gasto_comun)), '$999G999G999') AS "PROMEDIO GASTO COMUN",
    COUNT(nro_propiedad) AS "CANTIDAD PROPIEDADES",
    TO_CHAR(ROUND(AVG(valor_arriendo)), '$999G999G999') AS "PROMEDIO VALOR ARRIENDO"
FROM 
    propiedad
GROUP BY 
    id_tipo_propiedad,
    CASE id_tipo_propiedad
        WHEN 'A' THEN 'Casa'
        WHEN 'B' THEN 'Departamento'
        WHEN 'C' THEN 'Local'
        WHEN 'D' THEN 'Parcela sin casa'
        WHEN 'E' THEN 'Parcela con casa'
    END
HAVING 
    AVG(valor_arriendo) > &ARRIENDO_PROMEDIO_MINIMO
ORDER BY 
    id_tipo_propiedad ASC, 
    AVG(valor_arriendo) DESC;