ObjectiveBSON
=============
A small library that provides [BSON][bson] serialization methods for Mac or iOS applications.

Usage
-----
Copy BSONSerialization.h and BSONSerialization.m to your project.

Calling `[NSData BSONValue]` on an `NSData` object containing [BSON][bson] data returns an
`NSDictionary` with the deserialized [BSON][bson] data.

Calling `[NSDictionary BSONRepresentation]` returns an `NSData` with the serialized [BSON][bson]
data.

Alternatively, `[NSDictionary dictionaryFromBSONBytes:(char*)]` may be used if you
only have access to a `char[]` containing the [BSON][bson] data.

[bson]:http://bsonspec.org/
