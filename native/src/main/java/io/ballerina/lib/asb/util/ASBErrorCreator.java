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

import com.azure.core.exception.HttpResponseException;
import com.azure.messaging.servicebus.ServiceBusException;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;

import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Set;

/**
 * ASB module error related utilities.
 *
 * @since 4.0.0
 */
public class ASBErrorCreator {
    public static final String ASB_ERROR_PREFIX = "ASB Error: ";
    public static final String ASB_HTTP_ERROR_PREFIX = "Error occurred while processing request, Status Code:";
    public static final String UNHANDLED_ERROR_PREFIX = "Error occurred while processing request: ";
    public static final int CLIENT_INVOCATION_ERROR = 10001;
    public static BError fromASBException(ServiceBusException e) {
        return fromJavaException(ASB_ERROR_PREFIX + e.getReason().toString(), e);
    }
    public static BError fromASBHttpResponseException(HttpResponseException e) {
        return fromBError(ASB_HTTP_ERROR_PREFIX + e.getResponse().getStatusCode(),
                ErrorCreator.createError(e.fillInStackTrace()));
    }
    public static BError fromUnhandledException(Exception e) {
        // The synchronous Azure receiver may wrap its ServiceBusException in a
        // terminal RuntimeException. Preserve the ASB reason and the full cause chain.
        Set<Throwable> visited = Collections.newSetFromMap(new IdentityHashMap<>());
        for (Throwable cause = e; cause != null && visited.add(cause); cause = cause.getCause()) {
            if (cause instanceof ServiceBusException serviceBusException) {
                return fromJavaException(ASB_ERROR_PREFIX + serviceBusException.getReason(), e);
            }
        }
        return fromJavaException(UNHANDLED_ERROR_PREFIX + e.getMessage(), e);
    }
    public static BError fromBError(BError error) {
        return fromBError(error.getMessage(), error.getCause());
    }
    public static BError fromBError(String message, BError cause) {
        return ErrorCreator.createDistinctError(
                ASBConstants.ASB_ERROR, ModuleUtils.getModule(), StringUtils.fromString(message), cause);
    }
    private static BError fromJavaException(String message, Throwable cause) {
        return fromBError(message, ErrorCreator.createError(cause));
    }

    public static BError createError(String message) {
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ASBConstants.ASB_ERROR, StringUtils.fromString(message), null, null);
    }

    public static BError createError(String message, Throwable throwable) {
        BError cause = ErrorCreator.createError(throwable);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ASBConstants.ASB_ERROR, StringUtils.fromString(message), cause, null);
    }
}
