# Reconciliation Bridge

| Step | Description | Result | Reason |
|---:|---|---:|---|
| 0 | Naive count of October campaign send-log rows | 30 | Starting point: all merchant 501 campaign send attempts in October. |
| 1 | Apply campaign eligibility rules | 26 | Campaign 9004 is `approval_awaiting`, so its 4 rows are excluded. |
| 2 | Resolve retry chains | 26 | Campaigns 9001→9002→9003 and 9201→9202 represent underlying communications, not independent communications. |
| 3 | Count distinct customers within retry families | 15 | Family 9001→9002→9003 contributes 10; family 9201→9202 contributes 5. |
| 4 | Preserve every send in standalone campaigns | 7 | Campaign 9101 has no retry chain; C20 appears twice legitimately, so both events count. |
| **Final** | **target_base** | **22** | **15 retry-family customers + 7 standalone send events.** |

## Family-level check

| Family | Treatment | Contribution |
|---|---|---:|
| 9001 → 9002 → 9003 | Distinct customers across the retry chain | 10 |
| 9201 → 9202 | Distinct customers across the retry chain | 5 |
| 9101 | Count every send event | 7 |
| 9004 | Ineligible (`approval_awaiting`) | 0 |
| **Total** | | **22** |
