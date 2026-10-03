import 'package:faro_api/src/model/account_balance_out.dart';
import 'package:faro_api/src/model/account_in.dart';
import 'package:faro_api/src/model/account_out.dart';
import 'package:faro_api/src/model/account_patch.dart';
import 'package:faro_api/src/model/advance_in.dart';
import 'package:faro_api/src/model/advance_out.dart';
import 'package:faro_api/src/model/app_release.dart';
import 'package:faro_api/src/model/asset_class_in.dart';
import 'package:faro_api/src/model/asset_class_out.dart';
import 'package:faro_api/src/model/asset_detail_out.dart';
import 'package:faro_api/src/model/asset_exposure_in.dart';
import 'package:faro_api/src/model/asset_exposure_out.dart';
import 'package:faro_api/src/model/asset_in.dart';
import 'package:faro_api/src/model/asset_out.dart';
import 'package:faro_api/src/model/asset_patch.dart';
import 'package:faro_api/src/model/asset_target_in.dart';
import 'package:faro_api/src/model/asset_target_out.dart';
import 'package:faro_api/src/model/band_out.dart';
import 'package:faro_api/src/model/bank_line_out.dart';
import 'package:faro_api/src/model/bank_preview_out.dart';
import 'package:faro_api/src/model/bank_profile_in.dart';
import 'package:faro_api/src/model/bank_profile_out.dart';
import 'package:faro_api/src/model/batch_out.dart';
import 'package:faro_api/src/model/budget_in.dart';
import 'package:faro_api/src/model/budget_out.dart';
import 'package:faro_api/src/model/category_amount_out.dart';
import 'package:faro_api/src/model/category_in.dart';
import 'package:faro_api/src/model/category_out.dart';
import 'package:faro_api/src/model/category_patch.dart';
import 'package:faro_api/src/model/category_rise_out.dart';
import 'package:faro_api/src/model/category_stat_out.dart';
import 'package:faro_api/src/model/class_amount_out.dart';
import 'package:faro_api/src/model/class_out.dart';
import 'package:faro_api/src/model/compound_in.dart';
import 'package:faro_api/src/model/compound_out.dart';
import 'package:faro_api/src/model/compound_year_out.dart';
import 'package:faro_api/src/model/contribution_destination_out.dart';
import 'package:faro_api/src/model/contribution_item_out.dart';
import 'package:faro_api/src/model/contribution_month_out.dart';
import 'package:faro_api/src/model/contribution_out.dart';
import 'package:faro_api/src/model/contributions_out.dart';
import 'package:faro_api/src/model/correction_in.dart';
import 'package:faro_api/src/model/cut_effect_out.dart';
import 'package:faro_api/src/model/cycle_detail_out.dart';
import 'package:faro_api/src/model/cycle_out.dart';
import 'package:faro_api/src/model/cycle_start_in.dart';
import 'package:faro_api/src/model/cycle_stats_out.dart';
import 'package:faro_api/src/model/cycle_summary_out.dart';
import 'package:faro_api/src/model/debt_in.dart';
import 'package:faro_api/src/model/debt_movement_out.dart';
import 'package:faro_api/src/model/debt_out.dart';
import 'package:faro_api/src/model/debt_patch.dart';
import 'package:faro_api/src/model/debt_payment_in.dart';
import 'package:faro_api/src/model/emergency_out.dart';
import 'package:faro_api/src/model/evolution_point_out.dart';
import 'package:faro_api/src/model/exposure_item_out.dart';
import 'package:faro_api/src/model/exposure_out.dart';
import 'package:faro_api/src/model/fire_plan_out.dart';
import 'package:faro_api/src/model/fire_result_out.dart';
import 'package:faro_api/src/model/fire_settings_in.dart';
import 'package:faro_api/src/model/fire_settings_out.dart';
import 'package:faro_api/src/model/fixed_item_out.dart';
import 'package:faro_api/src/model/fixed_panel_out.dart';
import 'package:faro_api/src/model/fixed_suggestion_out.dart';
import 'package:faro_api/src/model/fixed_trend_out.dart';
import 'package:faro_api/src/model/forecast_month_out.dart';
import 'package:faro_api/src/model/forecast_out.dart';
import 'package:faro_api/src/model/gastos_settings_in.dart';
import 'package:faro_api/src/model/gastos_settings_out.dart';
import 'package:faro_api/src/model/gastos_setup_in.dart';
import 'package:faro_api/src/model/goal_in.dart';
import 'package:faro_api/src/model/goal_out.dart';
import 'package:faro_api/src/model/http_validation_error.dart';
import 'package:faro_api/src/model/health_out.dart';
import 'package:faro_api/src/model/income_out.dart';
import 'package:faro_api/src/model/installment_out.dart';
import 'package:faro_api/src/model/installment_plan_in.dart';
import 'package:faro_api/src/model/installment_plan_out.dart';
import 'package:faro_api/src/model/installment_plan_patch.dart';
import 'package:faro_api/src/model/inv_settings_in.dart';
import 'package:faro_api/src/model/inv_settings_out.dart';
import 'package:faro_api/src/model/job_result_out.dart';
import 'package:faro_api/src/model/login_in.dart';
import 'package:faro_api/src/model/login_out.dart';
import 'package:faro_api/src/model/lot_out.dart';
import 'package:faro_api/src/model/macro_target_in.dart';
import 'package:faro_api/src/model/macro_target_out.dart';
import 'package:faro_api/src/model/mfa_code_in.dart';
import 'package:faro_api/src/model/mfa_enabled_out.dart';
import 'package:faro_api/src/model/mfa_setup_out.dart';
import 'package:faro_api/src/model/mfa_token_in.dart';
import 'package:faro_api/src/model/milestone_next_out.dart';
import 'package:faro_api/src/model/milestone_out.dart';
import 'package:faro_api/src/model/milestones_in.dart';
import 'package:faro_api/src/model/milestones_out.dart';
import 'package:faro_api/src/model/monte_carlo_out.dart';
import 'package:faro_api/src/model/month_item_out.dart';
import 'package:faro_api/src/model/month_out.dart';
import 'package:faro_api/src/model/movement_in.dart';
import 'package:faro_api/src/model/movement_line_out.dart';
import 'package:faro_api/src/model/movement_out.dart';
import 'package:faro_api/src/model/movement_patch.dart';
import 'package:faro_api/src/model/net_worth_component_out.dart';
import 'package:faro_api/src/model/net_worth_evolution_out.dart';
import 'package:faro_api/src/model/net_worth_out.dart';
import 'package:faro_api/src/model/net_worth_point_out.dart';
import 'package:faro_api/src/model/new_asset_out.dart';
import 'package:faro_api/src/model/occurrence_in.dart';
import 'package:faro_api/src/model/order_in.dart';
import 'package:faro_api/src/model/order_out.dart';
import 'package:faro_api/src/model/orders_in.dart';
import 'package:faro_api/src/model/payday_in.dart';
import 'package:faro_api/src/model/payday_out.dart';
import 'package:faro_api/src/model/payday_undo_out.dart';
import 'package:faro_api/src/model/performance_month_out.dart';
import 'package:faro_api/src/model/performance_out.dart';
import 'package:faro_api/src/model/person_in.dart';
import 'package:faro_api/src/model/person_out.dart';
import 'package:faro_api/src/model/person_patch.dart';
import 'package:faro_api/src/model/plan_in.dart';
import 'package:faro_api/src/model/plan_out.dart';
import 'package:faro_api/src/model/platform_batch_out.dart';
import 'package:faro_api/src/model/platform_in.dart';
import 'package:faro_api/src/model/platform_op_out.dart';
import 'package:faro_api/src/model/platform_out.dart';
import 'package:faro_api/src/model/platform_position_out.dart';
import 'package:faro_api/src/model/platform_preview_out.dart';
import 'package:faro_api/src/model/portfolio_out.dart';
import 'package:faro_api/src/model/position_out.dart';
import 'package:faro_api/src/model/price_change_out.dart';
import 'package:faro_api/src/model/price_in.dart';
import 'package:faro_api/src/model/price_out.dart';
import 'package:faro_api/src/model/price_refresh_out.dart';
import 'package:faro_api/src/model/profile_in.dart';
import 'package:faro_api/src/model/projection_point_out.dart';
import 'package:faro_api/src/model/quarter_item_out.dart';
import 'package:faro_api/src/model/quarter_metrics_out.dart';
import 'package:faro_api/src/model/quarter_review_in.dart';
import 'package:faro_api/src/model/quarter_review_out.dart';
import 'package:faro_api/src/model/realized_out.dart';
import 'package:faro_api/src/model/reconcile_in.dart';
import 'package:faro_api/src/model/reconcile_out.dart';
import 'package:faro_api/src/model/recurring_in.dart';
import 'package:faro_api/src/model/recurring_out.dart';
import 'package:faro_api/src/model/recurring_patch.dart';
import 'package:faro_api/src/model/refresh_in.dart';
import 'package:faro_api/src/model/review_goal_out.dart';
import 'package:faro_api/src/model/rule_out.dart';
import 'package:faro_api/src/model/sale_out.dart';
import 'package:faro_api/src/model/sale_part_out.dart';
import 'package:faro_api/src/model/sell_preview_in.dart';
import 'package:faro_api/src/model/sell_preview_out.dart';
import 'package:faro_api/src/model/series_point_out.dart';
import 'package:faro_api/src/model/settle_in.dart';
import 'package:faro_api/src/model/settle_out.dart';
import 'package:faro_api/src/model/share_brief_out.dart';
import 'package:faro_api/src/model/share_in.dart';
import 'package:faro_api/src/model/share_out.dart';
import 'package:faro_api/src/model/snapshot_in.dart';
import 'package:faro_api/src/model/snapshot_out.dart';
import 'package:faro_api/src/model/stats_out.dart';
import 'package:faro_api/src/model/suggest_in.dart';
import 'package:faro_api/src/model/suggestion_out.dart';
import 'package:faro_api/src/model/table_inspect_out.dart';
import 'package:faro_api/src/model/targets_in.dart';
import 'package:faro_api/src/model/targets_out.dart';
import 'package:faro_api/src/model/tax_bracket_out.dart';
import 'package:faro_api/src/model/tax_in.dart';
import 'package:faro_api/src/model/tax_out.dart';
import 'package:faro_api/src/model/tax_prefill_out.dart';
import 'package:faro_api/src/model/tax_report_out.dart';
import 'package:faro_api/src/model/token_out.dart';
import 'package:faro_api/src/model/top_concept_out.dart';
import 'package:faro_api/src/model/tracker_cycle_out.dart';
import 'package:faro_api/src/model/tracker_in.dart';
import 'package:faro_api/src/model/tracker_out.dart';
import 'package:faro_api/src/model/tracker_patch.dart';
import 'package:faro_api/src/model/transfer_in.dart';
import 'package:faro_api/src/model/transfer_out.dart';
import 'package:faro_api/src/model/tx_in.dart';
import 'package:faro_api/src/model/tx_out.dart';
import 'package:faro_api/src/model/tx_settle_in.dart';
import 'package:faro_api/src/model/user_out.dart';
import 'package:faro_api/src/model/validation_error.dart';
import 'package:faro_api/src/model/version_out.dart';
import 'package:faro_api/src/model/year_end_out.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AccountBalanceOut':
          return AccountBalanceOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountIn':
          return AccountIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountOut':
          return AccountOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AccountPatch':
          return AccountPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdvanceIn':
          return AdvanceIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdvanceOut':
          return AdvanceOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AppRelease':
          return AppRelease.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetClassIn':
          return AssetClassIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetClassOut':
          return AssetClassOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetDetailOut':
          return AssetDetailOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetExposureIn':
          return AssetExposureIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetExposureOut':
          return AssetExposureOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetIn':
          return AssetIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetOut':
          return AssetOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetPatch':
          return AssetPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetTargetIn':
          return AssetTargetIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssetTargetOut':
          return AssetTargetOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BandOut':
          return BandOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BankLineOut':
          return BankLineOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BankPreviewOut':
          return BankPreviewOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BankProfileIn':
          return BankProfileIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BankProfileOut':
          return BankProfileOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BatchOut':
          return BatchOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BudgetIn':
          return BudgetIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BudgetOut':
          return BudgetOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryAmountOut':
          return CategoryAmountOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryIn':
          return CategoryIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryOut':
          return CategoryOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryPatch':
          return CategoryPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryRiseOut':
          return CategoryRiseOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategoryStatOut':
          return CategoryStatOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ClassAmountOut':
          return ClassAmountOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ClassOut':
          return ClassOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompoundIn':
          return CompoundIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompoundOut':
          return CompoundOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CompoundYearOut':
          return CompoundYearOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContributionDestinationOut':
          return ContributionDestinationOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContributionItemOut':
          return ContributionItemOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContributionMonthOut':
          return ContributionMonthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContributionOut':
          return ContributionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ContributionsOut':
          return ContributionsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CorrectionIn':
          return CorrectionIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CutEffectOut':
          return CutEffectOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CycleDetailOut':
          return CycleDetailOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CycleOut':
          return CycleOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CycleStartIn':
          return CycleStartIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CycleStatsOut':
          return CycleStatsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CycleSummaryOut':
          return CycleSummaryOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DebtIn':
          return DebtIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DebtMovementOut':
          return DebtMovementOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DebtOut':
          return DebtOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DebtPatch':
          return DebtPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DebtPaymentIn':
          return DebtPaymentIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EmergencyOut':
          return EmergencyOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EvolutionPointOut':
          return EvolutionPointOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExposureItemOut':
          return ExposureItemOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ExposureOut':
          return ExposureOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FirePlanOut':
          return FirePlanOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FireResultOut':
          return FireResultOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FireSettingsIn':
          return FireSettingsIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FireSettingsOut':
          return FireSettingsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FixedItemOut':
          return FixedItemOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FixedPanelOut':
          return FixedPanelOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FixedSuggestionOut':
          return FixedSuggestionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FixedTrendOut':
          return FixedTrendOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ForecastMonthOut':
          return ForecastMonthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ForecastOut':
          return ForecastOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GastosSettingsIn':
          return GastosSettingsIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GastosSettingsOut':
          return GastosSettingsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GastosSetupIn':
          return GastosSetupIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GoalIn':
          return GoalIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GoalOut':
          return GoalOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HTTPValidationError':
          return HTTPValidationError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HealthOut':
          return HealthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IncomeOut':
          return IncomeOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InstallmentOut':
          return InstallmentOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InstallmentPlanIn':
          return InstallmentPlanIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InstallmentPlanOut':
          return InstallmentPlanOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InstallmentPlanPatch':
          return InstallmentPlanPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvSettingsIn':
          return InvSettingsIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvSettingsOut':
          return InvSettingsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobResultOut':
          return JobResultOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginIn':
          return LoginIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginOut':
          return LoginOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LotOut':
          return LotOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MacroTargetIn':
          return MacroTargetIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MacroTargetOut':
          return MacroTargetOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MfaCodeIn':
          return MfaCodeIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MfaEnabledOut':
          return MfaEnabledOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MfaSetupOut':
          return MfaSetupOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MfaTokenIn':
          return MfaTokenIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MilestoneNextOut':
          return MilestoneNextOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MilestoneOut':
          return MilestoneOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MilestonesIn':
          return MilestonesIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MilestonesOut':
          return MilestonesOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MonteCarloOut':
          return MonteCarloOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MonthItemOut':
          return MonthItemOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MonthOut':
          return MonthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MovementIn':
          return MovementIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MovementLineOut':
          return MovementLineOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MovementOut':
          return MovementOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MovementPatch':
          return MovementPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetWorthComponentOut':
          return NetWorthComponentOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetWorthEvolutionOut':
          return NetWorthEvolutionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetWorthOut':
          return NetWorthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NetWorthPointOut':
          return NetWorthPointOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewAssetOut':
          return NewAssetOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OccurrenceIn':
          return OccurrenceIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderIn':
          return OrderIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderOut':
          return OrderOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrdersIn':
          return OrdersIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaydayIn':
          return PaydayIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaydayOut':
          return PaydayOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaydayUndoOut':
          return PaydayUndoOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PerformanceMonthOut':
          return PerformanceMonthOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PerformanceOut':
          return PerformanceOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PersonIn':
          return PersonIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PersonOut':
          return PersonOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PersonPatch':
          return PersonPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlanIn':
          return PlanIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlanOut':
          return PlanOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformBatchOut':
          return PlatformBatchOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformIn':
          return PlatformIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformOpOut':
          return PlatformOpOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformOut':
          return PlatformOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformPositionOut':
          return PlatformPositionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlatformPreviewOut':
          return PlatformPreviewOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PortfolioOut':
          return PortfolioOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PositionOut':
          return PositionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PriceChangeOut':
          return PriceChangeOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PriceIn':
          return PriceIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PriceOut':
          return PriceOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PriceRefreshOut':
          return PriceRefreshOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProfileIn':
          return ProfileIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProjectionPointOut':
          return ProjectionPointOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuarterItemOut':
          return QuarterItemOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuarterMetricsOut':
          return QuarterMetricsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuarterReviewIn':
          return QuarterReviewIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'QuarterReviewOut':
          return QuarterReviewOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RealizedOut':
          return RealizedOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReconcileIn':
          return ReconcileIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReconcileOut':
          return ReconcileOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecurringIn':
          return RecurringIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecurringOut':
          return RecurringOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RecurringPatch':
          return RecurringPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefreshIn':
          return RefreshIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReviewGoalOut':
          return ReviewGoalOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RuleOut':
          return RuleOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SaleOut':
          return SaleOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SalePartOut':
          return SalePartOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SellPreviewIn':
          return SellPreviewIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SellPreviewOut':
          return SellPreviewOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SeriesPointOut':
          return SeriesPointOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SettleIn':
          return SettleIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SettleOut':
          return SettleOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareBriefOut':
          return ShareBriefOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareIn':
          return ShareIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ShareOut':
          return ShareOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SnapshotIn':
          return SnapshotIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SnapshotOut':
          return SnapshotOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StatsOut':
          return StatsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SuggestIn':
          return SuggestIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SuggestionOut':
          return SuggestionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TableInspectOut':
          return TableInspectOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TargetsIn':
          return TargetsIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TargetsOut':
          return TargetsOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaxBracketOut':
          return TaxBracketOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaxIn':
          return TaxIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaxOut':
          return TaxOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaxPrefillOut':
          return TaxPrefillOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TaxReportOut':
          return TaxReportOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenOut':
          return TokenOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TopConceptOut':
          return TopConceptOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TrackerCycleOut':
          return TrackerCycleOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TrackerIn':
          return TrackerIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TrackerOut':
          return TrackerOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TrackerPatch':
          return TrackerPatch.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TransferIn':
          return TransferIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TransferOut':
          return TransferOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TxIn':
          return TxIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TxOut':
          return TxOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TxSettleIn':
          return TxSettleIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserOut':
          return UserOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ValidationError':
          return ValidationError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VersionOut':
          return VersionOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'YearEndOut':
          return YearEndOut.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }