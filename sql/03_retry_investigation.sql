-- Inspect the campaign hierarchy and send counts.
SELECT
    c.id AS campaign_id,
    c.parent_id,
    c.name,
    c.creation_status,
    c.processing_status,
    COUNT(cl.id) AS send_rows,
    COUNT(DISTINCT cl.customer_id) AS distinct_customers
FROM campaign c
LEFT JOIN communication_log cl
    ON cl.communication_id = c.id
   AND cl.merchant_id = 501
   AND cl.communication_type = '2'
   AND cl.sent_time >= '2026-10-01'
   AND cl.sent_time < '2026-11-01'
GROUP BY c.id, c.parent_id, c.name, c.creation_status, c.processing_status
ORDER BY c.id;

-- Important findings:
-- 9001 -> 9002 -> 9003 is one retry family.
-- 9004 is a pending/ineligible branch.
-- 9201 -> 9202 is another retry family.
-- 9101 is standalone and contains a legitimate repeated C20 send.
