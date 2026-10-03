# faro_api.api.ExportApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**exportAll**](ExportApi.md#exportall) | **GET** /api/export | Export All


# **exportAll**
> exportAll(format)

Export All

Todos tus datos (sin nada de seguridad). JSON para copias o Excel para mirarlos.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getExportApi();
final String format = format_example; // String | 

try {
    api.exportAll(format);
} catch on DioException (e) {
    print('Exception when calling ExportApi->exportAll: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **format** | **String**|  | [optional] [default to 'json']

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

