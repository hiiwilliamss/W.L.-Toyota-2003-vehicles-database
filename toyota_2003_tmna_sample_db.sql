-- ================
-- William Lorenzo
-- 09/12/2025
-- ================

-- Toyota Motor North America (TMNA) — Sample Database for 2003 Toyota Vehicles
-- Purpose: realistic schema + >500 rows of 2003 Toyota vehicles for SQL practice
-- Tested on: MySQL 8.x (uses recursive CTE)
-- Notes: VINs are synthetic but 17 characters long and Toyota-like (prefix "JTD"/"JT3" etc. for demo only).

-- =============================
-- CREATE DATABASE & SETTINGS
-- =============================
DROP DATABASE IF EXISTS toyota_tmna_2003;
CREATE DATABASE toyota_tmna_2003 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE toyota_tmna_2003;
SET sql_safe_updates = 0;

-- =============================
-- TABLES
-- =============================
CREATE TABLE make (
  make_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  region VARCHAR(10) NOT NULL DEFAULT 'TMNA',
  UNIQUE KEY uk_make_name (name)
) ENGINE=InnoDB;

CREATE TABLE plant (
  plant_id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(10) NOT NULL,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state_country VARCHAR(80) NOT NULL,
  UNIQUE KEY uk_plant_code (code)
) ENGINE=InnoDB;

CREATE TABLE model (
  model_id INT PRIMARY KEY AUTO_INCREMENT,
  make_id INT NOT NULL,
  name VARCHAR(60) NOT NULL,
  body_style VARCHAR(40) NOT NULL,
  segment VARCHAR(40) NOT NULL,
  usdm_start_year INT,
  usdm_end_year INT,
  FOREIGN KEY (make_id) REFERENCES make(make_id)
) ENGINE=InnoDB;

CREATE TABLE engine (
  engine_id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL,
  displacement_l DECIMAL(3,1) NOT NULL,
  cylinders TINYINT NOT NULL,
  aspiration VARCHAR(20) NOT NULL DEFAULT 'NA',
  fuel VARCHAR(20) NOT NULL DEFAULT 'Gasoline',
  hybrid TINYINT(1) NOT NULL DEFAULT 0,
  notes VARCHAR(200),
  UNIQUE KEY uk_engine_code (code)
) ENGINE=InnoDB;

CREATE TABLE transmission (
  transmission_id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL,
  type VARCHAR(20) NOT NULL,
  gears TINYINT,
  UNIQUE KEY uk_trans_code (code)
) ENGINE=InnoDB;

CREATE TABLE color (
  color_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(60) NOT NULL,
  type ENUM('exterior','interior') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE dealership (
  dealership_id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(16) NOT NULL,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state VARCHAR(2) NOT NULL,
  UNIQUE KEY uk_dealer_code (code)
) ENGINE=InnoDB;

-- TRIM carries the specific configuration at the point of build (common US 2003 trims)
CREATE TABLE `trim` (
  trim_id INT PRIMARY KEY AUTO_INCREMENT,
  model_id INT NOT NULL,
  name VARCHAR(60) NOT NULL,
  engine_id INT NOT NULL,
  transmission_id INT NOT NULL,
  drivetrain ENUM('FWD','RWD','AWD','4WD') NOT NULL,
  msrp_base DECIMAL(10,2) NOT NULL,
  plant_id INT NOT NULL,
  target_qty INT NOT NULL DEFAULT 0,
  FOREIGN KEY (model_id) REFERENCES model(model_id),
  FOREIGN KEY (engine_id) REFERENCES engine(engine_id),
  FOREIGN KEY (transmission_id) REFERENCES transmission(transmission_id),
  FOREIGN KEY (plant_id) REFERENCES plant(plant_id)
) ENGINE=InnoDB;

CREATE TABLE vehicles (
  vehicle_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  vin CHAR(17) NOT NULL,
  model_year SMALLINT NOT NULL,
  trim_id INT NOT NULL,
  exterior_color_id INT NOT NULL,
  interior_color VARCHAR(40) NOT NULL,
  production_month TINYINT NOT NULL,
  msrp DECIMAL(10,2) NOT NULL,
  plant_id INT NOT NULL,
  dealership_id INT NOT NULL,
  date_received DATE NOT NULL,
  CONSTRAINT fk_v_trim   FOREIGN KEY (trim_id)           REFERENCES `trim`(trim_id),
  CONSTRAINT fk_v_color  FOREIGN KEY (exterior_color_id) REFERENCES color(color_id),
  CONSTRAINT fk_v_plant  FOREIGN KEY (plant_id)          REFERENCES plant(plant_id),
  CONSTRAINT fk_v_dealer FOREIGN KEY (dealership_id)     REFERENCES dealership(dealership_id),
  UNIQUE KEY uk_vin (vin)
) ENGINE=InnoDB;

-- Helpful indexes
CREATE INDEX ix_vehicles_trim   ON vehicles(trim_id);
CREATE INDEX ix_vehicles_dealer ON vehicles(dealership_id);
CREATE INDEX ix_vehicles_year   ON vehicles(model_year);

-- =============================
-- STATIC DATA
-- =============================
INSERT INTO make (name, region) VALUES ('Toyota','TMNA');

-- Key TMNA plants for 2003-era Toyota
INSERT INTO plant (code, name, city, state_country) VALUES
 ('TMMK','Toyota Motor Manufacturing Kentucky','Georgetown','KY'),
 ('TMMC','Toyota Motor Manufacturing Canada','Cambridge','ON, Canada'),
 ('TMMI','Toyota Motor Manufacturing Indiana','Princeton','IN'),
 ('NUMMI','New United Motor Manufacturing Inc.','Fremont','CA'),
 ('TAHARA','Tahara Plant','Tahara','Aichi, Japan'),
 ('KYUSHU','Miyata Plant (Kyushu)','Miyawaka','Fukuoka, Japan');

-- 2003 USDM Toyota models (TMNA)
INSERT INTO model (make_id, name, body_style, segment, usdm_start_year, usdm_end_year)
SELECT make_id, m, b, s, sy, ey FROM make JOIN (
  SELECT '4Runner' m, 'SUV' b, 'Midsize SUV' s, 1984 sy, NULL ey UNION ALL
  SELECT 'Avalon','Sedan','Full-size',1995,NULL UNION ALL
  SELECT 'Camry','Sedan','Midsize',1983,NULL UNION ALL
  SELECT 'Camry Solara','Coupe','Midsize',1999,2008 UNION ALL
  SELECT 'Celica','Coupe','Sport Compact',1971,2005 UNION ALL
  SELECT 'Corolla','Sedan','Compact',1968,NULL UNION ALL
  SELECT 'Echo','Sedan','Subcompact',2000,2005 UNION ALL
  SELECT 'Highlander','SUV','Midsize Crossover',2001,NULL UNION ALL
  SELECT 'Land Cruiser','SUV','Full-size SUV',1958,NULL UNION ALL
  SELECT 'Matrix','Hatchback','Compact',2003,2014 UNION ALL
  SELECT 'MR2 Spyder','Roadster','Sports',2000,2005 UNION ALL
  SELECT 'Prius','Sedan','Hybrid',2001,NULL UNION ALL
  SELECT 'RAV4','SUV','Compact SUV',1996,NULL UNION ALL
  SELECT 'Sequoia','SUV','Full-size SUV',2001,NULL UNION ALL
  SELECT 'Sienna','Minivan','Minivan',1998,NULL UNION ALL
  SELECT 'Tacoma','Pickup','Compact Pickup',1995,2015 UNION ALL
  SELECT 'Tundra','Pickup','Full-size Pickup',2000,NULL
) x;

-- Engines present in 2003 US Toyota lineup
INSERT INTO engine (code, displacement_l, cylinders, aspiration, fuel, hybrid, notes) VALUES
 ('1ZZ-FE',1.8,4,'NA','Gasoline',0,'Corolla/Matrix/MR2'),
 ('2ZZ-GE',1.8,4,'NA','Gasoline',0,'High output Celica/Matrix XRS'),
 ('1NZ-FE',1.5,4,'NA','Gasoline',0,'Echo'),
 ('1NZ-FXE',1.5,4,'NA','Hybrid',1,'Prius hybrid Atkinson'),
 ('2AZ-FE',2.4,4,'NA','Gasoline',0,'Camry/Highlander'),
 ('1MZ-FE',3.0,6,'NA','Gasoline',0,'Camry/Avalon/Sienna/Highlander'),
 ('5VZ-FE',3.4,6,'NA','Gasoline',0,'Tacoma'),
 ('1GR-FE',4.0,6,'NA','Gasoline',0,'4Runner (new V6 in 2003)'),
 ('2UZ-FE',4.7,8,'NA','Gasoline',0,'Tundra/Sequoia/Land Cruiser'),
 ('1AZ-FE',2.0,4,'NA','Gasoline',0,'RAV4');

-- Transmissions present in 2003
INSERT INTO transmission (code, type, gears) VALUES
 ('5MT','Manual',5),
 ('6MT','Manual',6),
 ('4AT','Automatic',4),
 ('5AT','Automatic',5),
 ('eCVT','CVT',0);

-- Exterior colors (OEM Toyota color options circa 2003)
INSERT INTO color (name, type) VALUES
 ('Super White','exterior'),
 ('Black','exterior'),
 ('Phantom Gray Pearl','exterior'),
 ('Lunar Mist Metallic','exterior'),
 ('Desert Sand Mica','exterior'),
 ('Catalina Blue Metallic','exterior'),
 ('Indigo Ink Pearl','exterior'),
 ('Impulse Red Pearl','exterior'),
 ('Salsa Red Pearl','exterior'),
 ('Millennium Silver Metallic','exterior');

-- A few consistent interior trims
INSERT INTO color (name, type) VALUES
 ('Stone Cloth','interior'),('Stone Leather','interior'),('Gray Cloth','interior'),('Gray Leather','interior'),
 ('Tan Cloth','interior'),('Tan Leather','interior'),('Black Cloth','interior'),('Black Leather','interior');

-- Dealerships (sample TMNA dealers across the US)
INSERT INTO dealership (code, name, city, state) VALUES
 ('LA001','Toyota of Downtown LA','Los Angeles','CA'),
 ('SF002','SF Toyota','San Francisco','CA'),
 ('SEA003','Toyota of Seattle','Seattle','WA'),
 ('NY004','Toyota Manhattan','New York','NY'),
 ('DAL005','Toyota of Dallas','Dallas','TX'),
 ('CHI006','Chicago North Toyota','Chicago','IL'),
 ('MIA007','Toyota Miami','Miami','FL'),
 ('ATL008','Atlanta Toyota','Atlanta','GA');

-- =============================
-- TRIMS (US 2003 realistic selections)
-- target_qty chosen so total vehicles > 500
INSERT INTO `trim` (model_id, name, engine_id, transmission_id, drivetrain, msrp_base, plant_id, target_qty)
SELECT m.model_id,
       t.trim_name,
       e.engine_id,
       tr.transmission_id,
       t.d,               
       t.msrp,
       p.plant_id,
       t.qty
FROM model m
JOIN make mk ON mk.make_id = m.make_id AND mk.name='Toyota'
JOIN (
  -- model, trim, engine_code, trans_code, drivetrain, msrp, plant_code, qty
  SELECT 'Camry' model,'CE 2.4L 5MT' trim_name,'2AZ-FE' e,'5MT' t,'FWD' d, 19000.00 msrp,'TMMK' pc, 30 qty UNION ALL
  SELECT 'Camry','LE 2.4L 4AT','2AZ-FE','4AT','FWD', 20500.00,'TMMK', 60 UNION ALL
  SELECT 'Camry','XLE 3.0L 4AT','1MZ-FE','4AT','FWD', 25500.00,'TMMK', 35 UNION ALL
  SELECT 'Camry Solara','SE 2.4L 5MT','2AZ-FE','5MT','FWD', 19900.00,'TMMK', 20 UNION ALL
  SELECT 'Camry Solara','SLE 3.0L 4AT','1MZ-FE','4AT','FWD', 25500.00,'TMMK', 20 UNION ALL
  SELECT 'Corolla','CE 1.8L 5MT','1ZZ-FE','5MT','FWD', 13950.00,'TMMC', 40 UNION ALL
  SELECT 'Corolla','LE 1.8L 4AT','1ZZ-FE','4AT','FWD', 15500.00,'NUMMI', 50 UNION ALL
  SELECT 'Matrix','XR 1.8L 5MT','1ZZ-FE','5MT','FWD', 15900.00,'TMMC', 25 UNION ALL
  SELECT 'Matrix','XRS 1.8L 6MT','2ZZ-GE','6MT','FWD', 18900.00,'TMMC', 20 UNION ALL
  SELECT 'Echo','Base 1.5L 5MT','1NZ-FE','5MT','FWD', 10750.00,'TMMC', 15 UNION ALL
  SELECT 'Prius','Base 1.5L eCVT','1NZ-FXE','eCVT','FWD', 19995.00,'TMMC', 25 UNION ALL
  SELECT 'Celica','GT 1.8L 5MT','1ZZ-FE','5MT','FWD', 17000.00,'TMMC', 18 UNION ALL
  SELECT 'Celica','GT-S 1.8L 6MT','2ZZ-GE','6MT','FWD', 21950.00,'TMMC', 12 UNION ALL
  SELECT 'RAV4','Base 2.0L 4AT','1AZ-FE','4AT','FWD', 18995.00,'TAHARA', 28 UNION ALL
  SELECT 'RAV4','Base 2.0L 4AT 4WD','1AZ-FE','4AT','4WD', 19995.00,'TAHARA', 22 UNION ALL
  SELECT 'Highlander','Base 2.4L 4AT','2AZ-FE','4AT','FWD', 24000.00,'KYUSHU', 26 UNION ALL
  SELECT 'Highlander','V6 3.0L 4AT AWD','1MZ-FE','4AT','AWD', 28500.00,'KYUSHU', 24 UNION ALL
  SELECT '4Runner','SR5 4.0L 4AT 2WD','1GR-FE','4AT','RWD', 27400.00,'TAHARA', 22 UNION ALL
  SELECT '4Runner','Limited 4.7L 5AT 4WD','2UZ-FE','5AT','4WD', 35600.00,'TAHARA', 18 UNION ALL
  SELECT 'Sequoia','SR5 4.7L 4AT 2WD','2UZ-FE','4AT','RWD', 31295.00,'TMMI', 18 UNION ALL
  SELECT 'Sequoia','Limited 4.7L 4AT 4WD','2UZ-FE','4AT','4WD', 40500.00,'TMMI', 12 UNION ALL
  SELECT 'Land Cruiser','Base 4.7L 5AT 4WD','2UZ-FE','5AT','4WD', 54600.00,'KYUSHU', 10 UNION ALL
  SELECT 'Sienna','LE 3.0L 4AT','1MZ-FE','4AT','FWD', 24500.00,'TMMI', 25 UNION ALL
  SELECT 'Tacoma','PreRunner 3.4L 4AT','5VZ-FE','4AT','RWD', 20600.00,'NUMMI', 24 UNION ALL
  SELECT 'Tacoma','TRD 3.4L 5MT 4WD','5VZ-FE','5MT','4WD', 22000.00,'NUMMI', 16 UNION ALL
  SELECT 'Tundra','SR5 4.7L 4AT RWD','2UZ-FE','4AT','RWD', 22750.00,'TMMI', 26 UNION ALL
  SELECT 'Tundra','Limited 4.7L 4AT 4WD','2UZ-FE','4AT','4WD', 31500.00,'TMMI', 14 UNION ALL
  SELECT 'MR2 Spyder','Base 1.8L 5MT','1ZZ-FE','5MT','RWD', 24995.00,'TMMC', 10
) t  ON t.model = m.name
JOIN engine e        ON e.code = t.e
JOIN transmission tr ON tr.code = t.t
JOIN plant p         ON p.code = t.pc;

-- =============================
-- SYNTHETIC VEHICLE INVENTORY (>500 rows)
-- Build VINs and distribute colors/dealerships/months deterministically
WITH RECURSIVE seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM seq WHERE n < 1000
)
INSERT INTO vehicles (
  vin, model_year, trim_id, exterior_color_id, interior_color,
  production_month, msrp, plant_id, dealership_id, date_received
)
SELECT
  -- VIN pattern: 'JTD' (most) or 'JT3' (Land Cruiser) + trim + plant + color + 8-digit serial = 17 chars
  CONCAT('J',
         CASE WHEN m.name = 'Land Cruiser' THEN 'T3' ELSE 'TD' END,
         LPAD(t.trim_id,3,'0'),
         SUBSTRING(p.code,1,1),
         LPAD(c.color_id,2,'0'),
         LPAD(seq.n,8,'0')) AS vin,
  2003 AS model_year,
  t.trim_id,
  c.color_id AS exterior_color_id,
  CASE 
    WHEN (seq.n % 3)=0 THEN 'Gray Cloth'
    WHEN (seq.n % 3)=1 THEN 'Stone Cloth'
    ELSE 'Tan Cloth'
  END AS interior_color,
  ((seq.n - 1) % 12) + 1 AS production_month,
  -- small deterministic variance (+/- up to $400)
  ROUND(t.msrp_base + ((seq.n % 9) - 4) * 25, 2) AS msrp,
  t.plant_id,
  (1 + ((seq.n - 1) % 8)) AS dealership_id,
  DATE(CONCAT('2003-', LPAD(((seq.n - 1) % 12) + 1,2,'0'), '-', LPAD(10 + ((seq.n - 1) % 18),2,'0'))) AS date_received
FROM `trim` t
JOIN model m ON m.model_id = t.model_id
JOIN plant p ON p.plant_id = t.plant_id
JOIN color c ON c.type='exterior'
JOIN seq ON seq.n <= t.target_qty
WHERE m.name IN (
  '4Runner','Avalon','Camry','Camry Solara','Celica','Corolla','Echo','Highlander','Land Cruiser',
  'Matrix','MR2 Spyder','Prius','RAV4','Sequoia','Sienna','Tacoma','Tundra'
)
AND c.color_id = 1 + ((seq.n - 1) % 10);

-- =============================
-- Sanity checks (optional)
SELECT COUNT(*) AS total_vehicles FROM vehicles;           -- should be > 500
SELECT m.name, COUNT(*) AS units
FROM vehicles v
JOIN `trim` t ON t.trim_id = v.trim_id
JOIN model m ON m.model_id = t.model_id
GROUP BY m.name
ORDER BY units DESC;

