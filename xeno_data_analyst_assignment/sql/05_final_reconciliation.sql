WITH RECURSIVE campaign_roots(campaign_id, root_id) AS (
    SELECT id, id FROM campaign WHERE merchant_id = 501
    UNION ALL
    SELECT cr.campaign_id, c.parent_id
    FROM campaign_roots cr
    JOIN campaign c ON c.id = cr.root_id
    WHERE c.parent_id IS NOT NULL
),
resolved AS (
    SELECT campaign_id, root_id
    FROM campaign_roots
    WHERE root_id IN (SELECT id FROM campaign WHERE parent_id IS NULL)
),
eligible_logs AS (
    SELECT cl.id AS log_id, cl.communication_id, cl.customer_id, r.root_id
    FROM communication_log cl
    JOIN campaign c ON c.id = cl.communication_id
    JOIN resolved r ON r.campaign_id = cl.communication_id
    WHERE cl.merchant_id = 501
      AND cl.communication_type = '2'
      AND cl.sent_time >= '2026-10-01'
      AND cl.sent_time < '2026-11-01'
      AND c.merchant_id = 501
      AND c.creation_status IN ('approved','aborted','resumed','stopped')
      AND c.processing_status = 'processed'
),
retry_families AS (
    SELECT el.root_id, COUNT(DISTINCT el.customer_id) AS contribution
    FROM eligible_logs el
    WHERE EXISTS (SELECT 1 FROM campaign child WHERE child.parent_id = el.root_id)
    GROUP BY el.root_id
),
standalones AS (
    SELECT el.root_id, COUNT(*) AS contribution
    FROM eligible_logs el
    WHERE NOT EXISTS (SELECT 1 FROM campaign child WHERE child.parent_id = el.root_id)
    GROUP BY el.root_id
)
SELECT COALESCE((SELECT SUM(contribution) FROM retry_families),0)
     + COALESCE((SELECT SUM(contribution) FROM standalones),0) AS target_base;

-- Expected result: target_base = 22
