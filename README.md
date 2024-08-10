key is very important if you are handling multiple widgets of the same type, only the key can help flutter distinguish between each other.
if there is supposed to be only one widget of a type then no need to use keys. when key changes, new widgets of that type are created and old ones may be deleted if they are standing in place of the new widgets that are supposed to be made in the tree.

if you want to align an image, just wrap a container around the image and constraint the container.

also always set size based on the screensize of mediaquery. if the parent has width of 0.7 of screensize, make sure that all of the children that are kept side by side should not have more than this much width or even if all children are kept in column, the max width of any of thechildren shouldnot be greater than this.