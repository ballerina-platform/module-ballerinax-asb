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
import com.azure.core.http.HttpResponse;
import com.azure.messaging.servicebus.ServiceBusException;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Map;

/**
 * ASB module error related utilities.
 *
 * @since 4.0.0
 */
public class ASBErrorCreator {
    public static final String ASB_ERROR_PREFIX = "ASB Error: ";
    public static final String ASB_HTTP_ERROR_PREFIX = "Error occurred while processing request, Status Code:";
    public static final String UNHANDLED_ERROR_PREFIX = "Error occurred while processing request: ";

    private static final String ASB_ADMIN_ERROR = "AdminActionError";
    private static final int CLIENT_INITIALIZATION_ERROR_CODE = 10000;
    private static final int CLIENT_INVOCATION_ERROR_CODE = 10001;

    public static BError fromASBException(ServiceBusException e) {
        return fromJavaException(ASB_ERROR_PREFIX + e.getReason().toString(), e);
    }

    public static BError fromUnhandledException(Exception e) {
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

    public static BError createAdminInitError(Throwable throwable) {
        String message = constructErrorMsg(throwable);
        BError cause = ErrorCreator.createError(throwable);
        BMap<BString, Object> errorDetails = getAdminErrorDetails(throwable, true);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ASB_ADMIN_ERROR, StringUtils.fromString(message),
                cause, errorDetails
        );
    }

    public static BError createAdminActionError(Throwable throwable) {
        String message = constructErrorMsg(throwable);
        BError cause = ErrorCreator.createError(throwable);
        BMap<BString, Object> errorDetails = getAdminErrorDetails(throwable, false);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ASB_ADMIN_ERROR, StringUtils.fromString(message),
                cause, errorDetails
        );
    }

    private static String constructErrorMsg(Throwable throwable) {
        if (throwable instanceof ServiceBusException serviceBusExp) {
            return ASB_ERROR_PREFIX + serviceBusExp.getReason().toString();
        }
        if (throwable instanceof HttpResponseException httpResponseExp) {
            return ASB_HTTP_ERROR_PREFIX + httpResponseExp.getResponse().getStatusCode();
        }
        return UNHANDLED_ERROR_PREFIX + throwable.getMessage();
    }

    private static BMap<BString, Object> getAdminErrorDetails(Throwable throwable, boolean isInitError) {
        if (isInitError) {
            return ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "AdminErrorContext",
                    Map.of("statusCode", CLIENT_INITIALIZATION_ERROR_CODE, "reason", throwable.getMessage())
            );
        }

        if (throwable instanceof HttpResponseException httpResponseExp) {
            HttpResponse httpResponse = httpResponseExp.getResponse();
            int statusCode = httpResponse.getStatusCode();
            return ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "AdminErrorContext",
                    Map.of("statusCode", statusCode, "reason", httpResponseExp.getMessage())
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
                Map.of("statusCode", CLIENT_INVOCATION_ERROR_CODE, "reason", throwable.getMessage())
        );
    }
}
