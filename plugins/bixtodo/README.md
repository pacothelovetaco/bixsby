# Bixtodo
A todo module for Bixsby.

Todos can include tags by adding a `@tag_name`.

Add a todo
----------

    > Add todo Keep an eye on HAL @work
    "Very well, I've added todo: Keep an eye on HAL @work"

List todos
----------

    > List todos

    "These are your items to complete:"
    "1: Keep an eye on HAL  @work"
    "2: Check the CO2 levels @space-station"

  
    > List todos @work
    "These are your items to complete:"
    "1: Keep an eye on HAL  @work"

Deleting todos
----------
Use the todo number to `delete` it.

    > Delete todo 1
    "I have removed the item sir"

Delete all the todos:
    > Delete all todos
    "All items were deleted sir."

Completing todos
----------
Use the todo number to complete the todo.

    > Complete todo 1
    "Good work sir!"

