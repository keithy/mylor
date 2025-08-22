let state = import ".fraggle-state/fraggle-state.ncl" in match state.last_nightly with | null => "" | date => date
