CREATE TABLE vehicle_category (
  category_id int PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  daily_rate float,	
  hourly_late_fee float
);

INSERT INTO vehicle_category(category_id,name, daily_rate, hourly_late_fee) VALUES
 (1,'Economy', 1500, 200), (2,'SUV', 3000, 400);
 
drop table vehicle_category;
select * from vehicle_category;

CREATE TABLE branch (
  branch_id int  PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  street VARCHAR(120) NOT NULL,
  city VARCHAR(80)  NOT NULL,
  state VARCHAR(40)  NOT NULL,
  phone VARCHAR(10)
);

INSERT INTO branch(branch_id,name, street, city, state) VALUES
 (1,'Mumbai Central','A Rd','Mumbai','MH'),
 (2,'Pune East','B Rd','Pune','MH');

select * from branch;

CREATE TABLE vehicle (
  vehicle_id int PRIMARY KEY,
  registration_no VARCHAR(20) UNIQUE NOT NULL,
  model VARCHAR(60) NOT NULL,
  year INT,
  color VARCHAR(30),
  category_id INT NOT NULL ,FOREIGN KEY(category_id) REFERENCES vehicle_category(category_id),
  current_branch INT NOT NULL,foreign key(	current_branch) REFERENCES branch(branch_id),
  status VARCHAR(20) NOT NULL CHECK (status IN ('available','held','rented','maintenance','retired'))
);

INSERT INTO vehicle(vehicle_id,registration_no,model,year,category_id,current_branch,status)
VALUES(001,'MH01AB1234','Swift',2022,1,1,'available'),
      (002,'MH12XY9876','Creta',2023,2,2,'available');

select * from vehicle;


CREATE TABLE customer (
  customer_id int PRIMARY KEY,
  first_name  VARCHAR(60) NOT NULL,
  last_name   VARCHAR(60) NOT NULL,
  email       VARCHAR(120) UNIQUE NOT NULL,
  phone       VARCHAR(30),
  license_no  VARCHAR(40) UNIQUE NOT NULL
);

INSERT INTO customer(customer_id,first_name,last_name,email,phone,license_no)
VALUES(1,'Asha','Patil','asha@example.com','9999999999','MH-2020-12345');

select * from customer;


CREATE TABLE promotion (
  promo_code   VARCHAR(20) PRIMARY KEY,
  description  VARCHAR(200),
  percent_off  DECIMAL(5,4) NOT NULL CHECK (percent_off BETWEEN 0 AND 100),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE
);
INSERT INTO promotion(promo_code,description,percent_off,start_date,end_date,active)
VALUES('FEST10','Festive offer 10%',7.5,'2025-10-01','2025-10-31',TRUE);

SELECT * FROM PROMOTION;


CREATE TABLE reservation (
  reservation_id INT PRIMARY KEY,
  customer_id INT NOT NULL, FOREIGN KEY(customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
  vehicle_id INT,FOREIGN KEY(vehicle_id) REFERENCES vehicle(vehicle_id) ON UPDATE CASCADE,
  pickup_branch INT NOT NULL,FOREIGN KEY(pickup_branch) REFERENCES branch(branch_id),
  dropoff_branch  INT NOT NULL,FOREIGN KEY(dropoff_branch) REFERENCES branch(branch_id),
  start_at TIMESTAMP NOT NULL,
  end_at TIMESTAMP NOT NULL,
  promo_code VARCHAR(20),FOREIGN KEY(promo_code) REFERENCES promotion(promo_code),
  status VARCHAR(20) NOT NULL CHECK (status IN ('created','confirmed','cancelled','converted'))
);

INSERT INTO reservation(reservation_id,customer_id, vehicle_id, pickup_branch, dropoff_branch, start_at, end_at, promo_code, status)
VALUES(1,1, 1, 1, 2, '2025-10-05 10:00', '2025-10-07 10:00', 'FEST10', 'confirmed');
select * from reservation;


CREATE TABLE rental (
  rental_id int PRIMARY KEY,
  reservation_id INT UNIQUE ,FOREIGN KEY(reservation_id)REFERENCES reservation(reservation_id) ON DELETE SET NULL,
  customer_id     INT NOT NULL,FOREIGN KEY(customer_id) REFERENCES customer(customer_id),
  vehicle_id      INT NOT NULL,FOREIGN KEY(vehicle_id) REFERENCES vehicle(vehicle_id),
  pickup_branch   INT NOT NULL,FOREIGN KEY(pickup_branch) REFERENCES branch(branch_id),
  dropoff_branch  INT NOT NULL,FOREIGN KEY(dropoff_branch) REFERENCES branch(branch_id),
  pickup_at       TIMESTAMP NOT NULL,
  due_at          TIMESTAMP NOT NULL,
  status          VARCHAR(20) NOT NULL CHECK (status IN ('open','closed','overdue'))
);
INSERT INTO rental(rental_id,reservation_id, customer_id, vehicle_id, pickup_branch, dropoff_branch, pickup_at, due_at, status)
VALUES(1,1, 1, 1, 1, 2, '2025-10-05 10:15', '2025-10-07 10:00', 'open');

select * from rental;


CREATE TABLE vehicle_return (
  return_id INT PRIMARY KEY,
  rental_id      INT UNIQUE NOT NULL,FOREIGN KEY(rental_id) REFERENCES rental(rental_id) ON DELETE CASCADE,
  returned_at    TIMESTAMP NOT NULL,
  damage_notes   VARCHAR(500)
  );
 
 INSERT INTO vehicle_return(return_id ,rental_id, returned_at, damage_notes)
VALUES(1,1, '2025-10-07 13:30', 'No damage');
  SELECT * FROM VEHICLE_RETURN;
  
  
CREATE TABLE inspection (
  inspection_id INT PRIMARY KEY,
  vehicle_id INT NOT NULL,FOREIGN KEY(vehicle_id) REFERENCES vehicle(vehicle_id),
  noted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  notes VARCHAR(500),
  severity INT CHECK (severity BETWEEN 1 AND 5)
);
select* FROM INSPECTION;

CREATE TABLE invoice (
  invoice_id  INT PRIMARY KEY,
  rental_id      INT UNIQUE NOT NULL,FOREIGN KEY(rental_id) REFERENCES rental(rental_id) ON DELETE CASCADE,
  base_days      INT NOT NULL CHECK (base_days >= 0),
  base_amount    NUMERIC(10,2) NOT NULL CHECK (base_amount >= 0),
  late_hours     INT NOT NULL CHECK (late_hours >= 0),
  late_fee       NUMERIC(10,2) NOT NULL CHECK (late_fee >= 0),
  promo_discount NUMERIC(10,2) NOT NULL CHECK (promo_discount >= 0),
  total_amount   NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0)
);

INSERT INTO invoice (invoice_id ,rental_id, base_days, base_amount, late_hours, late_fee, promo_discount, total_amount)
  VALUES(1,1, 2, 3000.00, 3, 600.00, 300.00, 3300.00);
  SELECT * FROM INVOICE;
  
  
CREATE TABLE payment (
  payment_id INT  PRIMARY KEY,
  rental_id    INT NOT NULL,FOREIGN KEY(rental_id) REFERENCES rental(rental_id) ON DELETE CASCADE,
  amount       NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  currency     CHAR(3) NOT NULL DEFAULT 'INR',
  method       VARCHAR(20) NOT NULL CHECK (method IN ('card','upi','cash','wallet'))
)

INSERT INTO payment(payment_id,rental_id, amount, method) VALUES (1,1, (SELECT total_amount FROM invoice WHERE rental_id=1), 'upi');
select	* from payment;





