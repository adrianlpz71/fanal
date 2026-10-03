# faro_api.model.TaxOut

## Load the model package
```dart
import 'package:faro_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**year** | **int** |  | 
**region** | **String** |  | 
**irpfGeneralState** | **String** |  | 
**irpfGeneralRegional** | **String** |  | 
**irpfSavings** | **String** |  | 
**irpfTotal** | **String** |  | 
**wealthTaxable** | **String** |  | 
**wealthQuotaBeforeLimit** | **String** |  | 
**wealthQuota** | **String** |  | 
**wealthJointLimitApplied** | **bool** |  | 
**wealthObliged** | **bool** |  | 
**solidarityWarning** | **bool** |  | 
**baseGeneral** | **String** |  | 
**baseSavings** | **String** |  | 
**minimumState** | **String** |  | 
**minimumRegional** | **String** |  | 
**minimumQuota** | **String** | Cuota que corresponde al mínimo personal (se resta) | 
**generalBrackets** | [**List&lt;TaxBracketOut&gt;**](TaxBracketOut.md) | Escala estatal + autonómica | 
**savingsBrackets** | [**List&lt;TaxBracketOut&gt;**](TaxBracketOut.md) |  | 
**averageRate** | **String** |  | 
**marginalGeneral** | **String** |  | 
**marginalSavings** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


