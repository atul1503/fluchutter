key is very important if you are handling multiple widgets of the same type, only the key can help flutter distinguish between each other.
if there is supposed to be only one widget of a type then no need to use keys. when key changes, new widgets of that type are created and old ones may be deleted if they are standing in place of the new widgets that are supposed to be made in the tree.

