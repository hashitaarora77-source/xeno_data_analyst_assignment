-- Step 0: Naive count of all October campaign send attempts.
SELECT COUNT(*) AS naive_count
FROM communication_log
WHERE merchant_id = 501
  AND communication_type = '2'
  AND sent_time >= '2026-10-01'
  AND sent_time < '2026-11-01';
-- Expected: 30
 