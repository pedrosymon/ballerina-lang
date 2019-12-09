// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;
import ballerina/http;
import ballerina/io;

http:ClientEndpointConfig mutualSslCertClientConf = {
    secureSocket:{
        keyFile: config:getAsString("certificate.key"),
        certFile: config:getAsString("public.cert"),
        trustedCertFile: config:getAsString("public.cert")
    }
};

public function main (string... args) {
    http:Client clientEP = new("https://localhost:9217", config = mutualSslCertClientConf );
    http:Request req = new;
    var resp = clientEP->get("/echo/");
    if (resp is http:Response) {
        var payload = resp.getTextPayload();
        if (payload is string) {
            io:println(payload);
        } else if (payload is error) {
            io:println(<string> payload.detail().message);
        }
    } else if (resp is error) {
        io:println(<string> resp.detail().message);
    }
}