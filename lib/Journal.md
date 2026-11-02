

## Phase 1
Mutating changes the existing object. copyWith creates a new
Stock with updated values while leaving the original unchanged.

## Phase 2
StreamBuilder responds to new stream events and rebuilds its
display using the latest Stock. With setState, I would manually
tell a StatefulWidget that its data changed.

## Phase 3
The button adds a StockAction to the input sink. The BLoC
receives it, calculates the price, and creates a Stock using
copyWith. It adds that Stock to the output sink. StreamBuilder
receives the event and runs its builder to update the display.

## Phase 4
StockBloc handles price calculations and actions. StockPage
handles the display and buttons. Changing the appearance would
not require changing StockBloc because its logic is separate
from the UI. The controllers are closed when StockApp is removed.
