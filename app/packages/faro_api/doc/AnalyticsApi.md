# faro_api.api.AnalyticsApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**backfill**](AnalyticsApi.md#backfill) | **POST** /api/analytics/prices/backfill | Backfill
[**getAssetExposure**](AnalyticsApi.md#getassetexposure) | **GET** /api/analytics/exposure/{asset_id} | Get Asset Exposure
[**getContributions**](AnalyticsApi.md#getcontributions) | **GET** /api/analytics/contributions | Get Contributions
[**getExposure**](AnalyticsApi.md#getexposure) | **GET** /api/analytics/exposure | Get Exposure
[**getMilestones**](AnalyticsApi.md#getmilestones) | **GET** /api/analytics/milestones | Get Milestones
[**getNetworth**](AnalyticsApi.md#getnetworth) | **GET** /api/analytics/networth | Get Networth
[**getNetworthEvolution**](AnalyticsApi.md#getnetworthevolution) | **GET** /api/analytics/networth/evolution | Get Networth Evolution
[**getNetworthHistory**](AnalyticsApi.md#getnetworthhistory) | **GET** /api/analytics/networth/history | Get Networth History
[**getPerformance**](AnalyticsApi.md#getperformance) | **GET** /api/analytics/performance | Get Performance
[**putAssetExposure**](AnalyticsApi.md#putassetexposure) | **PUT** /api/analytics/exposure/{asset_id} | Put Asset Exposure
[**putMilestones**](AnalyticsApi.md#putmilestones) | **PUT** /api/analytics/milestones | Put Milestones
[**refreshExposure**](AnalyticsApi.md#refreshexposure) | **POST** /api/analytics/exposure/refresh | Refresh Exposure
[**taxReport**](AnalyticsApi.md#taxreport) | **GET** /api/analytics/tax-report | Tax Report


# **backfill**
> JobResultOut backfill()

Backfill

Histórico de precios desde la primera operación (para los gráficos y la rentabilidad).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.backfill();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->backfill: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JobResultOut**](JobResultOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAssetExposure**
> List<AssetExposureOut> getAssetExposure(assetId)

Get Asset Exposure

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getAssetExposure(assetId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getAssetExposure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 

### Return type

[**List&lt;AssetExposureOut&gt;**](AssetExposureOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContributions**
> ContributionsOut getContributions()

Get Contributions

Historial de aportaciones a inversiones y ahorro, con ritmo mensual y racha.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getContributions();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getContributions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ContributionsOut**](ContributionsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getExposure**
> ExposureOut getExposure()

Get Exposure

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getExposure();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getExposure: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ExposureOut**](ExposureOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMilestones**
> MilestonesOut getMilestones()

Get Milestones

Hitos del patrimonio neto: cuándo se cruzó cada umbral y una estimación del siguiente con la aportación media (sin rentabilidad: no es una previsión).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getMilestones();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getMilestones: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MilestonesOut**](MilestonesOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNetworth**
> NetWorthOut getNetworth()

Get Networth

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getNetworth();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getNetworth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NetWorthOut**](NetWorthOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNetworthEvolution**
> NetWorthEvolutionOut getNetworthEvolution()

Get Networth Evolution

Evolución del patrimonio por componente (cada cuenta y cada activo), con deudas, fraccionadas y el neto. Las cuentas se reconstruyen desde el saldo de hoy (D9).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getNetworthEvolution();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getNetworthEvolution: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**NetWorthEvolutionOut**](NetWorthEvolutionOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNetworthHistory**
> List<NetWorthPointOut> getNetworthHistory()

Get Networth History

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.getNetworthHistory();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getNetworthHistory: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;NetWorthPointOut&gt;**](NetWorthPointOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPerformance**
> PerformanceOut getPerformance(assetId, classId)

Get Performance

Rentabilidad de toda la cartera, de una categoría o de un activo.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();
final String assetId = assetId_example; // String | 
final String classId = classId_example; // String | 

try {
    final response = api.getPerformance(assetId, classId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getPerformance: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | [optional] [default to '']
 **classId** | **String**|  | [optional] [default to '']

### Return type

[**PerformanceOut**](PerformanceOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putAssetExposure**
> List<AssetExposureOut> putAssetExposure(assetId, assetExposureIn)

Put Asset Exposure

Composición manual de un activo (sustituye a la manual anterior; la automática se queda pero deja de usarse en las dimensiones que tengan manual).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final List<AssetExposureIn> assetExposureIn = ; // List<AssetExposureIn> | 

try {
    final response = api.putAssetExposure(assetId, assetExposureIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->putAssetExposure: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 
 **assetExposureIn** | [**List&lt;AssetExposureIn&gt;**](AssetExposureIn.md)|  | 

### Return type

[**List&lt;AssetExposureOut&gt;**](AssetExposureOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putMilestones**
> MilestonesOut putMilestones(milestonesIn)

Put Milestones

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();
final MilestonesIn milestonesIn = ; // MilestonesIn | 

try {
    final response = api.putMilestones(milestonesIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->putMilestones: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **milestonesIn** | [**MilestonesIn**](MilestonesIn.md)|  | 

### Return type

[**MilestonesOut**](MilestonesOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshExposure**
> JobResultOut refreshExposure()

Refresh Exposure

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();

try {
    final response = api.refreshExposure();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->refreshExposure: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JobResultOut**](JobResultOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **taxReport**
> TaxReportOut taxReport(year)

Tax Report

Resumen anual para la Renta: ventas (FIFO), traspasos, rendimientos y saldos a 31/12.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getAnalyticsApi();
final int year = 56; // int | 

try {
    final response = api.taxReport(year);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->taxReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **year** | **int**|  | [optional] [default to 0]

### Return type

[**TaxReportOut**](TaxReportOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

