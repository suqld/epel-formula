# Completely ignore non-RHEL based systems
{% if grains['os_family'] == 'RedHat' %}
  {% set epel_release = salt['pillar.get']('epel:release', false) %}
# A lookup table for EPEL GPG keys & RPM URLs for various RedHat releases
{% if ( grains['saltversion'] >= '2017.7.0' and grains['osmajorrelease'] == 5 ) or ( grains['saltversion'] < '2017.7.0' and grains['osmajorrelease'][0] == '5' ) %}
  {% set pkg = {
    'key': 'https://fedoraproject.org/static/A4D647E9.txt',
    'key_hash': 'md5=a1d12cd9628338ddb12e9561f9ac1d6a',
    'rpm': 'http://download.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm',
  } %}
{% elif ( grains['saltversion'] >= '2017.7.0' and grains['osmajorrelease'] == 6 ) or ( grains['saltversion'] < '2017.7.0' and grains['osmajorrelease'][0] == '6' ) %}
  {% set pkg = {
    'key': 'https://fedoraproject.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'http://download.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  } %}
{% elif ( grains['saltversion'] >= '2017.7.0' and grains['osmajorrelease'] == 7 ) or ( grains['saltversion'] < '2017.7.0' and grains['osmajorrelease'][0] == '7' ) %}
  {% set pkg = {
    'key': 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7',
    'key_hash': 'md5=58fa8ae27c89f37b08429f04fd4a88cc',
    'rpm': 'http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm',
  } %}
{% elif grains['os'] == 'Amazon' and ( ( grains['saltversion'] >= '2017.7.0' and grains['osmajorrelease'] == 2014 ) or ( grains['saltversion'] < '2017.7.0' and grains['osmajorrelease'] == '2014' ) ) %}
  {% set pkg = {
    'key': 'https://fedoraproject.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'http://download.fedoraproject.org/pub/epel/6/i386/epel-release-' ~ epel_release|default('6-8', true) ~ '.noarch.rpm',
  } %}
{% elif grains['os'] == 'Amazon' and ( ( grains['saltversion'] >= '2017.7.0' and grains['osmajorrelease'] == 2015 ) or ( grains['saltversion'] < '2017.7.0' and grains['osmajorrelease'] == '2015' ) ) %}
  {% set pkg = {
    'key': 'https://fedoraproject.org/static/0608B895.txt',
    'key_hash': 'md5=eb8749ea67992fd622176442c986b788',
    'rpm': 'http://download.fedoraproject.org/pub/epel/6/i386/epel-release-' ~ epel_release|default('6-8', true) ~ '.noarch.rpm',
  } %}
{% endif %}


install_pubkey_epel:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL
    - source: {{ salt['pillar.get']('epel:pubkey', pkg.key) }}
    - source_hash:  {{ salt['pillar.get']('epel:pubkey_hash', pkg.key_hash) }}


epel_release:
  pkg.installed:
    - sources:
      - epel-release: {{ salt['pillar.get']('epel:rpm', pkg.rpm) }}
    - require:
      - file: install_pubkey_epel

set_pubkey_epel:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL'
    - require:
      - pkg: epel_release

set_gpg_epel:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/epel.repo
    - pattern: 'gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: epel_release

{% if salt['pillar.get']('epel:disabled', False) %}
disable_epel:
  file.replace:
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=0'
{% else %}
enable_epel:
  file.replace:
    - name: /etc/yum.repos.d/epel.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=1'
{% endif %}

{% if salt['pillar.get']('epel:testing', False) %}
enable_epel_testing:
  file.replace:
    - name: /etc/yum.repos.d/epel-testing.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=1'
{% else %}
disable_epel_testing:
  file.replace:
    - name: /etc/yum.repos.d/epel-testing.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=0'
{% endif %}
{% endif %}
