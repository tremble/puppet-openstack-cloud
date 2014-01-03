#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for privatecloud::image class
#

require 'spec_helper'

describe 'privatecloud::image' do

  shared_examples_for 'openstack image' do

    let :params do
      { :glance_db_host            => '10.0.0.1',
        :glance_db_user            => 'glance',
        :glance_db_password        => 'secrete',
        :ks_keystone_internal_host => '10.0.0.1',
        :ks_glance_internal_port   => '9292',
        :ks_glance_password        => 'secrete',
        :rabbit_host               => '10.0.0.1',
        :rabbit_password           => 'secrete',
        :debug                     => true,
        :verbose                   => true,
        :api_eth                   => '10.0.0.1' }
    end

    it 'configure glance-api' do
      should contain_class('glance::api').with(
          :sql_connection    => 'mysql://glance:secrete@10.0.0.1/glance',
          :keystone_password => 'secrete',
          :keystone_tenant   => 'services',
          :keystone_user     => 'glance',
          :verbose           => true,
          :debug             => true,
          :auth_host         => '10.0.0.1',
          :log_facility      => 'LOG_LOCAL0',
          :bind_host         => '10.0.0.1',
          :use_syslog        => true
        )
    end

    it 'configure glance-registry' do
      should contain_class('glance::registry').with(
          :sql_connection    => 'mysql://glance:secrete@10.0.0.1/glance',
          :keystone_password => 'secrete',
          :keystone_tenant   => 'services',
          :keystone_user     => 'glance',
          :verbose           => true,
          :debug             => true,
          :auth_host         => '10.0.0.1',
          :log_facility      => 'LOG_LOCAL0',
          :bind_host         => '10.0.0.1',
          :use_syslog        => true
        )
    end

    it 'configure glance notifications with rabbitmq backend' do
      should contain_class('glance::notify::rabbitmq').with(
          :rabbit_password => 'secrete',
          :rabbit_userid   => 'glance',
          :rabbit_host     => '10.0.0.1'
        )
    end

    it 'configure glance swift backend' do
      should contain_class('glance::backend::swift').with(
          :swift_store_user          => 'services:glance',
          :swift_store_key           => 'secrete',
          :swift_store_auth_address  => '10.0.0.1',
        )
    end

    it 'configure crontab to clean glance cache' do
      should contain_class('glance::cache::cleaner')
      should contain_class('glance::cache::pruner')
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack image'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack image'
  end

end
