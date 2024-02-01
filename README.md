# lua_simple_conditions: A Lua library for managing conditions



This library offers a structured approach to managing conditions in your Lua code. By using this library, you can enhance the readability and maintainability of your code.



## Features

#### Handlers

A handler in lua_simple_conditions is a table that groups various functions. Each function corresponds to a specific condition or behavior. Typically, you define a handler and then add callbacks with associated conditions. When these conditions are met, the respective callbacks are called.



#### Condition System

The condition system is designed to be flexible, enabling the formulation of conditions in such simple terms as and and or. It also provides tools for creating more complex conditions by chaining multiple conditions, allowing for numerical and equality comparisons.



## Integration

Designed to be easy to use with any Eluna project, you can use lua_simple_conditions to structure the conditional code of your project. For example, within the lua_player_aura project or lua_player_statistics or lua_spell_overlay, lua_simple_conditions is used to manage the conditions under which auras are applied to players.



## Usage

You can start by defining a handler, then adding callbacks and their associated conditions. Then, you can use the provided tools to formulate your code conditions.


_Note: More information on how to use this library can be found in the detailed documentation._
