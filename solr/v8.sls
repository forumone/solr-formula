# Get solr
solr-8.1.1:
  file.managed:
    - name: /opt/solr-8.1.1.tgz
    - source: https://archive.apache.org/dist/lucene/solr/8.1.1/solr-8.1.1-src.tgz
    - source_hash: sha512=cd0e5f90cdf97e9de786ab969cb894af8564afeb31522f35c8b73a6d959115d50a812019cfe2476479a74197772525d20c6d0a8174b31b7c8517743caa46efef
    - unless: test -f /opt/solr-8.1.1-src.tgz

# Extract solr install file
extract-solr-install:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf solr-8.1.1-src.tgz solr-8.1.1/bin/install_solr_service.sh --strip-components=2
    - run
    - require:
      - file: solr-8.1.1
    - unless: test -d /opt/solr-8.1.1

# Install solr
install-solr:
  cmd:
    - cwd: /opt
    - names:
      - bash ./install_solr_service.sh solr-8.1.1.tgz
    - run
    - require:
      - file: solr-8.1.1
    - unless: test -d /opt/solr-8.1.1

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-8.1.1

# Create core
create-solr-core:
  cmd:
    - cwd: /opt/solr
    - names:
      - bash bin/solr create -c {{ salt['pillar.get']('siteuser', 'vagrant') }}
    - run
    - user: solr

/var/solr/data/{{ salt['pillar.get']('siteuser', 'vagrant') }}:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v7/core') }}
    - user: solr

# Sudo file to allow restarting solr
/etc/sudoers.d/solr:
  file.managed:
    - source: salt://solr/files/v8/sudoers
    - user: root
    - group: root
    - mode: 440
    - template: jinja
    - context:
        user: {{ salt['pillar.get']('project', 'root') }}
