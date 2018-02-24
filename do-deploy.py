import sys
import yaml
import salt.cloud
import salt.client.ssh.client

from pprint import pprint

cloud = salt.cloud.CloudClient('/etc/salt/cloud.providers')

pprint(cloud.query())

node_name = sys.argv[1]
node = cloud.profile('etcd-node', node_name)
ip = node[node_name]['networks']['v4'][0]['ip_address']

with open('/etc/salt/roster') as fd:
    rostears = yaml.load(fd)

node_defaults = {
    'priv': '/home/ark/.ssh/etcd',
    'user': 'root'
}

rostears[node_name] = node_defaults
rostears[node_name]['host'] = ip

with open('/etc/salt/roster', 'w') as fd:
    yaml.dump(rostears, fd, default_flow_style=False)

ssh = salt.client.ssh.client.SSHClient()
iargs = {
    'pkgs': [
        'vim',
        'tmux',
        'etcd',
        'rxvt-unicode'
    ]
}
print(ssh.cmd(node_name, 'pkg.install', kwarg=iargs, ignore_host_keys=True))
