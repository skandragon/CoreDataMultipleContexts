CoreDataMultipleContexts
========================

A sample project showing how to use multiple contexts in a Core Data application.

This example shows how to do these things:

*  Create a private writer context, which sits above all other contexts, and performs effective background saving.
*  Create a main queue context, which is used by the UI for display (but not edit) purposes.
*  Create a temporary context from the main queue context, and add an object.
*  Save this temporary context, and see the changes trickle up.

When doing this, all saves, fetches, etc. should be performed in a performBlock
or performBlockAndWait call to ensure the operations happen on the correct
queues.

See [http://www.cocoanetics.com/2012/07/multi-context-coredata/](Multi-Context CoreData)
for more information on this technique, but beware their typos.
