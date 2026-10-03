import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for GastosApi
void main() {
  final instance = FaroApi().getGastosApi();

  group(GastosApi, () {
    // Ack Price
    //
    //Future<RecurringOut> ackPrice(String templateId) async
    test('test ackPrice', () async {
      // TODO
    });

    // Advance Plan
    //
    //Future<AdvanceOut> advancePlan(String planId, AdvanceIn advanceIn) async
    test('test advancePlan', () async {
      // TODO
    });

    // Cancel Plan
    //
    //Future<InstallmentPlanOut> cancelPlan(String planId) async
    test('test cancelPlan', () async {
      // TODO
    });

    // Create Account
    //
    //Future<AccountOut> createAccount(AccountIn accountIn) async
    test('test createAccount', () async {
      // TODO
    });

    // Create Category
    //
    //Future<CategoryOut> createCategory(CategoryIn categoryIn) async
    test('test createCategory', () async {
      // TODO
    });

    // Create Debt
    //
    //Future<DebtOut> createDebt(DebtIn debtIn) async
    test('test createDebt', () async {
      // TODO
    });

    // Create Movement
    //
    //Future<MovementOut> createMovement(MovementIn movementIn) async
    test('test createMovement', () async {
      // TODO
    });

    // Create Person
    //
    //Future<PersonOut> createPerson(PersonIn personIn) async
    test('test createPerson', () async {
      // TODO
    });

    // Create Plan
    //
    //Future<InstallmentPlanOut> createPlan(InstallmentPlanIn installmentPlanIn) async
    test('test createPlan', () async {
      // TODO
    });

    // Create Recurring
    //
    //Future<RecurringOut> createRecurring(RecurringIn recurringIn) async
    test('test createRecurring', () async {
      // TODO
    });

    // Create Tracker
    //
    //Future<TrackerOut> createTracker(TrackerIn trackerIn) async
    test('test createTracker', () async {
      // TODO
    });

    // Current Cycle
    //
    //Future<CycleDetailOut> currentCycle() async
    test('test currentCycle', () async {
      // TODO
    });

    // Debt Payment
    //
    // Registra un pago (sale dinero si debo; entra si me deben) en la cuenta de gastos. Es una transferencia de patrimonio, no un gasto: no cuenta en las estadísticas.
    //
    //Future<DebtOut> debtPayment(String debtId, DebtPaymentIn debtPaymentIn) async
    test('test debtPayment', () async {
      // TODO
    });

    // Delete Budget
    //
    //Future deleteBudget(String categoryId) async
    test('test deleteBudget', () async {
      // TODO
    });

    // Delete Movement
    //
    //Future deleteMovement(String movementId) async
    test('test deleteMovement', () async {
      // TODO
    });

    // Delete Recurring
    //
    //Future deleteRecurring(String templateId) async
    test('test deleteRecurring', () async {
      // TODO
    });

    // Delete Rule
    //
    //Future deleteRule(String ruleId) async
    test('test deleteRule', () async {
      // TODO
    });

    // Delete Tracker
    //
    //Future deleteTracker(String trackerId) async
    test('test deleteTracker', () async {
      // TODO
    });

    // Duplicate Movement
    //
    //Future<MovementOut> duplicateMovement(String movementId) async
    test('test duplicateMovement', () async {
      // TODO
    });

    // Fixed Panel
    //
    //Future<FixedPanelOut> fixedPanel() async
    test('test fixedPanel', () async {
      // TODO
    });

    // Fixed Reviewed
    //
    // Marca la revisión periódica de suscripciones como hecha (vuelve a avisar en 90 días).
    //
    //Future fixedReviewed() async
    test('test fixedReviewed', () async {
      // TODO
    });

    // Get Cycle
    //
    //Future<CycleDetailOut> getCycle(String cycleId) async
    test('test getCycle', () async {
      // TODO
    });

    // Get Forecast
    //
    //Future<ForecastOut> getForecast({ int months }) async
    test('test getForecast', () async {
      // TODO
    });

    // Get Month
    //
    // Un ciclo futuro con todo lo que tiene previsto (movimientos y recurrentes proyectados). Los ciclos actual y pasados se ven en /cycles.
    //
    //Future<MonthOut> getMonth(String ym) async
    test('test getMonth', () async {
      // TODO
    });

    // Get Plan
    //
    //Future<InstallmentPlanOut> getPlan(String planId) async
    test('test getPlan', () async {
      // TODO
    });

    // Get Settings
    //
    //Future<GastosSettingsOut> getSettings() async
    test('test getSettings', () async {
      // TODO
    });

    // Get Shares
    //
    //Future<List<ShareOut>> getShares(String movementId) async
    test('test getShares', () async {
      // TODO
    });

    // List Accounts
    //
    //Future<List<AccountOut>> listAccounts() async
    test('test listAccounts', () async {
      // TODO
    });

    // List Budgets
    //
    //Future<List<BudgetOut>> listBudgets() async
    test('test listBudgets', () async {
      // TODO
    });

    // List Categories
    //
    //Future<List<CategoryOut>> listCategories() async
    test('test listCategories', () async {
      // TODO
    });

    // List Cycles
    //
    //Future<List<CycleOut>> listCycles({ int limit }) async
    test('test listCycles', () async {
      // TODO
    });

    // List Debts
    //
    //Future<List<DebtOut>> listDebts() async
    test('test listDebts', () async {
      // TODO
    });

    // List People
    //
    //Future<List<PersonOut>> listPeople({ bool includeArchived }) async
    test('test listPeople', () async {
      // TODO
    });

    // List Plans
    //
    //Future<List<InstallmentPlanOut>> listPlans({ bool includeClosed }) async
    test('test listPlans', () async {
      // TODO
    });

    // List Recurring
    //
    //Future<List<RecurringOut>> listRecurring() async
    test('test listRecurring', () async {
      // TODO
    });

    // List Rules
    //
    //Future<List<RuleOut>> listRules() async
    test('test listRules', () async {
      // TODO
    });

    // List Trackers
    //
    //Future<List<TrackerOut>> listTrackers() async
    test('test listTrackers', () async {
      // TODO
    });

    // Patch Account
    //
    //Future<AccountOut> patchAccount(String accountId, AccountPatch accountPatch) async
    test('test patchAccount', () async {
      // TODO
    });

    // Patch Category
    //
    //Future<CategoryOut> patchCategory(String categoryId, CategoryPatch categoryPatch) async
    test('test patchCategory', () async {
      // TODO
    });

    // Patch Debt
    //
    //Future<DebtOut> patchDebt(String debtId, DebtPatch debtPatch) async
    test('test patchDebt', () async {
      // TODO
    });

    // Patch Movement
    //
    //Future<MovementOut> patchMovement(String movementId, MovementPatch movementPatch) async
    test('test patchMovement', () async {
      // TODO
    });

    // Patch Person
    //
    //Future<PersonOut> patchPerson(String personId, PersonPatch personPatch) async
    test('test patchPerson', () async {
      // TODO
    });

    // Patch Plan
    //
    //Future<InstallmentPlanOut> patchPlan(String planId, InstallmentPlanPatch installmentPlanPatch) async
    test('test patchPlan', () async {
      // TODO
    });

    // Patch Recurring
    //
    //Future<RecurringOut> patchRecurring(String templateId, RecurringPatch recurringPatch) async
    test('test patchRecurring', () async {
      // TODO
    });

    // Patch Settings
    //
    //Future<GastosSettingsOut> patchSettings(GastosSettingsIn gastosSettingsIn) async
    test('test patchSettings', () async {
      // TODO
    });

    // Patch Tracker
    //
    //Future<TrackerOut> patchTracker(String trackerId, TrackerPatch trackerPatch) async
    test('test patchTracker', () async {
      // TODO
    });

    // Payday
    //
    // Botón \"He cobrado\".
    //
    //Future<PaydayOut> payday(PaydayIn paydayIn) async
    test('test payday', () async {
      // TODO
    });

    // Payday Undo Status
    //
    // ¿Se puede deshacer el último \"He cobrado\"? Solo mientras su ciclo siga abierto.
    //
    //Future<PaydayUndoOut> paydayUndoStatus() async
    test('test paydayUndoStatus', () async {
      // TODO
    });

    // Person Shares
    //
    //Future<List<ShareOut>> personShares(String personId) async
    test('test personShares', () async {
      // TODO
    });

    // Put Budget
    //
    //Future<BudgetOut> putBudget(String categoryId, BudgetIn budgetIn) async
    test('test putBudget', () async {
      // TODO
    });

    // Put Shares
    //
    // Reparte un gasto: qué parte corresponde a cada persona (me deben / debo).
    //
    //Future<List<ShareOut>> putShares(String movementId, List<ShareIn> shareIn) async
    test('test putShares', () async {
      // TODO
    });

    // Reconcile
    //
    // Cuadre con el banco: diferencia entre el saldo calculado y el real; opcionalmente crea un movimiento de ajuste en el ciclo abierto.
    //
    //Future<ReconcileOut> reconcile(String accountId, ReconcileIn reconcileIn) async
    test('test reconcile', () async {
      // TODO
    });

    // Recurring Occurrence
    //
    // Edita o salta una ocurrencia futura de un recurrente sin tocar la plantilla.
    //
    //Future<MovementOut> recurringOccurrence(String templateId, OccurrenceIn occurrenceIn) async
    test('test recurringOccurrence', () async {
      // TODO
    });

    // Settle
    //
    //Future<SettleOut> settle(String shareId, SettleIn settleIn) async
    test('test settle', () async {
      // TODO
    });

    // Setup
    //
    // Onboarding del módulo: cuenta de gastos (+ refugio opcional), ajustes, categorías y el primer ciclo (abierto con el saldo actual como arrastre).
    //
    //Future<CycleOut> setup(GastosSetupIn gastosSetupIn) async
    test('test setup', () async {
      // TODO
    });

    // Start Cycle
    //
    //Future<CycleOut> startCycle(CycleStartIn cycleStartIn) async
    test('test startCycle', () async {
      // TODO
    });

    // Stats
    //
    //Future<StatsOut> stats({ int cycles, int top }) async
    test('test stats', () async {
      // TODO
    });

    // Suggest
    //
    //Future<List<SuggestionOut>> suggest(String q) async
    test('test suggest', () async {
      // TODO
    });

    // Undo Payday
    //
    // Deshace el último \"He cobrado\": reabre el ciclo anterior y borra el nuevo (lo apuntado en el nuevo vuelve al reabierto).
    //
    //Future<CycleOut> undoPayday() async
    test('test undoPayday', () async {
      // TODO
    });

  });
}
