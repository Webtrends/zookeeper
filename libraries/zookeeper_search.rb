#
# Cookbook Name:: zookeeper
# Library:: zookeeper_search
# Author:: David Dvorak (<david.dvorak@webtrends.com>)
#
# Copyright 2012, Webtrends Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module ZookeeperSearch

  def zookeeper_search(role, limit = 1000)

    search_timeout = 60 # seconds

    Chef::Log.info "zookeeper_cluster_name: #{node[:zookeeper][:cluster_name]}"

    results = []

    if node[:zookeeper][:cluster_name] == 'default'

      # search for nodes with default cluster name
      query =  "chef_environment:#{node.chef_environment}"
      query << " AND role:#{role}"
      query << " AND zookeeper_cluster_name:#{node[:zookeeper][:cluster_name]}"
      Chef::Log.info "zookeeper_search: #{query}"

      i = 0
      while results.count == 0 && i < search_timeout
        search(:node, query).each { |n| results << n[:fqdn] }
        if results.count == 0
          Chef::Log.warn 'zookeeper_search: no results, sleeping...'
          i += 5
          sleep 5
        end
      end

      # search for nodes that have no cluster name
      query =  "chef_environment:#{node.chef_environment}"
      query << " AND role:#{role}"
      query << ' AND NOT zookeeper_cluster_name:*'
      Chef::Log.info "zookeeper_search: #{query}"

      search(:node, query).each { |n| results << n[:fqdn] }

    else

      # search for nodes with a non-default cluster name
      query =  "chef_environment:#{node.chef_environment}"
      query << " AND role:#{role}"
      query << " AND zookeeper_cluster_name:#{node[:zookeeper][:cluster_name]}"
      Chef::Log.info "zookeeper_search: #{query}"

      i = 0
      while results.count == 0 && i < search_timeout
        search(:node, query).each { |n| results << n[:fqdn] }
        if results.count == 0
          Chef::Log.warn 'zookeeper_search: no results, sleeping...'
          i += 5
          sleep 5
        end
      end

    end

    Chef::Log.warn  "zookeeper_search: slept for #{i} seconds." if i > 0
    Chef::Log.debug "zookeeper_search: #{role}: nodes found: #{results.count}"
    if results.count == 0 || results.count > limit
      Chef::Log.error "zookeeper_search: #{role}: nodes found: #{results.count}"
    else
      Chef::Log.info "zookeeper_search: #{role}: #{results.first}"
    end

    results

  end

end

class Chef::Recipe; include ZookeeperSearch; end
