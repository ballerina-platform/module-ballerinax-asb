// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.org).
// Licensed under the Apache License, Version 2.0.

import ballerina/log;
import ballerina/test;
import ballerina/time;

// Share one timestamp across all names in this test process. Keep names valid for Azure.
final string testResourceSuffix = createTestResourceSuffix();
map<boolean> createdTestQueues = {};
map<boolean> createdTestTopics = {};

function createTestResourceSuffix() returns string {
    time:Utc now = time:utcNow();
    int nanoseconds = <int>(now[1] * 1000000000d);
    return string `${now[0]}-${nanoseconds}`;
}

function newTestResourceName(string baseName) returns string {
    return string `asb-test-${baseName}-${testResourceSuffix}`;
}

// Record ownership only after successful creation. Explicitly configured names that
// already exist must never be deleted by this fallback cleanup.
@test:AfterSuite {alwaysRun: true}
function cleanupTestResources() returns error? {
    if createdTestQueues.length() == 0 && createdTestTopics.length() == 0 {
        return;
    }
    Administrator adminClient = check new (connectionString);
    boolean failed = false;
    // Deleting topics also deletes their subscriptions/rules and forwarding sources.
    foreach string name in createdTestTopics.keys() {
        error? result = cleanupTestTopic(adminClient, name);
        if result is error {
            log:printError(string `Failed to clean up test topic ${name}`, result);
            failed = true;
        }
    }
    foreach string name in createdTestQueues.keys() {
        error? result = cleanupTestQueue(adminClient, name);
        if result is error {
            log:printError(string `Failed to clean up test queue ${name}`, result);
            failed = true;
        }
    }
    if failed {
        return error("Failed to clean up some ASB test resources; see preceding errors");
    }
}

function cleanupTestTopic(Administrator adminClient, string name) returns error? {
    boolean? exists = check adminClient->topicExists(name);
    if exists == true {
        check adminClient->deleteTopic(name);
    } else if exists is () {
        return error(string `Could not determine whether test topic ${name} exists`);
    }
}

function cleanupTestQueue(Administrator adminClient, string name) returns error? {
    boolean? exists = check adminClient->queueExists(name);
    if exists == true {
        check adminClient->deleteQueue(name);
    } else if exists is () {
        return error(string `Could not determine whether test queue ${name} exists`);
    }
}
