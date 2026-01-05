## Triggery

### 1. Aktualizacja stanu magazynu części po rozpoczęciu składania produktu
(`trg_ProductionPlan_Start_ReduceComponents`)\
Celem tego wyzwalacza jest sprawdzenie czy w magazynie znajduje się wystarczająca ilość częsci by złożyć produkt, którego produkcja została zaplanowana (zmiana statusu na `in Production`). Jeżeli nie posiadamy w magazynie odpowiedniej liczby części produkcja jest blokowana. W przeciwnym wypadku pobierana jest odpowiednia ilość częsci z magazynu

### 2. Aktualizacja dostępnej liczby produktów po zakończeniu produkcji
(`trg_UpdateProductStock_OnProductionComplete`)\
Wyzwalacz automatycznie aktualizuje ilość dostępnych produktów w momencie ukończenia, ich składania (zmiana statusu na `Completed`).


### 3. Aktualizacja dostępnej liczby produktów po złożeniu zamówienia
(`trg_ReduceProductStock_OnOrder`)\
Wyzwalacz realizuje aktualizacje dostępnej liczby produktów w momencie dokonania zamówienia (`Pending`).