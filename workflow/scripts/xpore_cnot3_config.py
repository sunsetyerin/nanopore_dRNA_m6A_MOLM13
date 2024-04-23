import sys
sys.stderr = open(snakemake.log[0], "w")

from collections import defaultdict
from pathlib import Path

import yaml

data = defaultdict(dict)

data["control"]["rep1"] = str(Path("results/xpore/xpore_dataprep/control_0/data.json").resolve().parent)
data["control"]["rep2"] = str(Path("results/xpore/xpore_dataprep/control_1/data.json").resolve().parent)
data["control"]["rep3"] = str(Path("results/xpore/xpore_dataprep/control_2/data.json").resolve().parent)
data["control"]["rep4"] = str(Path("results/xpore/xpore_dataprep/control_3/data.json").resolve().parent)

data["test"]["rep1"] = str(Path("results/xpore/xpore_dataprep/cnot3_test_0/data.json").resolve().parent)
data["test"]["rep2"] = str(Path("results/xpore/xpore_dataprep/cnot3_test_1/data.json").resolve().parent)
data["test"]["rep3"] = str(Path("results/xpore/xpore_dataprep/cnot3_test_2/data.json").resolve().parent)
data["test"]["rep4"] = str(Path("results/xpore/xpore_dataprep/cnot3_test_3/data.json").resolve().parent)

criteria = {
    "readcount_min": snakemake.params.readcount_min,
    "readcount_max": snakemake.params.readcount_max,
}

yml = {"out": str(Path(snakemake.params.outdir)),
       "data": dict(data), 
       "criteria": criteria}

with open(snakemake.output.configuration, "w") as ofp:
    yaml.dump(yml, ofp, default_flow_style=False)
