# Get solr
solr-7.3.1:
  file.managed:
    - name: /opt/solr-7.3.1.tgz
    - source: https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
    - source_hash: md5=042a6c0d579375be1a8886428f13755f
    - unless: test -f /opt/solr-7.3.1.tgz

# Extract solr install file
extract-solr-install:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf solr-7.3.1.tgz solr-7.3.1/bin/install_solr_service.sh --strip-components=2
    - run
    - require:
      - file: solr-7.3.1
    - unless: test -d /opt/solr-7.3.1

# Install solr
install-solr:
  cmd:
    - cwd: /opt
    - names:
      - bash ./install_solr_service.sh solr-7.3.1.tgz
    - run
    - require:
      - file: solr-7.3.1
    - unless: test -d /opt/solr-7.3.1

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-7.3.1

# Create core
create-solr-core:
  cmd:
    - cwd: /opt/solr
    - names:
      - bash bin/solr create {{ salt['pillar.get']('siteuser', 'vagrant') }}
    - run
    - user: solr

/var/solr/data/{{ salt['pillar.get']('siteuser', 'vagrant') }}:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v7/core') }}
    - user: solr

# Sudo file to allow restarting solr
/etc/sudoers.d/solr:
  file.managed:
    - source: salt://solr/files/v7/sudoers
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - context:
        user: {{ salt['pillar.get']('project', 'root') }}
