import yaml
import logging
import salt.cloud
import salt.client.ssh.client

from copy import copy

cloud = salt.cloud.CloudClient('/etc/salt/cloud.providers')


def deploy(node_name):
    node = cloud.profile('etcd-node', node_name)
    ip = node[node_name]['networks']['v4'][0]['ip_address']

    # ssh = salt.client.ssh.client.SSHClient()
    # iargs = {
    #     'pkgs': [
    #         'vim',
    #         'tmux',
    #         'rxvt-unicode'
    #     ]
    # }
    return ip


log = logging.getLogger()
logging.basicConfig(level=logging.DEBUG)

cloud_map = {}
for node in ['ring{:02}'.format(x) for x in range(0, 3)]:
    log.info('Launching {}'.format(node))
    cloud_map[node] = deploy(node)
print(cloud_map)

rostears = {}
node_defaults = {
    'priv': '/home/ark/.ssh/etcd',
}

for node, ip in cloud_map.items():
    rostears[node] = copy(node_defaults)
    rostears[node]['host'] = ip

with open('/etc/salt/roster', 'w') as fd:
    yaml.dump(rostears, fd, default_flow_style=False)
log.info('Roster updated')

with open('/srv/salt/etcd/init.sls') as fd:
    etcd_init = yaml.load(fd)

for i in etcd_init['/etc/etcd/etcd.conf']['file.managed']:
    if 'defaults' in i:
        i['defaults'] = {'nodes': cloud_map}

with open('/srv/salt/etcd/init.sls', 'w') as fd:
    yaml.dump(etcd_init, fd, default_flow_style=False)

log.info('etcd state updated')

ssh = salt.client.ssh.client.SSHClient()
pending_run = True
while pending_run:
    result = ssh.cmd('*', 'state.apply', ('etcd',), ignore_host_keys=True)
    for node, detail in result.items():
        if detail.get('retcode', 0) == 255:
            log.info('Communication error with {}, retring...'.format(node))
            break
    else:
        log.info('State applied in all nodes'.format(node))
        pending_run = False
