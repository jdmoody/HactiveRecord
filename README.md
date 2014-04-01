# HactiveRecord

## Description
HactiveRecord uses Ruby metaprogramming to implement many of the core functionalities of Rails' ActiveRecord.
The functionalities implemented include:
* SQLObject similar to ActiveRecord::Base Model
  * Mass assignment capable #insert, #update, and #save methods to save SQLObjects to the database 
  * ::all method returns all SQLObjects of a given table
  * ::find method returns a SQLObject of a specific id from its table
  * ::where method returns one or more SQLObjects that fit one or more given criteria

* Associations
  * belongs_to, has_many, and has_one_through associations implemented
  * Associations follow ActiveRecord naming conventions
  * Associatons can take in an options hash for unconventional names
