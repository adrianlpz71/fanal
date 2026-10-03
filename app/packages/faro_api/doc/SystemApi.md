# faro_api.api.SystemApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**health**](SystemApi.md#health) | **GET** /api/health | Health
[**version**](SystemApi.md#version) | **GET** /api/version | Version


# **health**
> HealthOut health()

Health

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getSystemApi();

try {
    final response = api.health();
    print(response);
} catch on DioException (e) {
    print('Exception when calling SystemApi->health: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthOut**](HealthOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **version**
> VersionOut version()

Version

Última versión publicada de la app (la escribe el deploy en latest.json).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getSystemApi();

try {
    final response = api.version();
    print(response);
} catch on DioException (e) {
    print('Exception when calling SystemApi->version: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**VersionOut**](VersionOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

