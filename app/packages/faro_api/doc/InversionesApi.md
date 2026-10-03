# faro_api.api.InversionesApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assetDetail**](InversionesApi.md#assetdetail) | **GET** /api/inv/assets/{asset_id} | Asset Detail
[**correct**](InversionesApi.md#correct) | **POST** /api/inv/assets/{asset_id}/correction | Correct
[**createAsset**](InversionesApi.md#createasset) | **POST** /api/inv/assets | Create Asset
[**createClass**](InversionesApi.md#createclass) | **POST** /api/inv/classes | Create Class
[**createOrders**](InversionesApi.md#createorders) | **POST** /api/inv/contribution/orders | Create Orders
[**createPlan**](InversionesApi.md#createplan) | **POST** /api/inv/plans | Create Plan
[**createPlatform**](InversionesApi.md#createplatform) | **POST** /api/inv/platforms | Create Platform
[**createTransaction**](InversionesApi.md#createtransaction) | **POST** /api/inv/transactions | Create Transaction
[**createTransfer**](InversionesApi.md#createtransfer) | **POST** /api/inv/transfers | Create Transfer
[**deleteAsset**](InversionesApi.md#deleteasset) | **DELETE** /api/inv/assets/{asset_id} | Delete Asset
[**deletePlan**](InversionesApi.md#deleteplan) | **DELETE** /api/inv/plans/{plan_id} | Delete Plan
[**deleteTransaction**](InversionesApi.md#deletetransaction) | **DELETE** /api/inv/transactions/{tx_id} | Delete Transaction
[**getHistory**](InversionesApi.md#gethistory) | **GET** /api/inv/history | Get History
[**getPortfolio**](InversionesApi.md#getportfolio) | **GET** /api/inv/portfolio | Get Portfolio
[**getSettings**](InversionesApi.md#getsettings) | **GET** /api/inv/settings | Get Settings
[**getTargets**](InversionesApi.md#gettargets) | **GET** /api/inv/targets | Get Targets
[**listAssets**](InversionesApi.md#listassets) | **GET** /api/inv/assets | List Assets
[**listClasses**](InversionesApi.md#listclasses) | **GET** /api/inv/classes | List Classes
[**listPlans**](InversionesApi.md#listplans) | **GET** /api/inv/plans | List Plans
[**listPlatforms**](InversionesApi.md#listplatforms) | **GET** /api/inv/platforms | List Platforms
[**listPrices**](InversionesApi.md#listprices) | **GET** /api/inv/assets/{asset_id}/prices | List Prices
[**listTransactions**](InversionesApi.md#listtransactions) | **GET** /api/inv/transactions | List Transactions
[**patchAsset**](InversionesApi.md#patchasset) | **PATCH** /api/inv/assets/{asset_id} | Patch Asset
[**platformCommit**](InversionesApi.md#platformcommit) | **POST** /api/inv/imports/commit | Platform Commit
[**platformPreview**](InversionesApi.md#platformpreview) | **POST** /api/inv/imports/preview | Platform Preview
[**putHistory**](InversionesApi.md#puthistory) | **PUT** /api/inv/history | Put History
[**putPrice**](InversionesApi.md#putprice) | **PUT** /api/inv/assets/{asset_id}/prices | Put Price
[**putSettings**](InversionesApi.md#putsettings) | **PUT** /api/inv/settings | Put Settings
[**putTargets**](InversionesApi.md#puttargets) | **PUT** /api/inv/targets | Put Targets
[**refreshPrices**](InversionesApi.md#refreshprices) | **POST** /api/inv/prices/refresh | Refresh Prices
[**settleTransaction**](InversionesApi.md#settletransaction) | **POST** /api/inv/transactions/{tx_id}/settle | Settle Transaction
[**suggest**](InversionesApi.md#suggest) | **POST** /api/inv/contribution/suggest | Suggest
[**updatePlan**](InversionesApi.md#updateplan) | **PUT** /api/inv/plans/{plan_id} | Update Plan
[**updatePlatform**](InversionesApi.md#updateplatform) | **PUT** /api/inv/platforms/{platform_id} | Update Platform


# **assetDetail**
> AssetDetailOut assetDetail(assetId)

Asset Detail

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.assetDetail(assetId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->assetDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 

### Return type

[**AssetDetailOut**](AssetDetailOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **correct**
> PositionOut correct(assetId, correctionIn)

Correct

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final CorrectionIn correctionIn = ; // CorrectionIn | 

try {
    final response = api.correct(assetId, correctionIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->correct: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 
 **correctionIn** | [**CorrectionIn**](CorrectionIn.md)|  | 

### Return type

[**PositionOut**](PositionOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAsset**
> AssetOut createAsset(assetIn)

Create Asset

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final AssetIn assetIn = ; // AssetIn | 

try {
    final response = api.createAsset(assetIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createAsset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetIn** | [**AssetIn**](AssetIn.md)|  | 

### Return type

[**AssetOut**](AssetOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createClass**
> AssetClassOut createClass(assetClassIn)

Create Class

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final AssetClassIn assetClassIn = ; // AssetClassIn | 

try {
    final response = api.createClass(assetClassIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createClass: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetClassIn** | [**AssetClassIn**](AssetClassIn.md)|  | 

### Return type

[**AssetClassOut**](AssetClassOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createOrders**
> List<TxOut> createOrders(ordersIn)

Create Orders

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final OrdersIn ordersIn = ; // OrdersIn | 

try {
    final response = api.createOrders(ordersIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createOrders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ordersIn** | [**OrdersIn**](OrdersIn.md)|  | 

### Return type

[**List&lt;TxOut&gt;**](TxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPlan**
> PlanOut createPlan(planIn)

Create Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final PlanIn planIn = ; // PlanIn | 

try {
    final response = api.createPlan(planIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planIn** | [**PlanIn**](PlanIn.md)|  | 

### Return type

[**PlanOut**](PlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPlatform**
> PlatformOut createPlatform(platformIn)

Create Platform

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final PlatformIn platformIn = ; // PlatformIn | 

try {
    final response = api.createPlatform(platformIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createPlatform: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **platformIn** | [**PlatformIn**](PlatformIn.md)|  | 

### Return type

[**PlatformOut**](PlatformOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTransaction**
> TxOut createTransaction(txIn)

Create Transaction

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final TxIn txIn = ; // TxIn | 

try {
    final response = api.createTransaction(txIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createTransaction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **txIn** | [**TxIn**](TxIn.md)|  | 

### Return type

[**TxOut**](TxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTransfer**
> List<TxOut> createTransfer(transferIn)

Create Transfer

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final TransferIn transferIn = ; // TransferIn | 

try {
    final response = api.createTransfer(transferIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->createTransfer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **transferIn** | [**TransferIn**](TransferIn.md)|  | 

### Return type

[**List&lt;TxOut&gt;**](TxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteAsset**
> deleteAsset(assetId)

Delete Asset

Solo se borra un activo sin operaciones; si las tiene, se archiva.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteAsset(assetId);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->deleteAsset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deletePlan**
> deletePlan(planId)

Delete Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deletePlan(planId);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->deletePlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTransaction**
> deleteTransaction(txId)

Delete Transaction

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String txId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteTransaction(txId);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->deleteTransaction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **txId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHistory**
> List<SnapshotOut> getHistory(days)

Get History

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final int days = 56; // int | 

try {
    final response = api.getHistory(days);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->getHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **days** | **int**|  | [optional] [default to 3650]

### Return type

[**List&lt;SnapshotOut&gt;**](SnapshotOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPortfolio**
> PortfolioOut getPortfolio()

Get Portfolio

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.getPortfolio();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->getPortfolio: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PortfolioOut**](PortfolioOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSettings**
> InvSettingsOut getSettings()

Get Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.getSettings();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->getSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**InvSettingsOut**](InvSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTargets**
> TargetsOut getTargets()

Get Targets

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.getTargets();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->getTargets: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**TargetsOut**](TargetsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAssets**
> List<AssetOut> listAssets(includeArchived)

List Assets

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final bool includeArchived = true; // bool | 

try {
    final response = api.listAssets(includeArchived);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listAssets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **includeArchived** | **bool**|  | [optional] [default to false]

### Return type

[**List&lt;AssetOut&gt;**](AssetOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listClasses**
> List<AssetClassOut> listClasses()

List Classes

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.listClasses();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listClasses: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;AssetClassOut&gt;**](AssetClassOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlans**
> List<PlanOut> listPlans()

List Plans

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.listPlans();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listPlans: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PlanOut&gt;**](PlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlatforms**
> List<PlatformOut> listPlatforms()

List Platforms

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.listPlatforms();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listPlatforms: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PlatformOut&gt;**](PlatformOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPrices**
> List<PriceOut> listPrices(assetId, limit)

List Prices

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int limit = 56; // int | 

try {
    final response = api.listPrices(assetId, limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listPrices: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 
 **limit** | **int**|  | [optional] [default to 90]

### Return type

[**List&lt;PriceOut&gt;**](PriceOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTransactions**
> List<TxOut> listTransactions(pendingOnly, limit)

List Transactions

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final bool pendingOnly = true; // bool | 
final int limit = 56; // int | 

try {
    final response = api.listTransactions(pendingOnly, limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->listTransactions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pendingOnly** | **bool**|  | [optional] [default to false]
 **limit** | **int**|  | [optional] [default to 200]

### Return type

[**List&lt;TxOut&gt;**](TxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchAsset**
> AssetOut patchAsset(assetId, assetPatch)

Patch Asset

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AssetPatch assetPatch = ; // AssetPatch | 

try {
    final response = api.patchAsset(assetId, assetPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->patchAsset: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 
 **assetPatch** | [**AssetPatch**](AssetPatch.md)|  | 

### Return type

[**AssetOut**](AssetOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **platformCommit**
> PlatformBatchOut platformCommit(file, replaceInitial, mapping, profileId, saveProfileAs)

Platform Commit

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String file = file_example; // String | 
final bool replaceInitial = true; // bool | 
final String mapping = mapping_example; // String | 
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String saveProfileAs = saveProfileAs_example; // String | 

try {
    final response = api.platformCommit(file, replaceInitial, mapping, profileId, saveProfileAs);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->platformCommit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **String**|  | 
 **replaceInitial** | **bool**|  | [optional] [default to false]
 **mapping** | **String**|  | [optional] 
 **profileId** | **String**|  | [optional] 
 **saveProfileAs** | **String**|  | [optional] 

### Return type

[**PlatformBatchOut**](PlatformBatchOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **platformPreview**
> PlatformPreviewOut platformPreview(file, replaceInitial, mapping, profileId)

Platform Preview

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String file = file_example; // String | 
final bool replaceInitial = true; // bool | 
final String mapping = mapping_example; // String | 
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.platformPreview(file, replaceInitial, mapping, profileId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->platformPreview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **String**|  | 
 **replaceInitial** | **bool**|  | [optional] [default to false]
 **mapping** | **String**|  | [optional] 
 **profileId** | **String**|  | [optional] 

### Return type

[**PlatformPreviewOut**](PlatformPreviewOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putHistory**
> SnapshotOut putHistory(snapshotIn)

Put History

Punto manual del historial (anterior a Faro). No pisa un snapshot automático.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final SnapshotIn snapshotIn = ; // SnapshotIn | 

try {
    final response = api.putHistory(snapshotIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->putHistory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **snapshotIn** | [**SnapshotIn**](SnapshotIn.md)|  | 

### Return type

[**SnapshotOut**](SnapshotOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putPrice**
> PriceOut putPrice(assetId, priceIn)

Put Price

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String assetId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PriceIn priceIn = ; // PriceIn | 

try {
    final response = api.putPrice(assetId, priceIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->putPrice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assetId** | **String**|  | 
 **priceIn** | [**PriceIn**](PriceIn.md)|  | 

### Return type

[**PriceOut**](PriceOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putSettings**
> InvSettingsOut putSettings(invSettingsIn)

Put Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final InvSettingsIn invSettingsIn = ; // InvSettingsIn | 

try {
    final response = api.putSettings(invSettingsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->putSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **invSettingsIn** | [**InvSettingsIn**](InvSettingsIn.md)|  | 

### Return type

[**InvSettingsOut**](InvSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putTargets**
> TargetsOut putTargets(targetsIn)

Put Targets

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final TargetsIn targetsIn = ; // TargetsIn | 

try {
    final response = api.putTargets(targetsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->putTargets: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **targetsIn** | [**TargetsIn**](TargetsIn.md)|  | 

### Return type

[**TargetsOut**](TargetsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshPrices**
> List<PriceRefreshOut> refreshPrices()

Refresh Prices

Consulta ahora las fuentes de precios de mis activos (lo mismo que hace el worker).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();

try {
    final response = api.refreshPrices();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->refreshPrices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PriceRefreshOut&gt;**](PriceRefreshOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **settleTransaction**
> TxOut settleTransaction(txId, txSettleIn)

Settle Transaction

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String txId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TxSettleIn txSettleIn = ; // TxSettleIn | 

try {
    final response = api.settleTransaction(txId, txSettleIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->settleTransaction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **txId** | **String**|  | 
 **txSettleIn** | [**TxSettleIn**](TxSettleIn.md)|  | 

### Return type

[**TxOut**](TxOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suggest**
> ContributionOut suggest(suggestIn)

Suggest

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final SuggestIn suggestIn = ; // SuggestIn | 

try {
    final response = api.suggest(suggestIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->suggest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **suggestIn** | [**SuggestIn**](SuggestIn.md)|  | 

### Return type

[**ContributionOut**](ContributionOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlan**
> PlanOut updatePlan(planId, planIn)

Update Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PlanIn planIn = ; // PlanIn | 

try {
    final response = api.updatePlan(planId, planIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->updatePlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 
 **planIn** | [**PlanIn**](PlanIn.md)|  | 

### Return type

[**PlanOut**](PlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlatform**
> PlatformOut updatePlatform(platformId, platformIn)

Update Platform

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getInversionesApi();
final String platformId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PlatformIn platformIn = ; // PlatformIn | 

try {
    final response = api.updatePlatform(platformId, platformIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InversionesApi->updatePlatform: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **platformId** | **String**|  | 
 **platformIn** | [**PlatformIn**](PlatformIn.md)|  | 

### Return type

[**PlatformOut**](PlatformOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

