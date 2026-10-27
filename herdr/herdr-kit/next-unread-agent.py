#!/usr/bin/env python3
"""Focus the next agent that needs attention.

Herdr agent statuses: "done" means the agent finished and the user has
not seen the result yet; "blocked" means the agent waits for user input
(permission prompt or question). Both need attention. "working" and
"idle" (seen) agents are skipped.

Repeated invocations cycle: when the focused pane is itself a candidate,
the next candidate in agent-list order is chosen (wrap around).
"""

import json
import os
import subprocess
import sys

ATTENTION_STATUSES = ('done', 'blocked')


def main():
    herdr = os.environ.get('HERDR_BIN_PATH', 'herdr')
    out = subprocess.run([herdr, 'agent', 'list'], check=True, capture_output=True, text=True).stdout
    agents = json.loads(out)['result']['agents']

    candidates = [a for a in agents if a['agent_status'] in ATTENTION_STATUSES]
    if not candidates:
        subprocess.run(
            [herdr, 'notification', 'show', 'No agent needs attention', '--sound', 'none'],
            check=False,
        )
        return 0

    focused = next((i for i, a in enumerate(candidates) if a.get('focused')), None)
    if focused is None:
        target = candidates[0]
    else:
        target = candidates[(focused + 1) % len(candidates)]

    subprocess.run([herdr, 'agent', 'focus', target['pane_id']], check=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
