# Xeno Data Analyst Internship — Comm-Log Send Reconciliation

## Objective

Reproduce Finance's reported `target_base = 22` for merchant `501`, October 2026, across the Diwali campaigns.

The analysis focuses on three reporting rules:

1. A campaign is eligible only when its creation workflow has cleared and its processing is complete.
2. Retry campaigns linked through `campaign.parent_id` belong to the same underlying communication. Within a retry family, a customer is counted once.
3. A standalone campaign has no retry chain, so each send is a separate event even if the same customer appears more than once.

## Investigation

### Step 0 — Naive count

The obvious starting query counts every communication-log row:

**30**

### Step 1 — Apply campaign eligibility

Campaign `9004` has `creation_status = 'approval_awaiting'`, so it is not included in official reporting even though communication-log rows exist for it.

Four rows are removed:

**30 → 26**

### Step 2 — Understand retry chains

The campaign hierarchy is:

- `9001 → 9002 → 9003`
- `9004 → 9001` as a pending branch
- `9201 → 9202`
- `9101` standalone

The two completed retry families represent one underlying communication each.

### Step 3 — Apply the metric definition

For `9001 → 9002 → 9003`, there are 10 distinct customers.

For `9201 → 9202`, there are 5 distinct customers.

Together, retry families contribute:

**10 + 5 = 15**

Standalone `9101` has 7 send rows. Customer `C20` appears twice, and both are legitimate separate events, so all 7 rows count.

Therefore:

**15 + 7 = 22**

## Final result

`target_base = 22`

## Files

- `sql/01_naive_query.sql` — initial naive query
- `sql/02_eligibility_filter.sql` — eligibility adjustment
- `sql/03_retry_investigation.sql` — hierarchy investigation
- `sql/04_distinct_customer_trap.sql` — intentionally incorrect global DISTINCT example
- `sql/05_final_reconciliation.sql` — final SQLite query
- `reconciliation/reconciliation_bridge.md` — submission bridge
- `reconciliation/data_observation.md` — surprise/observation paragraph
- `data/comm_log.db` — SQLite dataset
- `data/campaign.csv` and `data/communication_log.csv` — CSV equivalents

## Running the final query

From this repository root:

```bash
sqlite3 data/comm_log.db < sql/05_final_reconciliation.sql
```

Expected result:

```text
22
```

## Notes

The solution intentionally shows the investigation path rather than jumping directly to the final number. The final query uses a recursive CTE so the logic handles retry chains with more than one retry level.
