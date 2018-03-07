/etc/etcd/etcd.conf:
  file.managed:
  - source: salt://etcd/etcd.conf.jinja
  - template: jinja
  - require:
    - pkg: etcd
  - defaults:
      nodes:
        {% for node, ip in pillar['nodes'].items() -%}
        {{ node }}: {{ ip }}
        {% endfor %}
etcd:
  pkg.installed: []
  service.running:
  - enable: true
  - require:
    - pkg: etcd
  - watch:
    - file: /etc/etcd/etcd.conf
