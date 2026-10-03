# faro_api.api.ImportsApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**bankCommit**](ImportsApi.md#bankcommit) | **POST** /api/imports/bank/commit | Bank Commit
[**bankPreview**](ImportsApi.md#bankpreview) | **POST** /api/imports/bank/preview | Bank Preview
[**createProfile**](ImportsApi.md#createprofile) | **POST** /api/imports/profiles | Create Profile
[**deleteProfile**](ImportsApi.md#deleteprofile) | **DELETE** /api/imports/profiles/{profile_id} | Delete Profile
[**inspectTable**](ImportsApi.md#inspecttable) | **POST** /api/imports/inspect | Inspect Table
[**listBatches**](ImportsApi.md#listbatches) | **GET** /api/imports | List Batches
[**listProfiles**](ImportsApi.md#listprofiles) | **GET** /api/imports/profiles | List Profiles
[**undoBatch**](ImportsApi.md#undobatch) | **POST** /api/imports/{batch_id}/undo | Undo Batch


# **bankCommit**
> BatchOut bankCommit(file, accountId, mapping, profileId, saveProfileAs)

Bank Commit

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String file = file_example; // String | 
final String accountId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String mapping = mapping_example; // String | 
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String saveProfileAs = saveProfileAs_example; // String | 

try {
    final response = api.bankCommit(file, accountId, mapping, profileId, saveProfileAs);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->bankCommit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **String**|  | 
 **accountId** | **String**|  | [optional] 
 **mapping** | **String**|  | [optional] 
 **profileId** | **String**|  | [optional] 
 **saveProfileAs** | **String**|  | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bankPreview**
> BankPreviewOut bankPreview(file, accountId, mapping, profileId)

Bank Preview

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String file = file_example; // String | 
final String accountId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String mapping = mapping_example; // String | 
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.bankPreview(file, accountId, mapping, profileId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->bankPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **String**|  | 
 **accountId** | **String**|  | [optional] 
 **mapping** | **String**|  | [optional] 
 **profileId** | **String**|  | [optional] 

### Return type

[**BankPreviewOut**](BankPreviewOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createProfile**
> BankProfileOut createProfile(bankProfileIn)

Create Profile

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final BankProfileIn bankProfileIn = ; // BankProfileIn | 

try {
    final response = api.createProfile(bankProfileIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->createProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bankProfileIn** | [**BankProfileIn**](BankProfileIn.md)|  | 

### Return type

[**BankProfileOut**](BankProfileOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteProfile**
> deleteProfile(profileId)

Delete Profile

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteProfile(profileId);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->deleteProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inspectTable**
> TableInspectOut inspectTable(file, kind)

Inspect Table

Para el editor de columnas: las primeras filas y, si se reconoce, el mapeo sugerido.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String file = file_example; // String | 
final String kind = kind_example; // String | 

try {
    final response = api.inspectTable(file, kind);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->inspectTable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **String**|  | 
 **kind** | **String**|  | [optional] [default to 'bank']

### Return type

[**TableInspectOut**](TableInspectOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBatches**
> List<BatchOut> listBatches()

List Batches

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();

try {
    final response = api.listBatches();
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->listBatches: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;BatchOut&gt;**](BatchOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listProfiles**
> List<BankProfileOut> listProfiles(kind)

List Profiles

Formatos guardados: `bank` (extractos) o `broker` (operaciones de inversión).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String kind = kind_example; // String | 

try {
    final response = api.listProfiles(kind);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->listProfiles: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **kind** | **String**|  | [optional] [default to 'bank']

### Return type

[**List&lt;BankProfileOut&gt;**](BankProfileOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **undoBatch**
> BatchOut undoBatch(batchId)

Undo Batch

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getImportsApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.undoBatch(batchId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ImportsApi->undoBatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**|  | 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

