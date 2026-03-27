/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.asb.util;

import com.azure.core.amqp.AmqpRetryMode;
import com.azure.core.amqp.AmqpRetryOptions;
import com.azure.messaging.servicebus.ServiceBusClientBuilder;
import com.azure.messaging.servicebus.ServiceBusClientBuilder.ServiceBusReceiverClientBuilder;
import com.azure.messaging.servicebus.ServiceBusReceiverClient;
import com.azure.messaging.servicebus.administration.models.CreateQueueOptions;
import com.azure.messaging.servicebus.administration.models.CreateRuleOptions;
import com.azure.messaging.servicebus.administration.models.CreateSubscriptionOptions;
import com.azure.messaging.servicebus.administration.models.CreateTopicOptions;
import com.azure.messaging.servicebus.administration.models.EntityStatus;
import com.azure.messaging.servicebus.administration.models.QueueProperties;
import com.azure.messaging.servicebus.administration.models.RuleProperties;
import com.azure.messaging.servicebus.administration.models.SqlRuleAction;
import com.azure.messaging.servicebus.administration.models.SqlRuleFilter;
import com.azure.messaging.servicebus.administration.models.SubscriptionProperties;
import com.azure.messaging.servicebus.administration.models.TopicProperties;
import com.azure.messaging.servicebus.models.ServiceBusReceiveMode;
import com.azure.messaging.servicebus.models.SubQueue;
import io.ballerina.lib.asb.receiver.MessageReceiver;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.ErrorType;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.XmlUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import org.apache.qpid.proton.amqp.Binary;
import org.ballerinalang.langlib.value.CloneWithType;
import org.ballerinalang.langlib.value.FromJsonWithType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

import static io.ballerina.runtime.api.TypeTags.ANYDATA_TAG;
import static io.ballerina.runtime.api.TypeTags.ARRAY_TAG;
import static io.ballerina.runtime.api.TypeTags.BYTE_TAG;
import static io.ballerina.runtime.api.TypeTags.NULL_TAG;
import static io.ballerina.runtime.api.TypeTags.RECORD_TYPE_TAG;
import static io.ballerina.runtime.api.TypeTags.STRING_TAG;
import static io.ballerina.runtime.api.TypeTags.UNION_TAG;
import static io.ballerina.runtime.api.TypeTags.XML_TAG;
import static io.ballerina.runtime.api.constants.RuntimeConstants.ORG_NAME_SEPARATOR;
import static io.ballerina.runtime.api.constants.RuntimeConstants.VERSION_SEPARATOR;
import static io.ballerina.runtime.api.utils.TypeUtils.getReferredType;

/**
 * Utility class for Azure Service Bus.
 */
public class ASBUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(MessageReceiver.class);

    /**
     * Convert Map to BMap.
     *
     * @param map Input Map used to convert to BMap.
     * @return Converted BMap object.
     */
    public static BMap<BString, Object> toBMap(Map<String, Object> map) {
        MapType mapType = TypeCreator.createMapType(PredefinedTypes.TYPE_ANY);
        BMap<BString, Object> envMap = ValueCreator.createMapValue(mapType);
        if (map != null) {
            for (Object aKey : map.keySet().toArray()) {
                Object value = map.get(aKey);
                String classType = value.getClass().getName();
                switch (classType) {
                    case "java.lang.Integer":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Integer) value);
                        break;
                    case "java.lang.Long":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Long) value);
                        break;
                    case "java.lang.Float":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Float) value);
                        break;
                    case "java.lang.Double":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Double) value);
                        break;
                    case "java.lang.Boolean":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Boolean) value);
                        break;
                    case "java.lang.Character":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Character) value);
                        break;
                    case "java.lang.Byte":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Byte) value);
                        break;
                    case "java.lang.Short":
                        envMap.put(StringUtils.fromString(aKey.toString()), (Short) value);
                        break;
                    default:
                        envMap.put(StringUtils.fromString(aKey.toString()),
                                StringUtils.fromString(value.toString()));
                        break;
                }
            }
        }
        return envMap;
    }

    /**
     * Get the value as string or as empty based on the object value.
     *
     * @param value Input value.
     * @return value as a string or empty.
     */
    public static String convertString(Object value) {
        return (value == null || Objects.equals(value.toString(), "")) ? null : value.toString();
    }

    /**
     * Build the ServiceBusClientBuilder object.
     *
     * @param retryOptions             Retry options.
     * @param connectionString         Connection string.
     * @param queueName                Queue name.
     * @param receiveMode              Receive mode.
     * @param maxAutoLockRenewDuration Max auto lock renew duration.
     * @param topicName                Topic name.
     * @param subscriptionName         Subscription name.
     * @return ServiceBusReceiverClientBuilder object.
     */
    public static ServiceBusReceiverClient constructReceiverClient(AmqpRetryOptions retryOptions,
                                                                   String connectionString,
                                                                   String queueName,
                                                                   String receiveMode,
                                                                   long maxAutoLockRenewDuration,
                                                                   String topicName,
                                                                   String subscriptionName,
                                                                   boolean isDeadLetterReceiver) {
        ServiceBusReceiverClientBuilder receiverClientBuilder = new ServiceBusClientBuilder()
                .connectionString(connectionString)
                .retryOptions(retryOptions)
                .receiver();

        ServiceBusReceiveMode mode = ServiceBusReceiveMode.valueOf(receiveMode);

        if (isDeadLetterReceiver) {
            receiverClientBuilder.subQueue(SubQueue.DEAD_LETTER_QUEUE);
        }

        if (!queueName.isEmpty()) {
            receiverClientBuilder.queueName(queueName);
        } else if (!subscriptionName.isEmpty() && !topicName.isEmpty()) {
            receiverClientBuilder.topicName(topicName)
                    .subscriptionName(subscriptionName);
        }

        if (mode == ServiceBusReceiveMode.PEEK_LOCK) {
            receiverClientBuilder.maxAutoLockRenewDuration(Duration.ofSeconds(maxAutoLockRenewDuration));
        }

        return receiverClientBuilder.receiveMode(mode).buildClient();
    }

    /**
     * Get the map value as string or as empty based on the key.
     *
     * @param map Input map.
     * @param key Input key.
     * @return map value as a string or empty.
     */
    public static String convertString(Map<String, ?> map, String key) {
        Object value = map.get(key);
        return value == null ? null : value.toString();
    }

    /**
     * Convert BMap to String Map.
     *
     * @param map Input BMap used to convert to Map.
     * @return Converted Map object.
     */
    public static Map<String, Object> toMap(BMap<BString, Object> map) {
        Map<String, Object> returnMap = new HashMap<>();
        Object value;
        String classType;
        String key;
        if (map != null) {
            for (Object aKey : map.getKeys()) {
                value = map.get(aKey);
                classType = value.getClass().getName();
                key = aKey.toString();
                switch (classType) {
                    case "java.lang.Long":
                        returnMap.put(key, (Long) value);
                        break;
                    case "java.lang.Integer":
                        returnMap.put(key, (Integer) value);
                        break;
                    case "java.lang.Float":
                        returnMap.put(key, (Float) value);
                        break;
                    case "java.lang.Double":
                        returnMap.put(key, (Double) value);
                        break;
                    case "java.lang.Boolean":
                        returnMap.put(key, (Boolean) value);
                        break;
                    case "java.lang.Character":
                        returnMap.put(key, (Character) value);
                        break;
                    case "java.lang.Byte":
                        returnMap.put(key, (Byte) value);
                        break;
                    case "java.lang.Short":
                        returnMap.put(key, (Short) value);
                        break;
                    default:
                        returnMap.put(key, value.toString());
                }
            }
        }
        return returnMap;
    }

    /**
     * Convert BMap to Object Map.
     *
     * @param map Input BMap used to convert to Map.
     * @return Converted Map object.
     */
    public static Map<String, Object> toObjectMap(BMap<BString, Object> map) {
        Map<String, Object> returnMap = new HashMap<>();
        if (map != null) {
            for (Object aKey : map.getKeys()) {
                returnMap.put(aKey.toString(), map.get(aKey));
            }
        }
        return returnMap;
    }

    public static AmqpRetryOptions getRetryOptions(BMap<BString, Object> retryConfigs) {
        Long maxRetries = retryConfigs.getIntValue(ASBConstants.MAX_RETRIES);
        BigDecimal delayConfig = ((BDecimal) retryConfigs.get(ASBConstants.DELAY)).decimalValue();
        BigDecimal maxDelay = ((BDecimal) retryConfigs.get(ASBConstants.MAX_DELAY)).decimalValue();
        BigDecimal tryTimeout = ((BDecimal) retryConfigs.get(ASBConstants.TRY_TIMEOUT)).decimalValue();
        String retryMode = retryConfigs.getStringValue(ASBConstants.RETRY_MODE).getValue();
        return new AmqpRetryOptions()
                .setMaxRetries(maxRetries.intValue())
                .setDelay(Duration.ofSeconds(delayConfig.intValue()))
                .setMaxDelay(Duration.ofSeconds(maxDelay.intValue()))
                .setTryTimeout(Duration.ofSeconds(tryTimeout.intValue()))
                .setMode(AmqpRetryMode.valueOf(retryMode));
    }

    public static RecordType getRecordType(BTypedesc bTypedesc) {
        RecordType recordType;
        if (bTypedesc.getDescribingType().isReadOnly()) {
            recordType = (RecordType) getReferredType(((IntersectionType) getReferredType(
                    bTypedesc.getDescribingType())).getConstituentTypes().get(0));
        } else {
            recordType = (RecordType) getReferredType(bTypedesc.getDescribingType());
        }
        return recordType;
    }

    /**
     * Get CreateSubscriptionProperties from BMap.
     *
     * @param subscriptionConfig BMap containing the subscription configurations.
     * @return CreateSubscriptionOptions object.
     */
    public static CreateSubscriptionOptions getCreateSubscriptionPropertiesFromBObject(BMap<BString, Object>
                                                                                               subscriptionConfig) {
        CreateSubscriptionOptions subscriptionOptions = new CreateSubscriptionOptions();
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            subscriptionOptions.setAutoDeleteOnIdle(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            subscriptionOptions.setDefaultMessageTimeToLive(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (subscriptionConfig.containsKey(
                ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION)) {
            subscriptionOptions.setDeadLetteringOnMessageExpiration(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS)) {
            subscriptionOptions.setBatchedOperationsEnabled(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS));
        }
        if (subscriptionConfig.containsKey(
                ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO)) {
            subscriptionOptions.setForwardDeadLetteredMessagesTo(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO).getValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_TO)) {
            subscriptionOptions.setForwardTo(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_TO).getValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_LOCK_DURATION)) {
            subscriptionOptions.setLockDuration(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_LOCK_DURATION)));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_MAX_DELIVERY_COUNT)) {
            subscriptionOptions.setMaxDeliveryCount(
                    subscriptionConfig.getIntValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_MAX_DELIVERY_COUNT).intValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_STATUS)) {
            subscriptionOptions.setStatus(EntityStatus.fromString(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_STATUS).getValue()));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_USER_METADATA)) {
            subscriptionOptions.setUserMetadata(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_USER_METADATA).getValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_SESSION_REQUIRED)) {
            subscriptionOptions.setSessionRequired(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_SESSION_REQUIRED));
        }
        return subscriptionOptions;
    }

    /**
     * Get UpdatedTopicProperties from BMap.
     *
     * @param topicConfig BMap containing the updated topic configurations.
     * @return TopicProperties object.
     */
    public static TopicProperties getUpdatedTopicPropertiesFromBObject(BMap<BString, Object> topicConfig,
                                                                       TopicProperties topicProperties) {
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            topicProperties.setAutoDeleteOnIdle(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            topicProperties.setDefaultMessageTimeToLive(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)) {
            topicProperties.setDuplicateDetectionHistoryTimeWindow(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES)) {
            topicProperties.setMaxMessageSizeInKilobytes(
                    topicConfig.getIntValue(
                            ASBConstants.TOPIC_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES).intValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES)) {
            topicProperties.setMaxSizeInMegabytes(
                    topicConfig.getIntValue(
                            ASBConstants.TOPIC_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES).intValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_STATUS)) {
            topicProperties.setStatus(EntityStatus.fromString(
                    topicConfig.getStringValue(
                            ASBConstants.TOPIC_RECORD_FIELD_STATUS).getValue()));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_USER_METADATA)) {
            topicProperties.setUserMetadata(
                    topicConfig.getStringValue(
                            ASBConstants.TOPIC_RECORD_FIELD_USER_METADATA).getValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION)) {
            topicProperties.setDuplicateDetectionRequired(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_ENABLE_ORDERING_SUPPORT)) {
            topicProperties.setOrderingSupported(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_ENABLE_ORDERING_SUPPORT));
        }
        return topicProperties;
    }

    /**
     * Get UpdatedSubscriptionProperties from BMap.
     *
     * @param subscriptionProperties BMap containing the rule configurations.
     * @return subscriptionProperties object.
     */
    public static SubscriptionProperties getUpdatedSubscriptionPropertiesFromBObject(
            BMap<BString, Object> subscriptionConfig, SubscriptionProperties subscriptionProperties) {
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            subscriptionProperties.setAutoDeleteOnIdle(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            subscriptionProperties.setDefaultMessageTimeToLive(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (subscriptionConfig.containsKey(
                ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION)) {
            subscriptionProperties.setDeadLetteringOnMessageExpiration(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION));
        }
        if (subscriptionConfig.containsKey(
                ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_FILTER_EVALUATION_EXCEPTIONS)) {
            subscriptionProperties.setDeadLetteringOnMessageExpiration(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_DEAD_LETTERING_ON_FILTER_EVALUATION_EXCEPTIONS));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS)) {
            subscriptionProperties.setBatchedOperationsEnabled(
                    subscriptionConfig.getBooleanValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS));
        }
        if (subscriptionConfig.containsKey(
                ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO)) {
            subscriptionProperties.setForwardDeadLetteredMessagesTo(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO).getValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_TO)) {
            subscriptionProperties.setForwardTo(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_FORWARD_TO).getValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_LOCK_DURATION)) {
            subscriptionProperties.setLockDuration(
                    getDurationFromBObject(subscriptionConfig.getMapValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_LOCK_DURATION)));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_MAX_DELIVERY_COUNT)) {
            subscriptionProperties.setMaxDeliveryCount(
                    subscriptionConfig.getIntValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_MAX_DELIVERY_COUNT).intValue());
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_STATUS)) {
            subscriptionProperties.setStatus(EntityStatus.fromString(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_STATUS).getValue()));
        }
        if (subscriptionConfig.containsKey(ASBConstants.SUBSCRIPTION_RECORD_FIELD_USER_METADATA)) {
            subscriptionProperties.setUserMetadata(
                    subscriptionConfig.getStringValue(
                            ASBConstants.SUBSCRIPTION_RECORD_FIELD_USER_METADATA).getValue());
        }
        return subscriptionProperties;
    }

    /**
     * Get UpdatedRuleProperties from BMap.
     *
     * @param ruleConfig BMap containing the queue configurations.
     * @return RuleProperties object.
     */
    public static RuleProperties getUpdatedRulePropertiesFromBObject(BMap<BString, Object> ruleConfig,
                                                                     RuleProperties ruleProp) {
        if (ruleConfig.containsKey(ASBConstants.RECORD_FIELD_SQL_RULE)) {
            if (ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).containsKey(
                    ASBConstants.RECORD_FIELD_ACTION)) {
                ruleProp.setAction(new SqlRuleAction(
                        ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).getStringValue(
                                ASBConstants.RECORD_FIELD_ACTION).getValue()));
            }
            if (ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).containsKey(
                    ASBConstants.RECORD_FIELD_FILTER)) {
                ruleProp.setFilter(new SqlRuleFilter(
                        ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).getStringValue(
                                ASBConstants.RECORD_FIELD_FILTER).getValue()));
            }
        }
        return ruleProp;
    }

    /**
     * Get UpdatedQueueProperties from BMap.
     *
     * @param queueConfig BMap containing the queue configurations.
     * @return QueueProperties object.
     */
    public static QueueProperties getUpdatedQueuePropertiesFromBObject(BMap<BString, Object> queueConfig,
                                                                       QueueProperties updateQueueOptions) {
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_FORWARD_TO)) {
            updateQueueOptions.setForwardTo(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_FORWARD_TO).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO)) {
            updateQueueOptions.setForwardDeadLetteredMessagesTo(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_USER_METADATA)) {
            updateQueueOptions.setUserMetadata(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_USER_METADATA).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_STATUS)) {
            updateQueueOptions.setStatus(EntityStatus.fromString(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_STATUS).getValue()));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_DELIVERY_COUNT)) {
            updateQueueOptions.setMaxDeliveryCount(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_DELIVERY_COUNT).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES)) {
            updateQueueOptions.setMaxSizeInMegabytes(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES)) {
            updateQueueOptions.setMaxMessageSizeInKilobytes(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS)) {
            updateQueueOptions.setBatchedOperationsEnabled(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION)) {
            updateQueueOptions.setDeadLetteringOnMessageExpiration(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            updateQueueOptions.setDefaultMessageTimeToLive(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            updateQueueOptions.setAutoDeleteOnIdle(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_LOCK_DURATION)) {
            updateQueueOptions.setLockDuration(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_LOCK_DURATION)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)) {
            updateQueueOptions.setDuplicateDetectionHistoryTimeWindow(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)));
        }
        return updateQueueOptions;
    }

    /**
     * Get Create Topic Properties from BMap.
     *
     * @param topicConfig BMap containing the topic configurations.
     * @return CreateTopicOptions object.
     */
    public static CreateTopicOptions getCreateTopicPropertiesFromBObject(BMap<BString, Object> topicConfig) {
        CreateTopicOptions topicProperties = new CreateTopicOptions();
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            topicProperties.setAutoDeleteOnIdle(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            topicProperties.setDefaultMessageTimeToLive(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)) {
            topicProperties.setDuplicateDetectionHistoryTimeWindow(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_LOCK_DURATION)) {
            topicProperties.setLockDuration(
                    getDurationFromBObject(topicConfig.getMapValue(
                            ASBConstants.TOPIC_RECORD_FIELD_LOCK_DURATION)));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_MAX_DELIVERY_COUNT)) {
            topicProperties.setMaxDeliveryCount(
                    topicConfig.getIntValue(
                            ASBConstants.TOPIC_RECORD_FIELD_MAX_DELIVERY_COUNT).intValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES)) {
            topicProperties.setMaxMessageSizeInKilobytes(
                    topicConfig.getIntValue(
                            ASBConstants.TOPIC_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES).intValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES)) {
            topicProperties.setMaxSizeInMegabytes(
                    topicConfig.getIntValue(
                            ASBConstants.TOPIC_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES).intValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_STATUS)) {
            topicProperties.setStatus(EntityStatus.fromString(
                    topicConfig.getStringValue(
                            ASBConstants.TOPIC_RECORD_FIELD_STATUS).getValue()));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_USER_METADATA)) {
            topicProperties.setUserMetadata(
                    topicConfig.getStringValue(
                            ASBConstants.TOPIC_RECORD_FIELD_USER_METADATA).getValue());
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS)) {
            topicProperties.setBatchedOperationsEnabled(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION)) {
            topicProperties.setDuplicateDetectionRequired(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_ENABLE_PARTITIONING)) {
            topicProperties.setPartitioningEnabled(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_ENABLE_PARTITIONING));
        }
        if (topicConfig.containsKey(ASBConstants.TOPIC_RECORD_FIELD_REQUIRE_SESSION)) {
            topicProperties.setSessionRequired(
                    topicConfig.getBooleanValue(
                            ASBConstants.TOPIC_RECORD_FIELD_REQUIRE_SESSION));
        }
        return topicProperties;
    }

    /**
     * Get QueueProperties from BMap.
     *
     * @param queueConfig BMap containing the queue configurations.
     * @return CreateQueueOptions object.
     */
    public static CreateQueueOptions getQueuePropertiesFromBObject(BMap<BString, Object> queueConfig) {
        CreateQueueOptions createQueueOptions = new CreateQueueOptions();
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_FORWARD_TO)) {
            createQueueOptions.setForwardTo(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_FORWARD_TO).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO)) {
            createQueueOptions.setForwardDeadLetteredMessagesTo(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_FORWARD_DEAD_LETTERED_MESSAGES_TO).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_USER_METADATA)) {
            createQueueOptions.setUserMetadata(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_USER_METADATA).getValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_STATUS)) {
            createQueueOptions.setStatus(EntityStatus.fromString(
                    queueConfig.getStringValue(
                            ASBConstants.QUEUE_RECORD_FIELD_STATUS).getValue()));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_DELIVERY_COUNT)) {
            createQueueOptions.setMaxDeliveryCount(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_DELIVERY_COUNT).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES)) {
            createQueueOptions.setMaxSizeInMegabytes(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_SIZE_IN_MEGABYTES).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES)) {
            createQueueOptions.setMaxMessageSizeInKilobytes(
                    queueConfig.getIntValue(
                            ASBConstants.QUEUE_RECORD_FIELD_MAX_MESSAGE_SIZE_IN_KILOBYTES).intValue());
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS)) {
            createQueueOptions.setBatchedOperationsEnabled(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_ENABLE_BATCHED_OPERATIONS));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION)) {
            createQueueOptions.setDeadLetteringOnMessageExpiration(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DEAD_LETTERING_ON_MESSAGE_EXPIRATION));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION)) {
            createQueueOptions.setDuplicateDetectionRequired(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_REQUIRES_DUPLICATE_DETECTION));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_ENABLE_PARTITIONING)) {
            createQueueOptions.setPartitioningEnabled(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_ENABLE_PARTITIONING));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_REQUIRE_SESSION)) {
            createQueueOptions.setSessionRequired(
                    queueConfig.getBooleanValue(
                            ASBConstants.QUEUE_RECORD_FIELD_REQUIRE_SESSION));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)) {
            createQueueOptions.setDefaultMessageTimeToLive(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DEFAULT_MESSAGE_TIME_TO_LIVE)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_AUTO_DELETE_ON_IDLE)) {
            createQueueOptions.setAutoDeleteOnIdle(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_AUTO_DELETE_ON_IDLE)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_LOCK_DURATION)) {
            createQueueOptions.setLockDuration(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_LOCK_DURATION)));
        }
        if (queueConfig.containsKey(ASBConstants.QUEUE_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)) {
            createQueueOptions.setDuplicateDetectionHistoryTimeWindow(
                    getDurationFromBObject(queueConfig.getMapValue(
                            ASBConstants.QUEUE_RECORD_FIELD_DUPLICATE_DETECTION_HISTORY_TIME_WINDOW)));
        }
        return createQueueOptions;
    }

    /**
     * Get CreateRuleProperties from BMap.
     *
     * @param ruleConfig BMap containing the rule configurations.
     * @return CreateRuleOptions object.
     */
    public static CreateRuleOptions getCreateRulePropertiesFromBObject(BMap<BString, Object> ruleConfig) {
        CreateRuleOptions createRuleOptions = new CreateRuleOptions();
        if (ruleConfig.containsKey(ASBConstants.RECORD_FIELD_SQL_RULE)) {
            if (ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).containsKey(
                    ASBConstants.RECORD_FIELD_ACTION)) {
                createRuleOptions.setAction(new SqlRuleAction(
                        ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).getStringValue(
                                ASBConstants.RECORD_FIELD_ACTION).getValue()));
            }
            if (ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).containsKey(
                    ASBConstants.RECORD_FIELD_FILTER)) {
                createRuleOptions.setFilter(new SqlRuleFilter(
                        ruleConfig.getMapValue(ASBConstants.RECORD_FIELD_SQL_RULE).getStringValue(
                                ASBConstants.RECORD_FIELD_FILTER).getValue()));
            }
        }
        return createRuleOptions;
    }

    /**
     * Get Duration from BMap.
     *
     * @param durationConfig BMap containing the duration configurations.
     * @return Duration object.
     */
    public static Duration getDurationFromBObject(BMap<?, ?> durationConfig) {
        long seconds = durationConfig.getIntValue(ASBConstants.DURATION_FIELD_SECONDS);
        long nanoseconds = durationConfig.getIntValue(ASBConstants.DURATION_FIELD_NANOSECONDS);
        return Duration.ofSeconds(seconds).plusNanos(nanoseconds);
    }

    /**
     * Converts AMPQ Body value to Java objects.
     *
     * @param amqpValue AMQP Value type object
     */
    public static Object convertAMQPToJava(String messageId, Object amqpValue) {
        LOGGER.debug("Type of amqpValue object  of received message " + messageId + " is " + amqpValue.getClass());
        Class<?> clazz = amqpValue.getClass();
        switch (clazz.getSimpleName()) {
            case "Integer":
            case "Long":
            case "Float":
            case "Double":
            case "String":
            case "Boolean":
            case "Byte":
            case "Short":
            case "Character":
            case "BigDecimal":
            case "Date":
            case "UUID":
                return amqpValue;
            case "Binary":
                return ((Binary) amqpValue).getArray();
            default:
                LOGGER.debug("The type of amqpValue object " + clazz + " is not supported");
                return null;
        }
    }

    /**
     * Converts a given java value its counterpart BValue instance.
     *
     * @param jValue java value
     */
    public static Optional<Object> convertJavaToBValue(String messageId, Object jValue) {
        LOGGER.debug("Type of java object of received message " + messageId + " is " + jValue.getClass());
        Class<?> clazz = jValue.getClass();
        switch (clazz.getSimpleName()) {
            case "Integer":
            case "Long":
            case "Float":
            case "Double":
            case "Boolean":
            case "Byte":
            case "Short":
            case "Character":
                return Optional.of(jValue);
            case "String":
                return Optional.of(StringUtils.fromString((String) jValue));
            case "BigDecimal":
                return Optional.of(ValueCreator.createDecimalValue((BigDecimal) jValue));
            default:
                LOGGER.debug("java object with type '" + clazz + "' can not be converted to as a Ballerina value");
                return Optional.empty();
        }
    }

    /**
     * Converts `byte[]` value to the intended Ballerina type.
     *
     * @param type  expected type
     * @param value Value to be converted
     * @return value with the intended type
     */
    public static Object getValueWithIntendedType(byte[] value, Type type) {
        try {
            return getValueWithIntendedTypeRecursive(value, type);
        } catch (BError be) {
            throw ASBErrorCreator.fromBError(String.format("Failed to deserialize the message payload " +
                            "into the contextually expected type '%s'. Use a compatible Ballerina type or, " +
                            "use 'byte[]' type along with an appropriate deserialization logic afterwards.",
                    type.toString()), be);
        }
    }

    /**
     * Converts `byte[]` value to the intended Ballerina type.
     *
     * @param type  expected type
     * @param value Value to be converted
     * @return value with the intended type
     */
    private static Object getValueWithIntendedTypeRecursive(byte[] value, Type type) {
        String strValue = new String(value, StandardCharsets.UTF_8);
        Object intendedValue;
        switch (type.getTag()) {
            case STRING_TAG:
                intendedValue = StringUtils.fromString(strValue);
                break;
            case XML_TAG:
                intendedValue = XmlUtils.parse(strValue);
                break;
            case ANYDATA_TAG:
                intendedValue = ValueCreator.createArrayValue(value);
                break;
            case RECORD_TYPE_TAG:
                intendedValue = CloneWithType.convert(type, JsonUtils.parse(strValue));
                break;
            case UNION_TAG:
                if (isSupportedUnionType(type)) {
                    intendedValue = getValueWithIntendedType(value, getExpectedTypeFromNilableType(type));
                } else {
                    intendedValue = ErrorCreator.createError(StringUtils.fromString("Union types are not " +
                            "supported for the contextually expected type, except for nilable types"));
                }
                break;
            case ARRAY_TAG:
                if (getReferredType(((ArrayType) type).getElementType()).getTag() == BYTE_TAG) {
                    intendedValue = ValueCreator.createArrayValue(value);
                    break;
                }
                /*-fallthrough*/
            default:
                intendedValue = getValueFromJson(type, strValue);
        }

        if (intendedValue instanceof BError) {
            throw (BError) intendedValue;
        }
        return intendedValue;
    }

    /**
     * Checks whether the given type is a union type of two member types, including the nil type.
     *
     * @param type Type to be checked
     * @return True if the given type is a union type of two member types, including nil type.
     */
    private static boolean isSupportedUnionType(Type type) {
        if (type.getTag() != UNION_TAG) {
            return false;
        }
        UnionType unionType = (UnionType) type;
        return unionType.getMemberTypes().size() == 2
                && unionType.getMemberTypes().stream().anyMatch(memberType -> memberType.getTag() == NULL_TAG);
    }

    public static Type getExpectedTypeFromNilableType(Type type) {
        if (!(type instanceof UnionType)) {
            return null;
        }
        UnionType unionType = (UnionType) type;
        return unionType.getMemberTypes().stream()
                .filter(memberType -> memberType.getTag() != NULL_TAG)
                .findFirst()
                .orElse(null);
    }

    private static Object getValueFromJson(Type type, String stringValue) {
        BTypedesc typeDesc = ValueCreator.createTypedescValue(type);
        return FromJsonWithType.fromJsonWithType(JsonUtils.parse(stringValue), typeDesc);
    }

    /**
     * Adds the ASB properties to the Ballerina record response, only if present.
     *
     * @param map              Ballerina record map
     * @param key              Key of the property
     * @param receivedProperty Received property
     */
    public static void addFieldIfPresent(Map<String, Object> map, String key, Object receivedProperty) {
        if (receivedProperty != null) {
            map.put(key, receivedProperty);
        }
    }
    
    /**
     * Get the value as string or as empty based on the object value.
     *
     * @param value Input value.
     * @return value as a string or empty.
     */
    public static String valueToEmptyOrToString(Object value) {
        return (value == null || Objects.equals(value.toString(), "")) ? null : value.toString();
    }

    /**
     * Returns a Ballerina Error with the given String message.
     *
     * @param errorMessage The error message
     * @return Resulting Ballerina Error
     */
    public static BError createErrorValue(String errorMessage) {
        return ErrorCreator.createError(StringUtils.fromString(errorMessage));
    }

    /**
     * Returns a Ballerina Error with the given String message and exception.
     *
     * @param message The error message
     * @param error   The exception
     * @return Resulting Ballerina Error
     */
    public static BError createErrorValue(String message, Exception error) {
        ErrorType errorType = TypeCreator.createErrorType(error.getClass().getTypeName(), ModuleUtils.getModule());
        String errorFromClass = error.getStackTrace()[0].getClassName();
        String errorMessage = "An error occurred while processing your request. ";
        errorMessage += "Cause: " + error.getCause() + " ";
        errorMessage += "Class: " + error.getClass() + " ";
        BError er = ErrorCreator.createError(StringUtils.fromString(errorMessage));

        BMap<BString, Object> map = ValueCreator.createMapValue();
        map.put(StringUtils.fromString("Type"), StringUtils.fromString(error.getClass().getSimpleName()));
        map.put(StringUtils.fromString("errorCause"), StringUtils.fromString(error.getCause().getClass().getName()));
        map.put(StringUtils.fromString("message"), StringUtils.fromString(error.getMessage()));
        map.put(StringUtils.fromString("stackTrace"), StringUtils.fromString(Arrays.toString(error.getStackTrace())));
        return ErrorCreator.createError(errorType, StringUtils.fromString(message + " error from " + errorFromClass),
                er, map);
    }

    /**
     * Checks if PEEK LOCK mode is enabled for listening for messages.
     * 
     * @param service Service instance having configuration 
     * @return true if enabled
     */
    public static boolean isPeekLockModeEnabled(BObject service) {
        BMap<BString, Object> serviceConfig = getServiceConfig(service);
        boolean peekLockEnabled = false;
        if (serviceConfig != null && serviceConfig.containsKey(ASBConstants.PEEK_LOCK_ENABLE_CONFIG_KEY)) {
            peekLockEnabled = serviceConfig.getBooleanValue(ASBConstants.PEEK_LOCK_ENABLE_CONFIG_KEY);
        }
        return peekLockEnabled;
    }

    /**
     * Obtain string value of a service level configuration. 
     * 
     * @param service Service instance
     * @param key Key of the configuration
     * @return String value of the given config key, or empty string if not found
     */
    public static String getServiceConfigStringValue(BObject service, String key) {
        BMap<BString, Object> serviceConfig = getServiceConfig(service);
        if (serviceConfig != null && serviceConfig.containsKey(StringUtils.fromString(key))) {
            return serviceConfig.getStringValue(StringUtils.fromString(key)).getValue();
        } else {
            return ASBConstants.EMPTY_STRING;
        }
    }

    /**
     * Obtain numeric value of a service level configuration.
     * 
     * @param service Service instance
     * @param key     Key of the configuration
     * @return Integer value of the given config key, or null if not found
     */
    public static Integer getServiceConfigSNumericValue(BObject service, String key, int defaultValue) {
        BMap<BString, Object> serviceConfig = getServiceConfig(service);
        if (serviceConfig != null && serviceConfig.containsKey(StringUtils.fromString(key))) {
            return serviceConfig.getIntValue(StringUtils.fromString(key)).intValue();
        } else {
            return defaultValue;
        }
    }
    
    private static BMap<BString, Object> getServiceConfig(BObject service) {
        ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(service.getType());
        @SuppressWarnings("unchecked")
        BMap<BString, Object> serviceConfig = (BMap<BString, Object>) serviceType
                .getAnnotation(StringUtils.fromString(ModuleUtils.getModule().getOrg() + ORG_NAME_SEPARATOR
                        + ModuleUtils.getModule().getName() + VERSION_SEPARATOR
                        + ModuleUtils.getModule().getMajorVersion() + ":"
                        + ASBConstants.SERVICE_CONFIG));
        return serviceConfig;
    }

}
