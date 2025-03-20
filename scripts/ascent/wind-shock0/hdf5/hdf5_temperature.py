import conduit
import conduit.blueprint as blueprint
import conduit.relay as relay
import numpy as np

n = conduit.Node()
in_file = 'pl_geometric_clip.cycle_000002.root'
relay.io.load(n, in_file, "hdf5")
# print content
print(n['mesh']['fields']['Temperature'])

mini = np.min(n["mesh/fields/Temperature/values"])
print(f'mini={mini}')
