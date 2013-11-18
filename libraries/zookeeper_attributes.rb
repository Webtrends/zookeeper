#
# Cookbook Name:: zookeeper
# Library:: zookeeper_attributes
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

module ZookeeperAttributes

	def zookeeper_attrib(*keys)

		raise ArgumentError, 'Requires 1 or more arguments.' unless keys.length > 0

		cluster_name = construct_attributes[:zookeeper][:cluster_name]
		Chef::Log.debug "zookeeper_attrib: cluster_name: #{cluster_name}"

		# compose call to get zookeeper default attribute
		default_call = "construct_attributes[:zookeeper][:default]"
		keys.each {|k| default_call << "[:#{k}]" }

		# get zookeeper cluster_name attribute if it exists, otherwise get zookeeper default attribute
		if eval("construct_attributes[:zookeeper].attribute?(cluster_name)")
			cluster_keys = "[:zookeeper][cluster_name]"
			count = 0
			keys.each do |k|
				break unless eval("construct_attributes#{cluster_keys}.attribute?(:#{k})")
				cluster_keys << "[:#{k}]"
				count += 1
			end
			if count == keys.length
				cluster_call = "construct_attributes#{cluster_keys}"
				Chef::Log.info "zookeeper_attrib: cluster_call: #{cluster_call}"
				eval(cluster_call)
			else
				Chef::Log.info "zookeeper_attrib: default_call: #{default_call}"
				eval(default_call)
			end
		else
			Chef::Log.info "zookeeper_attrib: default_call: #{default_call}"
			eval(default_call)
		end

	end

end

class Chef::Node; include ZookeeperAttributes; end
