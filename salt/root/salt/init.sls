/etc/salt/cloud.profiles.d:
  file.recurse:
  - source: salt://salt/cloud.profiles.d

/etc/salt/cloud.providers.d:
  file.recurse:
  - source: salt://salt/cloud.providers.d


/etc/salt/roster:
  file.managed:
  - source: salt://roster
  - template: jinja
  - context:
    cuca: {{ pillar['bar'] }}
  

/srv/salt/salt:
  file.recurse:
  - source: salt://salt

/srv/salt/etcd:
  file.recurse:
  - source: salt://etcd

salt:
  pkg.installed:
    - pkgs:
      - salt
      - salt-cloud
      - salt-ssh
      - python2-etcd
      - git

cucaraft_app:
  git.latest:
    - name: https://github.com/arksega/cucaraft.git
    - target: /opt/cucaraft

/usr/bin/beacon:
  file.copy:
    - source: /opt/cucaraft/beacon
    - mode: 755

/etc/systemd/system/cuca.service:
  file.copy:
    - source: /opt/cucaraft/cuca.service

cuca:
  service.running:
    - enable: True
