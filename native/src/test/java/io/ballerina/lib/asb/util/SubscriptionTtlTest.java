/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org).
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

import com.azure.core.util.Context;
import com.azure.core.util.logging.ClientLogger;
import com.azure.messaging.servicebus.administration.models.SubscriptionProperties;
import org.junit.Test;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.time.Duration;

import static org.junit.Assert.assertEquals;

public class SubscriptionTtlTest {
    @Test
    public void updateRequestPreservesSubscriptionTtl() throws ReflectiveOperationException {
        // Exercise SDK request conversion without Azure credentials. Older SDKs
        // nullified TTL in this path even though the connector set it correctly.
        Constructor<?> propertiesConstructor = SubscriptionProperties.class.getDeclaredConstructors()[0];
        propertiesConstructor.setAccessible(true);
        Object description = propertiesConstructor.getParameterTypes()[0].getDeclaredConstructor().newInstance();
        SubscriptionProperties properties = (SubscriptionProperties) propertiesConstructor.newInstance(description);
        Duration ttl = Duration.ofSeconds(70000, 200);
        properties.setDefaultMessageTimeToLive(ttl);

        Class<?> converterClass = Class.forName(
                "com.azure.messaging.servicebus.administration.AdministrationModelConverter");
        Constructor<?> converterConstructor = converterClass.getDeclaredConstructor(ClientLogger.class, String.class);
        converterConstructor.setAccessible(true);
        Object converter = converterConstructor.newInstance(new ClientLogger(SubscriptionTtlTest.class),
                "unused.servicebus.windows.net");
        Method update = converterClass.getDeclaredMethod("getUpdateSubscriptionBody",
                SubscriptionProperties.class, Context.class);
        update.setAccessible(true);
        Object body = update.invoke(converter, properties, Context.NONE);
        Object content = body.getClass().getMethod("getContent").invoke(body);
        Object requestDescription = content.getClass().getMethod("getSubscriptionDescription").invoke(content);
        Object requestTtl = requestDescription.getClass().getMethod("getDefaultMessageTimeToLive")
                .invoke(requestDescription);
        assertEquals(ttl, requestTtl);
    }
}
