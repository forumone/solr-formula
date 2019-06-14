# Get solr
solr-6.6.6:
  file.managed:
    - name: /opt/solr-6.6.6.tgz
    - source: https://archive.apache.org/dist/lucene/solr/6.6.6/solr-6.6.6.tgz
    - source_hash: md5=6a97b6aa2d713e39ea7521cc3468e046
    - unless: test -f /opt/solr-6.6.6.tgz

# Extract solr install file
extract-solr-install:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf solr-6.6.6.tgz solr-6.6.6/bin/install_solr_service.sh --strip-components=2
    - run
    - require:
      - file: solr-6.6.6
    - unless: test -d /opt/solr-6.6.6

# Install solr
install-solr:
  cmd:
    - cwd: /opt
    - names:
      - bash ./install_solr_service.sh solr-6.6.6.tgz
    - run
    - require:
      - file: solr-6.6.6
    - unless: test -d /opt/solr-6.6.6

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-6.6.6

# Create core
create-solr-core:
  cmd:
    - cwd: /opt/solr
    - names:
      - bash bin/solr create -c {{ salt['pillar.get']('core', 'vagrant') }}
    - run
    - user: solr

/var/solr/data/{{ salt['pillar.get']('siteuser', 'vagrant') }}:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v6/core') }}
    - user: solr

# Sudo file to allow restarting solr
/etc/sudoers.d/solr:
  file.managed:
    - source: salt://solr/files/v6/sudoers
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - context:
        user: {{ salt['pillar.get']('project', 'root') }}
