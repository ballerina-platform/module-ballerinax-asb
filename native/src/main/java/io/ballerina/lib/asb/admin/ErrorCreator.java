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

package io.ballerina.lib.asb.admin;

import com.azure.core.exception.HttpResponseException;
import com.azure.core.http.HttpResponse;
import com.azure.messaging.servicebus.ServiceBusException;
import io.ballerina.lib.asb.util.ModuleUtils;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Map;

import static io.ballerina.runtime.api.creators.ErrorCreator.createError;

/**
 * Helper class to create Ballerina errors for administrator actions.
 *
 * @since 3.10.0
 */
public final class ErrorCreator {
    private static final String ASB_ERROR_PREFIX = "ASB Error: ";
    private static final String ASB_HTTP_ERROR_PREFIX = "Error occurred while processing request, Status Code:";
    private static final String UNHANDLED_ERROR_PREFIX = "Error occurred while processing request: ";
    private static final String ASB_ADMIN_ERROR = "AdminActionError";
    private static final int CLIENT_INITIALIZATION_ERROR_CODE = 10000;
    private static final int CLIENT_INVOCATION_ERROR_CODE = 10001;

    private ErrorCreator() {}

    // Admin init errors
    public static BError fromAsbAdminInitException(BError error) {
        BMap<BString, Object> errorDetails = getAdminErrorDetails(error, true);
        return fromBError(error.getMessage(), error.getCause(), errorDetails);
    }

    public static BError fromAsbAdminInitException(ServiceBusException e) {
        String reason = e.getReason() != null ? e.getReason().toString() : "Unknown reason";
        return fromJavaException(ASB_ERROR_PREFIX + reason, e, true);
    }

    public static BError fromAsbAdminInitException(Exception e) {
        return fromJavaException(UNHANDLED_ERROR_PREFIX + e.getMessage(), e, true);
    }

    // Admin action errors
    public static BError fromASBException(ServiceBusException e) {
        String reason = e.getReason() != null ? e.getReason().toString() : "Unknown reason";
        return fromJavaException(ASB_ERROR_PREFIX + reason, e, false);
    }

    public static BError fromASBHttpResponseException(HttpResponseException e) {
        BMap<BString, Object> errorDetails = getAdminErrorDetails(e, false);
        return fromBError(ASB_HTTP_ERROR_PREFIX + e.getResponse().getStatusCode(),
                createError(e.fillInStackTrace()), errorDetails);
    }

    public static BError fromUnhandledException(Exception e) {
        return fromJavaException(UNHANDLED_ERROR_PREFIX + e.getMessage(), e, false);
    }

    public static BError fromBError(BError error) {
        BMap<BString, Object> errorDetails = getAdminErrorDetails(error, false);
        return fromBError(error.getMessage(), error.getCause(), errorDetails);
    }

    private static BError fromJavaException(String message, Throwable cause, boolean isInit) {
        BMap<BString, Object> errorDetails = getAdminErrorDetails(cause, isInit);
        return fromBError(message, createError(cause), errorDetails);
    }

    private static BError fromBError(String message, BError cause, BMap<BString, Object> errorDetails) {
        return createError(
                ModuleUtils.getModule(), ASB_ADMIN_ERROR, StringUtils.fromString(message), cause, errorDetails);
    }

    private static BMap<BString, Object> getAdminErrorDetails(Throwable throwable, boolean isInitError) {
        if (isInitError) {
            return ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "AdminErrorContext",
                    Map.of("statusCode", CLIENT_INITIALIZATION_ERROR_CODE, "reason", getExpReason(throwable))
            );
        }

        if (throwable instanceof HttpResponseException httpResponseExp) {
            HttpResponse httpResponse = httpResponseExp.getResponse();
            int statusCode = httpResponse.getStatusCode();
            return ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "AdminErrorContext",
                    Map.of("statusCode", statusCode, "reason", getExpReason(httpResponseExp))
            );
        }

        if (throwable instanceof ServiceBusException serviceBusExp) {
            String reason = serviceBusExp.getReason().toString();
            return ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "AdminErrorContext",
                    Map.of("statusCode", CLIENT_INVOCATION_ERROR_CODE, "reason", reason)
            );
        }

        return ValueCreator.createRecordValue(
                ModuleUtils.getModule(), "AdminErrorContext",
                Map.of("statusCode", CLIENT_INVOCATION_ERROR_CODE, "reason", getExpReason(throwable))
        );
    }

    private static String getExpReason(Throwable throwable) {
        String msg = throwable.getMessage();
        return msg != null ? msg : throwable.toString();
    }
}
