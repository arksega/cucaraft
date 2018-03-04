/etc/etcd/etcd.conf:
  file.managed:
  - source: salt://etcd/etcd.conf.jinja
  - template: jinja
  - require:
    - pkg: etcd
  - defaults:
      nodes:
        ring00: 46.101.238.103
        ring01: 207.154.210.70
        ring02: 188.166.164.2
etcd:
  pkg.installed: []
  service.running:
  - enable: true
  - require:
    - pkg: etcd
  - watch:
    - file: /etc/etcd/etcd.conf
