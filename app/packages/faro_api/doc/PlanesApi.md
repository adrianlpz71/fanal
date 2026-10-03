# faro_api.api.PlanesApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**compound**](PlanesApi.md#compound) | **POST** /api/planes/compound | Compound
[**createGoal**](PlanesApi.md#creategoal) | **POST** /api/planes/goals | Create Goal
[**deleteGoal**](PlanesApi.md#deletegoal) | **DELETE** /api/planes/goals/{goal_id} | Delete Goal
[**getFire**](PlanesApi.md#getfire) | **GET** /api/planes/fire | Get Fire
[**getFireSettings**](PlanesApi.md#getfiresettings) | **GET** /api/planes/fire/settings | Get Fire Settings
[**getReview**](PlanesApi.md#getreview) | **GET** /api/planes/reviews/{quarter} | Get Review
[**listGoals**](PlanesApi.md#listgoals) | **GET** /api/planes/goals | List Goals
[**listQuarters**](PlanesApi.md#listquarters) | **GET** /api/planes/reviews | List Quarters
[**montecarlo**](PlanesApi.md#montecarlo) | **POST** /api/planes/fire/montecarlo | Montecarlo
[**putFireSettings**](PlanesApi.md#putfiresettings) | **PUT** /api/planes/fire/settings | Put Fire Settings
[**saveReview**](PlanesApi.md#savereview) | **PUT** /api/planes/reviews/{quarter} | Save Review
[**sellPreview**](PlanesApi.md#sellpreview) | **POST** /api/planes/tax/sell-preview | Sell Preview
[**simulateFire**](PlanesApi.md#simulatefire) | **POST** /api/planes/fire/simulate | Simulate Fire
[**simulateTax**](PlanesApi.md#simulatetax) | **POST** /api/planes/tax | Simulate Tax
[**taxPrefill**](PlanesApi.md#taxprefill) | **GET** /api/planes/tax/prefill | Tax Prefill
[**updateGoal**](PlanesApi.md#updategoal) | **PUT** /api/planes/goals/{goal_id} | Update Goal


# **compound**
> CompoundOut compound(compoundIn)

Compound

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final CompoundIn compoundIn = ; // CompoundIn | 

try {
    final response = api.compound(compoundIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->compound: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **compoundIn** | [**CompoundIn**](CompoundIn.md)|  | 

### Return type

[**CompoundOut**](CompoundOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createGoal**
> GoalOut createGoal(goalIn)

Create Goal

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final GoalIn goalIn = ; // GoalIn | 

try {
    final response = api.createGoal(goalIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->createGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalIn** | [**GoalIn**](GoalIn.md)|  | 

### Return type

[**GoalOut**](GoalOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteGoal**
> deleteGoal(goalId)

Delete Goal

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final String goalId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteGoal(goalId);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->deleteGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFire**
> FirePlanOut getFire()

Get Fire

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();

try {
    final response = api.getFire();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->getFire: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FirePlanOut**](FirePlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFireSettings**
> FireSettingsOut getFireSettings()

Get Fire Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();

try {
    final response = api.getFireSettings();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->getFireSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FireSettingsOut**](FireSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReview**
> QuarterReviewOut getReview(quarter)

Get Review

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final String quarter = quarter_example; // String | 

try {
    final response = api.getReview(quarter);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->getReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **quarter** | **String**|  | 

### Return type

[**QuarterReviewOut**](QuarterReviewOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listGoals**
> List<GoalOut> listGoals()

List Goals

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();

try {
    final response = api.listGoals();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->listGoals: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;GoalOut&gt;**](GoalOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listQuarters**
> List<QuarterItemOut> listQuarters()

List Quarters

Trimestres con datos, del más reciente al más antiguo.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();

try {
    final response = api.listQuarters();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->listQuarters: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;QuarterItemOut&gt;**](QuarterItemOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **montecarlo**
> MonteCarloOut montecarlo(fireSettingsIn)

Montecarlo

Probabilidad de éxito con rentabilidades aleatorias (2.000 simulaciones).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final FireSettingsIn fireSettingsIn = ; // FireSettingsIn | 

try {
    final response = api.montecarlo(fireSettingsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->montecarlo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fireSettingsIn** | [**FireSettingsIn**](FireSettingsIn.md)|  | 

### Return type

[**MonteCarloOut**](MonteCarloOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putFireSettings**
> FireSettingsOut putFireSettings(fireSettingsIn)

Put Fire Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final FireSettingsIn fireSettingsIn = ; // FireSettingsIn | 

try {
    final response = api.putFireSettings(fireSettingsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->putFireSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fireSettingsIn** | [**FireSettingsIn**](FireSettingsIn.md)|  | 

### Return type

[**FireSettingsOut**](FireSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **saveReview**
> QuarterReviewOut saveReview(quarter, quarterReviewIn)

Save Review

Guarda las respuestas y una foto de las métricas de este momento.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final String quarter = quarter_example; // String | 
final QuarterReviewIn quarterReviewIn = ; // QuarterReviewIn | 

try {
    final response = api.saveReview(quarter, quarterReviewIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->saveReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **quarter** | **String**|  | 
 **quarterReviewIn** | [**QuarterReviewIn**](QuarterReviewIn.md)|  | 

### Return type

[**QuarterReviewOut**](QuarterReviewOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sellPreview**
> SellPreviewOut sellPreview(sellPreviewIn)

Sell Preview

¿Y si vendo X € hoy? Ganancia FIFO de esa venta (de un activo o de toda la cartera en proporción a su peso, D8) y lo que añade a tu IRPF del año.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final SellPreviewIn sellPreviewIn = ; // SellPreviewIn | 

try {
    final response = api.sellPreview(sellPreviewIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->sellPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sellPreviewIn** | [**SellPreviewIn**](SellPreviewIn.md)|  | 

### Return type

[**SellPreviewOut**](SellPreviewOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **simulateFire**
> FirePlanOut simulateFire(fireSettingsIn)

Simulate Fire

¿Y si…? Calcula con otros valores sin guardarlos.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final FireSettingsIn fireSettingsIn = ; // FireSettingsIn | 

try {
    final response = api.simulateFire(fireSettingsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->simulateFire: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fireSettingsIn** | [**FireSettingsIn**](FireSettingsIn.md)|  | 

### Return type

[**FirePlanOut**](FirePlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **simulateTax**
> TaxOut simulateTax(taxIn)

Simulate Tax

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final TaxIn taxIn = ; // TaxIn | 

try {
    final response = api.simulateTax(taxIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->simulateTax: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **taxIn** | [**TaxIn**](TaxIn.md)|  | 

### Return type

[**TaxOut**](TaxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **taxPrefill**
> TaxPrefillOut taxPrefill(year)

Tax Prefill

Datos para prellenar el simulador: nóminas del año (referencia), la base general que guardaste, y ganancias FIFO e ingresos del año (como en el Informe fiscal).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final int year = 56; // int | 0 = el año en curso

try {
    final response = api.taxPrefill(year);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->taxPrefill: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **year** | **int**| 0 = el año en curso | [optional] [default to 0]

### Return type

[**TaxPrefillOut**](TaxPrefillOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateGoal**
> GoalOut updateGoal(goalId, goalIn)

Update Goal

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getPlanesApi();
final String goalId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final GoalIn goalIn = ; // GoalIn | 

try {
    final response = api.updateGoal(goalId, goalIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlanesApi->updateGoal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **goalId** | **String**|  | 
 **goalIn** | [**GoalIn**](GoalIn.md)|  | 

### Return type

[**GoalOut**](GoalOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

