import json
import logging
import subprocess
import os
from typing import Dict, List, Optional, Tuple

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(__file__), p)

def vl2asp(vl: Dict) -> List[str]:
    proc = subprocess.Popen(
        args=['node', absolute_path('../js/bin/vl2asp')],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate(json.dumps(vl).encode('utf8'))

    if stderr:
        logger.error('stderr: %s', stderr)

    return stdout.decode('utf-8').split('\n')

def asp2vl(asp: List[str]) -> Dict:
    proc = subprocess.Popen(
        args=['node', absolute_path('../js/bin/asp2vl')],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate('\n'.join(asp).encode('utf8'))

    if stderr:
        logger.error('stderr: %s', stderr)

    return json.loads(stdout)
