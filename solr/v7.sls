# Get solr
solr-7.3.1:
  file.managed:
    - name: /opt/solr-7.3.1.tgz
    - source: https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
    - source_hash: md5=042a6c0d579375be1a8886428f13755f
    - unless: test -f /opt/solr-7.3.1.tgz

# Extract it
extract-solr:
  cmd:
    - cwd: /opt
    - names:
      - tar zxf solr-7.3.1.tgz
    - run
    - require:
      - file: solr-7.3.1
    - unless: test -d /opt/solr-7.3.1

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-7.3.1

/opt/solr/server/solr/vagrant:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v7/core') }}
    - user: root
