-- A tempting but incorrect query:
SELECT COUNT(DISTINCT cl.customer_id) AS distinct_customers
FROM communication_log cl
JOIN campaign c ON c.id = cl.communication_id
WHERE cl.merchant_id = 501
  AND cl.communication_type = '2'
  AND cl.sent_time >= '2026-10-01'
  AND cl.sent_time < '2026-11-01'
  AND c.creation_status IN ('approved','aborted','resumed','stopped')
  AND c.processing_status = 'processed';

-- Why it is wrong:
-- C20 appears twice in standalone campaign 9101.
-- A standalone campaign has no retry chain, so each send is a separate event.
-- Therefore global COUNT(DISTINCT customer_id) would undercount.
