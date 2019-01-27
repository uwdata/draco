import json
import logging
import os
import subprocess
from typing import Dict, List, Optional, Tuple

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def absolute_path(p: str) -> str:
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), p)


def vl2asp(vl: Dict) -> List[str]:
    proc = subprocess.Popen(
        args=["node", absolute_path("../js/bin/vl2asp")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = proc.communicate(json.dumps(vl).encode("utf8"))

    if stderr:
        logger.error("stderr: %s", stderr)

    return list(filter(lambda x: x, stdout.decode("utf-8").split("\n")))


def asp2vl(asp: List[str]) -> Dict:
    proc = subprocess.Popen(
        args=["node", absolute_path("../js/bin/asp2vl")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = proc.communicate("\n".join(asp).encode("utf8"))

    if stderr:
        logger.error("stderr: %s", stderr)

    return json.loads(stdout)


def cql2asp(cql: Dict) -> List[str]:
    proc = subprocess.Popen(
        args=["node", absolute_path("../js/bin/cql2asp")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = proc.communicate(json.dumps(cql).encode("utf8"))

    if stderr:
        logger.error("stderr: %s", stderr)

    return stdout.decode("utf-8").split("\n")


def data2schema(data: List) -> Dict:
    proc = subprocess.Popen(
        args=["node", absolute_path("../js/bin/data2schema")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = proc.communicate(json.dumps(data).encode("utf8"))

    if stderr:
        logger.error("stderr: %s", stderr)

    return json.loads(stdout)


def schema2asp(schema: Dict) -> List[str]:
    proc = subprocess.Popen(
        args=["node", absolute_path("../js/bin/schema2asp")],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    stdout, stderr = proc.communicate(json.dumps(schema).encode("utf8"))

    if stderr:
        logger.error("stderr: %s", stderr)

    return stdout.decode("utf-8").split("\n")
