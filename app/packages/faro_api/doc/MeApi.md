# faro_api.api.MeApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**me**](MeApi.md#me) | **GET** /api/me | Me
[**updateProfile**](MeApi.md#updateprofile) | **PATCH** /api/me | Update Profile


# **me**
> UserOut me()

Me

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getMeApi();

try {
    final response = api.me();
    print(response);
} catch on DioException (e) {
    print('Exception when calling MeApi->me: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserOut**](UserOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateProfile**
> UserOut updateProfile(profileIn)

Update Profile

Perfil básico del onboarding. Cada módulo añadirá sus preguntas en su fase.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getMeApi();
final ProfileIn profileIn = ; // ProfileIn | 

try {
    final response = api.updateProfile(profileIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling MeApi->updateProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileIn** | [**ProfileIn**](ProfileIn.md)|  | 

### Return type

[**UserOut**](UserOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

