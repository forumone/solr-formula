# Get solr
solr-6.6.6:
  file.managed:
    - name: /opt/solr-6.6.6-src.tgz
    - source: https://archive.apache.org/dist/lucene/solr/6.6.6/solr-6.6.6-src.tgz
    - source_hash: md5=6a97b6aa2d713e39ea7521cc3468e046
    - unless: test -f /opt/solr-6.6.6-src.tgz

# Extract it
extract-solr:
  cmd:
    - cwd: /opt
    - names:
      - tar xzf solr-6.6.6-src.tgz
    - run
    - require:
      - file: solr-6.6.6
    - unless: test -d /opt/solr-6.6.6

# link it
/opt/solr:
  file.symlink:
    - target: /opt/solr-6.6.6

/opt/solr/example/multicore/vagrant:
  file.recurse:
    - source: {{ salt['pillar.get']('solr:conf', 'salt://solr/files/v6') }}
    - user: root

/opt/solr/example/multicore/solr.xml:
  file.managed:
    - source: salt://solr/files/solr.xml
    - mode: 644
    # Don't overwrite if already exists
    - unless: test -f /opt/solr/example/multicore/solr.xml
    - watch_in:
      - service: jetty-service

# init
/etc/init.d/jetty:
  file.managed:
    - source: salt://solr/files/jetty-init
    - mode: 744

/sbin/chkconfig --add jetty:
  cmd.run:
    - unless: /sbin/chkconfig | grep -q jetty
    - require:
      - file: /etc/init.d/jetty

jetty-service:
  service:
    - name: jetty
    - enable: True
    - sig: Dsolr
    - running

# logrotate
/etc/logrotate.d/jetty:
  file.managed:
    - source: salt://solr/files/jetty-logrotate
    - mode: 744

