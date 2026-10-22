from dataclasses import dataclass
from typing import List

@dataclass
class Lead:
    name: str
    email: str
    company: str
    stage: str = 'new'
    value: float = 0.0
    source: str = 'manual'


def seed_leads() -> List[Lead]:
    return [
        Lead('Ava Patel', 'ava@northstar.ai', 'Northstar AI', 'qualified', 12000, 'outbound'),
        Lead('Milo Chen', 'milo@atlascloud.io', 'Atlas Cloud', 'proposal', 18000, 'partner'),
        Lead('Sofia Reed', 'sofia@greenline.io', 'Greenline', 'demo', 9500, 'inbound'),
    ]
