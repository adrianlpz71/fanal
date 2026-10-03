# faro_api.model.ContributionsOut

## Load the model package
```dart
import 'package:faro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**thisMonth** | **String** |  | 
**thisYear** | **String** |  | 
**total** | **String** |  | 
**withdrawn** | **String** |  | 
**starting** | **String** | Posiciones iniciales: saldo de partida, no aportación | 
**pace** | **String** | Media mensual de los últimos 12 meses | 
**streak** | **int** | Meses seguidos aportando | 
**paceInvesting** | **String** | Como pace, solo a inversiones (sin ahorro) | 
**streakInvesting** | **int** | Como streak, solo a inversiones (sin ahorro) | 
**trackStart** | [**DateTime**](DateTime.md) |  | 
**destinations** | [**List&lt;ContributionDestinationOut&gt;**](ContributionDestinationOut.md) |  | 
**months** | [**List&lt;ContributionMonthOut&gt;**](ContributionMonthOut.md) |  | 
**items** | [**List&lt;ContributionItemOut&gt;**](ContributionItemOut.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


