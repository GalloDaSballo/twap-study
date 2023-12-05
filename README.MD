# NOT AUDITED - YOU WILL REK YOURSELF

- Release Candidate: OPTIMIZED_RelativeTwapWeightedObserver
- Reference Implementation: REFERENCE_RelativeTwapWeightedObserver

## Requirements

Release Candidate must meet reference functionality given the following constraints:
- 80 years of operations
- `valueToTrack` having a maximum value of 100e27 (100 Billion eBTC)

## Goals

- For Spike up, we want to delay those spike ups
- For spike downs, we will use min(TWAP, Spot) meaning that we always chose the lowest value