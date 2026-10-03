# Cómo descargar los movimientos de tu banco

1. Entra en la web de tu banco y abre los **movimientos** de la cuenta.
2. Elige el periodo y descárgalos en **Excel** (`.xlsx`), **CSV** o texto (`.txt`). Si solo te deja `.xls`, ábrelo y guárdalo como `.xlsx` o `.csv`.

## Qué hace Fanal con el fichero

- Reconoce por sí solo las columnas habituales (fecha, concepto, importe o cargo y abono, saldo). Si no las reconoce, le dices tú qué columna es cada cosa y **guardas el formato** para la próxima vez.
- Lo que ya tengas apuntado se empareja: un **previsto** con el mismo importe pasa a **cargado**, y un gasto que ya apuntaste a mano solo se marca como visto en el banco.
- Lo nuevo se crea con su categoría, aprendida de tus reglas.
- ¿Tienes una cuenta en Trade Republic? Su extracto en PDF tiene su propia tarjeta.
- Si el fichero trae el saldo, Fanal comprueba que cuadra con el de tu cuenta.
