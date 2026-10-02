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

import com.azure.core.amqp.exception.AmqpErrorCondition;
import com.azure.core.amqp.exception.AmqpException;
import com.azure.messaging.servicebus.ServiceBusErrorSource;
import com.azure.messaging.servicebus.ServiceBusException;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.values.BError;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import java.lang.reflect.Field;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

public class ASBErrorCreatorTest {
    private static Field moduleField;
    private static Object previousModule;

    @BeforeClass
    public static void initializeModule() throws ReflectiveOperationException {
        moduleField = ModuleUtils.class.getDeclaredField("asbModule");
        moduleField.setAccessible(true);
        previousModule = moduleField.get(null);
        moduleField.set(null, new Module("ballerinax", "asb", "3"));
    }

    @AfterClass
    public static void restoreModule() throws IllegalAccessException {
        moduleField.set(null, previousModule);
    }

    @Test
    public void preservesWrappedServiceBusReason() {
        ServiceBusException original = new ServiceBusException(
                new AmqpException(false, AmqpErrorCondition.NOT_FOUND, "Missing queue", null),
                ServiceBusErrorSource.RECEIVE);
        RuntimeException terminal = new RuntimeException("Receiver terminated", new RuntimeException(original));
        BError error = ASBErrorCreator.fromUnhandledException(terminal);
        assertEquals("ASB Error: MESSAGING_ENTITY_NOT_FOUND", error.getMessage());
        assertNotNull(error.getCause());
    }

    @Test
    public void preservesUnrelatedExceptionMessage() {
        BError error = ASBErrorCreator.fromUnhandledException(new IllegalStateException("Unexpected failure"));
        assertEquals("Error occurred while processing request: Unexpected failure", error.getMessage());
    }

}
