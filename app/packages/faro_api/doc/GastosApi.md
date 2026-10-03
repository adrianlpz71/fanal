# faro_api.api.GastosApi

## Load the API package
```dart
import 'package:faro_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**ackPrice**](GastosApi.md#ackprice) | **POST** /api/recurring/{template_id}/ack-price | Ack Price
[**advancePlan**](GastosApi.md#advanceplan) | **POST** /api/installments/{plan_id}/advance | Advance Plan
[**cancelPlan**](GastosApi.md#cancelplan) | **POST** /api/installments/{plan_id}/cancel | Cancel Plan
[**createAccount**](GastosApi.md#createaccount) | **POST** /api/accounts | Create Account
[**createCategory**](GastosApi.md#createcategory) | **POST** /api/categories | Create Category
[**createDebt**](GastosApi.md#createdebt) | **POST** /api/debts | Create Debt
[**createMovement**](GastosApi.md#createmovement) | **POST** /api/movements | Create Movement
[**createPerson**](GastosApi.md#createperson) | **POST** /api/people | Create Person
[**createPlan**](GastosApi.md#createplan) | **POST** /api/installments | Create Plan
[**createRecurring**](GastosApi.md#createrecurring) | **POST** /api/recurring | Create Recurring
[**createTracker**](GastosApi.md#createtracker) | **POST** /api/trackers | Create Tracker
[**currentCycle**](GastosApi.md#currentcycle) | **GET** /api/cycles/current | Current Cycle
[**debtPayment**](GastosApi.md#debtpayment) | **POST** /api/debts/{debt_id}/payments | Debt Payment
[**deleteBudget**](GastosApi.md#deletebudget) | **DELETE** /api/budgets/{category_id} | Delete Budget
[**deleteMovement**](GastosApi.md#deletemovement) | **DELETE** /api/movements/{movement_id} | Delete Movement
[**deleteRecurring**](GastosApi.md#deleterecurring) | **DELETE** /api/recurring/{template_id} | Delete Recurring
[**deleteRule**](GastosApi.md#deleterule) | **DELETE** /api/category-rules/{rule_id} | Delete Rule
[**deleteTracker**](GastosApi.md#deletetracker) | **DELETE** /api/trackers/{tracker_id} | Delete Tracker
[**duplicateMovement**](GastosApi.md#duplicatemovement) | **POST** /api/movements/{movement_id}/duplicate | Duplicate Movement
[**fixedPanel**](GastosApi.md#fixedpanel) | **GET** /api/gastos/fijos | Fixed Panel
[**fixedReviewed**](GastosApi.md#fixedreviewed) | **POST** /api/gastos/fijos/reviewed | Fixed Reviewed
[**getCycle**](GastosApi.md#getcycle) | **GET** /api/cycles/{cycle_id} | Get Cycle
[**getForecast**](GastosApi.md#getforecast) | **GET** /api/forecast | Get Forecast
[**getMonth**](GastosApi.md#getmonth) | **GET** /api/months/{ym} | Get Month
[**getPlan**](GastosApi.md#getplan) | **GET** /api/installments/{plan_id} | Get Plan
[**getSettings**](GastosApi.md#getsettings) | **GET** /api/gastos/settings | Get Settings
[**getShares**](GastosApi.md#getshares) | **GET** /api/movements/{movement_id}/shares | Get Shares
[**listAccounts**](GastosApi.md#listaccounts) | **GET** /api/accounts | List Accounts
[**listBudgets**](GastosApi.md#listbudgets) | **GET** /api/budgets | List Budgets
[**listCategories**](GastosApi.md#listcategories) | **GET** /api/categories | List Categories
[**listCycles**](GastosApi.md#listcycles) | **GET** /api/cycles | List Cycles
[**listDebts**](GastosApi.md#listdebts) | **GET** /api/debts | List Debts
[**listPeople**](GastosApi.md#listpeople) | **GET** /api/people | List People
[**listPlans**](GastosApi.md#listplans) | **GET** /api/installments | List Plans
[**listRecurring**](GastosApi.md#listrecurring) | **GET** /api/recurring | List Recurring
[**listRules**](GastosApi.md#listrules) | **GET** /api/category-rules | List Rules
[**listTrackers**](GastosApi.md#listtrackers) | **GET** /api/trackers | List Trackers
[**patchAccount**](GastosApi.md#patchaccount) | **PATCH** /api/accounts/{account_id} | Patch Account
[**patchCategory**](GastosApi.md#patchcategory) | **PATCH** /api/categories/{category_id} | Patch Category
[**patchDebt**](GastosApi.md#patchdebt) | **PATCH** /api/debts/{debt_id} | Patch Debt
[**patchMovement**](GastosApi.md#patchmovement) | **PATCH** /api/movements/{movement_id} | Patch Movement
[**patchPerson**](GastosApi.md#patchperson) | **PATCH** /api/people/{person_id} | Patch Person
[**patchPlan**](GastosApi.md#patchplan) | **PATCH** /api/installments/{plan_id} | Patch Plan
[**patchRecurring**](GastosApi.md#patchrecurring) | **PATCH** /api/recurring/{template_id} | Patch Recurring
[**patchSettings**](GastosApi.md#patchsettings) | **PATCH** /api/gastos/settings | Patch Settings
[**patchTracker**](GastosApi.md#patchtracker) | **PATCH** /api/trackers/{tracker_id} | Patch Tracker
[**payday**](GastosApi.md#payday) | **POST** /api/cycles/payday | Payday
[**paydayUndoStatus**](GastosApi.md#paydayundostatus) | **GET** /api/cycles/payday/undo | Payday Undo Status
[**personShares**](GastosApi.md#personshares) | **GET** /api/people/{person_id}/shares | Person Shares
[**putBudget**](GastosApi.md#putbudget) | **PUT** /api/budgets/{category_id} | Put Budget
[**putShares**](GastosApi.md#putshares) | **PUT** /api/movements/{movement_id}/shares | Put Shares
[**reconcile**](GastosApi.md#reconcile) | **POST** /api/accounts/{account_id}/reconcile | Reconcile
[**recurringOccurrence**](GastosApi.md#recurringoccurrence) | **POST** /api/recurring/{template_id}/occurrences | Recurring Occurrence
[**settle**](GastosApi.md#settle) | **POST** /api/shares/{share_id}/settle | Settle
[**setup**](GastosApi.md#setup) | **POST** /api/gastos/setup | Setup
[**startCycle**](GastosApi.md#startcycle) | **POST** /api/cycles/start | Start Cycle
[**stats**](GastosApi.md#stats) | **GET** /api/stats | Stats
[**suggest**](GastosApi.md#suggest) | **GET** /api/movements/suggest | Suggest
[**undoPayday**](GastosApi.md#undopayday) | **POST** /api/cycles/payday/undo | Undo Payday


# **ackPrice**
> RecurringOut ackPrice(templateId)

Ack Price

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String templateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.ackPrice(templateId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->ackPrice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 

### Return type

[**RecurringOut**](RecurringOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **advancePlan**
> AdvanceOut advancePlan(planId, advanceIn)

Advance Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdvanceIn advanceIn = ; // AdvanceIn | 

try {
    final response = api.advancePlan(planId, advanceIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->advancePlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 
 **advanceIn** | [**AdvanceIn**](AdvanceIn.md)|  | 

### Return type

[**AdvanceOut**](AdvanceOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelPlan**
> InstallmentPlanOut cancelPlan(planId)

Cancel Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.cancelPlan(planId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->cancelPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 

### Return type

[**InstallmentPlanOut**](InstallmentPlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAccount**
> AccountOut createAccount(accountIn)

Create Account

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final AccountIn accountIn = ; // AccountIn | 

try {
    final response = api.createAccount(accountIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountIn** | [**AccountIn**](AccountIn.md)|  | 

### Return type

[**AccountOut**](AccountOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCategory**
> CategoryOut createCategory(categoryIn)

Create Category

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final CategoryIn categoryIn = ; // CategoryIn | 

try {
    final response = api.createCategory(categoryIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryIn** | [**CategoryIn**](CategoryIn.md)|  | 

### Return type

[**CategoryOut**](CategoryOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDebt**
> DebtOut createDebt(debtIn)

Create Debt

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final DebtIn debtIn = ; // DebtIn | 

try {
    final response = api.createDebt(debtIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createDebt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **debtIn** | [**DebtIn**](DebtIn.md)|  | 

### Return type

[**DebtOut**](DebtOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMovement**
> MovementOut createMovement(movementIn)

Create Movement

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final MovementIn movementIn = ; // MovementIn | 

try {
    final response = api.createMovement(movementIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createMovement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementIn** | [**MovementIn**](MovementIn.md)|  | 

### Return type

[**MovementOut**](MovementOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPerson**
> PersonOut createPerson(personIn)

Create Person

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final PersonIn personIn = ; // PersonIn | 

try {
    final response = api.createPerson(personIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createPerson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personIn** | [**PersonIn**](PersonIn.md)|  | 

### Return type

[**PersonOut**](PersonOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPlan**
> InstallmentPlanOut createPlan(installmentPlanIn)

Create Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final InstallmentPlanIn installmentPlanIn = ; // InstallmentPlanIn | 

try {
    final response = api.createPlan(installmentPlanIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **installmentPlanIn** | [**InstallmentPlanIn**](InstallmentPlanIn.md)|  | 

### Return type

[**InstallmentPlanOut**](InstallmentPlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRecurring**
> RecurringOut createRecurring(recurringIn)

Create Recurring

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final RecurringIn recurringIn = ; // RecurringIn | 

try {
    final response = api.createRecurring(recurringIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createRecurring: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **recurringIn** | [**RecurringIn**](RecurringIn.md)|  | 

### Return type

[**RecurringOut**](RecurringOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTracker**
> TrackerOut createTracker(trackerIn)

Create Tracker

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final TrackerIn trackerIn = ; // TrackerIn | 

try {
    final response = api.createTracker(trackerIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->createTracker: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackerIn** | [**TrackerIn**](TrackerIn.md)|  | 

### Return type

[**TrackerOut**](TrackerOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **currentCycle**
> CycleDetailOut currentCycle()

Current Cycle

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.currentCycle();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->currentCycle: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CycleDetailOut**](CycleDetailOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **debtPayment**
> DebtOut debtPayment(debtId, debtPaymentIn)

Debt Payment

Registra un pago (sale dinero si debo; entra si me deben) en la cuenta de gastos. Es una transferencia de patrimonio, no un gasto: no cuenta en las estadísticas.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String debtId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DebtPaymentIn debtPaymentIn = ; // DebtPaymentIn | 

try {
    final response = api.debtPayment(debtId, debtPaymentIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->debtPayment: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **debtId** | **String**|  | 
 **debtPaymentIn** | [**DebtPaymentIn**](DebtPaymentIn.md)|  | 

### Return type

[**DebtOut**](DebtOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteBudget**
> deleteBudget(categoryId)

Delete Budget

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String categoryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteBudget(categoryId);
} catch on DioException (e) {
    print('Exception when calling GastosApi->deleteBudget: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMovement**
> deleteMovement(movementId)

Delete Movement

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String movementId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteMovement(movementId);
} catch on DioException (e) {
    print('Exception when calling GastosApi->deleteMovement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRecurring**
> deleteRecurring(templateId)

Delete Recurring

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String templateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteRecurring(templateId);
} catch on DioException (e) {
    print('Exception when calling GastosApi->deleteRecurring: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRule**
> deleteRule(ruleId)

Delete Rule

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String ruleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteRule(ruleId);
} catch on DioException (e) {
    print('Exception when calling GastosApi->deleteRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ruleId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteTracker**
> deleteTracker(trackerId)

Delete Tracker

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String trackerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.deleteTracker(trackerId);
} catch on DioException (e) {
    print('Exception when calling GastosApi->deleteTracker: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackerId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **duplicateMovement**
> MovementOut duplicateMovement(movementId)

Duplicate Movement

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String movementId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.duplicateMovement(movementId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->duplicateMovement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementId** | **String**|  | 

### Return type

[**MovementOut**](MovementOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **fixedPanel**
> FixedPanelOut fixedPanel()

Fixed Panel

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.fixedPanel();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->fixedPanel: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FixedPanelOut**](FixedPanelOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **fixedReviewed**
> fixedReviewed()

Fixed Reviewed

Marca la revisión periódica de suscripciones como hecha (vuelve a avisar en 90 días).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    api.fixedReviewed();
} catch on DioException (e) {
    print('Exception when calling GastosApi->fixedReviewed: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCycle**
> CycleDetailOut getCycle(cycleId)

Get Cycle

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String cycleId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getCycle(cycleId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getCycle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cycleId** | **String**|  | 

### Return type

[**CycleDetailOut**](CycleDetailOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getForecast**
> ForecastOut getForecast(months)

Get Forecast

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final int months = 56; // int | 0 = el valor de tus ajustes

try {
    final response = api.getForecast(months);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getForecast: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **months** | **int**| 0 = el valor de tus ajustes | [optional] [default to 0]

### Return type

[**ForecastOut**](ForecastOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMonth**
> MonthOut getMonth(ym)

Get Month

Un ciclo futuro con todo lo que tiene previsto (movimientos y recurrentes proyectados). Los ciclos actual y pasados se ven en /cycles.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String ym = ym_example; // String | 

try {
    final response = api.getMonth(ym);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getMonth: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ym** | **String**|  | 

### Return type

[**MonthOut**](MonthOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlan**
> InstallmentPlanOut getPlan(planId)

Get Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getPlan(planId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 

### Return type

[**InstallmentPlanOut**](InstallmentPlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSettings**
> GastosSettingsOut getSettings()

Get Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.getSettings();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getSettings: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GastosSettingsOut**](GastosSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getShares**
> List<ShareOut> getShares(movementId)

Get Shares

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String movementId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getShares(movementId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->getShares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementId** | **String**|  | 

### Return type

[**List&lt;ShareOut&gt;**](ShareOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAccounts**
> List<AccountOut> listAccounts()

List Accounts

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listAccounts();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listAccounts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;AccountOut&gt;**](AccountOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBudgets**
> List<BudgetOut> listBudgets()

List Budgets

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listBudgets();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listBudgets: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;BudgetOut&gt;**](BudgetOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCategories**
> List<CategoryOut> listCategories()

List Categories

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listCategories();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listCategories: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;CategoryOut&gt;**](CategoryOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCycles**
> List<CycleOut> listCycles(limit)

List Cycles

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final int limit = 56; // int | 

try {
    final response = api.listCycles(limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listCycles: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 24]

### Return type

[**List&lt;CycleOut&gt;**](CycleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDebts**
> List<DebtOut> listDebts()

List Debts

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listDebts();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listDebts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;DebtOut&gt;**](DebtOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPeople**
> List<PersonOut> listPeople(includeArchived)

List People

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final bool includeArchived = true; // bool | 

try {
    final response = api.listPeople(includeArchived);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listPeople: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **includeArchived** | **bool**|  | [optional] [default to false]

### Return type

[**List&lt;PersonOut&gt;**](PersonOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlans**
> List<InstallmentPlanOut> listPlans(includeClosed)

List Plans

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final bool includeClosed = true; // bool | 

try {
    final response = api.listPlans(includeClosed);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listPlans: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **includeClosed** | **bool**|  | [optional] [default to false]

### Return type

[**List&lt;InstallmentPlanOut&gt;**](InstallmentPlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRecurring**
> List<RecurringOut> listRecurring()

List Recurring

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listRecurring();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listRecurring: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;RecurringOut&gt;**](RecurringOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRules**
> List<RuleOut> listRules()

List Rules

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listRules();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listRules: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;RuleOut&gt;**](RuleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTrackers**
> List<TrackerOut> listTrackers()

List Trackers

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.listTrackers();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->listTrackers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;TrackerOut&gt;**](TrackerOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchAccount**
> AccountOut patchAccount(accountId, accountPatch)

Patch Account

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String accountId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AccountPatch accountPatch = ; // AccountPatch | 

try {
    final response = api.patchAccount(accountId, accountPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 
 **accountPatch** | [**AccountPatch**](AccountPatch.md)|  | 

### Return type

[**AccountOut**](AccountOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchCategory**
> CategoryOut patchCategory(categoryId, categoryPatch)

Patch Category

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String categoryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final CategoryPatch categoryPatch = ; // CategoryPatch | 

try {
    final response = api.patchCategory(categoryId, categoryPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchCategory: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryId** | **String**|  | 
 **categoryPatch** | [**CategoryPatch**](CategoryPatch.md)|  | 

### Return type

[**CategoryOut**](CategoryOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchDebt**
> DebtOut patchDebt(debtId, debtPatch)

Patch Debt

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String debtId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DebtPatch debtPatch = ; // DebtPatch | 

try {
    final response = api.patchDebt(debtId, debtPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchDebt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **debtId** | **String**|  | 
 **debtPatch** | [**DebtPatch**](DebtPatch.md)|  | 

### Return type

[**DebtOut**](DebtOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchMovement**
> MovementOut patchMovement(movementId, movementPatch)

Patch Movement

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String movementId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final MovementPatch movementPatch = ; // MovementPatch | 

try {
    final response = api.patchMovement(movementId, movementPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchMovement: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementId** | **String**|  | 
 **movementPatch** | [**MovementPatch**](MovementPatch.md)|  | 

### Return type

[**MovementOut**](MovementOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchPerson**
> PersonOut patchPerson(personId, personPatch)

Patch Person

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String personId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final PersonPatch personPatch = ; // PersonPatch | 

try {
    final response = api.patchPerson(personId, personPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchPerson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personId** | **String**|  | 
 **personPatch** | [**PersonPatch**](PersonPatch.md)|  | 

### Return type

[**PersonOut**](PersonOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchPlan**
> InstallmentPlanOut patchPlan(planId, installmentPlanPatch)

Patch Plan

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String planId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final InstallmentPlanPatch installmentPlanPatch = ; // InstallmentPlanPatch | 

try {
    final response = api.patchPlan(planId, installmentPlanPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchPlan: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planId** | **String**|  | 
 **installmentPlanPatch** | [**InstallmentPlanPatch**](InstallmentPlanPatch.md)|  | 

### Return type

[**InstallmentPlanOut**](InstallmentPlanOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchRecurring**
> RecurringOut patchRecurring(templateId, recurringPatch)

Patch Recurring

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String templateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RecurringPatch recurringPatch = ; // RecurringPatch | 

try {
    final response = api.patchRecurring(templateId, recurringPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchRecurring: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 
 **recurringPatch** | [**RecurringPatch**](RecurringPatch.md)|  | 

### Return type

[**RecurringOut**](RecurringOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchSettings**
> GastosSettingsOut patchSettings(gastosSettingsIn)

Patch Settings

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final GastosSettingsIn gastosSettingsIn = ; // GastosSettingsIn | 

try {
    final response = api.patchSettings(gastosSettingsIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchSettings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **gastosSettingsIn** | [**GastosSettingsIn**](GastosSettingsIn.md)|  | 

### Return type

[**GastosSettingsOut**](GastosSettingsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchTracker**
> TrackerOut patchTracker(trackerId, trackerPatch)

Patch Tracker

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String trackerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TrackerPatch trackerPatch = ; // TrackerPatch | 

try {
    final response = api.patchTracker(trackerId, trackerPatch);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->patchTracker: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackerId** | **String**|  | 
 **trackerPatch** | [**TrackerPatch**](TrackerPatch.md)|  | 

### Return type

[**TrackerOut**](TrackerOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **payday**
> PaydayOut payday(paydayIn)

Payday

Botón \"He cobrado\".

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final PaydayIn paydayIn = ; // PaydayIn | 

try {
    final response = api.payday(paydayIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->payday: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paydayIn** | [**PaydayIn**](PaydayIn.md)|  | 

### Return type

[**PaydayOut**](PaydayOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paydayUndoStatus**
> PaydayUndoOut paydayUndoStatus()

Payday Undo Status

¿Se puede deshacer el último \"He cobrado\"? Solo mientras su ciclo siga abierto.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.paydayUndoStatus();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->paydayUndoStatus: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PaydayUndoOut**](PaydayUndoOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **personShares**
> List<ShareOut> personShares(personId)

Person Shares

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String personId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.personShares(personId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->personShares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personId** | **String**|  | 

### Return type

[**List&lt;ShareOut&gt;**](ShareOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putBudget**
> BudgetOut putBudget(categoryId, budgetIn)

Put Budget

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String categoryId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final BudgetIn budgetIn = ; // BudgetIn | 

try {
    final response = api.putBudget(categoryId, budgetIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->putBudget: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **categoryId** | **String**|  | 
 **budgetIn** | [**BudgetIn**](BudgetIn.md)|  | 

### Return type

[**BudgetOut**](BudgetOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putShares**
> List<ShareOut> putShares(movementId, shareIn)

Put Shares

Reparte un gasto: qué parte corresponde a cada persona (me deben / debo).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String movementId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final List<ShareIn> shareIn = ; // List<ShareIn> | 

try {
    final response = api.putShares(movementId, shareIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->putShares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **movementId** | **String**|  | 
 **shareIn** | [**List&lt;ShareIn&gt;**](ShareIn.md)|  | 

### Return type

[**List&lt;ShareOut&gt;**](ShareOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reconcile**
> ReconcileOut reconcile(accountId, reconcileIn)

Reconcile

Cuadre con el banco: diferencia entre el saldo calculado y el real; opcionalmente crea un movimiento de ajuste en el ciclo abierto.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String accountId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ReconcileIn reconcileIn = ; // ReconcileIn | 

try {
    final response = api.reconcile(accountId, reconcileIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->reconcile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 
 **reconcileIn** | [**ReconcileIn**](ReconcileIn.md)|  | 

### Return type

[**ReconcileOut**](ReconcileOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recurringOccurrence**
> MovementOut recurringOccurrence(templateId, occurrenceIn)

Recurring Occurrence

Edita o salta una ocurrencia futura de un recurrente sin tocar la plantilla.

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String templateId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final OccurrenceIn occurrenceIn = ; // OccurrenceIn | 

try {
    final response = api.recurringOccurrence(templateId, occurrenceIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->recurringOccurrence: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **templateId** | **String**|  | 
 **occurrenceIn** | [**OccurrenceIn**](OccurrenceIn.md)|  | 

### Return type

[**MovementOut**](MovementOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **settle**
> SettleOut settle(shareId, settleIn)

Settle

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String shareId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final SettleIn settleIn = ; // SettleIn | 

try {
    final response = api.settle(shareId, settleIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->settle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **shareId** | **String**|  | 
 **settleIn** | [**SettleIn**](SettleIn.md)|  | 

### Return type

[**SettleOut**](SettleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setup**
> CycleOut setup(gastosSetupIn)

Setup

Onboarding del módulo: cuenta de gastos (+ refugio opcional), ajustes, categorías y el primer ciclo (abierto con el saldo actual como arrastre).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final GastosSetupIn gastosSetupIn = ; // GastosSetupIn | 

try {
    final response = api.setup(gastosSetupIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->setup: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **gastosSetupIn** | [**GastosSetupIn**](GastosSetupIn.md)|  | 

### Return type

[**CycleOut**](CycleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startCycle**
> CycleOut startCycle(cycleStartIn)

Start Cycle

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final CycleStartIn cycleStartIn = ; // CycleStartIn | 

try {
    final response = api.startCycle(cycleStartIn);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->startCycle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cycleStartIn** | [**CycleStartIn**](CycleStartIn.md)|  | 

### Return type

[**CycleOut**](CycleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stats**
> StatsOut stats(cycles, top)

Stats

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final int cycles = 56; // int | 
final int top = 56; // int | 

try {
    final response = api.stats(cycles, top);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->stats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cycles** | **int**|  | [optional] [default to 6]
 **top** | **int**|  | [optional] [default to 15]

### Return type

[**StatsOut**](StatsOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suggest**
> List<SuggestionOut> suggest(q)

Suggest

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();
final String q = q_example; // String | 

try {
    final response = api.suggest(q);
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->suggest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**|  | 

### Return type

[**List&lt;SuggestionOut&gt;**](SuggestionOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **undoPayday**
> CycleOut undoPayday()

Undo Payday

Deshace el último \"He cobrado\": reabre el ciclo anterior y borra el nuevo (lo apuntado en el nuevo vuelve al reabierto).

### Example
```dart
import 'package:faro_api/api.dart';

final api = FaroApi().getGastosApi();

try {
    final response = api.undoPayday();
    print(response);
} catch on DioException (e) {
    print('Exception when calling GastosApi->undoPayday: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CycleOut**](CycleOut.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

