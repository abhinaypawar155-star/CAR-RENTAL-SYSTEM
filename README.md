Purpose: Provide a reliable, auditable multi-branch car rental database that manages vehicles, customers, reservations, rentals, returns, promotions, invoices, and payments while preventing booking conflicts and ensuring accurate billing.

Core entities: Vehicles ( registration, category, current_branch, status), Vehicle categories (daily_rate, hourly_late_fee), Branches (location/contact), Customers (contact and license), Reservations (start_at, end_at, pickup/drop-off, promo_code, status), Rentals (pickup_at, due_at, status), Returns (returned_at, odometer_end, fuel level, damage notes), Promotions (percent_off, validity window), Invoices (base_days, base_amount, late_hours, late_fee, promo_discount, total_amount), Payments (amount, method, timestamp).

Data integrity: Primary/foreign keys across all relationships; UNIQUE constraints on VIN and registration; CHECK constraints for nonnegative monetary values, valid statuses, and time order (end_at > start_at); conservative referential actions (cascade updates, restricted deletes for master data).

Availability and double-booking control: Unique index prevents exact duplicate reservation windows per vehicle; overlap prevention via exclusion constraints (range types) where supported or via BEFORE INSERT/UPDATE triggers that reject intersecting time ranges.

Status and lifecycle: Vehicle status transitions among available, held, rented, maintenance, retired; reservation status flows from created/confirmed to converted at rental pickup; rental moves from open to closed/overdue; return updates vehicle’s current_branch to the drop-off location.

Billing model: Base charges calculated as billable days × daily_rate; late_fee as ceiling(late hours) × hourly_late_fee; promo_discount applied within active date range; total_amount snapshotted in invoice for an immutable financial record.

Numeric and time handling: Exact DECIMAL/NUMERIC types for money and percentages to avoid rounding errors; consistent timestamp strategy (prefer UTC or timezone-aware) for accurate duration and billing computations.

Operational workflows: Search available vehicles by branch and time window; convert reservations to rentals with atomic status updates; record returns, compute invoices automatically, and log payments; maintain branch inventory accuracy.

Reporting and analytics: Fleet utilization by day/branch; revenue by category and month; customer lifetime value; overdue/aging dashboards; audit trails via immutable invoices and payment logs.

Performance and scalability: Targeted indexing on high-traffic predicates (status, branch, time windows, invoice dates); optional summary tables/materialized views; partitioning strategies for high-volume rentals/invoices; predictable migrations with named constraints. 
