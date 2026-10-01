// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/log;
import ballerina/os;
import ballerina/test;

// Connection Configurations
configurable string connectionString = os:getEnv("CONNECTION_STRING");
configurable string testTopic1 = newTestResourceName("topic1");
configurable string testTopic2 = newTestResourceName("topic2");
configurable string testSubscription1 = "subscription1";
configurable string testSubscription2 = "subscription2";
configurable string testRule1 = "rule1";
configurable string testQueue1 = newTestResourceName("queue1");
configurable string testQueue2 = newTestResourceName("queue2");
configurable string testRule2 = "rule2";
configurable string testTopic4 = newTestResourceName("topic4");
configurable string testSubscription4 = "subscription4";
configurable string testRule4 = "rule4";
configurable string testQueue4 = newTestResourceName("queue4");
string subscriptionPath1 = testSubscription1;
string userMetaData = "Test User Meta Data";

SqlRule rule = {
    filter: "1=1",
    action: "SET a = 'b'"
};

Duration deletion = {
    seconds: 80000,
    nanoseconds: 101
};
Duration dupdue = {
    seconds: 80000,
    nanoseconds: 101
};
Duration ttl = {
    seconds: 70000,
    nanoseconds: 200
};
Duration lockDue = {
    seconds: 90,
    nanoseconds: 200
};
CreateTopicOptions topicConfig = {
    autoDeleteOnIdle: deletion,
    defaultMessageTimeToLive: ttl,
    duplicateDetectionHistoryTimeWindow: dupdue,
    lockDuration: lockDue,
    maxDeliveryCount: 10,
    maxSizeInMegabytes: 1024,
    status: ACTIVE,
    userMetadata: userMetaData,
    enableBatchedOperations: true,
    deadLetteringOnMessageExpiration: true,
    requiresDuplicateDetection: false,
    enablePartitioning: false,
    requiresSession: false,
    supportOrdering: false
};
UpdateTopicOptions updateTopicConfig = {
    autoDeleteOnIdle: deletion,
    defaultMessageTimeToLive: ttl,
    duplicateDetectionHistoryTimeWindow: dupdue,
    maxDeliveryCount: 10,
    maxSizeInMegabytes: 1024,
    status: ACTIVE,
    userMetadata: userMetaData,
    enableBatchedOperations: true,
    deadLetteringOnMessageExpiration: true,
    requiresDuplicateDetection: false,
    enablePartitioning: false,
    requiresSession: false,
    supportOrdering: false
};
CreateSubscriptionOptions subConfig = {
    autoDeleteOnIdle: deletion,
    enableBatchedOperations: true,
    deadLetteringOnMessageExpiration: true,
    defaultMessageTimeToLive: ttl,
    deadLetteringOnFilterEvaluationExceptions: true,
    forwardDeadLetteredMessagesTo: testQueue1,
    forwardTo: testQueue1,
    requiresSession: false,
    lockDuration: lockDue,
    maxDeliveryCount: 10,
    status: ACTIVE,
    userMetadata: userMetaData
};
UpdateSubscriptionOptions updateSubConfig = {
    autoDeleteOnIdle: deletion,
    defaultMessageTimeToLive: ttl,
    deadLetteringOnMessageExpiration: true,
    deadLetteringOnFilterEvaluationExceptions: true,
    enableBatchedOperations: true,
    forwardDeadLetteredMessagesTo: testQueue1,
    forwardTo: testQueue1,
    lockDuration: lockDue,
    maxDeliveryCount: 10,
    status: ACTIVE,
    userMetadata: userMetaData
};
CreateQueueOptions queueConfig = {
    autoDeleteOnIdle: deletion,
    defaultMessageTimeToLive: ttl,
    duplicateDetectionHistoryTimeWindow: dupdue,
    forwardDeadLetteredMessagesTo: testQueue1,
    forwardTo: testQueue1,
    lockDuration: lockDue,
    maxDeliveryCount: 10,
    maxMessageSizeInKilobytes: 0,
    maxSizeInMegabytes: 1024,
    status: ACTIVE,
    userMetadata: userMetaData,
    enableBatchedOperations: true,
    deadLetteringOnMessageExpiration: true,
    requiresDuplicateDetection: false,
    enablePartitioning: false,
    requiresSession: false
};
UpdateQueueOptions updateQueueConfig = {
    autoDeleteOnIdle: deletion,
    defaultMessageTimeToLive: ttl,
    duplicateDetectionHistoryTimeWindow: dupdue,
    forwardDeadLetteredMessagesTo: testQueue2,
    lockDuration: lockDue,
    maxDeliveryCount: 10,
    maxMessageSizeInKilobytes: 0,
    maxSizeInMegabytes: 1024,
    status: ACTIVE,
    userMetadata: userMetaData,
    enableBatchedOperations: true,
    deadLetteringOnMessageExpiration: true,
    requiresDuplicateDetection: false,
    enablePartitioning: false,
    requiresSession: false
};
CreateRuleOptions ruleConfig = {
    rule: rule
};
UpdateRuleOptions updateRuleConfig = {
    rule: rule
};

@test:Config {
    groups: ["asb_admin"],
    enable: true
}
function testCreateQueue() returns error? {
    log:printInfo("[[testCreateQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->createQueue(testQueue1);
    if queueProp is QueueProperties {
        createdTestQueues[testQueue1] = true;
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateQueue],
    enable: true
}
function testQueueExists() returns error? {
    log:printInfo("[[testQueueExists]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    boolean? queueExists = check adminClient->queueExists(testQueue1);
    if queueExists is boolean {
        test:assertTrue(queueExists, msg = "Queue exists failed.");
    } else {
        test:assertFail("Queue exists failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    enable: true
}
function testCreateTopicOperation() returns error? {
    log:printInfo("[[testCreateTopicOperation]]");

    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->createTopic(testTopic1);
    if topicProp is TopicProperties {
        createdTestTopics[testTopic1] = true;
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Topic creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateTopicOperation],
    enable: true
}
function testTopicExists() returns error? {
    log:printInfo("[[testTopicExists]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    boolean? topicExists = check adminClient->topicExists(testTopic1);
    if topicExists is boolean {
        test:assertTrue(topicExists, msg = "Topic creation failed.");
    } else {
        test:assertFail("Topic exists failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateTopicOperation],
    enable: true
}
function testCreateSubscription() returns error? {
    log:printInfo("[[testCreateSubscription]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subscriptionProp = check adminClient->createSubscription(testTopic1, testSubscription1);
    if subscriptionProp is SubscriptionProperties {
        log:printInfo("Subscription created successfully.");
        test:assertEquals(subscriptionProp.status, "Active", msg = "Subscription creation failed.");
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateSubscription],
    enable: true
}
function testSubscriptionExists() returns error? {
    log:printInfo("[[testSubscriptionExists]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    boolean? subscriptionExists = check adminClient->subscriptionExists(testTopic1, testSubscription1);
    if subscriptionExists is boolean {
        test:assertTrue(subscriptionExists, msg = "Subscription exists failed.");
    } else {
        test:assertFail("Subscription exists failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testMessageScheduling],
    enable: true
}
function testCreateRule() returns error? {
    log:printInfo("[[testCreateRule]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->createRule(testTopic1, testSubscription1, testRule1);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule1, msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testQueueExists],
    enable: true
}
function testCreateWithOptionQueue() returns error? {
    log:printInfo("[[testCreateWithOptionQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->createQueue(testQueue2, queueConfig);
    if queueProp is QueueProperties {
        createdTestQueues[testQueue2] = true;
        log:printInfo(queueProp.toString());
        test:assertEquals(queueProp.name, testQueue2, msg = "Queue creation failed. wrong name");
        //test:assertEquals(queueProp.autoDeleteOnIdle, queueConfig.autoDeleteOnIdle, msg = "Queue creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(queueProp.deadLetteringOnMessageExpiration, queueConfig.deadLetteringOnMessageExpiration,
            msg = "Queue creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(queueProp.defaultMessageTimeToLive.seconds, queueConfig.defaultMessageTimeToLive?.seconds,
            msg = "Queue creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(queueProp.duplicateDetectionHistoryTimeWindow.seconds,
            queueConfig.duplicateDetectionHistoryTimeWindow?.seconds, msg = "Queue creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(queueProp.enableBatchedOperations, queueConfig.enableBatchedOperations,
            msg = "Queue creation failed. wrong enableBatchedOperations");
        test:assertEquals(queueProp.enablePartitioning, queueConfig.enablePartitioning, msg = "Queue creation failed.");
        test:assertTrue(queueProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(queueProp.forwardTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardTo");
        test:assertEquals(queueProp.lockDuration.seconds, queueConfig.lockDuration?.seconds, msg = "Queue creation failed. wrong lockDuration");
        test:assertEquals(queueProp.maxDeliveryCount, queueConfig.maxDeliveryCount, msg = "Queue creation failed. wrong maxDeliveryCount");
        test:assertEquals(queueProp.requiresDuplicateDetection, queueConfig.requiresDuplicateDetection,
            msg = "Queue creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(queueProp.requiresSession, queueConfig.requiresSession, msg = "Queue creation failed. wrong requiresSession");
        test:assertEquals(queueProp.status, queueConfig.status, msg = "Queue creation failed. wrong status");
        test:assertEquals(queueProp.userMetadata, queueConfig.userMetadata, msg = "Queue creation failed. wrong userMetadata");
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateQueue],
    enable: true
}
function createQueueWithInclusionParameters() returns error? {
    log:printInfo("[[createQueueWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->createQueue(testQueue4,
                                deadLetteringOnMessageExpiration = true,
                                defaultMessageTimeToLive = ttl,
                                duplicateDetectionHistoryTimeWindow = dupdue,
                                forwardDeadLetteredMessagesTo = testQueue1,
                                forwardTo = testQueue1,
                                lockDuration = lockDue,
                                maxDeliveryCount = 10,
                                requiresDuplicateDetection = false,
                                requiresSession = false,
                                status = ACTIVE,
                                userMetadata = userMetaData);
    if queueProp is QueueProperties {
        createdTestQueues[testQueue4] = true;
        log:printInfo(queueProp.toString());
        test:assertEquals(queueProp.name, testQueue4, msg = "Queue creation failed. wrong name");
        test:assertEquals(queueProp.deadLetteringOnMessageExpiration, true,
            msg = "Queue creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(queueProp.defaultMessageTimeToLive.seconds, ttl.seconds,
            msg = "Queue creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(queueProp.duplicateDetectionHistoryTimeWindow.seconds,
            dupdue.seconds, msg = "Queue creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertTrue(queueProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(queueProp.forwardTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardTo");
        test:assertEquals(queueProp.lockDuration.seconds, lockDue.seconds,
            msg = "Queue creation failed. wrong lockDuration");
        test:assertEquals(queueProp.maxDeliveryCount, 10,
            msg = "Queue creation failed. wrong maxDeliveryCount");
        test:assertEquals(queueProp.requiresDuplicateDetection, false,
            msg = "Queue creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(queueProp.requiresSession, false,
            msg = "Queue creation failed. wrong requiresSession");
        test:assertEquals(queueProp.status, ACTIVE,
            msg = "Queue creation failed. wrong status");
        test:assertEquals(queueProp.userMetadata, userMetaData,
            msg = "Queue creation failed. wrong userMetadata");
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createQueueWithInclusionParameters],
    enable: true
}
function updateQueueWithInclusionParameters() returns error? {
    log:printInfo("[[updateQueueWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->updateQueue(testQueue4,
                                deadLetteringOnMessageExpiration = false,
                                defaultMessageTimeToLive = ttl,
                                duplicateDetectionHistoryTimeWindow = dupdue,
                                forwardDeadLetteredMessagesTo = testQueue1,
                                forwardTo = testQueue1,
                                lockDuration = lockDue,
                                maxDeliveryCount = 10,
                                status = ACTIVE,
                                userMetadata = userMetaData);
    if queueProp is QueueProperties {
        log:printInfo(queueProp.toString());
        test:assertEquals(queueProp.name, testQueue4, msg = "Queue creation failed. wrong name");
        test:assertEquals(queueProp.deadLetteringOnMessageExpiration, false,
            msg = "Queue update failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(queueProp.defaultMessageTimeToLive.seconds, ttl.seconds,
            msg = "Queue update failed. wrong defaultMessageTimeToLive");
        test:assertEquals(queueProp.duplicateDetectionHistoryTimeWindow.seconds,
            dupdue.seconds, msg = "Queue update failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertTrue(queueProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Queue update failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(queueProp.forwardTo.endsWith(testQueue1),
            msg = "Queue update failed. wrong forwardTo");
        test:assertEquals(queueProp.lockDuration.seconds, lockDue.seconds,
            msg = "Queue update failed. wrong lockDuration");
        test:assertEquals(queueProp.maxDeliveryCount, 10,
            msg = "Queue update failed. wrong maxDeliveryCount");
        test:assertEquals(queueProp.status, ACTIVE,
            msg = "Queue update failed. wrong status");
        test:assertEquals(queueProp.userMetadata, userMetaData,
            msg = "Queue update failed. wrong userMetadata");
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue update failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateWithOptionQueue],
    enable: true
}
function testGetQueue() returns error? {
    log:printInfo("[[testCreateWithOptionQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->getQueue(testQueue2);
    if queueProp is QueueProperties {
        log:printInfo(queueProp.toString());
        test:assertEquals(queueProp.name, testQueue2, msg = "Queue creation failed. wrong name");
        //test:assertEquals(queueProp.autoDeleteOnIdle, queueConfig.autoDeleteOnIdle, msg = "Queue creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(queueProp.deadLetteringOnMessageExpiration, queueConfig.deadLetteringOnMessageExpiration,
            msg = "Queue creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(queueProp.defaultMessageTimeToLive.seconds, queueConfig.defaultMessageTimeToLive?.seconds,
            msg = "Queue creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(queueProp.duplicateDetectionHistoryTimeWindow.seconds,
            queueConfig.duplicateDetectionHistoryTimeWindow?.seconds, msg = "Queue creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(queueProp.enableBatchedOperations, queueConfig.enableBatchedOperations,
            msg = "Queue creation failed. wrong enableBatchedOperations");
        test:assertEquals(queueProp.enablePartitioning, queueConfig.enablePartitioning, msg = "Queue creation failed.");
        test:assertTrue(queueProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(queueProp.forwardTo.endsWith(testQueue1),
            msg = "Queue creation failed. wrong forwardTo");
        test:assertEquals(queueProp.lockDuration.seconds, queueConfig.lockDuration?.seconds, msg = "Queue creation failed. wrong lockDuration");
        test:assertEquals(queueProp.maxDeliveryCount, queueConfig.maxDeliveryCount, msg = "Queue creation failed. wrong maxDeliveryCount");
        test:assertEquals(queueProp.requiresDuplicateDetection, queueConfig.requiresDuplicateDetection,
            msg = "Queue creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(queueProp.requiresSession, queueConfig.requiresSession, msg = "Queue creation failed. wrong requiresSession");
        test:assertEquals(queueProp.status, queueConfig.status, msg = "Queue creation failed. wrong status");
        test:assertEquals(queueProp.userMetadata, queueConfig.userMetadata, msg = "Queue creation failed. wrong userMetadata");
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateQueue, testMessageScheduling],
    enable: true
}
function testUpdateQueue() returns error? {
    log:printInfo("[[testUpdateQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    QueueProperties? queueProp = check adminClient->updateQueue(testQueue1, updateQueueConfig);
    if queueProp is QueueProperties {
        log:printInfo(queueProp.toString());
        test:assertEquals(queueProp.name, testQueue1, msg = "Queue creation failed. wrong name");
        //test:assertEquals(queueProp.autoDeleteOnIdle, queueConfig.autoDeleteOnIdle, msg = "Queue creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(queueProp.deadLetteringOnMessageExpiration, updateQueueConfig.deadLetteringOnMessageExpiration,
            msg = "Queue creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(queueProp.defaultMessageTimeToLive.seconds, updateQueueConfig.defaultMessageTimeToLive?.seconds,
            msg = "Queue creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(queueProp.duplicateDetectionHistoryTimeWindow.seconds,
            updateQueueConfig.duplicateDetectionHistoryTimeWindow?.seconds, msg = "Queue creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(queueProp.enableBatchedOperations, queueConfig.enableBatchedOperations,
            msg = "Queue creation failed. wrong enableBatchedOperations");
        test:assertEquals(queueProp.enablePartitioning, updateQueueConfig.enablePartitioning, msg = "Queue creation failed.");
        test:assertTrue(queueProp.forwardDeadLetteredMessagesTo.endsWith(testQueue2),
            msg = "Queue creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertEquals(queueProp.lockDuration.seconds, updateQueueConfig.lockDuration?.seconds, msg = "Queue creation failed. wrong lockDuration");
        test:assertEquals(queueProp.maxDeliveryCount, updateQueueConfig.maxDeliveryCount, msg = "Queue creation failed. wrong maxDeliveryCount");
        test:assertEquals(queueProp.requiresDuplicateDetection, updateQueueConfig.requiresDuplicateDetection,
            msg = "Queue creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(queueProp.requiresSession, updateQueueConfig.requiresSession, msg = "Queue creation failed. wrong requiresSession");
        test:assertEquals(queueProp.status, updateQueueConfig.status, msg = "Queue creation failed. wrong status");
        test:assertEquals(queueProp.userMetadata, updateQueueConfig.userMetadata, msg = "Queue creation failed. wrong userMetadata");
        log:printInfo("Queue created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateQueue],
    enable: true
}
function testCreateWithOptionTopic() returns error? {
    log:printInfo("[[testCreateWithOptionTopic]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->createTopic(testTopic2, topicConfig);
    if topicProp is TopicProperties {
        createdTestTopics[testTopic2] = true;
        log:printInfo(topicProp.toString());
        test:assertEquals(topicProp.name, testTopic2, msg = "Topic creation failed. wrong name");
        test:assertEquals(topicProp.autoDeleteOnIdle.seconds, topicConfig.autoDeleteOnIdle?.seconds, msg = "Topic creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(topicProp.enableBatchedOperations, topicConfig.enableBatchedOperations,
            msg = "Topic creation failed. wrong enableBatchedOperations");
        test:assertEquals(topicProp.enablePartitioning, topicConfig.enablePartitioning, msg = "Topic creation failed.");
        test:assertEquals(topicProp.maxSizeInMegabytes, topicConfig.maxSizeInMegabytes, msg = "Topic creation failed. wrong maxSizeInMegabytes");
        test:assertEquals(topicProp.requiresDuplicateDetection, topicConfig.requiresDuplicateDetection,
            msg = "Topic creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(topicProp.status, topicConfig.status, msg = "Topic creation failed. wrong status");
        test:assertEquals(topicProp.userMetadata, topicConfig.userMetadata, msg = "Topic creation failed. wrong userMetadata");
        test:assertEquals(topicProp.duplicateDetectionHistoryTimeWindow?.seconds, topicConfig.duplicateDetectionHistoryTimeWindow?.seconds,
            msg = "Topic creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(topicProp.defaultMessageTimeToLive?.seconds, topicConfig.defaultMessageTimeToLive?.seconds,
            msg = "Topic creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(topicProp.supportOrdering, topicConfig.supportOrdering, msg = "Topic creation failed. wrong supportOrdering");
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Topic creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateTopicOperation],
    enable: true
}
function createTopicWithInclusionParameters() returns error? {
    log:printInfo("[[createTopicWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->createTopic(testTopic4,
                                defaultMessageTimeToLive = ttl,
                                duplicateDetectionHistoryTimeWindow = dupdue,
                                enableBatchedOperations = true,
                                enablePartitioning = false,
                                maxSizeInMegabytes = 1024,
                                requiresDuplicateDetection = false,
                                status = ACTIVE,
                                userMetadata = userMetaData,
                                supportOrdering = false);
    if topicProp is TopicProperties {
        createdTestTopics[testTopic4] = true;
        log:printInfo(topicProp.toString());
        test:assertEquals(topicProp.name, testTopic4, msg = "Topic creation failed. wrong name");
        test:assertEquals(topicProp.enableBatchedOperations, true,
            msg = "Topic creation failed. wrong enableBatchedOperations");
        test:assertEquals(topicProp.enablePartitioning, false, msg = "Topic creation failed.");
        test:assertEquals(topicProp.maxSizeInMegabytes, 1024, msg = "Topic creation failed. wrong maxSizeInMegabytes");
        test:assertEquals(topicProp.requiresDuplicateDetection, false,
            msg = "Topic creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(topicProp.status, ACTIVE, msg = "Topic creation failed. wrong status");
        test:assertEquals(topicProp.userMetadata, userMetaData, msg = "Topic creation failed. wrong userMetadata");
        test:assertEquals(topicProp.duplicateDetectionHistoryTimeWindow?.seconds, dupdue.seconds,
            msg = "Topic creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(topicProp.defaultMessageTimeToLive?.seconds, ttl.seconds,
            msg = "Topic creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(topicProp.supportOrdering, false, msg = "Topic creation failed. wrong supportOrdering");
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Queue creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createTopicWithInclusionParameters],
    enable: true
}
function updateTopicWithInclusionParameters() returns error? {
    log:printInfo("[[updateTopicWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->updateTopic(testTopic4,
                                defaultMessageTimeToLive = ttl,
                                duplicateDetectionHistoryTimeWindow = dupdue,
                                maxSizeInMegabytes = 1024,
                                status = ACTIVE,
                                userMetadata = userMetaData,
                                supportOrdering = true);
    if topicProp is TopicProperties {
        log:printInfo(topicProp.toString());
        test:assertEquals(topicProp.name, testTopic4, msg = "Topic update failed. wrong name");
        test:assertEquals(topicProp.maxSizeInMegabytes, 1024, msg = "Topic update failed. wrong maxSizeInMegabytes");
        test:assertEquals(topicProp.status, ACTIVE, msg = "Topic update failed. wrong status");
        test:assertEquals(topicProp.userMetadata, userMetaData, msg = "Topic update failed. wrong userMetadata");
        test:assertEquals(topicProp.duplicateDetectionHistoryTimeWindow?.seconds, dupdue.seconds,
            msg = "Topic update failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(topicProp.defaultMessageTimeToLive?.seconds, ttl.seconds,
            msg = "Topic update failed. wrong defaultMessageTimeToLive");
        test:assertEquals(topicProp.supportOrdering, true, msg = "Topic update failed. wrong supportOrdering");
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Queue update failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateWithOptionTopic],
    enable: true
}
function testGetTopic() returns error? {
    log:printInfo("[[testGetTopic]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->getTopic(testTopic2);
    if topicProp is TopicProperties {
        log:printInfo(topicProp.toString());
        test:assertEquals(topicProp.name, testTopic2, msg = "Topic creation failed. wrong name");
        test:assertEquals(topicProp.autoDeleteOnIdle.seconds, topicConfig.autoDeleteOnIdle?.seconds, msg = "Topic creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(topicProp.enableBatchedOperations, topicConfig.enableBatchedOperations,
            msg = "Topic creation failed. wrong enableBatchedOperations");
        test:assertEquals(topicProp.enablePartitioning, topicConfig.enablePartitioning, msg = "Topic creation failed.");
        test:assertEquals(topicProp.maxSizeInMegabytes, topicConfig.maxSizeInMegabytes, msg = "Topic creation failed. wrong maxSizeInMegabytes");
        test:assertEquals(topicProp.requiresDuplicateDetection, topicConfig.requiresDuplicateDetection,
            msg = "Topic creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(topicProp.status, topicConfig.status, msg = "Topic creation failed. wrong status");
        test:assertEquals(topicProp.userMetadata, topicConfig.userMetadata, msg = "Topic creation failed. wrong userMetadata");
        test:assertEquals(topicProp.duplicateDetectionHistoryTimeWindow?.seconds, topicConfig.duplicateDetectionHistoryTimeWindow?.seconds,
            msg = "Topic creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(topicProp.defaultMessageTimeToLive?.seconds, topicConfig.defaultMessageTimeToLive?.seconds,
            msg = "Topic creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(topicProp.supportOrdering, topicConfig.supportOrdering, msg = "Topic creation failed. wrong supportOrdering");
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Topic creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testGetTopic, testMessageScheduling],
    enable: true
}
function testUpdateTopic() returns error? {
    log:printInfo("[[testUpdateTopic]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicProperties? topicProp = check adminClient->updateTopic(testTopic2, updateTopicConfig);
    if topicProp is TopicProperties {
        log:printInfo(topicProp.toString());
        test:assertEquals(topicProp.name, testTopic2, msg = "Topic creation failed. wrong name");
        test:assertEquals(topicProp.autoDeleteOnIdle.seconds, topicConfig.autoDeleteOnIdle?.seconds, msg = "Topic creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(topicProp.enableBatchedOperations, topicConfig.enableBatchedOperations,
            msg = "Topic creation failed. wrong enableBatchedOperations");
        test:assertEquals(topicProp.enablePartitioning, topicConfig.enablePartitioning, msg = "Topic creation failed.");
        test:assertEquals(topicProp.maxSizeInMegabytes, topicConfig.maxSizeInMegabytes, msg = "Topic creation failed. wrong maxSizeInMegabytes");
        test:assertEquals(topicProp.requiresDuplicateDetection, topicConfig.requiresDuplicateDetection,
            msg = "Topic creation failed. wrong requiresDuplicateDetection");
        test:assertEquals(topicProp.status, topicConfig.status, msg = "Topic creation failed. wrong status");
        test:assertEquals(topicProp.userMetadata, topicConfig.userMetadata, msg = "Topic creation failed. wrong userMetadata");
        test:assertEquals(topicProp.duplicateDetectionHistoryTimeWindow?.seconds, topicConfig.duplicateDetectionHistoryTimeWindow?.seconds,
            msg = "Topic creation failed. wrong duplicateDetectionHistoryTimeWindow");
        test:assertEquals(topicProp.defaultMessageTimeToLive?.seconds, topicConfig.defaultMessageTimeToLive?.seconds,
            msg = "Topic creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(topicProp.supportOrdering, topicConfig.supportOrdering, msg = "Topic creation failed. wrong supportOrdering");
        log:printInfo("Topic created successfully.");
    } else {
        test:assertFail("Topic creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testUpdateTopic],
    enable: false
}
function testTopicList() returns error? {
    log:printInfo("[[testTopicList]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    TopicList? topicProp = check adminClient->listTopics();
    if topicProp is TopicList {
        if topicProp.list.length() >= 1 {
            log:printInfo(topicProp.toString());
            log:printInfo("Topic list successfully.");
        } else {
            test:assertFail("Topic list failed.");
        }
    } else {
        test:assertFail("Topic list creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateSubscription],
    enable: true
}
function testCreateSubscriptionWithOption() returns error?
{
    log:printInfo("[[testCreateSubscriptionWithOption]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subscriptionProp = check adminClient->createSubscription(testTopic1, testSubscription2, subConfig);
    if subscriptionProp is SubscriptionProperties {
        log:printInfo(subscriptionProp.toString());
        test:assertEquals(subscriptionProp.subscriptionName, testSubscription2, msg = "Subscription creation failed. wrong name");
        test:assertEquals(subscriptionProp.topicName, testTopic1, msg = "Subscription creation failed. wrong topic");
        //test:assertEquals(subscriptionProp.autoDeleteOnIdle.seconds, subConfig.autoDeleteOnIdle?.seconds, msg = "Subscription creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(subscriptionProp.deadLetteringOnMessageExpiration, subConfig.deadLetteringOnMessageExpiration,
            msg = "Subscription creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(subscriptionProp.defaultMessageTimeToLive.seconds, subConfig.defaultMessageTimeToLive?.seconds,
            msg = "Subscription creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(subscriptionProp.enableBatchedOperations, subConfig.enableBatchedOperations,
            msg = "Subscription creation failed. wrong enableBatchedOperations");
        test:assertTrue(subscriptionProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(subscriptionProp.forwardTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardTo");
        test:assertEquals(subscriptionProp.lockDuration.seconds, subConfig.lockDuration?.seconds, msg = "Subscription creation failed. wrong lockDuration");
        test:assertEquals(subscriptionProp.maxDeliveryCount, subConfig.maxDeliveryCount, msg = "Subscription creation failed. wrong maxDeliveryCount");
        test:assertEquals(subscriptionProp.status, subConfig.status, msg = "Subscription creation failed. wrong status");
        test:assertEquals(subscriptionProp.userMetadata, subConfig.userMetadata, msg = "Subscription creation failed. wrong userMetadata");
        test:assertEquals(subscriptionProp.requiresSession, subConfig.requiresSession, msg = "Subscription creation failed. wrong requiresSession");
        log:printInfo("Subscription created successfully.");
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createTopicWithInclusionParameters],
    enable: true
}
function createSubscriptionWithInclusionParameters() returns error? {
    log:printInfo("[[createSubscriptionWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subProp = check adminClient->createSubscription(testTopic4, testSubscription4,
                                defaultMessageTimeToLive = ttl,
                                deadLetteringOnMessageExpiration = true,
                                enableBatchedOperations = true,
                                forwardDeadLetteredMessagesTo = testQueue1,
                                forwardTo = testQueue1,
                                lockDuration = lockDue,
                                maxDeliveryCount = 10,
                                requiresSession = false,
                                status = ACTIVE,
                                userMetadata = userMetaData);
    if subProp is CreateSubscriptionOptions {
        log:printInfo(subProp.toString());
        test:assertEquals(subProp.subscriptionName, testSubscription4, msg = "Subscription creation failed. wrong name");
        test:assertEquals(subProp.topicName, testTopic4, msg = "Subscription creation failed. wrong topic");
        test:assertEquals(subProp.deadLetteringOnMessageExpiration, true,
            msg = "Subscription creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(subProp.defaultMessageTimeToLive.seconds, ttl.seconds,
            msg = "Subscription creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(subProp.enableBatchedOperations, true,
            msg = "Subscription creation failed. wrong enableBatchedOperations");
        test:assertTrue(subProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(subProp.forwardTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardTo");
        test:assertEquals(subProp.lockDuration.seconds, lockDue.seconds,
            msg = "Subscription creation failed. wrong lockDuration");
        test:assertEquals(subProp.maxDeliveryCount, 10,
            msg = "Subscription creation failed. wrong maxDeliveryCount");
        test:assertEquals(subProp.requiresSession, false,
            msg = "Subscription creation failed. wrong requiresSession");
        test:assertEquals(subProp.status, ACTIVE,
            msg = "Subscription creation failed. wrong status");
        test:assertEquals(subProp.userMetadata, userMetaData,
            msg = "Subscription creation failed. wrong userMetadata");
        log:printInfo("Subscription created successfully.");
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createSubscriptionWithInclusionParameters],
    enable: true
}
function updateSubscriptionWithInclusionParameters() returns error? {
    log:printInfo("[[updateSubscriptionWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subProp = check adminClient->updateSubscription(testTopic4, testSubscription4,
                                defaultMessageTimeToLive = ttl,
                                deadLetteringOnMessageExpiration = false,
                                enableBatchedOperations = false,
                                forwardDeadLetteredMessagesTo = testQueue1,
                                forwardTo = testQueue1,
                                lockDuration = lockDue,
                                maxDeliveryCount = 10,
                                status = ACTIVE
                                );
    if subProp is CreateSubscriptionOptions {
        log:printInfo(subProp.toString());
        test:assertEquals(subProp.subscriptionName, testSubscription4, msg = "Subscription creation failed. wrong name");
        test:assertEquals(subProp.topicName, testTopic4, msg = "Subscription creation failed. wrong topic");
        test:assertEquals(subProp.deadLetteringOnMessageExpiration, false,
            msg = "Subscription update failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(subProp.defaultMessageTimeToLive.seconds, ttl.seconds,
            msg = "Subscription update failed. wrong defaultMessageTimeToLive");
        test:assertEquals(subProp.enableBatchedOperations, false,
            msg = "Subscription update failed. wrong enableBatchedOperations");
        test:assertTrue(subProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Subscription update failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(subProp.forwardTo.endsWith(testQueue1),
            msg = "Subscription update failed. wrong forwardTo");
        test:assertEquals(subProp.lockDuration.seconds, lockDue.seconds,
            msg = "Subscription update failed. wrong lockDuration");
        test:assertEquals(subProp.maxDeliveryCount, 10,
            msg = "Subscription update failed. wrong maxDeliveryCount");
        test:assertEquals(subProp.requiresSession, false,
            msg = "Subscription update failed. wrong requiresSession");
        test:assertEquals(subProp.status, ACTIVE,
            msg = "Subscription update failed. wrong status");
        log:printInfo("Subscription created successfully.");
    } else {
        test:assertFail("Subscription update failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [updateSubscriptionWithInclusionParameters, updateRuleWithInclusionParameters, updateQueueWithInclusionParameters, updateTopicWithInclusionParameters],
    enable: true
}
function deleteTopicAndQueue() returns error? {
    log:printInfo("[[deleteTopicAndQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    error? e = adminClient->deleteTopic(testTopic4);
    if e is error {
        test:assertFail("Topic deletion failed.");
    } else {
        log:printInfo("Topic deleted successfully.");
    }
    e = adminClient->deleteQueue(testQueue4);
    if e is error {
        test:assertFail("Queue deletion failed.");
    } else {
        log:printInfo("Queue deleted successfully.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateSubscriptionWithOption],
    enable: true
}
function testGetSubscription() returns error? {
    log:printInfo("[[testGetSubscription]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subscriptionProp = check adminClient->getSubscription(testTopic1, testSubscription2);
    if subscriptionProp is SubscriptionProperties {
        log:printInfo(subscriptionProp.toString());
        test:assertEquals(subscriptionProp.subscriptionName, testSubscription2, msg = "Subscription creation failed. wrong name");
        test:assertEquals(subscriptionProp.topicName, testTopic1, msg = "Subscription creation failed. wrong topic");
        //test:assertEquals(subscriptionProp.autoDeleteOnIdle.seconds, subConfig.autoDeleteOnIdle?.seconds, msg = "Subscription creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(subscriptionProp.deadLetteringOnMessageExpiration, subConfig.deadLetteringOnMessageExpiration,
            msg = "Subscription creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(subscriptionProp.defaultMessageTimeToLive.seconds, subConfig.defaultMessageTimeToLive?.seconds,
            msg = "Subscription creation failed. wrong defaultMessageTimeToLive");
        test:assertEquals(subscriptionProp.enableBatchedOperations, subConfig.enableBatchedOperations,
            msg = "Subscription creation failed. wrong enableBatchedOperations");
        test:assertTrue(subscriptionProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(subscriptionProp.forwardTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardTo");
        test:assertEquals(subscriptionProp.lockDuration.seconds, subConfig.lockDuration?.seconds, msg = "Subscription creation failed. wrong lockDuration");
        test:assertEquals(subscriptionProp.maxDeliveryCount, subConfig.maxDeliveryCount, msg = "Subscription creation failed. wrong maxDeliveryCount");
        test:assertEquals(subscriptionProp.status, subConfig.status, msg = "Subscription creation failed. wrong status");
        test:assertEquals(subscriptionProp.userMetadata, subConfig.userMetadata, msg = "Subscription creation failed. wrong userMetadata");
        test:assertEquals(subscriptionProp.requiresSession, subConfig.requiresSession, msg = "Subscription creation failed. wrong requiresSession");
        log:printInfo("Subscription created successfully.");
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testMessageScheduling],
    enable: true
}
function testUpdateSubscription() returns error? {
    log:printInfo("[[testUpdateSubscription]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionProperties? subscriptionProp = check adminClient->updateSubscription(testTopic1, testSubscription1, updateSubConfig);
    if subscriptionProp is SubscriptionProperties {
        test:assertEquals(subscriptionProp.subscriptionName, testSubscription1, msg = "Subscription creation failed. wrong name");
        test:assertEquals(subscriptionProp.topicName, testTopic1, msg = "Subscription creation failed. wrong topic");
        //test:assertEquals(subscriptionProp.autoDeleteOnIdle.seconds, subConfig.autoDeleteOnIdle?.seconds, msg = "Subscription creation failed. wrong autoDeleteOnIdle");
        test:assertEquals(subscriptionProp.deadLetteringOnMessageExpiration, updateSubConfig.deadLetteringOnMessageExpiration,
            msg = "Subscription creation failed. wrong deadLetteringOnMessageExpiration");
        test:assertEquals(subscriptionProp.defaultMessageTimeToLive.seconds, updateSubConfig.defaultMessageTimeToLive?.seconds,
            msg = "Subscription creation failed. wrong defaultMessageTimeToLive");
        test:assertTrue(subscriptionProp.forwardDeadLetteredMessagesTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardDeadLetteredMessagesTo");
        test:assertTrue(subscriptionProp.forwardTo.endsWith(testQueue1),
            msg = "Subscription creation failed. wrong forwardTo");
        test:assertEquals(subscriptionProp.lockDuration.seconds, updateSubConfig.lockDuration?.seconds, msg = "Subscription creation failed. wrong lockDuration");
        test:assertEquals(subscriptionProp.maxDeliveryCount, updateSubConfig.maxDeliveryCount, msg = "Subscription creation failed. wrong maxDeliveryCount");
        test:assertEquals(subscriptionProp.status, updateSubConfig.status, msg = "Subscription creation failed. wrong status");
        //test:assertEquals(subscriptionProp.userMetadata, updateSubConfig.userMetadata, msg = "Subscription creation failed. wrong userMetadata");
        log:printInfo("Subscription created successfully.");
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateSubscriptionWithOption],
    enable: true
}
function testSubscriptionList() returns error? {
    log:printInfo("[[testSubscriptionList]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    SubscriptionList? subscriptionProp = check adminClient->listSubscriptions(testTopic1);
    if subscriptionProp is SubscriptionList {
        if subscriptionProp.list.length() >= 2 {
            log:printInfo(subscriptionProp.toString());
            log:printInfo("Subscription list successfully.");
        } else {
            test:assertFail("Subscription list failed.");
        }
    } else {
        test:assertFail("Subscription creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateSubscriptionWithOption],
    enable: true
}
function testCreateRuleWithOptions() returns error? {
    log:printInfo("[[testCreateRuleWithOptions]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->createRule(testTopic1, testSubscription1, testRule2, ruleConfig);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule2, msg = "Rule creation failed.");
        test:assertEquals(ruleProp.rule.filter, "1=1", msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createSubscriptionWithInclusionParameters],
    enable: true
}
function createRuleWithInclusionParameters() returns error? {
    log:printInfo("[[createRuleWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->createRule(testTopic4, testSubscription4, testRule4, rule = rule);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule4, msg = "Rule creation failed.");
        test:assertEquals(ruleProp.rule.filter, "1=1", msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [createRuleWithInclusionParameters],
    enable: true
}
function updateRuleWithInclusionParameters() returns error? {
    log:printInfo("[[updateRuleWithInclusionParameters]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->updateRule(testTopic4, testSubscription4, testRule4, rule = rule);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule4, msg = "Rule creation failed.");
        test:assertEquals(ruleProp.rule.filter, "1=1", msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateRuleWithOptions],
    enable: true
}
function testGetRule() returns error? {
    log:printInfo("[[testGetRule]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->getRule(testTopic1, testSubscription1, testRule2);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule2, msg = "Rule creation failed.");
        test:assertEquals(ruleProp.rule.filter, "1=1", msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testGetRule],
    enable: true
}
function testUpdateRule() returns error? {
    log:printInfo("[[testUpdateRule]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleProperties? ruleProp = check adminClient->updateRule(testTopic1, testSubscription1, testRule1, updateRuleConfig);
    if ruleProp is RuleProperties {
        log:printInfo("Rule created successfully.");
        test:assertEquals(ruleProp.name, testRule1, msg = "Rule creation failed.");
        test:assertEquals(ruleProp.rule.filter, "1=1", msg = "Rule creation failed.");
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testUpdateRule],
    enable: true
}
function testRuleList() returns error? {
    log:printInfo("[[testRuleList]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    RuleList? ruleProp = check adminClient->listRules(testTopic1, testSubscription1);
    if ruleProp is RuleList {
        if ruleProp.list.length() >= 2 {
            log:printInfo(ruleProp.toString());
            log:printInfo("Rule list successfully.");
        } else {
            test:assertFail("Rule list failed.");
        }
    } else {
        test:assertFail("Rule creation failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testCreateRuleWithOptions, testMessageScheduling, updateSubscriptionWithInclusionParameters, updateQueueWithInclusionParameters, testInvalidConnectionString],
    enable: true
}
function testDeleteRule() returns error? {
    log:printInfo("[[testDeleteRule]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    Error? result = check adminClient->deleteRule(testTopic1, testSubscription1, testRule1);
    if result is Error {
        test:assertFail("Rule deletion failed.");
    }
    result = check adminClient->deleteRule(testTopic1, testSubscription1, testRule2);
    if result is Error {
        test:assertFail("Rule deletion failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testDeleteRule],
    enable: true
}
function testDeleteSubscription() returns error? {
    log:printInfo("[[testDeleteSubscriptionWithOption]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    Error? result = check adminClient->deleteSubscription(testTopic1, testSubscription1);
    if result is Error {
        test:assertFail("Subscription deletion failed.");
    }
    result = check adminClient->deleteSubscription(testTopic1, testSubscription2);
    if result is Error {
        test:assertFail("Subscription deletion failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testDeleteSubscription],
    enable: true
}
function testDeleteQueue() returns error? {
    log:printInfo("[[testDeleteQueue]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    Error? result = check adminClient->deleteQueue(testQueue2);
    if result is Error {
        test:assertFail("Queue deletion failed.");
    }
    result = check adminClient->deleteQueue(testQueue1);
    if result is Error {
        test:assertFail("Queue deletion failed.");
    }
}

@test:Config {
    groups: ["asb_admin"],
    dependsOn: [testDeleteQueue],
    enable: true
}
function testDeleteTopic() returns error? {
    log:printInfo("[[testDeleteTopic]]");
    log:printInfo("Initializing Asb admin client.");
    Administrator adminClient = check new (connectionString);
    Error? result = check adminClient->deleteTopic(testTopic1);
    if result is Error {
        test:assertFail("Topic deletion failed.");
    }
    result = check adminClient->deleteTopic(testTopic2);
    if result is Error {
        test:assertFail("Topic deletion failed.");
    }
}
