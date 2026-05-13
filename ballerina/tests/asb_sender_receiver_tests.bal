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
import ballerina/test;
import ballerina/time;

type Order record {
    string color;
    decimal price;
};

// Input values
() nilContent = ();
int intContent = 1;
float floatContent = 1.345;
boolean booleanContent = true;
map<anydata> mapContent = {color: "orange", price: 5.36d};
Order recordContent = {color: "orange", price: 5.36d};
string stringContent = "This is ASB connector test-Message Body";
byte[] byteContent = stringContent.toBytes();
json jsonContent = {name: "wso2", color: "orange", price: 5.36d};
byte[] byteContentFromJson = jsonContent.toJsonString().toBytes();
xml xmlContent = xml `<name>wso2</name>`;

map<anydata> properties = {a: "propertyValue1", b: "propertyValue2", c: 1, d: "true", f: 1.345, s: false, k: 1020202, g: jsonContent};
int timeToLive = 60; // In seconds
int serverWaitTime = 60; // In seconds
int maxMessageCount = 2;

ApplicationProperties applicationProperties = {
    properties: properties
};

Message message = {
    body: byteContent,
    contentType: TEXT,
    timeToLive: timeToLive,
    applicationProperties: applicationProperties
};

Message message1 = {
    body: byteContent,
    contentType: TEXT,
    timeToLive: timeToLive,
    applicationProperties: applicationProperties
};

Message message2 = {
    body: byteContent,
    contentType: TEXT,
    timeToLive: timeToLive
};

MessageBatch messages = {
    messageCount: 2,
    messages: [message1, message2]
};

ASBServiceSenderConfig senderConfig = {
    connectionString: connectionString,
    entityType: QUEUE,
    topicOrQueueName: testQueue1
};

ASBServiceReceiverConfig receiverConfig = {
    connectionString: connectionString,
    entityConfig: {
        queueName: testQueue1
    },
    receiveMode: PEEK_LOCK
};

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testCreateSubscription],
    enable: true
}
function testSendAndReceiveMessageFromQueueOperation() returns error? {
    log:printInfo("[[testSendAndReceiveMessageFromQueueOperation]]");

    log:printInfo("Creating Asb message sender.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Creating Asb message receiver.");
    receiverConfig.receiveMode = PEEK_LOCK;
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check messageReceiver->complete(messageReceived);
        test:assertEquals(result, (), msg = "Complete message not successful.");
        float mapValue = check getApplicationPropertyByName(messageReceived, "f").ensureType();
        test:assertEquals(mapValue, <float>properties["f"], "Retrieving application properties failed");
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }
    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveMessageFromQueueOperation],
    enable: true
}
function testSendAndReceiveMessagePayloadFromQueueOperation() returns error? {
    log:printInfo("[[testSendAndReceiveMessagePayloadFromQueueOperation]]");
    log:printInfo("Creating Asb message sender.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Sending all the anydata payloads via ASB sender");
    check messageSender->sendPayload(nilContent);
    check messageSender->sendPayload(booleanContent);
    check messageSender->sendPayload(intContent);
    check messageSender->sendPayload(floatContent);
    check messageSender->sendPayload(stringContent);
    check messageSender->sendPayload(jsonContent);
    check messageSender->sendPayload(byteContent);
    check messageSender->sendPayload(xmlContent);
    check messageSender->sendPayload(mapContent);
    check messageSender->sendPayload(recordContent);

    log:printInfo("Creating Asb message receiver.");
    receiverConfig.receiveMode = RECEIVE_AND_DELETE;
    MessageReceiver messageReceiver = check new (receiverConfig);
    log:printInfo("Receiving from Asb receiver client.");
    error? nilPayload = messageReceiver->receivePayload(serverWaitTime);
    boolean|error? booleanPayload = messageReceiver->receivePayload(serverWaitTime);
    int|error? intPayload = messageReceiver->receivePayload(serverWaitTime);
    float|error? floatPayload = messageReceiver->receivePayload(serverWaitTime);
    string|error? stringPayload = messageReceiver->receivePayload(serverWaitTime);
    json|error? jsonPayload = messageReceiver->receivePayload(serverWaitTime);
    byte[]|error? bytePayload = messageReceiver->receivePayload(serverWaitTime);
    xml|error? xmlPayload = messageReceiver->receivePayload(serverWaitTime);
    map<anydata>|error? mapPayload = messageReceiver->receivePayload(serverWaitTime);
    Order|error? recordPayload = messageReceiver->receivePayload(serverWaitTime);

    log:printInfo("Asserting received payloads.");
    test:assertTrue(nilPayload is (), msg = "Nil payload not received.");
    test:assertEquals(nilPayload, nilContent, msg = "Nil payload not received.");
    test:assertTrue(booleanPayload is boolean, msg = "Boolean payload not received.");
    test:assertEquals(booleanPayload, true, msg = "Boolean payload not received.");
    test:assertTrue(intPayload is int, msg = "Int payload not received.");
    test:assertEquals(intPayload, intContent, msg = "Int payload not received.");
    test:assertTrue(floatPayload is float, msg = "Float payload not received.");
    test:assertEquals(floatPayload, floatContent, msg = "Float payload not received.");
    test:assertTrue(stringPayload is string, msg = "String payload not received.");
    test:assertEquals(stringPayload, stringContent, msg = "String payload not received.");
    test:assertTrue(jsonPayload is json, msg = "Json payload not received.");
    test:assertEquals(jsonPayload, jsonContent, msg = "Json payload not received.");
    test:assertTrue(bytePayload is byte[], msg = "Byte payload not received.");
    test:assertEquals(bytePayload, byteContent, msg = "Byte payload not received.");
    test:assertTrue(xmlPayload is xml, msg = "Xml payload not received.");
    test:assertEquals(xmlPayload, xmlContent, msg = "Xml payload not received.");
    test:assertTrue(mapPayload is map<anydata>, msg = "Map payload not received.");
    test:assertEquals(mapPayload, mapContent, msg = "Map payload not received.");
    test:assertTrue(recordPayload is Order, msg = "Record payload not received.");
    test:assertEquals(recordPayload, recordContent, msg = "Record payload not received.");

    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveMessagePayloadFromQueueOperation],
    enable: true
}
function testReceiveMessagePayloadFromDeadLetterQueueOperation() returns error? {
    log:printInfo("[[testReceiveMessagePayloadFromDeadLetterQueueOperation]]");
    log:printInfo("Creating Asb message sender and receiver.");
    MessageSender messageSender = check new (senderConfig);
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        check messageReceiver->deadLetter(messageReceived);
        byte[]|error? bytePayload = messageReceiver->receivePayload(serverWaitTime, deadLettered = true);
        if bytePayload is byte[] {
            string receivedContent = check string:fromBytes(bytePayload);
            test:assertEquals(receivedContent, stringContent, msg = "Sent & received payload are not equal.");
        } else {
            test:assertFail("Receiving message via Asb receiver connection failed.");
        }
    } else if messageReceived is () {
        test:assertFail("No message in the dead-letter queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testReceiveMessagePayloadFromDeadLetterQueueOperation],
    enable: true
}
function testSendAndReceiveBatchFromQueueOperation() returns error? {
    log:printInfo("[[testSendAndReceiveBatchFromQueueOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    receiverConfig.receiveMode = RECEIVE_AND_DELETE;
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->sendBatch(messages);

    // Here we set the batch size to be more than the number of messages sent. 
    // This is to validate whether the received message count is always same as the sent count, 
    // even when the expected count is larger than the sent count
    log:printInfo("Receiving from Asb receiver.");
    MessageBatch|error? messageReceived = messageReceiver->receiveBatch(messages.length() + 5);

    if messageReceived is MessageBatch {
        log:printInfo(messageReceived.toString());
        test:assertEquals(messageReceived.messages.length(), messages.length(), msg = "Sent & received message counts are not equal.");
        foreach Message message in messageReceived.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received message are not equal.");
            }
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed." + messageReceived.toString());
    }

    log:printInfo("Closing Asb sender. ");
    check messageSender->close();

    log:printInfo("Closing Asb receiver.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveMessagePayloadFromQueueOperation],
    enable: true
}
function testSendAndReceiveBatchFromDeadLetterQueueOperation() returns error? {
    log:printInfo("[[testSendAndReceiveBatchFromQueueOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->sendBatch(messages);

    log:printInfo("Receiving from Asb receiver.");
    MessageBatch|error? messageReceived = messageReceiver->receiveBatch(messages.length() + 5);

    if messageReceived is MessageBatch {
        log:printInfo(messageReceived.toString());
        test:assertEquals(messageReceived.messages.length(), messages.length(), msg = "Sent & received message counts are not equal.");
        foreach Message message in messageReceived.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received message are not equal.");
                check messageReceiver->deadLetter(message);
            }
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed." + messageReceived.toString());
    }
    log:printInfo("Receiving from Asb dead-letter receiver.");
    MessageBatch|error? receivedDeadletterMessages = messageReceiver->receiveBatch(messages.length() + 5, deadLettered = true);
    if receivedDeadletterMessages is MessageBatch {
        log:printInfo(receivedDeadletterMessages.toString());
        test:assertEquals(receivedDeadletterMessages.messages.length(), messages.length(), msg = "Sent & received message counts are not equal.");
        foreach Message message in receivedDeadletterMessages.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received dead-letter message are not equal.");
            }
        }
    } else if receivedDeadletterMessages is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb dead-letter receiver connection failed." + receivedDeadletterMessages.toString());
    }

    log:printInfo("Closing Asb sender. ");
    check messageSender->close();

    log:printInfo("Closing Asb receiver.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveBatchFromDeadLetterQueueOperation],
    enable: true
}
function testCompleteMessageFromQueueOperation() returns error? {
    log:printInfo("[[testCompleteMessageFromQueueOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    receiverConfig.receiveMode = PEEK_LOCK;
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        log:printInfo("messgae" + messageReceived.toString());
        var result = check messageReceiver->complete(messageReceived);
        test:assertEquals(result, (), msg = "Complete message not successful.");
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageSender->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testCompleteMessageFromQueueOperation],
    enable: true
}
function testCompleteDeadLetterMessageFromQueueOperation() returns error? {
    log:printInfo("[[testCompleteDeadLetterMessageFromQueueOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        check messageReceiver->deadLetter(messageReceived);
        log:printInfo("Receiving from DLQ via Asb receiver client.");
        Message|error? messageReceivedFromDLQ = messageReceiver->receive(serverWaitTime, deadLettered = true);
        if messageReceivedFromDLQ is Message {
            log:printInfo("Message received from DLQ.");
            string? message_id_dl = messageReceivedFromDLQ.messageId;

            log:printInfo("Completing the DLQ message.");
            check messageReceiver->complete(messageReceivedFromDLQ);

            log:printInfo("Receiving from DLQ via Asb receiver client after complete.");
            Message|error? checkReceivingDLQAfterComplete = messageReceiver->receive(serverWaitTime, deadLettered = true);
            if checkReceivingDLQAfterComplete is Message { //if there are any messages in the DLQ
                log:printInfo("Message received from DLQ.");
                string? message_id_top = checkReceivingDLQAfterComplete.messageId;
                if message_id_top is string && (message_id_dl is string) {
                    test:assertNotEquals(message_id_top, message_id_dl, msg = "Message id of the message received from DLQ is same as the message id of the message sent to DLQ.");
                } else {
                    test:assertFail("Message id of the message received from DLQ is null.");
                }
            } else {
                test:assertEquals(checkReceivingDLQAfterComplete, (), msg = "Message received from DLQ after complete.");
            }
        } else if messageReceivedFromDLQ is () {
            test:assertFail("No message in the DLQ.");
        } else {
            test:assertFail("Receiving message via ASBReceiver:DLQ connection failed.");
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageSender->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testCompleteDeadLetterMessageFromQueueOperation],
    enable: true
}
function testAbandonMessageFromQueueOperation() returns error? {
    log:printInfo("[[testAbandonMessageFromQueueOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check messageReceiver->abandon(messageReceived);
        test:assertEquals(result, (), msg = "Abandon message not successful.");
        Message|error? messageReceivedAgain = messageReceiver->receive(serverWaitTime);
        if messageReceivedAgain is Message {
            test:assertEquals(messageReceivedAgain?.messageId, messageReceived?.messageId,
                msg = "Abandon message not successful.");
            check messageReceiver->complete(messageReceivedAgain);
        } else {
            test:assertFail("Abandon message not successful.");
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testAbandonMessageFromQueueOperation],
    enable: true
}
function testDeadletterMessageFromQueueOperation() returns error? {
    log:printInfo("[[testDeadletterMessageFromQueueOperation]]");

    log:printInfo("Initializing Asb sender.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver.");
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check messageReceiver->deadLetter(messageReceived);
        test:assertEquals(result, (), msg = "Deadletter message not successful.");
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testDeadletterMessageFromQueueOperation],
    enable: true
}
function testReceiveDeadLetterQueueMessages() returns error? {
    log:printInfo("[[testReceiveDeadLetterQueueMessages]]");

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver queueReceiver = check new (receiverConfig);

    log:printInfo("Receiving from Asb receiver.");
    Message|error? message = queueReceiver->receive(serverWaitTime, deadLettered = true);

    if message is Message {
        string receivedContent = check string:fromBytes(<byte[]>message.body);
        test:assertEquals(receivedContent, stringContent, msg = "Sent & received dead letter message not equal.");
    } else if message is () {
        log:printError("No dead letter message in the queue.");
    } else {
        log:printError("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Receiving from Asb receiver.(for test usage of already creaated dead letter queue receiver)");
    message = queueReceiver->receive(serverWaitTime, deadLettered = true);

    if message is Message {
        string receivedContent = check string:fromBytes(<byte[]>message.body);
        test:assertEquals(receivedContent, stringContent, msg = "Sent & received dead letter message not equal.");
    } else if message is () {
        log:printError("No dead letter message in the queue.");
    } else {
        log:printError("Receiving message via Asb receiver connection failed.");
    }
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testReceiveDeadLetterQueueMessages],
    enable: true
}
function testDeferMessageFromQueueOperation() returns error? {
    log:printInfo("[[testDeferMessageFromQueueOperation]]");

    log:printInfo("Initializing Asb sender.");
    MessageSender messageSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver.");
    MessageReceiver messageReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender.");
    check messageSender->send(message1);

    log:printInfo("Receiving from Asb receiver.");
    Message|error? messageReceived = messageReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        int result = check messageReceiver->defer(messageReceived);
        test:assertNotEquals(result, 0, msg = "Defer message not successful.");
        Message|error? messageReceivedAgain = check messageReceiver->receiveDeferred(result);
        if messageReceivedAgain is Message {
            test:assertEquals(messageReceivedAgain?.messageId, messageReceived?.messageId,
                msg = "Receiving deferred message not succesful.");
            check messageReceiver->complete(messageReceivedAgain);
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check messageSender->close();

    log:printInfo("Closing Asb receiver client.");
    check messageReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testDeferMessageFromQueueOperation],
    enable: true
}
function testSendAndReceiveMessageFromSubscriptionOperation() returns error? {
    log:printInfo("[[testSendAndReceiveMessageFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    senderConfig.topicOrQueueName = testTopic1;
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    receiverConfig.entityConfig = {
        topicName: testTopic1,
        subscriptionName: testSubscription1
    };
    receiverConfig.receiveMode = RECEIVE_AND_DELETE;
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        log:printInfo(messageReceived.toString());
        string msg = check string:fromBytes(<byte[]>messageReceived.body);
        test:assertEquals(msg, stringContent, msg = "Sent & received message not equal.");
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveMessageFromSubscriptionOperation],
    enable: true
}
function testSendAndReceiveBatchFromSubscriptionOperation() returns error? {
    log:printInfo("[[testSendAndReceiveBatchFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->sendBatch(messages);

    log:printInfo("Receiving from Asb receiver client.");
    MessageBatch|error? messageReceived = subscriptionReceiver->receiveBatch(maxMessageCount, serverWaitTime);

    if messageReceived is MessageBatch {
        foreach Message message in messageReceived.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received message not equal.");
            }
        }
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveMessageFromSubscriptionOperation],
    enable: true
}
function testSendAndReceiveBatchFromDeadLetterSubscriptionOperation() returns error? {
    log:printInfo("[[testSendAndReceiveBatchFromDeadLetterSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->sendBatch(messages);

    log:printInfo("Receiving from Asb receiver client.");
    MessageBatch|error? messageReceived = subscriptionReceiver->receiveBatch(maxMessageCount, serverWaitTime);

    if messageReceived is MessageBatch {
        foreach Message message in messageReceived.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received message not equal.");
                check subscriptionReceiver->deadLetter(message);
            }
        }
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Receiving from Asb dead-letter receiver client.");
    MessageBatch|error? receivedDeadletterMessages = subscriptionReceiver->receiveBatch(maxMessageCount, serverWaitTime, true);

    if receivedDeadletterMessages is MessageBatch {
        foreach Message message in receivedDeadletterMessages.messages {
            if message.toString() != "" {
                string msg = check string:fromBytes(<byte[]>message.body);
                test:assertEquals(msg, stringContent, msg = "Sent & received deadl-letter message not equal.");
            }
        }
    } else if receivedDeadletterMessages is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }
    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testSendAndReceiveBatchFromDeadLetterSubscriptionOperation],
    enable: true
}
function testCompleteMessageFromSubscriptionOperation() returns error? {
    log:printInfo("[[testCompleteMessageFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    receiverConfig.receiveMode = PEEK_LOCK;
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check subscriptionReceiver->complete(messageReceived);
        test:assertEquals(result, (), msg = "Complete message not successful.");
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testCompleteMessageFromSubscriptionOperation],
    enable: true
}
function testAbandonMessageFromSubscriptionOperation() returns error? {
    log:printInfo("[[testAbandonMessageFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check subscriptionReceiver->abandon(messageReceived);
        test:assertEquals(result, (), msg = "Abandon message not successful.");
        Message|error? messageReceivedAgain = subscriptionReceiver->receive(serverWaitTime);
        if messageReceivedAgain is Message {
            check subscriptionReceiver->complete(messageReceivedAgain);
        } else {
            test:assertFail("Abandon message not succesful.");
        }
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testAbandonMessageFromSubscriptionOperation],
    enable: true
}
function testDeadletterMessageFromSubscriptionOperation() returns error? {
    log:printInfo("[[testDeadletterMessageFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        var result = check subscriptionReceiver->deadLetter(messageReceived);
        test:assertEquals(result, (), msg = "Deadletter message not successful.");
    } else if messageReceived is () {
        test:assertFail("No message in the subscription.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testDeadletterMessageFromSubscriptionOperation],
    enable: true
}
function testReceiveDeadLetterSubscriptionMessages() returns error? {
    log:printInfo("[[testReceiveDeadLetterSubscriptionMessages]]");

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver queueReceiver = check new (receiverConfig);

    log:printInfo("Receiving from Asb receiver.");
    Message|error? message = queueReceiver->receive(serverWaitTime, deadLettered = true);

    if message is Message {
        string receivedContent = check string:fromBytes(<byte[]>message.body);
        test:assertEquals(receivedContent, stringContent, msg = "Sent & received dead letter message not equal.");
    } else if message is () {
        log:printError("No dead letter message in the queue.");
    } else {
        log:printError("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Receiving from Asb receiver.(for test usage of already creaated dead letter queue receiver)");
    message = queueReceiver->receive(serverWaitTime, deadLettered = true);

    if message is Message {
        string receivedContent = check string:fromBytes(<byte[]>message.body);
        test:assertEquals(receivedContent, stringContent, msg = "Sent & received dead letter message not equal.");
    } else if message is () {
        log:printError("No dead letter message in the queue.");
    } else {
        log:printError("Receiving message via Asb receiver connection failed.");
    }
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testReceiveDeadLetterSubscriptionMessages],
    enable: true
}
function testDeferMessageFromSubscriptionOperation() returns error? {
    log:printInfo("[[testDeferMessageFromSubscriptionOperation]]");

    log:printInfo("Initializing Asb sender client.");
    MessageSender topicSender = check new (senderConfig);

    log:printInfo("Initializing Asb receiver client.");
    MessageReceiver subscriptionReceiver = check new (receiverConfig);

    log:printInfo("Sending via Asb sender client.");
    check topicSender->send(message1);

    log:printInfo("Receiving from Asb receiver client.");
    Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);

    if messageReceived is Message {
        int result = check subscriptionReceiver->defer(messageReceived);
        test:assertNotEquals(result, 0, msg = "Defer message not successful.");
        Message|error? messageReceivedAgain = check subscriptionReceiver->receiveDeferred(result);
        if messageReceivedAgain is Message {
            test:assertEquals(messageReceivedAgain?.messageId, messageReceived?.messageId,
                msg = "Receiving deferred message not successful.");
            check subscriptionReceiver->complete(messageReceivedAgain);
        }
    } else if messageReceived is () {
        test:assertFail("No message in the queue.");
    } else {
        test:assertFail("Receiving message via Asb receiver connection failed.");
    }

    log:printInfo("Closing Asb sender client.");
    check topicSender->close();

    log:printInfo("Closing Asb receiver client.");
    check subscriptionReceiver->close();
}

@test:Config {
    groups: ["asb_sender_receiver"],
    dependsOn: [testDeferMessageFromSubscriptionOperation],
    enable: true
}
function testMessageScheduling() returns error? {
    log:printInfo("[[testMessageScheduling]]");
    MessageSender? topicSender = ();
    MessageReceiver? subscriptionReceiver = ();

    do {

        log:printInfo("Initializing Asb sender client.");
        senderConfig.topicOrQueueName = testTopic1;
        topicSender = check new (senderConfig);

        log:printInfo("Initializing Asb receiver client.");
        receiverConfig.entityConfig = {
            topicName: testTopic1,
            subscriptionName: testSubscription1
        };
        receiverConfig.receiveMode = RECEIVE_AND_DELETE;
        subscriptionReceiver = check new (receiverConfig);

        log:printInfo("Scheduling message via Asb sender client to be enqueued by 15 seconds");
        time:Utc utcScheduleTime = time:utcAddSeconds(time:utcNow(), 15);
        time:Civil civilScheduleTime = time:utcToCivil(utcScheduleTime);
        if topicSender is MessageSender {
            int sequenceNumber = check topicSender->schedule(message1, civilScheduleTime);

            log:printInfo("Scheduled message with sequence ID = " + sequenceNumber.toString());
            log:printInfo("Receiving from Asb receiver client. Max wait = " + serverWaitTime.toString());
            if subscriptionReceiver is MessageReceiver {
                Message|error? messageReceived = subscriptionReceiver->receive(serverWaitTime);
                if messageReceived is Message {
                    log:printInfo(messageReceived.toString());
                    string msg = check string:fromBytes(<byte[]>messageReceived.body);
                    test:assertEquals(msg, stringContent, msg = "Sent & received message not equal.");
                } else if messageReceived is () {
                    test:assertFail("Subscription did not receive message within " + serverWaitTime.toString());
                } else {
                    test:assertFail("Receiving message via Asb receiver connection failed.");
                }
            } else {
                test:assertFail("Initializing Asb receiver client failed.");
            }
        } else {
            test:assertFail("Initializing Asb sender client failed.");
        }
    } on fail error e {
        log:printInfo("Closing Asb sender client.");
        if (topicSender is MessageSender) {
            check topicSender->close();
        }
        log:printInfo("Closing Asb receiver client.");
        if (subscriptionReceiver is MessageReceiver) {
            check subscriptionReceiver->close();
        }
        return error("Error while executing test testMessageScheduling", e);
    }
}

@test:AfterEach
function afterEach() {
    // Restore sender and receiver configurations after each test, as they are modified by some of the tests.
    senderConfig = {
        connectionString: connectionString,
        entityType: QUEUE,
        topicOrQueueName: testQueue1
    };

    receiverConfig = {
        connectionString: connectionString,
        entityConfig: {
            queueName: testQueue1
        },
        receiveMode: PEEK_LOCK
    };
}
