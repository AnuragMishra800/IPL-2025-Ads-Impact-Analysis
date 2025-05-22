
-- First creating tables for insert the data from dataset.

CREATE TABLE demographic_summary (
    income_group TEXT,
    annual_income TEXT,
    estimated_user_population TEXT,
    avg_user_population INT,
    key_characteristics TEXT
);

CREATE TABLE ipl_advertisers (
    sno INT PRIMARY KEY,
    advertiser_brand TEXT,
    category TEXT,
    brand_ambassadors TEXT,
    celebrity_influence TEXT,
    health_social_risk TEXT,
    risk_score INT
);

CREATE TABLE ipl_contracts (
    contract_type TEXT,
    partner_sponsor_name TEXT,
    amount_in_crores_2025 NUMERIC,
    total_deal_value_in_crores NUMERIC,
    contract_duration TEXT
);

CREATE TABLE revenue_demography (
    company TEXT,
    sector TEXT,
    parent TEXT,
    latest_annual_revenue TEXT, 
    annual_revenue_crores NUMERIC,
    revenue_notes TEXT,
    income_group TEXT,
    urban_population TEXT,
    demographic_notes TEXT
);

SELECT * FROM demographic_summary;
SELECT * FROM ipl_advertisers;
SELECT * FROM ipl_contracts;
SELECT * FROM revenue_demography;

-- 1. Total IPL Central Revenue (2025) & % Contribution.
SELECT 
    partner_sponsor_name,
    amount_in_crores_2025,
    ROUND(amount_in_crores_2025 * 100.0 / SUM(amount_in_crores_2025) OVER (), 2) AS percentage_share
FROM 
    ipl_contracts
ORDER BY 
    percentage_share DESC;

-- 2. Health / Social Risk Index for Top Advertising Brands.
SELECT 
    advertiser_brand,
    category,
    risk_score,
    risk_score * 20 AS risk_index_100
FROM 
    ipl_advertisers
ORDER BY 
    risk_score DESC;

-- 3. Projected CAGR until 2030 for Top 5 High-Risk Companies.
SELECT 
    a.advertiser_brand,
    r.annual_revenue_crores,
    a.risk_score
FROM 
    ipl_advertisers a
JOIN 
    revenue_demography r ON a.advertiser_brand ILIKE '%' || r.company || '%'
WHERE 
    a.risk_score >= 4
ORDER BY 
    r.annual_revenue_crores DESC
LIMIT 5;

-- CAGR & % OF Top 5 Companies.
SELECT 
    company,
    annual_revenue_crores AS present_value,
    annual_revenue_crores * 2 AS future_value,
    ROUND(POWER((annual_revenue_crores * 2) / annual_revenue_crores, 1.0/5) - 1, 4) AS cagr,
    (ROUND(POWER((annual_revenue_crores * 2) / annual_revenue_crores, 1.0/5) - 1, 4)) * 100 AS cagr_in_percentage
FROM 
    revenue_demography
WHERE 
    company IN ('Dream11', 'PokerBaazi', 'My11Circle', 'Vimal Pan Masala', 'Rajshree', 'Kamla Pasand')
ORDER BY 
    cagr DESC;

-- 4. Estimate Total Population Being Negatively Impacted.
SELECT 
    SUM(avg_user_population) AS total_users_estimated
FROM 
    demographic_summary
WHERE 
    income_group IN ('Lower Income', 'Lower-Middle') 
    OR key_characteristics ILIKE '%rural%' 
    OR key_characteristics ILIKE '%unorganized%';

-- 5. Top 5 Celebrities for High-Risk Brands.
SELECT 
    unnest(string_to_array(brand_ambassadors, ', ')) AS celebrity,
    COUNT(*) AS number_of_times_promoted
FROM 
    ipl_advertisers
WHERE 
    risk_score >= 4
GROUP BY 
    celebrity
ORDER BY 
    number_of_times_promoted DESC
LIMIT 5;

-- Category-wise Seasonal Jobs Estimate
SELECT 
    category,
    COUNT(*) AS num_brands,
    CASE 
        WHEN category ILIKE '%Pan Masala%' THEN COUNT(*) * 800
        WHEN category ILIKE '%Fantasy%' THEN COUNT(*) * 400
        WHEN category ILIKE '%FMCG%' THEN COUNT(*) * 150
        WHEN category ILIKE '%OTT%' THEN COUNT(*) * 120
        ELSE COUNT(*) * 100
    END AS estimated_jobs_created
FROM 
    ipl_advertisers
GROUP BY 
    category;

-- Government GST Tax Revenue Estimate
SELECT 
    SUM(amount_in_crores_2025) AS total_advertising_revenue,
    SUM(amount_in_crores_2025) * 0.18 AS estimated_tax_collected
FROM 
    ipl_contracts;
