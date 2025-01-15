# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/sh

#example: ./sign-release-artifacts.sh <GPG_LOCAL_USER> <MANIFOLDCF_SDK_VERSION> (for example: ./sign-release-artifacts.sh piergiorgio@apache.org 1.0.2)
gpg_local_user=$1
mcf_sdk_version=$2

gpg --local-user "$1" --armor --output target/apache-manifoldcf-sdk-$2-src.tar.gz.asc --detach-sig target/apache-manifoldcf-sdk-$2-src.tar.gz
gpg --local-user "$1" --armor --output target/apache-manifoldcf-sdk-$2-src.zip.asc --detach-sig target/apache-manifoldcf-sdk-$2-src.zip

gpg --print-md MD5 target/apache-manifoldcf-sdk-$2-src.tar.gz > target/apache-manifoldcf-sdk-$2-src.tar.gz.md5
gpg --print-md MD5 target/apache-manifoldcf-sdk-$2-src.zip > target/apache-manifoldcf-sdk-$2-src.zip.md5

gpg --print-md SHA512 target/apache-manifoldcf-sdk-$2-src.tar.gz > target/apache-manifoldcf-sdk-$2-src.tar.gz.sha512
gpg --print-md SHA512 target/apache-manifoldcf-sdk-$2-src.zip > target/apache-manifoldcf-sdk-$2-src.zip.sha512