/etc/salt/cloud.profiles.d:
  file.recurse:
  - source: salt://salt/cloud.profiles.d

/etc/salt/cloud.providers.d/do.conf:
  file.managed:
  - source: salt://salt/cloud.providers.d/do.conf
  - template: jinja


/etc/salt/roster:
  file.managed:
  - source: salt://roster
  - template: jinja
  - context:
    cuca: {{ pillar['source_key_path'] }}

/root/.ssh/etcd:
  file.managed:
  - contents_pillar: source_key
  - mode: 600

/srv/salt/salt:
  file.recurse:
  - source: salt://salt
  
/srv/pillar:
  file.recurse:
  - source: salt://pillar

/srv/salt/pillar:
  file.symlink:
    - target: /srv/pillar

/srv/salt/etcd:
  file.recurse:
  - source: salt://etcd

salt:
  pkg.installed:
    - pkgs:
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
