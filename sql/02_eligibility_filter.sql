-- Step 1: Apply the campaign reporting eligibility gate.
SELECT COUNT(*) AS eligible_send_attempts
FROM communication_log cl
JOIN campaign c ON c.id = cl.communication_id
WHERE cl.merchant_id = 501
  AND cl.communication_type = '2'
  AND cl.sent_time >= '2026-10-01'
  AND cl.sent_time < '2026-11-01'
  AND c.creation_status IN ('approved','aborted','resumed','stopped')
  AND c.processing_status = 'processed';
-- Expected: 26
-- 4 rows from campaign 9004 are removed because creation_status = approval_awaiting.
 