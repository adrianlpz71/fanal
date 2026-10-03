# faro_api.api.AuthApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**login**](AuthApi.md#login) | **POST** /api/auth/login | Login
[**logout**](AuthApi.md#logout) | **POST** /api/auth/logout | Logout
[**mfaEnable**](AuthApi.md#mfaenable) | **POST** /api/auth/2fa/enable | Mfa Enable
[**mfaSetup**](AuthApi.md#mfasetup) | **POST** /api/auth/2fa/setup | Mfa Setup
[**mfaVerify**](AuthApi.md#mfaverify) | **POST** /api/auth/2fa/verify | Mfa Verify
[**refresh**](AuthApi.md#refresh) | **POST** /api/auth/refresh | Refresh


# **login**
> LoginOut login(loginIn)

Login

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final LoginIn loginIn = ; // LoginIn | 

try {
    final response = api.login(loginIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginIn** | [**LoginIn**](LoginIn.md)|  | 

### Return type

[**LoginOut**](LoginOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> logout(refreshIn)

Logout

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final RefreshIn refreshIn = ; // RefreshIn | 

try {
    api.logout(refreshIn);
} catch on DioException (e) {
    print('Exception when calling AuthApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshIn** | [**RefreshIn**](RefreshIn.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mfaEnable**
> MfaEnabledOut mfaEnable(mfaCodeIn)

Mfa Enable

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final MfaCodeIn mfaCodeIn = ; // MfaCodeIn | 

try {
    final response = api.mfaEnable(mfaCodeIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->mfaEnable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mfaCodeIn** | [**MfaCodeIn**](MfaCodeIn.md)|  | 

### Return type

[**MfaEnabledOut**](MfaEnabledOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mfaSetup**
> MfaSetupOut mfaSetup(mfaTokenIn)

Mfa Setup

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final MfaTokenIn mfaTokenIn = ; // MfaTokenIn | 

try {
    final response = api.mfaSetup(mfaTokenIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->mfaSetup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mfaTokenIn** | [**MfaTokenIn**](MfaTokenIn.md)|  | 

### Return type

[**MfaSetupOut**](MfaSetupOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mfaVerify**
> TokenOut mfaVerify(mfaCodeIn)

Mfa Verify

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final MfaCodeIn mfaCodeIn = ; // MfaCodeIn | 

try {
    final response = api.mfaVerify(mfaCodeIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->mfaVerify: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mfaCodeIn** | [**MfaCodeIn**](MfaCodeIn.md)|  | 

### Return type

[**TokenOut**](TokenOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refresh**
> TokenOut refresh(refreshIn)

Refresh

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAuthApi();
final RefreshIn refreshIn = ; // RefreshIn | 

try {
    final response = api.refresh(refreshIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->refresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshIn** | [**RefreshIn**](RefreshIn.md)|  | 

### Return type

[**TokenOut**](TokenOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

