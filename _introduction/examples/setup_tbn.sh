#!/bin/bash -e
#
# Copyright 2018 Turbine Labs, Inc.
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.

# Install tbnctl
go get -u github.com/turbinelabs/tbnctl
go install github.com/turbinelabs/tbnctl

# Login (interactive)
echo Log in with your Houston password:
tbnctl login

# Set up some objects
tbnctl init-zone testbed
echo using zone testbed

has_proxy=$(tbnctl list proxy | grep testbed)
if [ -z "$has_proxy" ]
then
    tbnctl create proxy testbed-proxy
    echo created proxy testbed-proxy
else
    echo testbed-proxy proxy already exists
fi

# Look for an access token
has_access_token=$(tbnctl access-tokens list | grep "setup_tbnctl.sh key")
if [ -z "$has_access_token" ]
then
    tbnctl access-tokens add "setup_tbnctl.sh key"
    echo created new access token \"setup_tbnctl.sh key\":
else
    echo using existing access token \"setup_tbnctl.sh key\":
fi
tbnctl access-tokens list | grep -B 2 -A 3 "setup_tbnctl.sh key"
