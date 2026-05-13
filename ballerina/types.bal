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

# Azure service bus message batch representation.
#
# + messageCount - Number of messages in a batch  
# + messages - Array of Azure service bus message representation (Array of Message records)
@display {label: "Batch Message"}
public type MessageBatch record {|
    @display {label: "Message Count"}
    int messageCount = -1;
    @display {label: "Array of Messages"}
    Message[] messages = [];
|};

# Azure service bus Message representation.
#
# + body - Message body, Here the connector supports AMQP message body types - DATA and VALUE, However, DATA type message bodies  
# will be received in Ballerina Byte[] type. VALUE message bodies can be any primitive AMQP type. therefore, the connector  
# supports for string, int or byte[]. Please refer Azure docs (https://learn.microsoft.com/en-us/java/api/com.azure.core.amqp.models.amqpmessagebody?view=azure-java-stable)  
# and AMQP docs (https://qpid.apache.org/amqp/type-reference.html#PrimitiveTypes)  
# + contentType - Message content type, with a descriptor following the format of `RFC2045`, (e.g. `application/json`) (optional)
# + messageId - Message Id (optional)  
# + to - Message to (optional)  
# + replyTo - Message reply to (optional)  
# + replyToSessionId - Identifier of the session to reply to (optional)  
# + label - Message label (optional)  
# + sessionId - Message session Id (optional)  
# + correlationId - Message correlationId (optional)  
# + partitionKey - Message partition key (optional)  
# + timeToLive - Message time to live in seconds (optional)  
# + sequenceNumber - Message sequence number (optional)  
# + lockToken - Message lock token (optional)  
# + applicationProperties - Message broker application specific properties (optional)  
# + deliveryCount - Number of times a message has been delivered in a queue/subscription  
# + enqueuedTime - Timestamp indicating when a message was added to the queue/subscription 
# + enqueuedSequenceNumber - Sequence number assigned to a message when it is added to the queue/subscription 
# + deadLetterErrorDescription - Error description of why a message went to a dead-letter queue  
# + deadLetterReason - Reason why a message was moved to a dead-letter queue  
# + deadLetterSource - Original queue/subscription where the message was before being moved to the dead-letter queue 
# + state - Current state of a message in the queue/subscription, could be "Active", "Scheduled", "Deferred", etc.
@display {label: "Message"}
public type Message record {|
    @display {label: "Message Body"}
    anydata body;
    @display {label: "Content Type"}
    string contentType = BYTE_ARRAY;
    @display {label: "Message Id"}
    string messageId?;
    @display {label: "To"}
    string to?;
    @display {label: "Reply To"}
    string replyTo?;
    @display {label: "Reply To Session Id"}
    string replyToSessionId?;
    @display {label: "Label"}
    string label?;
    @display {label: "Session Id"}
    string sessionId?;
    @display {label: "Correlation Id"}
    string correlationId?;
    @display {label: "Partition Key"}
    string partitionKey?;
    @display {label: "Time To Live"}
    int timeToLive?;
    @display {label: "Sequence Number"}
    readonly int sequenceNumber?;
    @display {label: "Lock Token"}
    readonly string lockToken?;
    ApplicationProperties applicationProperties?;
    @display {label: "Delivery Count"}
    int deliveryCount?;
    @display {label: "Enqueued Time"}
    string enqueuedTime?;
    @display {label: "Enqueued SequenceNumber"}
    int enqueuedSequenceNumber?;
    @display {label: "DeadLetter Error Description"}
    string deadLetterErrorDescription?;
    @display {label: "DeadLetter Reason"}
    string deadLetterReason?;
    @display {label: "DeadLetter Source"}
    string deadLetterSource?;
    @display {label: "Message State"}
    string state?;
|};

# Azure service bus message, application specific properties representation.
#
# + properties - Key-value pairs for each brokered property (optional)
@display {label: "Application Properties"}
public type ApplicationProperties record {|
    @display {label: "Properties"}
    map<anydata> properties?;
|};

# Configurations used to create an `asb:Connection`.
#
# + connectionString - Service bus connection string with Shared Access Signatures  
# ConnectionString format:
# Endpoint=sb://namespace_DNS_Name;EntityPath=EVENT_HUB_NAME;
# SharedAccessKeyName=SHARED_ACCESS_KEY_NAME;SharedAccessKey=SHARED_ACCESS_KEY or
# Endpoint=sb://namespace_DNS_Name;EntityPath=EVENT_HUB_NAME;
# SharedAccessSignatureToken=SHARED_ACCESS_SIGNATURE_TOKEN
# + entityConfig - This field holds the configuration details of either a topic or a queue. The type of the entity is
# determined by the entityType field. The actual configuration details are stored in either a
# TopicSubsConfig or a QueueConfig record
# + receiveMode - This field holds the receive modes(RECEIVE_AND_DELETE/PEEK_LOCK) for the connection. The receive mode determines how messages are 
# retrieved from the entity. The default value is PEEK_LOCK  
# + maxAutoLockRenewDuration - Max lock renewal duration under PEEK_LOCK mode in seconds. Setting to 0 disables auto-renewal. 
# For RECEIVE_AND_DELETE mode, auto-renewal is disabled. Default 300 seconds.
# + amqpRetryOptions - Retry configurations related to underlying AMQP message receiver
@display {label: "Receiver Connection Config"}
public type ASBServiceReceiverConfig record {
    @display {label: "ConnectionString"}
    string connectionString;
    @display {label: "Entity Configuration"}
    TopicSubsConfig|QueueConfig entityConfig;
    @display {label: "Receive Mode"}
    ReceiveMode receiveMode = PEEK_LOCK;
    @display {label: "Max Auto Lock Renew Duration"}
    int maxAutoLockRenewDuration = 300;
    @display {label: "AMQP retry configurations"}
    AmqpRetryOptions amqpRetryOptions = {};
};

# Set of options that can be specified to influence how the retry attempts are made.
#
# + maxRetries - Maximum number of retry attempts  
# + delay - Delay between retry attempts in seconds 
# + maxDelay - Maximum permissible delay between retry attempts in seconds
# + tryTimeout - Maximum duration to wait for completion of a single attempt in seconds  
# + retryMode - Approach to use for calculating retry delays
public type AmqpRetryOptions record {|
    @display {
        label: "Max retry attempts"
    }
    int maxRetries = 3;
    @display {
        label: "Duration between retries"
    }
    decimal delay = 10;
    @display {
        label: "Maximum duration between retries"
    }
    decimal maxDelay = 60;
    @display {
        label: "Timeout duration for retry attempt"
    }
    decimal tryTimeout = 60;
    @display {
        label: "Approach to calculated the retry"
    }
    AmqpRetryMode retryMode = FIXED;
|};

# The type of approach to apply when calculating the delay between retry attempts.
public enum AmqpRetryMode {
    # Retry attempts happen at fixed intervals; each delay is a consistent duration.
    @display {
        label: "Retry on fixed intervals"
    }
    FIXED,
    # Retry attempts will delay based on a backoff strategy, where each attempt will increase the duration that it waits before retrying.
    @display {
        label: "Retry based on a backoff strategy"
    }
    EXPONENTIAL
};

# This record holds the configuration details of a topic and its associated subscription in Azure Service Bus.
#
# + topicName - A string field that holds the name of the topic  
# + subscriptionName - A string field that holds the name of the subscription associated with the topic
@display {label: "Topic/Subscriptions Configurations"}
public type TopicSubsConfig record {
    @display {label: "Topic Name"}
    string topicName;
    @display {label: "Subscription Name"}
    string subscriptionName;
};

# This record holds the configuration details of a queue in Azure Service Bus.
#
# + queueName - A string field that holds the name of the queue
@display {label: "Queue Configurations"}
public type QueueConfig record {
    @display {label: "Queue Name"}
    string queueName;
};

# Holds the configuration details needed to create a sender connection to Azure Service Bus.
#
# + entityType - An enumeration value of type EntityType, which specifies whether the connection is for a topic or a queue. 
# The valid values are TOPIC and QUEUE
# + topicOrQueueName - A string field that holds the name of the topic or queue
# + connectionString - A string field that holds the Service Bus connection string with Shared Access Signatures.
# + amqpRetryOptions - Retry configurations related to underlying AMQP message sender
@display {label: "Sender Connection Config"}
public type ASBServiceSenderConfig record {
    @display {label: "EntityType"}
    EntityType entityType;
    @display {label: "Queue/Topic Name"}
    string topicOrQueueName;
    @display {label: "ConnectionString"}
    string connectionString;
    @display {label: "AMQP retry configurations"}
    AmqpRetryOptions amqpRetryOptions = {};
};

# Represents Custom configurations for the ASB connector.
#
# + logLevel - Enables the connector debug log prints (log4j log levels), default: OFF
public type CustomConfiguration record {
    @display {label: "Log Level"}
    LogLevel logLevel = OFF;
};

# Message entity types
public enum EntityType {
    @display {label: "Queue"}
    QUEUE = "queue",
    @display {label: "Topic"}
    TOPIC = "topic"
}

# Message receiver modes
public enum ReceiveMode {
    @display {label: "RECEIVE AND DELETE"}
    RECEIVE_AND_DELETE,
    @display {label: "PEEK LOCK"}
    PEEK_LOCK
}

# Log levels
public enum LogLevel {
    @display {label: "DEBUG"}
    DEBUG,
    @display {label: "INFO"}
    INFO,
    @display {label: "WARNING"}
    WARNING,
    @display {label: "ERROR"}
    ERROR,
    @display {label: "FATAL"}
    FATAL,
    @display {label: "OFF"}
    OFF
}

# SQL Rule.
#
# + filter - Represents a filter which is a composition of an expression and an action that is executed in the pub/sub pipeline
# + action - Represents set of actions written in Sql language-based syntax
@display {label: "SQL Rule"}
public type SqlRule record {
    string filter;
    string action;
};

# Create Rule Options.
#
# + rule - Represents a SQL filter which is a composition of an expression and an action that is executed in the pub/sub pipeline
@display {label: "Create Rule Options"}
public type CreateRuleOptions record {
    SqlRule rule?;
};

# Rule Properties.
#
# + rule - Represents a SQL filter which is a composition of an expression and an action that is executed in the pub/sub pipeline
# + name - The name of the rule
@display {label: "Rule Properties"}
public type RuleProperties record {
    SqlRule rule;
    string name;
};

# Update Rule Options.
#
# + rule - Represents a SQL filter which is a composition of an expression and an action that is executed in the pub/sub pipeline
@display {label: "Update Rule Options"}
public type UpdateRuleOptions record {
    SqlRule rule?;
};

# Rule List.
#
# + list - The list of rules
@display {label: "Rule List"}
public type RuleList record {
    RuleProperties[] list;
};

# Create Subscription Options.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the subscription is automatically deleted
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this subscription has dead letter support when a message expires
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value
# + deadLetteringOnFilterEvaluationExceptions - Value that indicates whether this subscription has dead letter support when a message expires
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + forwardTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + lockDuration - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10
# + requiresSession - A value that indicates whether the queue supports the concept of sessions
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the subscription
@display {label: "Create Subscription Options"}
public type CreateSubscriptionOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Dead Lettering On Filter Evaluation Exceptions"}
    boolean deadLetteringOnFilterEvaluationExceptions?;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo?;
    @display {label: "Forward To"}
    string forwardTo?;
    @display {label: "Lock Duration"}
    Duration lockDuration?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Requires Session"}
    boolean requiresSession?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
};

# SubscriptionProperties.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the subscription is automatically deleted
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + forwardTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + lockDuration - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10
# + status - Enumerates the possible values for the status of a messaging entity
# + subscriptionName - The name of the subscription
# + topicName - The name of the topic under which subscription exists
# + userMetadata - Metadata associated with the subscription
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnFilterEvaluationExceptions - A value that indicates whether this subscription has dead letter support when a message expires
# + deadLetteringOnMessageExpiration - A value that indicates whether this subscription has dead letter support when a message expires
# + requiresSession - A value that indicates whether the queue supports the concept of sessions
@display {label: "Subscription Properties"}
public type SubscriptionProperties record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo;
    @display {label: "Forward To"}
    string forwardTo;
    @display {label: "Lock Duration"}
    Duration lockDuration;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount;
    @display {label: "Status"}
    EntityStatus status;
    @display {label: "Subscription Name"}
    string subscriptionName;
    @display {label: "Topic Name"}
    string topicName;
    @display {label: "User Metadata"}
    string userMetadata;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations;
    @display {label: "Dead Lettering On Filter Evaluation Exceptions"}
    boolean deadLetteringOnFilterEvaluationExceptions;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration;
    @display {label: "Requires Session"}
    boolean requiresSession;
};

# Update Subscription Options.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the subscription is automatically deleted
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value
# + deadLetteringOnMessageExpiration - Value that indicates whether this subscription has dead letter support when a message expires
# + deadLetteringOnFilterEvaluationExceptions - Value that indicates whether this subscription has dead letter support when a message expires
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + forwardTo - The name of the recipient entity to which all the messages sent to the subscription are forwarded to
# + lockDuration - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the subscription
@display {label: "Update Subscription Options"}
public type UpdateSubscriptionOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Dead Lettering On Filter Evaluation Exceptions"}
    boolean deadLetteringOnFilterEvaluationExceptions?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo?;
    @display {label: "Forward To"}
    string forwardTo?;
    @display {label: "Lock Duration"}
    Duration lockDuration?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
};

# Subscription List.
#
# + list - The list of subscriptions
@display {label: "Subscription List"}
public type SubscriptionList record {
    SubscriptionProperties[] list;
};

# TopicProperties.
#
# + name - The name of the topic to create
# + authorizationRules - Authorization rules for resource
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue.
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue.
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + supportOrdering - Defines whether ordering needs to be maintained
@display {label: "Topic Properties"}
public type TopicProperties record {
    @display {label: "Name"}
    string name;
    @display {label: "Authorization Rules"}
    AuthorizationRule[] authorizationRules;
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes;
    @display {label: "Status"}
    EntityStatus status;
    @display {label: "User Metadata"}
    string userMetadata;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning;
    @display {label: "Support Ordering"}
    boolean supportOrdering;
};

# Create Topic Options.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + lockDuration - ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. The maximum value for LockDuration is 5 minutes; the default value is 1 minute.
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this queue has dead letter support when a message expires
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + requiresSession - Value that indicates whether the queue supports the concept of sessions
# + supportOrdering - Defines whether ordering needs to be maintained
@display {label: "Create Topic Options"}
public type CreateTopicOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow?;
    @display {label: "Lock Duration"}
    Duration lockDuration?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes?;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection?;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning?;
    @display {label: "Requires Session"}
    boolean requiresSession?;
    @display {label: "Support Ordering"}
    boolean supportOrdering?;
};

# Upadate Topic Propertise.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes.
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this queue has dead letter support when a message expires
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + requiresSession - Value that indicates whether the queue supports the concept of sessions
# + supportOrdering - Defines whether ordering needs to be maintained
@display {label: "Update Topic Options"}
public type UpdateTopicOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes?;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection?;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning?;
    @display {label: "Requires Session"}
    boolean requiresSession?;
    @display {label: "Support Ordering"}
    boolean supportOrdering?;
};

# Topic List
#
# + list - The list of topics.
@display {label: "Topic List"}
public type TopicList record {
    TopicProperties[] list;
};

# # QueueProperties.
#
# + authorizationRules - Authorization rules for resource
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes.
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the dead-lettered messages of this subscription are forwarded to.
# + forwardTo - The name of the recipient entity to which all the messages sent to the queue are forwarded to.
# + lockDuration - ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. The maximum value for LockDuration is 5 minutes; the default value is 1 minute.
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + name - The name of the queue to create
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this queue has dead letter support when a message expires
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + requiresSession - Value that indicates whether the queue supports the concept of sessions
@display {label: "Queue Properties"}
public type QueueProperties record {
    @display {label: "Authorization Rules"}
    AuthorizationRule[] authorizationRules;
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo;
    @display {label: "Forward To"}
    string forwardTo;
    @display {label: "Lock Duration"}
    Duration lockDuration;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes;
    @display {label: "Name"}
    string name;
    @display {label: "Status"}
    EntityStatus status;
    @display {label: "User Metadata"}
    string userMetadata;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning;
    @display {label: "Requires Session"}
    boolean requiresSession;
};

# Create Queue Options.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes.
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the dead-lettered messages of this subscription are forwarded to.
# + forwardTo - The name of the recipient entity to which all the messages sent to the queue are forwarded to
# + lockDuration - ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. The maximum value for LockDuration is 5 minutes; the default value is 1 minute.
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this queue has dead letter support when a message expires
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + requiresSession - Value that indicates whether the queue supports the concept of sessions
@display {label: "Create Queue Options"}
public type CreateQueueOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow?;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo?;
    @display {label: "Forward To"}
    string forwardTo?;
    @display {label: "Lock Duration"}
    Duration lockDuration?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes?;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection?;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning?;
    @display {label: "Requires Session"}
    boolean requiresSession?;
};

# Update Queue Options.
#
# + autoDeleteOnIdle - ISO 8601 timeSpan idle interval after which the queue is automatically deleted. The minimum duration is 5 minutes.
# + defaultMessageTimeToLive - ISO 8601 default message timespan to live value. This is the duration after which the message expires, starting from when the message is sent to Service Bus.
# + duplicateDetectionHistoryTimeWindow - ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.
# + forwardDeadLetteredMessagesTo - The name of the recipient entity to which all the dead-lettered messages of this subscription are forwarded to.
# + forwardTo - The name of the recipient entity to which all the messages sent to the queue are forwarded to
# + lockDuration - ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. The maximum value for LockDuration is 5 minutes; the default value is 1 minute.
# + maxDeliveryCount - The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.
# + maxMessageSizeInKilobytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + maxSizeInMegabytes - The maximum size of the queue in megabytes, which is the size of memory allocated for the queue
# + status - Enumerates the possible values for the status of a messaging entity
# + userMetadata - Metadata associated with the queue
# + enableBatchedOperations - Value that indicates whether server-side batched operations are enabled
# + deadLetteringOnMessageExpiration - Value that indicates whether this queue has dead letter support when a message expires
# + requiresDuplicateDetection - Value indicating if this queue requires duplicate detection
# + enablePartitioning - Value that indicates whether the queue is to be partitioned across multiple message brokers
# + requiresSession - Value that indicates whether the queue supports the concept of sessions
@display {label: "Update Queue Options"}
public type UpdateQueueOptions record {
    @display {label: "Auto Delete On Idle"}
    Duration autoDeleteOnIdle?;
    @display {label: "Default Message Time To Live"}
    Duration defaultMessageTimeToLive?;
    @display {label: "Duplicate Detection History Time Window"}
    Duration duplicateDetectionHistoryTimeWindow?;
    @display {label: "Forward Dead Lettered Messages To"}
    string forwardDeadLetteredMessagesTo?;
    @display {label: "Forward To"}
    string forwardTo?;
    @display {label: "Lock Duration"}
    Duration lockDuration?;
    @display {label: "Max Delivery Count"}
    int maxDeliveryCount?;
    @display {label: "Max Message Size In Kilobytes"}
    int maxMessageSizeInKilobytes?;
    @display {label: "Max Size In Megabytes"}
    int maxSizeInMegabytes?;
    @display {label: "Status"}
    EntityStatus status?;
    @display {label: "User Metadata"}
    string userMetadata?;
    @display {label: "Enable Batched Operations"}
    boolean enableBatchedOperations?;
    @display {label: "Dead Lettering On Message Expiration"}
    boolean deadLetteringOnMessageExpiration?;
    @display {label: "Requires Duplicate Detection"}
    boolean requiresDuplicateDetection?;
    @display {label: "Enable Partitioning"}
    boolean enablePartitioning?;
    @display {label: "Requires Session"}
    boolean requiresSession?;
};

# Queue List.
#
# + list - The list of queues
@display {label: "Queue List"}
public type QueueList record {
    QueueProperties[] list;
};

# Duration.
#
# + seconds - Seconds
# + nanoseconds - Nanoseconds
@display {label: "Duration"}
public type Duration record {
    @display {label: "Seconds"}
    int seconds = 0;
    @display {label: "Nano Seconds"}
    int nanoseconds = 0;
};

# AuthorizationRule.
#
# + accessRights - The rights associated with the rule
# + claimType - The type of the claim
# + claimValue - The value of the claim
# + createdAt - The exact time the rule was created
# + keyName - The name of the key that was used
# + modifiedAt - The exact time the rule was modified
# + primaryKey - The primary key associated with the rule
# + secondaryKey - The secondary key associated with the rule
@display {label: "Authorization Rule"}
public type AuthorizationRule record {
    @display {label: "Access Rights"}
    AccessRight[] accessRights;
    @display {label: "Claim Type"}
    string claimType;
    @display {label: "Claim Value"}
    string claimValue;
    @display {label: "Created At"}
    string createdAt;
    @display {label: "Key Name"}
    string keyName;
    @display {label: "Modified At"}
    string modifiedAt;
    @display {label: "Primary Key"}
    string primaryKey;
    @display {label: "Secondary Key"}
    string secondaryKey;
};

# Access rights
@display {label: "Access Rights"}
public enum AccessRight {
    @display {label: "MANAGE"}
    MANAGE = "MANAGE",
    @display {label: "SEND"}
    SEND = "SEND",
    @display {label: "LISTEN"}
    LISTEN = "LISTEN"
};

# Entity status
@display {label: "Entity Status"}
public enum EntityStatus {
    @display {label: "ACTIVE"}
    ACTIVE = "Active",
    @display {label: "CREATING"}
    CREATING = "Creating",
    @display {label: "DELETING"}
    DELETING = "Deleting",
    @display {label: "DISABLED"}
    DISABLED = "Disabled",
    @display {label: "RECEIVE_DISABLED"}
    RECEIVE_DISABLED = "ReceiveDisabled",
    @display {label: "RENAMING"}
    RENAMING = "Renaming",
    @display {label: "RESTORING"}
    RESTORING = "Restoring",
    @display {label: "SEND_DISABLED"}
    SEND_DISABLED = "SendDisabled",
    @display {label: "UNKNOWN"}
    UNKNOWN = "Unknown"
};

# Represents Azure service bus listener configuration.
#
# + autoComplete - Enables auto-complete and auto-abandon of received messages 
# + prefetchCount - The number of messages to prefetch  
# + maxConcurrency - Max concurrent messages that this listener should process
public type ListenerConfiguration record {|
    *ASBServiceReceiverConfig;
    boolean autoComplete = true;
    int prefetchCount = 0;
    int maxConcurrency = 1;
|};

# Options to specify when sending an `asb:Message` received via `asb:ReceiveMode#PEEK_LOCK` to the dead-letter queue.
#
# + deadLetterReason - The deadletter reason
# + deadLetterErrorDescription - The deadletter error description
# + propertiesToModify - Message properties to modify
public type DeadLetterOptions record {|
    string deadLetterReason?;
    string deadLetterErrorDescription?;
    map<anydata> propertiesToModify?;
|};

# Represents Custom configurations for the ASB connector
#
# + logLevel - Enables the connector debug log prints (log4j log levels), default: OFF
public type Options record {
    @display {label: "Log Level"}
    LogLevel logLevel = OFF;
};

# Represents message retrieval error context.
#
# + entityPath - The entity path of the error source  
# + className - The name of the originating class    
# + namespace -  The namespace of the error source  
# + errorSource - The error source, such as a function or action name   
# + reason - The reason for the error
public type ErrorContext record {
    @display {label: "Entity Path"}
    string entityPath;
    @display {label: "Class Name"}
    string className;
    @display {label: "Namespace"}
    string namespace;
    @display {label: "Error Source"}
    string errorSource;
    @display {label: "Reason"}
    string reason;
};

# Represents admin action error context.
# 
# + statusCode - The HTTP status code returned by the ASB Admin API
# + reason - The reason for the error
public type AdminErrorContext record {
    @display {label: "Status code"}
    int statusCode;
    @display {label: "Reason"}
    string reason;
};
